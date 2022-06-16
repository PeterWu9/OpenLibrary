//
//  OpenLibraryTests.swift
//  OpenLibraryTests
//
//  Created by Peter Wu on 6/15/22.
//  Copyright © 2022 Peter Wu. All rights reserved.
//

import XCTest
@testable import OpenLibrary

class OpenLibraryTests: XCTestCase {
    
    var networkManager: NetworkingManager!
    var testUrl: URL!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        networkManager = NetworkingManager()
        testUrl = URL(string: "https://www.example.com")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        networkManager = nil
    }

    func testCreateRequestSuccess() {
        let request = networkManager.create(.get, for: testUrl)
        XCTAssert(request.httpMethod == "GET")
    }
    
    func testResponseSuccess() async throws {
        let (_, response) = try await networkManager.response(.get, for: testUrl)
        let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
        XCTAssertEqual(httpResponse.statusCode, 200)
    }
    
    func testResponseAndStatusCodeSuccess() async throws {
        let (_, response) = try await networkManager.response(.get, for: testUrl)
        XCTAssertNoThrow(try networkManager.checkResponseAndStatusCode(response))
    }
    
    func testResponseAndStatusCodeFailure() async throws {
        let invalidUrl = URL(string: "https://openlibrary.org/invalid")
        let (_, response) = try await networkManager.response(.get, for: invalidUrl!)
        XCTAssertThrowsError(try networkManager.checkResponseAndStatusCode(response)) { error in
            XCTAssertEqual((error as! APIError), APIError.invalidNetworkResponse(response: response))
        }
    }
    
    
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
