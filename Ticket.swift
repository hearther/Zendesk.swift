//
//  Ticket.swift
//  Zendesk
//
//  Created by Adam Holt on 05/01/2017.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation
import ObjectMapper

public enum TicketType: String {
    case Problem = "problem"
    case Incident = "incident"
    case Question = "question"
    case Task = "task"
}

public enum TicketPriority: String {
    case Urgent = "urgent"
    case High = "high"
    case Normal = "normal"
    case Low = "low"
}

public enum TicketStatus: String {
    case New = "new"
    case Open = "open"
    case Pending = "pending"
    case Hold = "hold"
    case Solved = "solved"
    case Closed = "closed"
}

public class Ticket: NSObject, Mappable {
    public var remoteId: Int?
    public var url: URL?
    public var externalId: String?
    public var type: TicketType?
    public var subject: String?
    public var desc: String?
    public var priority: TicketPriority?
    public var status: TicketStatus?
    public var recipient: String?
    public var requesterId: Int?
    public var submitterId: Int?
    public var assigneeId: Int?
    public var organizationId: Int?
    public var groupId: Int?
    public var collaboratorIds: [Int]?
    public var tags: [String]?
    public var customFields: [String : AnyObject] = [:]
    public var createdAt: Date?
    public var updatedAt: Date?
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        remoteId <- map["id"]
        url <- (map["url"], URLTransform())
        externalId <- map["external_id"]
        type <- (map["type"], EnumTransform<TicketType>())
        subject <- map["subject"]
        desc <- map["description"]
        priority <- (map["priority"], EnumTransform<TicketPriority>())
        status <- (map["status"], EnumTransform<TicketStatus>())
        recipient <- map["recipient"]
        requesterId <- map["requester_id"]
        submitterId <- map["submitter_id"]
        assigneeId <- map["assignee_id"]
        organizationId <- map["organization_id"]
        groupId <- map["group_id"]
        collaboratorIds <- map["collaborator_ids"]
        tags <- map["tags"]
        customFields <- map["custom_fields"]
        createdAt <- (map["created_at"], DateTransform())
        updatedAt <- (map["updated_at"], DateTransform())
    }
}
