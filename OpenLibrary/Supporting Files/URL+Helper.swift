//
//  URL+Helper.swift
//  OpenLibrary
//
//  Created by Peter Wu on 7/10/19.
//  Copyright © 2019 Peter Wu. All rights reserved.
//

import Foundation

extension URL {
    func withQueries(matching query: [String: String]) -> URL? {
        // Make URL into URLComponents so that each component is separated
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = query.map { (key, value) -> URLQueryItem in
            return URLQueryItem(name: key, value: value)
        }
        return components?.url
    }
}
