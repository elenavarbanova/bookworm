//
//  InfoBook.swift
//  bookworm
//
//  Created by Elena Varbanova on 2.02.23.
//

import Foundation

struct InfoBook: Decodable {
    var key: String
    var title: String
    var editionCount: Int
    var editionKey: [String]
    var publishPlace: [String]?
    var firstPublishYear: Int
    var numberOfPagesMedian: Int
    var coverEditionKey: String?
    var coverI: Int?
    var language: [String]?
    var authorKey: [String]?
    var authorName: [String]?
    var subject: [String]
    var contributor: [String]?
    
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case editionCount = "edition_count"
        case editionKey = "edition_key"
        case publishPlace = "publish_place"
        case firstPublishYear = "first_publish_year"
        case numberOfPagesMedian = "number_of_pages_median"
        case coverEditionKey = "cover_edition_key"
        case coverI = "cover_i"
        case language
        case authorKey = "author_key"
        case authorName = "author_name"
        case subject
        case contributor
    }
}
