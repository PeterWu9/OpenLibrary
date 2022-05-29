//
//  BookService.swift
//  OpenLibrary
//
//  Created by Peter Wu on 5/28/22.
//  Copyright © 2022 Peter Wu. All rights reserved.
//

import Foundation

class BookService {
    
    private let baseURL = URL(string: "https://openlibrary.org/search.json?")!
    
    private lazy var networkManager = NetworkingManager(baseURL: baseURL)
    
    func search(with query: [String: String]) async throws -> [Book] {
        let url = baseURL.withQueries(matching: query)!
        let searchResults: BookSearchResults = try await networkManager.get(url: url)
        return searchResults.books
    }
}
