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


    func testInstitutionsURL() {
        XCTAssertEqual(plaidURL.institutions().url?.absoluteString, "https://tartan.plaid.com/institutions")
    }


    func testInstitutionsMethod() {
        XCTAssertEqual(plaidURL.institutions().httpMethod, "GET")
    }


    func testInstitutionWithIDURL() {
        XCTAssertEqual(plaidURL.institutions(id: "ID").url?.absoluteString, "https://tartan.plaid.com/institutions/ID")
    }


    func testIntuitURL() {
        XCTAssertEqual(plaidURL.intuit(clientID: "clientID", secret: "secret", count: 1, skip: 1).url?.absoluteString, "https://tartan.plaid.com/longtail?client_id=clientID&secret=secret&count=1&offset=1")
    }


    func testIntuitMethod() {
        XCTAssertEqual(plaidURL.intuit(clientID: "clientID", secret: "secret", count: 1, skip: 1).httpMethod, "POST")
    }

}
