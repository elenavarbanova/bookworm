//
//  Books.swift
//  bookworm
//
//  Created by Elena Varbanova on 18.01.23.
//

import Foundation

struct Books: Decodable {
    let allBooks: [Book]
    
    enum CodingKeys: String, CodingKey {
        case allBooks = "works"
    }
}
