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
    public func views() -> Signal<[TicketView], AnyError> {
        return self.getViews(endpoint: ViewsRequest.list(sort: nil, order: nil))
    }
    
    func getViews(endpoint: ViewsRequest) -> Signal<[TicketView], AnyError> {
        let (signal, observer) = Signal<[TicketView], AnyError>.pipe()
        
        self.api.request(endpoint).responseJSON { response in
            if response.result.isSuccess {
                if let json = response.result.value as? [String: AnyObject] {
                    if let views = json["views"] as? Array<[String: AnyObject]> {
                        let mapper = Mapper<TicketView>()
                        
                        if let mappedViews = mapper.mapArray(JSONArray: views) {
                            observer.send(value: mappedViews)
                        }
                    }
                }
            } else {
                if response.result.error != nil {
                    observer.send(error: AnyError(response.result.error!))
                }
            }
            
            observer.sendCompleted()
        }
        
        return signal
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
