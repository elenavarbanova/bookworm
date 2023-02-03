//
//  ResultBooks.swift
//  bookworm
//
//  Created by Elena Varbanova on 29.01.23.
//

import Foundation

struct ResultBooks: Decodable {
    let resultBooks: [Book]
    
    enum CodingKeys: String, CodingKey {
        case resultBooks = "docs"
    }
}
