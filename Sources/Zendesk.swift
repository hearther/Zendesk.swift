/**
 *  Zendesk
 *
 *  Copyright (c) 2017 Adam Holt. Licensed under the MIT license, as follows:
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

import Foundation
import ReactiveSwift
import Alamofire

public class Zendesk {
    let api: ZendeskAPI
    
    public required init(api: ZendeskAPI) {
        self.api = api
    }
}

public class ZendeskAPI {
    public let baseURL: URL
    public let username: String
    public let token: String
    
    public required init(url: URL, username: String, token:String) {
        self.baseURL = url
        self.username = username
        self.token = token
    }
    
    public func request(_ resource: ZendeskURLRequestConvertable) -> DataRequest {
        return Alamofire.request(ZendeskRequest(client: self, request: resource)).authenticate(user: "\(self.username)/token", password: self.token)
    }
}

public protocol ZendeskURLRequestConvertable {
    func asURLRequest(client: ZendeskAPI) throws -> URLRequest
}

extension ZendeskURLRequestConvertable {
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

public enum RequestOrder: String {
    case Asc = "asc"
    case Desc = "desc"
}

public class ZendeskRequest: URLRequestConvertible {
    let client: ZendeskAPI
    let request: ZendeskURLRequestConvertable
    
    public required init(client: ZendeskAPI, request: ZendeskURLRequestConvertable) {
        self.client = client
        self.request = request
    }
    
    public func asURLRequest() throws -> URLRequest {
        return try self.request.asURLRequest(client: client)
    }
}
