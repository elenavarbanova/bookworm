//
//  Comment.swift
//  bookworm
//
//  Created by Elena Varbanova on 20.02.23.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct Review: Decodable {
    var userId: String
    var comment: String?
    var rating: Int?
    var date: Date
    init(aDoc: DocumentSnapshot) {
        self.userId = aDoc.get("user_id") as? String ?? "Unknown"
        self.comment = aDoc.get("comment") as? String
        self.rating = aDoc.get("rating") as? Int
        let ts = aDoc.get("date") as? Timestamp
        self.date = ts!.dateValue()
    }
}
