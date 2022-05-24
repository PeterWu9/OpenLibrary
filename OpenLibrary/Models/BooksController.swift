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
    
    
    /// Searches Open Library API with query dictionary.  Search results is passed
    /// back in completion handler.
    ///
    /// - Parameters:
    ///   - query: In the form of [String: String] dictionary
    ///   - completion: The argument of the closure is the optional array of Book
    ///     as a result of the search
    public func searchLibrary(with query: [String: String], searchSuccessful:@escaping(Bool) -> Void) {
        compareCurrentQuery(from: query)
        let baseURL = URL(string: "https://openlibrary.org/search.json?")!
        
        let defaultQuery = [
            SearchKeys.hasFullText: "true",
            SearchKeys.page: String(page)
        ]
        
        let newQuery = query.merging(defaultQuery) { (current, _) -> String in
            current
        }
        
        
        
        // Construct URL
        let url = baseURL.withQueries(matching: newQuery)!
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse, let weakSelf = self {
                switch httpResponse.statusCode {
                case 200..<300:
                    if let data = data {
                        let decoder = JSONDecoder()
                        do {
                            let results = try decoder.decode(BookSearchResults.self, from: data)
                            if weakSelf.page > 1 {
                                weakSelf.books.append(contentsOf: results.books)
                            } else {
                                weakSelf.books = results.books
                            }
                            searchSuccessful(true)
                        } catch let error {
                            print("Unable decode data to SearchResults")
                            print(error)
                            searchSuccessful(false)
                        }
                    }
                default:
                    print("Received HTTP response status code other than successful (2xx)")
                    searchSuccessful(false)
                }
            } else {
                print("No response from server")
                searchSuccessful(false)
            }
            
        }
        
        task.resume()
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
    public func fetchCoverImage(coverID: Int, imageSize: BookCoverImageSize, completion: @escaping(UIImage?)-> Void) {
        
        let baseURL = URL(string: "http://covers.openlibrary.org/b/id/")!
        
        let url = baseURL.appendingPathComponent("\(coverID)-\(imageSize.rawValue)").appendingPathExtension("jpg")
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                print("Unable to retrieve image data, or create image out of data")
                completion(nil)
            }
        }
        
        task.resume()
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
        searchLibrary(with: currentQuery) { [weak self](successful) in
            if successful {
                self?.delegate?.dataReloaded()
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

public enum BookCoverImageSize: String {
    case small = "S"
    case medium = "M"
    case large = "L"
}

protocol BooksControllerDelegate {
    func dataReloaded()
}
