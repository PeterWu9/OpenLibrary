//
//  Books.swift
//  OpenLibrary
//
//  Created by Peter Wu on 7/10/19.
//  Copyright © 2019 Peter Wu. All rights reserved.
//

import Foundation



struct BookDetail {
    
    var description: String?
    var numberOfPages: Int?
    var subjects: String?
    
    init(from json: [String: Any]) {
        self.description = json["description"] as? String
        self.numberOfPages = json["number_of_pages"] as? Int
        self.subjects = (json["subjects"] as? [String])?.joined(separator: ",\n")
    }
}

extension Array where Element == Author {
    var concatedNames: String? {
        get {
            switch count {
            case 0:
                return nil
            case 1:
                return first!.name
            default:
                let arrayOfNames = self.map() { $0.name }
                return arrayOfNames.joined(separator: ",/n")
            }
        }
    }
}

struct Author: Codable {
    var name: String
}

struct Book: Codable {
    
    var author: [Author]?
    var title: String
    var coverID: Int?
    var publishYear: Int?
    var editionsCount: Int
    var lendingEditionID: String?
    var key: String
    
    enum CodingKeys: String, CodingKey {
        case author = "author_name"
        case title
        case coverID = "cover_i"
        case publishYear = "first_publish_year"
        case editionsCount = "edition_count"
        case lendingEditionID = "lending_edition_s"
        case key
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        if let authorNames = try? valueContainer.decode([String].self, forKey: CodingKeys.author) {
            self.author = authorNames.map() { Author(name: $0)}
        }
        self.title = try valueContainer.decode(String.self, forKey: CodingKeys.title)
        self.coverID = try? valueContainer.decode(Int.self, forKey: CodingKeys.coverID)
        self.publishYear = try? valueContainer.decode(Int.self, forKey: CodingKeys.publishYear)
        self.editionsCount = try valueContainer.decode(Int.self, forKey: CodingKeys.editionsCount)
        self.lendingEditionID = try? valueContainer.decode(String.self, forKey: CodingKeys.lendingEditionID)
        let keyString = try valueContainer.decode(String.self, forKey: CodingKeys.key)
        self.key = keyString.components(separatedBy: "/")[2]
    }
}

struct BookSearchResults: Codable {
    var start: Int
    var numberOfResults: Int
    var books: [Book]
    
    
    enum CodingKeys: String, CodingKey {
        case start
        case numberOfResults = "num_found"
        case books = "docs"
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.start = try valueContainer.decode(Int.self, forKey: CodingKeys.start)
        self.numberOfResults = try valueContainer.decode(Int.self, forKey: CodingKeys.numberOfResults)
        self.books = try valueContainer.decode([Book].self, forKey: CodingKeys.books)
        
    }
}
