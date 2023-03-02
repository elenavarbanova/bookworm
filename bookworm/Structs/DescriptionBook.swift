//
//  DescriptionBook.swift
//  bookworm
//
//  Created by Elena Varbanova on 2.02.23.
//

import Foundation

struct DescriptionBook: Decodable {
    var description: DescriptionValue
}

struct DescriptionValue: Decodable {
    var type: String
    var value: String
}
