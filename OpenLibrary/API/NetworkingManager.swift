//
//  NetworkManager.swift
//  OpenLibrary
//
//  Created by Peter Wu on 5/28/22.
//  Copyright © 2022 Peter Wu. All rights reserved.
//

import Foundation

class NetworkingManager {
    
    let decoder = JSONDecoder()
    
    func get<T>(url: URL) async throws -> T where T: Decodable {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
//        print("Start Request: \(Date())")
        let (data, response) = try await URLSession.shared.data(for: request)
//        print("Finished Request: \(Date())")
        
        // Throw error to forego data decoding if task has been cancelled
        guard !Task.isCancelled else {
            throw APIError.networkTaskCancelled
        }
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200..<300).contains(statusCode) else {
            throw APIError.invalidNetworkResponse(response: response)
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.dataDecodingFailure(data)
        }
    }
    
    func fetch(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Throw error to forego data decoding if task has been cancelled
        guard !Task.isCancelled else {
            throw APIError.networkTaskCancelled
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200..<300).contains(statusCode) else {
            throw APIError.invalidNetworkResponse(response: response)
        }
        return data
    }
    
}
