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
        
        // ✅ Tested in create(_:for) and response(_, for)
        let (data, response) = try await response(.get, for: url)
        
        // Throw error to forego data decoding if task has been cancelled
        guard !Task.isCancelled else {
            throw APIError.networkTaskCancelled
        }
        
        // ✅ Tested
        try checkResponseAndStatusCode(response)
        
        // Decode data by meta type
        // Throw APIError.dataDecodingFailure if decode failed.
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.dataDecodingFailure(data)
        }
    }
    
    enum RequestMethod {
        case get
        
        var description: String {
            switch self {
            case .get:
                return "GET"
            }
        }
    }
    
    func fetch(url: URL) async throws -> Data {
        
        // ✅ Tested
        let (data, response) = try await response(.get, for: url)
        
        // Throw error to forego data decoding if task has been cancelled
        guard !Task.isCancelled else {
            throw APIError.networkTaskCancelled
        }
        
        // ✅ Tested
        try checkResponseAndStatusCode(response)
        
        return data
    }
    
    func checkResponseAndStatusCode(_ response: URLResponse) throws {
        guard
            let statusCode = (response as? HTTPURLResponse)?.statusCode,
            (200..<300).contains(statusCode) else {
            throw APIError.invalidNetworkResponse(response: response)
        }
    }
    
    func create(_ method: RequestMethod, for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.description
        return request
    }
    
    func response(_ method: RequestMethod, for url: URL) async throws -> (Data, URLResponse) {
        let request = create(method, for: url)
        return try await URLSession.shared.data(for: request)
    }
    
}
