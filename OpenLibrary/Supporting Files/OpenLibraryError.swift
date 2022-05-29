//
//  OpenLibraryError.swift
//  OpenLibrary
//
//  Created by Peter Wu on 5/28/22.
//  Copyright © 2022 Peter Wu. All rights reserved.
//

import Foundation

enum OpenLibraryError<T>: Error, LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidNetworkResponse(let response):
            return "Invalid network response \(response)"
        case .dataDecodingFailure(let type):
            return "Unable to decode data for type \(type)"
        }
    }
    case invalidNetworkResponse(response: URLResponse)
    case dataDecodingFailure(T.Type)
}
