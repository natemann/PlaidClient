//
//  PlaidClientTests.swift
//  PlaidClientTests
//
//  Created by Nathan Mann on 1/23/16.
//  Copyright © 2016 Nathan Mann. All rights reserved.
//

import XCTest
@testable import PlaidClient

class PlaidClientTests: XCTestCase {

    let plaidClient = PlaidClient(clientIDToken: "test_id", secretToken: "test_secret", environment: .development)

    
    func test_plaidInstitutions() {

        let testExpectation = expectation(withDescription: "fetching Plaid Institutions")

        plaidClient.plaidInstitutions { _, institutions in

            //Run tests for each institution
            for plaidInstitution in institutions {

                //test source is correctly set to Plaid
                XCTAssertEqual(plaidInstitution.source, PlaidInstitution.Source.plaid, "Source is not correct for institution: \(plaidInstitution)")

                //Insure that if has_mfa is true, mfa is not nil/ empty
                if plaidInstitution.has_mfa == true {
                    XCTAssertTrue(plaidInstitution.mfa?.count > 0, "MFA array should have objects. Institution: \(plaidInstitution)")

                    //Test all known MFA types
                    let knownMFATypes = ["code", "list", "questions", "selections", "questions(3)"]
                    for mfaType in plaidInstitution.mfa! {
                        XCTAssertTrue(knownMFATypes.contains(mfaType), "\(mfaType) is not a known MFA type")
                    }
                }

                //Test all known products
                let knownProducts = ["auth", "balance", "connect", "income", "info", "risk"]
                for product in plaidInstitution.products {
                    XCTAssertTrue(knownProducts.contains(product), "\(product) is not a known product")
                }
            }

            testExpectation.fulfill()
        }

        waitForExpectations(withTimeout: 100000) { error in
            if let error = error {
                print("Fetching Plaid institutions took too long. \(error)")
            }
        }
    }
    
}
