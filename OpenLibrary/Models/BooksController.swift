//
//  BooksController.swift
//  OpenLibrary
//
//  Created by Peter Wu on 7/10/19.
//  Copyright © 2019 Peter Wu. All rights reserved.
//

import Foundation
import UIKit

class BooksController {
    
    var books = [Book]()
    var currentQuery = [String: String]()
    
    
    private var page: Int = 1
    
    var delegate: BooksControllerDelegate?
    
    private struct SearchKeys {
        static let title = "title"
        static let author = "author"
        static let hasFullText = "has_fulltext"
        static let language = "language"
        static let bookKey = "bibkeys"
        static let format = "format"
        static let responseFormat = "jscmd"
        static let page = "page"
    }
    
    private var bookService = BookService()
    
    private lazy var defaultQuery = [
        SearchKeys.hasFullText: "true",
        SearchKeys.page: String(page)
    ]
    
    func searchLibrary(withQuery query: [String: String]) async throws {
        compareCurrentQuery(from: query)
        
        let newQuery = query.merging(defaultQuery) { (current, _) -> String in
            current
        }
        let newBooks = try await bookService.search(with: newQuery)
        if page > 1 {
            books.append(contentsOf: newBooks)
        } else {
            books = newBooks
        }
    }
    
    func fetchCoverImage(coverID: Int, imageSize: BookCoverImageSize) async throws -> UIImage {
        return try await bookService.fetchCoverImage(coverID: coverID, imageSize: imageSize)
    }
    
    func fetchDetails(fromID lendingID: String) async throws -> BookDetail {
        let fullID = "OLID:" + lendingID
        let query = [
            SearchKeys.bookKey: fullID,
            SearchKeys.format: "json",
            SearchKeys.responseFormat: "details"
        ]
        
        return try await bookService.fetchDetails(fromID: lendingID, withQuery: query)
    }
    
    func reachedEndOfData() {
        page += 1
        
        Task {
            do {
                try await searchLibrary(withQuery: currentQuery)
                delegate?.dataReloaded()
            }
        }
    }
    
    /// Compares query with currentQuery.  Resets pagination and updates currentQuery if different from new query
    ///
    /// - Parameter query: of type [String:String]
    /// - Returns: True if query equals currentQuery, false if not
    private func compareCurrentQuery(from newQuery: [String: String]){
        if currentQuery != newQuery {
            // reset page and currentQuery
            page = 1
            currentQuery = newQuery
        }
    }
    
}

enum BookCoverImageSize: String {
    case small = "S"
    case medium = "M"
    case large = "L"
}

protocol BooksControllerDelegate {
    func dataReloaded()
}
