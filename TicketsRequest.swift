//
//  TicketsRequest.swift
//  Zendesk
//
//  Created by Adam Holt on 05/01/2017.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift
import Result
import ObjectMapper

extension Zendesk {
    public func tickets() -> Signal<[Ticket], AnyError> {
        
        let (signal, observer) = Signal<[Ticket], AnyError>.pipe()
        
        self.api.request(TicketRequest.list(sort: nil, order: nil)).responseJSON { response in
            if response.result.isSuccess {
                if let json = response.result.value as? [String: AnyObject] {
                    if let tickets = json["tickets"] as? Array<[String: AnyObject]> {
                        let mapper = Mapper<Ticket>()
                        
                        if let mappedTickets = mapper.mapArray(JSONArray: tickets) {
                            observer.send(value: mappedTickets)
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

public enum TicketRequest: ZendeskURLRequestConvertable {
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
            return "/tickets"
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
    
    func sortParams(_ sort: String?, _ order: RequestOrder?) -> Parameters {
        var params = Parameters()
        
        if (sort != nil) {
            params["sort_by"] = sort
        }
        
        if (order != nil) {
            params["sort_order"] = order
        }
        
        return params
    }
}
