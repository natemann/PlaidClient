//
//  PlaidURLTests.swift
//  PlaidClient
//
//  Created by Nathan Mann on 8/14/16.
//  Copyright © 2016 Nathan Mann. All rights reserved.
//

import XCTest
@testable import PlaidClient


class PlaidURLTests: XCTestCase {

    let plaidURL = PlaidURL(environment: .development)

    func testDevelopementBaseURL() {
        XCTAssertEqual(plaidURL.baseURL, "https://tartan.plaid.com")
    }


    func testProductionBaseURL() {
        XCTAssertEqual(PlaidURL(environment: .production).baseURL, "https://api.plaid.com")
    }

}
