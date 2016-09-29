//
//  IntuitInstitutionTests.swift
//  PlaidClient
//
//  Created by Nathan Mann on 6/28/16.
//  Copyright © 2016 Nathan Mann. All rights reserved.
//

import XCTest
@testable import PlaidClient

class IntuitInstitutionTests: XCTestCase {

    let plaidClient = PlaidClient(clientIDToken: "test_id", secretToken: "test_secret", environment: .development)

    func test_source_is_correct() {

        let testExpectation = expectation(description: "fetching Plaid Institutions")

        plaidClient.intuitInstitutions(count: 50000, skip: 0) { _, institutions, error in

            print("Institution Count: \(institutions?.count)")
            //Run test for each institution
            for institution in institutions! {

                //test source is correctly set to Plaid
                XCTAssertEqual(institution.source, PlaidInstitution.Source.intuit, "Source is not correct for institution: \(institution)")
            }

            testExpectation.fulfill()
        }
        waitForExpectations(timeout: 10000000) { error in
            if let error = error {
                print("Fetching Intuit institutions took too long. \(error)")
            }
        }
    }

}
