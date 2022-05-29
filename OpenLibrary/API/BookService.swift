//
//  BookService.swift
//  OpenLibrary
//
//  Created by Peter Wu on 5/28/22.
//  Copyright © 2022 Peter Wu. All rights reserved.
//

import Foundation
import UIKit

class BookService {
    
    private let searchBaseURL = URL(string: "https://openlibrary.org/search.json?")!
    private let coverImageBaseURL = URL(string: "http://covers.openlibrary.org/b/id/")!
    
    private var networkManager = NetworkingManager()
    
    func search(with query: [String: String]) async throws -> [Book] {
        let url = searchBaseURL.withQueries(matching: query)!
        let searchResults: BookSearchResults = try await networkManager.get(url: url)
        return searchResults.books
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
    func fetchCoverImage(coverID: Int, imageSize: BookCoverImageSize) async throws -> UIImage {
                
        let url = coverImageBaseURL.appendingPathComponent("\(coverID)-\(imageSize.rawValue)").appendingPathExtension("jpg")
        let imageData = try await networkManager.fetch(url: url)
        if let image = UIImage(data: imageData) {
            return image
        } else {
            throw APIError.imageDecodingFailure(imageData)
        }
    }
}
