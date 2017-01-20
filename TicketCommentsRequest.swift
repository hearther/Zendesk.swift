//
//  TicketCommentsRequest.swift
//  Zendesk
//
//  Created by Adam Holt on 15/01/2017.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift
import Result
import ObjectMapper

extension Zendesk {
    public func ticketComments(ticket: Ticket) -> SignalProducer<TicketComment, AnyError> {
        return self.collectionRequest(endpoint: TicketCommentRequest.list(ticket: ticket, sort: nil, order: nil), rootElement: "comments")
    }
}

public enum TicketCommentRequest: ZendeskURLRequestConvertable {
    case list(ticket: Ticket, sort:String?, order: RequestOrder?)
    
    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .list(let ticket, _, _):
            return "/tickets/\(ticket.remoteId)/comments"
        }
    }
    
    public func asURLRequest(client: ZendeskAPI) throws -> URLRequest {
        let url = client.baseURL
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .list(_, let sort, let order):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: sortParams(sort, order))
        }
        
        return urlRequest
    }
}
