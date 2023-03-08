//
//  BooksViewModel.swift
//  OpenLibrary
//
//  Created by Peter Wu on 7/10/19.
//  Copyright © 2019 Peter Wu. All rights reserved.
//

import Foundation
import UIKit

class BooksViewModel {
    
    @Published private(set) var books = [Book]()
    @Published private(set) var isSearching: Bool = false
    
    var currentQuery = [String: String]()
    
    private struct SearchKeys {
        static let title = "title"
        static let author = "author"
        static let hasFullText = "has_fulltext"
        static let language = "language"
        static let bookKey = "bibkeys"
        static let format = "format"
        static let responseFormat = "jscmd"
    }
    
    private var bookService = BookService()
    
    private lazy var defaultQuery = [
        SearchKeys.hasFullText: "true"
    ]
    
    func update(_ book: Book) {
        if let index = books.firstIndex(of: book) {
            self.books[index] = book
        }
    }
        
    func clearBooks() {
        books = []
    }
    
    func searchLibrary(withQuery query: [String: String]) async throws {
        isSearching = true
        let newBooks = try await bookService.search(with: query)
        isSearching = false
        books = newBooks.sorted(using: KeyPathComparator(\.title))
    }
    
    func fetchCoverImage(coverID: Int, imageSize: BookCoverImageSize) async throws -> UIImage {
        return try await bookService.fetchBookCover(coverID: coverID, imageSize: imageSize)
    }
    
    func fetchDetails(fromID lendingID: String) async throws -> BookDetail {
        let fullID = "OLID:" + lendingID
        let query = [
            SearchKeys.bookKey: fullID,
            SearchKeys.format: "json",
            SearchKeys.responseFormat: "details"
        ]
        
        return try await bookService.fetchBookDetails(fromID: lendingID, withQuery: query)
    }
}

enum BookCoverImageSize: String {
    case small = "S"
    case medium = "M"
    case large = "L"
}
