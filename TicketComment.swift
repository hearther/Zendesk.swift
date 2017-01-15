//
//  TicketComment.swift
//  Zendesk
//
//  Created by Adam Holt on 15/01/2017.
//  Copyright © 2017 GitHub. All rights reserved.
//

import Foundation
import ObjectMapper

public enum TicketCommentType: String {
    case Comment = "comment"
    case VoiceComment = "voice_comment"
}

public class TicketComment: NSObject, Mappable {
    public var remoteId: Int?
    public var type: TicketCommentType?
    public var body: String?
    public var htmlBody: String?
    public var plainBody: String?
    public var isPublic: Bool?
    public var authorId: Int?
    public var attachments: [AnyObject] = []
    public var via: [String:AnyObject] = [:]
    public var metadata: [String:AnyObject] = [:]
    public var createdAt: Date?
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        remoteId <- map["id"]
        type <- (map["type"], EnumTransform<TicketCommentType>())
        body <- map["body"]
        htmlBody <- map["html_body"]
        plainBody <- map["plain_body"]
        isPublic <- map["public"]
        authorId <- map["author_id"]
        attachments <- map["attachments"]
        via <- map["via"]
        metadata <- map["metadata"]
        createdAt <- (map["created_at"], DateTransform())
    }
}
