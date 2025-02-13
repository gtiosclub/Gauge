//
//  GaugeTests.swift
//  GaugeTests
//
//  Created by Austin Huguenard on 2/2/25.
//

import XCTest
@testable import Gauge

final class GaugeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGetOutgoingRequests() async {
        let testUser = User(userId: "dummy", username: "dummy", email: "dummy")
        let viewModel = FriendsViewModel(user: testUser)
        
        let userId = testUser.userId
        let friendsOutgoing = await viewModel.getOutgoingRequests(userId: userId)
        print(friendsOutgoing)
    }

}
