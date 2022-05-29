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
    
    /// Retrieve book cover image from openlibrary.org using internal coverID.  CoverID and
    /// imageSize are string parameters appended to Open Library's base URL to form the
    /// URL that points to the book cover image.
    ///
    /// - Parameters:
    ///   - coverID: an internal ID (Int) used by Open Library to identify cover images
    ///   - imageSize: of type BookCoverImageSize enum with cases for small, medium, and large
    ///                cover size
    ///   - completion: The argument of the closure is the optional image fetched from
    ///                 book cover URL
    public func fetchCoverImage(coverID: Int, imageSize: BookCoverImageSize) async throws -> UIImage {
        return try await bookService.fetchCoverImage(coverID: coverID, imageSize: imageSize)
    }
    
    public func fetchDetails(fromID lendingID: String, completion:@escaping(BookDetail?) -> Void) {
        let baseURL = URL(string: "https://openlibrary.org/api/books?")!
        let fullID = "OLID:" + lendingID
        let query = [
            SearchKeys.bookKey: fullID,
            SearchKeys.format: "json",
            SearchKeys.responseFormat: "details"
        ]
        
        let url = baseURL.withQueries(matching: query)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200..<300:
                    if let data = data,
                        let rawJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                        let bookDetailResultJSON = rawJSON[fullID] as? [String: Any],
                        let bookDetailJSON = bookDetailResultJSON["details"] as? [String: Any]{
                        let bookDetail = BookDetail(from: bookDetailJSON)
                        completion(bookDetail)
                    } else {
                        print("Unable to instantiate BookDetail from data")
                    }
                default:
                    print("Received HTTP response status code other than successful (2xx)")
                    completion(nil)
                }
            } else {
                print("No response from server")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    public func reachedEndOfData() {
        
        page += 1
        Task {
            do {
                try await searchLibrary(withQuery: currentQuery)
                delegate?.dataReloaded()
            }
            if let _ = try? await searchLibrary(withQuery: currentQuery) {
                delegate?.dataReloaded()
            }
        }
//        searchLibrary(with: currentQuery) { [weak self](successful) in
//            if successful {
//                self?.delegate?.dataReloaded()
//            }
//        }
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

public enum BookCoverImageSize: String {
    case small = "S"
    case medium = "M"
    case large = "L"
}

protocol BooksControllerDelegate {
    func dataReloaded()
}
