//
//  Comment.swift
//  bookworm
//
//  Created by Elena Varbanova on 20.02.23.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct Comment: Decodable {
    var userName: String
    var comment: String?
    var rating: Int?
    var date: Date
    init(aDoc: DocumentSnapshot) {
        self.userName = aDoc.get("user_name") as? String ?? "Unknown"
        self.comment = aDoc.get("comment") as? String
        self.rating = aDoc.get("rating") as? Int
        let ts = aDoc.get("date") as? Timestamp
        self.date = ts!.dateValue()
    }
}
