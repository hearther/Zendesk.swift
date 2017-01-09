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
    public func tickets(_ view: TicketView) -> Signal<[Ticket], AnyError> {
        return self.getTickets(endpoint: TicketRequest.viewList(view: view, sort: nil, order: nil))
    }
    
    public func tickets() -> Signal<[Ticket], AnyError> {
        return self.getTickets(endpoint: TicketRequest.list(sort: nil, order: nil))
    }
    
    func getTickets(endpoint: TicketRequest) -> Signal<[Ticket], AnyError> {
        let (signal, observer) = Signal<[Ticket], AnyError>.pipe()
        
        self.api.request(endpoint).responseJSON { response in
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
    case viewList(view: TicketView, sort: String?, order: RequestOrder?)
    
    var method: HTTPMethod {
        switch self {
        case .list:
            return .get
        default:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .list:
            return "/tickets"
        case .viewList(let view, _, _):
            return "/views/\(view.remoteId!)/tickets"
        }
    }
    
    public func asURLRequest(client: ZendeskAPI) throws -> URLRequest {
        let url = client.baseURL
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .list(let sort, let order):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: sortParams(sort, order))
        case .viewList(_, let sort, let order):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: sortParams(sort, order))
        }
        
        return urlRequest
    }
}
