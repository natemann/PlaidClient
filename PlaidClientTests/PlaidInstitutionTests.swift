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

    
//    func test_plaidInstitutions() {
//
//        let testExpectation = expectation(withDescription: "fetching Plaid Institutions")
//
//        plaidClient.plaidInstitutions { (response, institutions, error) in
//
//            guard let institutions = institutions else { return XCTFail("Failed to get Plaid institutions") }
//            //Run tests for each institution
//            for plaidInstitution in institutions {
//                print(plaidInstitution.id)
//                //test source is correctly set to Plaid
//                XCTAssertEqual(plaidInstitution.source, PlaidInstitution.Source.plaid, "Source is not correct for institution: \(plaidInstitution)")
//
//                //Insure that if has_mfa is true, mfa is not nil/ empty
//                if plaidInstitution.has_mfa == true {
//                    XCTAssertTrue(plaidInstitution.mfa?.count > 0, "MFA array should have objects. Institution: \(plaidInstitution)")
//
//                    //Test all known MFA types
//                    let knownMFATypes = ["code", "list", "questions", "selections", "questions(3)"]
//                    for mfaType in plaidInstitution.mfa! {
//                        XCTAssertTrue(knownMFATypes.contains(mfaType), "\(mfaType) is not a known MFA type")
//                    }
//                }
//
//                //Test all known products
//                let knownProducts = ["auth", "balance", "connect", "income", "info", "risk"]
//                for product in plaidInstitution.products {
//                    XCTAssertTrue(knownProducts.contains(product), "\(product) is not a known product")
//                }
//            }
//            
//            testExpectation.fulfill()
//
//        }
//
//        waitForExpectations(withTimeout: 100000) { error in
//            if let error = error {
//                print("Fetching Plaid institutions took too long. \(error)")
//            }
//        }
//    }
//
//
    func test_intuitInstitutions() {

        let testExpectation = expectation(withDescription: "fetching Intuit Institutions")

        plaidClient.intuitInstitutions(count: 20000, skip: 0) { (response, institutions, error) in

            guard let institutions = institutions else { return XCTFail("Failed to get Intuit institutions") }

            //Run tests for each institution
            for plaidInstitution in institutions {
                print("running test for \(plaidInstitution.name)")
                //test source is correctly set to Intuit

                XCTAssertEqual(plaidInstitution.source, PlaidInstitution.Source.intuit, "Source is not correct for institution: \(plaidInstitution)")

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
                print("Fetching Intuit institutions took too long. \(error)")
            }
        }
    }


    func test_institution_with_id() {
        let testExpectation = expectation(withDescription: "fetching Bank Of America Institution")

        plaidClient.plaidInstitution(withID: "5301a93ac140de84910000e0") { response, institution, error in
            XCTAssertEqual(institution?.name, "Bank of America")
            testExpectation.fulfill()
        }

        waitForExpectations(withTimeout: 100000) { error in
            if let error = error {
                print("Fetchin Bank Of America took too long. \(error)")
            }
        }
    }
}
