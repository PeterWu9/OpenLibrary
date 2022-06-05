//
//  OpenLibraryError.swift
//  OpenLibrary
//
//  Created by Peter Wu on 5/28/22.
//  Copyright © 2022 Peter Wu. All rights reserved.
//

import Foundation

enum APIError: Error, LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidNetworkResponse(let response):
            return "Invalid network response \(response)"
        case .dataDecodingFailure(let data):
            return "Unable to decode data \(data)"
        case .imageDecodingFailure(let data):
            return "Unable to create image from data: \(data)"
        case .networkTaskCancelled:
            return "Network task cancelled"
        }
    }
    
    case invalidNetworkResponse(response: URLResponse)
    case dataDecodingFailure(Data)
    case imageDecodingFailure(Data)
    case networkTaskCancelled
}


