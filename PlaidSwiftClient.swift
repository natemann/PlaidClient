//
//  File.swift
//  Budget
//
//  Created by Nate on 8/12/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

import Foundation
import Alamofire

struct PlaidSwiftClient {

    //    MARK: Class Functions
    
    static func plaidInstitutions(completionHandler: (response: NSHTTPURLResponse?, institutions: [PlaidInstitution], error: NSError?) -> ()) {
        Alamofire.request(.GET, PlaidURL.institutions).responseJSON {(request, response, data, error) in
            if let institutions = data as? [[String : AnyObject]] {
                let plaidInstitutions = institutions.map { PlaidInstitution(institution: $0) }
                completionHandler(response: response, institutions: plaidInstitutions, error: error)
            }
        }
    }
    
    
    static func plaidInstitutionWithID(id: String, callBack: (response: NSHTTPURLResponse?, institution: PlaidInstitution, error: NSError?) -> ()) {
        Alamofire.request(.GET, PlaidURL.institutions + "/\(id)").responseJSON {(request, response, data, error) in
            if let institution = data as? [String : AnyObject] {
                callBack(response: response, institution: PlaidInstitution(institution: institution), error: error)
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
        
        Alamofire.request(.POST, PlaidURL.connect, parameters: parameters, encoding: .JSON).responseJSON { (request, response, data, error) in
            let responseObject = data! as! [String: AnyObject]
            callBack(response: response!, responseData: responseObject)
        }
    }
    
    
    static func submitMFAResponse(response: String, institution: PlaidInstitution, accessToken: String, callBack: (response: NSHTTPURLResponse, responseData: [String: AnyObject]) -> ()) {
                            
        let parameters: [String: AnyObject] = ["client_id" : clientIDToken,
                                                  "secret" : secretToken,
                                                     "mfa" : response,
                                            "access_token" : accessToken,
                                                    "type" : institution.type]
                            
        Alamofire.request(.POST, PlaidURL.step, parameters: parameters, encoding: .JSON).responseJSON { (request, response, data, error) in
            if let responseObject = data as? [String: AnyObject] {
                callBack(response: response!, responseData: responseObject)
            }
        }
    }
    
    
    static func patchInstitution(accessToken: String, username: String, password: String, pin: String, callBack: (response: NSHTTPURLResponse, data: [String : AnyObject]) -> ()) {
        let parameters = ["client_id" : clientIDToken,
                             "secret" : secretToken,
                           "username" : username,
                           "password" : password,
                                "pin" : pin,
                       "access_token" : accessToken]
        
        Alamofire.request(.PATCH, PlaidURL.connect, parameters: parameters, encoding: .JSON).responseJSON { (request, response, data, error) in
            println(response)
            println(data)
            println(error)
            callBack(response: response!, data: data as! [String : AnyObject])
        }
    }
    
    
    static func patchSubmitMFAResponse(response: String, accessToken: String, username: String, password: String, pin: String, callBack: (response: NSHTTPURLResponse, data: [String : AnyObject]) -> ()) {
        let parameters = ["client_id" : clientIDToken,
                             "secret" : secretToken,
                           "username" : username,
                           "password" : password,
                                "pin" : pin,
                       "access_token" : accessToken,
                                "mfa" : response]
        Alamofire.request(.PATCH, PlaidURL.step, parameters: parameters, encoding: .JSON).responseJSON { (request, response, data, error) in callBack(response: response!, data: data as! [String : AnyObject]) }
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
        Alamofire.request(.GET, PlaidURL.connect, parameters: downloadCredentials).responseJSON { (request, response, data, error) in
            if error != nil {
                callBack(response: response!, account: nil, plaidTransactions: nil, error: error)
            }
            if let code = data?["code"] as? Int {
                switch code {
                case 1200:
                    let accessToken = data!["access_token"] as! String
                    let userInfo = [NSLocalizedDescriptionKey : "Account Locked",
                                                "accessToken" : accessToken,
                             NSLocalizedFailureReasonErrorKey : "Cannot Access Account",
                        NSLocalizedRecoverySuggestionErrorKey : "Unlock Account"]
                    let connectionError = NSError(domain: "com.nathanmann.InTheBlack", code: 1205, userInfo: userInfo)
                    
                    callBack(response: response!, account: nil, plaidTransactions: nil, error: connectionError)
                case 1203, 1206, 1215, 1205:
                    let accessToken = data!["access_token"] as! String
                    let userInfo = [NSLocalizedDescriptionKey : "Download was unsuccessful",
                                                "accessToken" : accessToken,
                             NSLocalizedFailureReasonErrorKey : "Account not connected",
                        NSLocalizedRecoverySuggestionErrorKey : "Recconnect the account"]
                    let connectionError = NSError(domain: "com.nathanmann.InTheBlack", code: 1206, userInfo: userInfo)
                    
                    callBack(response: response!, account: nil, plaidTransactions: nil, error: connectionError)
                default:
                    return
                }
            }
            
            if let transactions = data?["transactions"] as? [[String : AnyObject]], accounts = data?["accounts"] as? [[String : AnyObject]], accountData = accounts.first {
                let plaidTransactions = transactions.map { PlaidTransaction(transaction: $0) }
                callBack(response: response!, account: PlaidAccount(account: accountData), plaidTransactions: plaidTransactions, error: error)
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










