//
//  AuthorWorks.swift
//  bookworm
//
//  Created by Elena Varbanova on 5.02.23.
//

import Foundation

struct AuthorWorks: Decodable {
    var key: String
}

struct Works: Decodable {
    let size: Int
    let entries: [AuthorWorks]
}
