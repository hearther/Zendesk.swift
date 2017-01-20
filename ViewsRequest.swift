//
//  ViewsRequest.swift
//  Zendesk
//
//  Created by Adam Holt on 09/01/2017.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation

import Alamofire
import ReactiveSwift
import Result
import ObjectMapper

extension Zendesk {
    public func views() -> SignalProducer<TicketView, AnyError> {
        return self.collectionRequest(endpoint: ViewsRequest.list(sort: nil, order: nil), rootElement: "views")
    }
    
}

public enum ViewsRequest: ZendeskURLRequestConvertable {
    case list(sort:String?, order: RequestOrder?)
    
    var method: HTTPMethod {
        switch self {
        case .list:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .list:
            return "/views"
        }
    }
    
    public func asURLRequest(client: ZendeskAPI) throws -> URLRequest {
        let url = client.baseURL
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .list(let sort, let order):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: sortParams(sort, order))
        }
        
        return urlRequest
    }
}
