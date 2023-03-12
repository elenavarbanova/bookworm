//
//  Nickname.swift
//  bookworm
//
//  Created by Elena Varbanova on 12.03.23.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct Nickname: Decodable {
    var userNickname: String
    init(aDoc: DocumentSnapshot) {
        self.userNickname = aDoc.get("nickname") as? String ?? "Unknown"
    }
}
