//
//  Book.swift
//  bookworm
//
//  Created by Elena Varbanova on 18.01.23.
//

import Foundation

protocol Displayable {
    var key: String { get }
    var authorKeys: [String]? { get }
    var authorNames: [String]? { get }
    var image: String? { get }
    var largeImage: String? { get }
    var titleLabelText: String { get }
    var subtitleLabelText: String { get }
}

struct Book: Decodable {
    let key: String
    let title: String
    let coverImage: Int?
    let authorKeys: [String]?
    let authorNames: [String]?
    
    enum CodingKeys: String, CodingKey {
        case key
        case title
        case coverImage = "cover_i"
        case authorKeys = "author_key"
        case authorNames = "author_name"
    }
}

extension Book: Displayable {
    var image: String? {
        guard let imageID = coverImage else {
            return nil
        }
        return "https://covers.openlibrary.org/b/id/\(imageID)-M.jpg"
    }
    
    var largeImage: String? {
        guard let imageID = coverImage else {
            return nil
        }
        return "https://covers.openlibrary.org/b/id/\(imageID)-L.jpg"
    }
    
    var titleLabelText: String {
        title
    }
    
    var subtitleLabelText: String {
        authorNames?.formatted() ?? "Unknown author"
    }
}
