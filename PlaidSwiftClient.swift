//
//  File.swift
//  Budget
//
//  Created by Nate on 8/12/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

import Foundation


struct PlaidSwiftClient {

    //    MARK: Class Functions
    
    static func plaidInstitutions(completionHandler: (response: NSHTTPURLResponse?, institutions: [PlaidInstitution], error: NSError?) -> ()) {
        Alamofire.manager.request(.GET, PlaidURL.institutions).responseJSON {(request, response, data, error) in
            if let institutions = data as? [[String : AnyObject]] {
                let plaidInstitutions = institutions.map { PlaidInstitution(institution: $0) }
                completionHandler(response: response, institutions: plaidInstitutions, error: error)
            }
        }
    }
    
    
    
    static func loginToInstitution(institution: PlaidInstitution, username: String, password: String, pin: String, email: String, callBack: (response: NSHTTPURLResponse, responseData: [String: AnyObject]) -> ()) {
        let credentials = ["username" : username,
                           "password" : password,
                                "pin" : pin]
        
        let parameters: [String: AnyObject] = ["client_id" : clientIDToken,
                                                  "secret" : secretToken,
                                             "credentials" : credentials,
                                                    "type" : institution.type,
                                                   "email" : email]
        
        Alamofire.manager.request(.POST, PlaidURL.connect, parameters: parameters, encoding: .JSON).responseJSON { (request, response, data, error) in
            let responseObject = data! as [String: AnyObject]
            callBack(response: response!, responseData: responseObject)
        }
    }
    
    
    static func submitMFAResponse(response: String, institution: PlaidInstitution, accessToken: String, callBack: (response: NSHTTPURLResponse, responseData: [String: AnyObject]) -> ()) {
                            
        let parameters: [String: AnyObject] = ["client_id" : clientIDToken,
                                                  "secret" : secretToken,
                                                     "mfa" : response,
                                            "access_token" : accessToken,
                                                    "type" : institution.type]
                            
        Alamofire.manager.request(.POST, PlaidURL.step, parameters: parameters, encoding: .JSON).responseJSON { (request, response, data, error) in
            if let responseObject = data as? [String: AnyObject] {
                callBack(response: response!, responseData: responseObject)
            }
        }
    }
    
    
    static func downloadAccountData(#accessToken: String, account: String, pending: Bool, fromDate: NSDate?, toDate: NSDate?, callBack: (response: NSHTTPURLResponse, account: PlaidAccount?, plaidTransactions: [PlaidTransaction]?, error: NSError?) -> ()) {
        var options: [String: AnyObject] = ["pending" : pending,
                                            "account" : account]
        if let fromDate = fromDate {
            options["gte"] = NSDateFormatter.plaidDate(date: fromDate)
        }
        
        if let toDate = toDate {
            options["lte"] = NSDateFormatter.plaidDate(date: toDate)
        }
        
        let downloadCredentials: [String: AnyObject] = ["client_id" : clientIDToken,
                                                           "secret" : secretToken,
                                                     "access_token" : accessToken,
                                                          "options" : options]
        Alamofire.manager.request(.GET, PlaidURL.connect, parameters: downloadCredentials).responseJSON { (request, response, data, error) in
            if error != nil {
                callBack(response: response!, account: nil, plaidTransactions: nil, error: error)
            }
            
            if let code = data?["code"] as? Int {
                switch code {
                case 1206:
                    let accessToken = data!["access_token"] as String
                    let userInfo = [NSLocalizedDescriptionKey : "Download was unsuccessful",
                                    "accessToken" : data?["access_token"] as String,
                                    NSLocalizedFailureReasonErrorKey: "Account not connected",
                                    NSLocalizedRecoverySuggestionErrorKey : "Recconnect the account"]
                    let connectionError = NSError(domain: "com.nathanmann.InTheBlack", code: 1206, userInfo: userInfo)
                    
                    callBack(response: response!, account: nil, plaidTransactions: nil, error: connectionError)
                default:
                    return
                }
            }
            
            if let transactions = data?["transactions"] as? [[String : AnyObject]] {
                if let accounts = data?["accounts"] as? [[String : AnyObject]] {
                    if let accountData = accounts.first {
                        let plaidTransactions = transactions.map { PlaidTransaction(transaction: $0) }
                        callBack(response: response!, account: PlaidAccount(account: accountData), plaidTransactions: plaidTransactions, error: error)
                    }
                }
            }
            callBack(response: response!, account: nil, plaidTransactions: nil, error: nil)
        }
    }
    
}





extension NSDecimalNumber {
    
    class func roundTwoDecimalPlaces(#double: Double) -> NSDecimalNumber {
        let handler = NSDecimalNumberHandler(roundingMode: .RoundPlain, scale: 2, raiseOnExactness: true, raiseOnOverflow: true, raiseOnUnderflow: true,raiseOnDivideByZero: true)
        let number  = NSDecimalNumber(double: double)
        
        return number.decimalNumberByRoundingAccordingToBehavior(handler)
    }
    
}





extension NSDateFormatter {
    
    class var dateFormatter: NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale     = NSLocale(localeIdentifier: "en_US_PSIX")
        dateFormatter.dateFormat = "yyy-MM-dd"
        
        return dateFormatter
    }
    
    class func plaidDate(#date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    class func dateFromString(string: String) -> NSDate {
        return dateFormatter.dateFromString(string)!
    }
}










