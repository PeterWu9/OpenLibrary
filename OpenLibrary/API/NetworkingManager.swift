//
//  NetworkManager.swift
//  OpenLibrary
//
//  Created by Peter Wu on 5/28/22.
//  Copyright © 2022 Peter Wu. All rights reserved.
//

import Foundation

class NetworkingManager {
    
    let baseURL: URL
    
    let decoder = JSONDecoder()
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    func get<T>(url: URL) async throws -> T where T: Decodable {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200..<300).contains(statusCode) else {
            throw OpenLibraryError<T>.invalidNetworkResponse(response: response)
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw OpenLibraryError<T>.dataDecodingFailure(T.self)
        }
    }
    
}
