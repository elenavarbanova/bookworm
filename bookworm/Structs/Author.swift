//
//  Author.swift
//  bookworm
//
//  Created by Elena Varbanova on 5.02.23.
//

import Foundation

struct Author: Decodable {
    var birthDate: String?
    var key: String
    var bio: String?
    var alternateNames: [String]?
    var name: String
    var photos: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case birthDate = "birth_date"
        case key
        case bio
        case alternateNames = "alternate_names"
        case name
        case photos
    }
}
