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
    public func ticket(_ id: Int) -> Signal<Ticket, AnyError> {
        return self.resourceRequest(endpoint: TicketRequest.show(id: id), rootElement: "ticket")
    }
    
    public func tickets(_ view: TicketView) -> Signal<[Ticket], AnyError> {
        return self.collectionRequest(endpoint: TicketRequest.viewList(view: view, sort: nil, order: nil), rootElement: "tickets")
    }
    
    public func tickets() -> Signal<[Ticket], AnyError> {
        return self.collectionRequest(endpoint: TicketRequest.list(sort: nil, order: nil), rootElement: "tickets")
    }
}

public enum TicketRequest: ZendeskURLRequestConvertable {
    case show(id: Int)
    case list(sort:String?, order: RequestOrder?)
    case viewList(view: TicketView, sort: String?, order: RequestOrder?)
    
    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .show(let id):
            return "/tickets/\(id)"
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
        default:
            break
        }
        
        return urlRequest
    }
}
