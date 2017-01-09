//
//  View.swift
//  Zendesk
//
//  Created by Adam Holt on 09/01/2017.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation
import ObjectMapper

public class TicketView: NSObject, Mappable {
    public var remoteId: Int?
    public var title: String?
    public var active: Bool?
    public var slaId: Int?
    public var position: Int?
    public var restriction: Dictionary<String, AnyObject> = [:]
    public var execution: Dictionary<String, AnyObject> = [:]
    public var conditions: Dictionary<String, AnyObject> = [:]
    public var createdAt: Date?
    public var updatedAt: Date?
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        remoteId <- map["id"]
        title <- map["title"]
        active <- map["active"]
        slaId <- map["sla_id"]
        position <- map["position"]
        restriction <- map["restriction"]
        execution <- map["execution"]
        conditions <- map["conditions"]
        createdAt <- (map["created_at"], DateTransform())
        updatedAt <- (map["updated_at"], DateTransform())
    }
}
