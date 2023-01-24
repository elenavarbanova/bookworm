//
//  Book.swift
//  bookworm
//
//  Created by Elena Varbanova on 18.01.23.
//

import Foundation

protocol Displayable {
    var image: String? { get }
    var titleLabelText: String { get }
    var subtitleLabelText: String { get }
}

struct Book: Decodable {
    let key: String
    let title: String
    let coverImage: Int?
    let authorKey: [String]?
    let authorName: [String]?
    
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case coverImage = "cover_i"
        case authorKey = "author_key"
        case authorName = "author_name"
    }
}

extension Book: Displayable {
    var image: String? {
        guard let imageID = coverImage else {
            return nil
        }
        return "https://covers.openlibrary.org/b/id/\(imageID)-M.jpg"
    }
    
    var titleLabelText: String {
        title
    }
    
    var subtitleLabelText: String {
        authorName?.formatted() ?? "Unknown author"
    }
}
