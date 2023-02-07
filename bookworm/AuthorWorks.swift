//
//  AuthorWorks.swift
//  bookworm
//
//  Created by Elena Varbanova on 5.02.23.
//

import Foundation

struct AuthorWorks: Decodable {
    var title: String
    var covers: [Int]?
}

struct Works: Decodable {
    let size: Int
    let entries: [AuthorWorks]
}
