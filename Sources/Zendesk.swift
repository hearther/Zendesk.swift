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
import Result
import Alamofire
import ObjectMapper

public class Zendesk {
    let api: ZendeskAPI
    
    public required init(api: ZendeskAPI) {
        self.api = api
    }
    
    func collectionRequest<T: Mappable>(endpoint: ZendeskURLRequestConvertable, rootElement:String) -> SignalProducer<[T], AnyError> {
        return SignalProducer { observer, disposable in
            let request = self.api.request(endpoint).responseJSON { response in
                if response.result.isSuccess {
                    if let json = response.result.value as? [String: AnyObject] {
                        if let resources = json[rootElement] as? Array<[String: AnyObject]> {
                            let mapper = Mapper<T>()
                            let mappedResources = mapper.mapArray(JSONArray: resources)
                            observer.send(value: mappedResources)
                        }
                    }
                } else {
                    if response.result.error != nil {
                        observer.send(error: AnyError(response.result.error!))
                    }
                }
                
                observer.sendCompleted()
            }
            
            disposable.add {
                request.cancel()
            }
        }
    }
    
    func resourceRequest<T: Mappable>(endpoint: ZendeskURLRequestConvertable, rootElement: String) -> SignalProducer<T, AnyError> {
        return SignalProducer { (observer, disposable) in
            let request = self.api.request(endpoint).responseJSON { response in
                if response.result.isSuccess {
                    if let json = response.result.value as? [String: AnyObject] {
                        if let resource = json[rootElement] as? [String: AnyObject] {
                            let mapper = Mapper<T>()
                            if let mappedResource = mapper.map(JSONObject: resource) {
                                observer.send(value: mappedResource)
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
            
            disposable.add {
                request.cancel()
            }
        }
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
        debugPrint(try! resource.asURLRequest(client: self))
        
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
