//
//  File.swift
//  Budget
//
//  Created by Nate on 8/12/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

import Foundation
import Alamofire

let plaidBaseURL = "https://tartan.plaid.com"
let clientID     = "clientID"
let secret       = "secret"

struct PlaidInstitution {
    let credentials: [String : String]
    let has_mfa:     Bool
    let id:          String
    let name:        String
    let type:        String
    let mfa:         [String]
    let products:    [String]
    
    init(institution: [String : AnyObject]) {
        credentials = institution["credentials"]! as [String : String]
        has_mfa     = institution["has_mfa"]! as Int == 1 ? true : false
        id          = institution["id"]! as String
        name        = institution["name"]! as String
        type        = institution["type"]! as String
        mfa         = institution["mfa"]! as [String]
        products    = institution["products"]! as [String]
    }
}


struct PlaidAccount {
    
    let name    = String()
    let number  = String()
    let id      = String()
    let balance = NSDecimalNumber()
    let type    = String()
    
    init(account: [String : AnyObject]) {
        let meta           = account["meta"]! as [String: AnyObject]
        let accountBalance = account["balance"]! as [String: Double]
        
        name    = meta["name"]! as String
        number  = meta["number"]! as String
        id      = account["_id"]! as String
        type    = account["tpe"]! as String
        balance = NSDecimalNumber(double: accountBalance["current"]! as Double)
    }
}


struct PlaidTransaction {
    
    let account:   String
    let id:        String
    let pendingID: String?
    let amount:    NSDecimalNumber
    let date:      NSDate
    let pending:   Bool
    
    init(transaction: [String : AnyObject]) {
        account   = transaction["_account"]! as String
        id        = transaction["_id"]! as String
        pendingID = transaction["_pendingTransaction"] as? String
        amount    = NSDecimalNumber.roundTwoDecimalPlaces(double: transaction["amount"]! as Double * -1)  //Plaid stores withdraws as positve numbers and deposits as negative numbers
        date      = NSDateFormatter.dateFromString(transaction["date"]! as String)
        pending   = transaction["pending"]! as Bool
        
    }
}


class PlaidSwiftClient {

    //    MARK: Class Functions
    
    class func plaidInstitutions(completionHandler: (response: NSHTTPURLResponse?, institutions: [PlaidInstitution], error: NSError?) -> ()) {
        Alamofire.request(.GET, "https://tartan.plaid.com/institutions")
                 .responseJSON {(request, response, data, error) -> Void in
            var plaidInstitutions = [PlaidInstitution]()
            for institution in data as [AnyObject] {
                if let institution = institution as? [String: AnyObject] {
                    let plaidInstitution = PlaidInstitution(institution: institution)
                    plaidInstitutions.append(plaidInstitution)
                }
            }
            completionHandler(response: response, institutions: plaidInstitutions, error: error)
        }
    }
    
    
    class func loginToInstitution(institution: PlaidInstitution,
                                     username: String,
                                     password: String,
                                          pin: String,
                                        email: String,
                            completionHandler: (response: NSHTTPURLResponse, responseData: [String: AnyObject]) -> ()) {
        let credentials = ["username" : username,
                           "password" : password,
                                "pin" : pin]
        
        let parameters: [String: AnyObject] = ["client_id" : clientID,
                                                  "secret" : secret,
                                             "credentials" : credentials,
                                                    "type" : institution.type,
                                                   "email" : email]
        
        Alamofire.request(.POST, plaidBaseURL + "/connect", parameters: parameters, encoding: .JSON)
                 .responseJSON { (request, response, data, error) -> Void in
            let responseObject = data! as [String: AnyObject]
            completionHandler(response: response!, responseData: responseObject)
        }
    }
    
    
    class func submitMFAResponse(response: String,
                              institution: PlaidInstitution,
                              accessToken: String,
                        completionHandler: (response: NSHTTPURLResponse, responseData: [String: AnyObject]) -> ()) {
                            
        let parameters: [String: AnyObject] = ["client_id" : clientID,
                                                  "secret" : secret,
                                                     "mfa" : response,
                                            "access_token" : accessToken,
                                                    "type" : institution.type]
                            
        Alamofire.request(.POST, plaidBaseURL + "/connect/step", parameters: parameters, encoding: .JSON)
                 .responseJSON { (request, response, data, error) -> Void in
            if let responseObject = data as? [String: AnyObject] {
                completionHandler(response: response!, responseData: responseObject)
            }
        }
    }
    
    
    class func downloadTransactions(#accessToken: String,
                                         account: String,
                                         pending: Bool,
                                        fromDate: NSDate?,
                                          toDate: NSDate?,
                                         success: (response: NSHTTPURLResponse, plaidTransactions: [PlaidTransaction]) -> ()) {
        var options: [String: AnyObject] = ["pending" : pending,
                                            "account" : account]
        if let fromDate = fromDate {
            options["gte"] = NSDateFormatter.plaidDate(date: fromDate)
        }
        
        if let toDate = toDate {
            options["lte"] = NSDateFormatter.plaidDate(date: toDate)
        }
        
        let downloadCredentials: [String: AnyObject] = ["client_id" : clientID,
                                                           "secret" : secret,
                                                     "access_token" : accessToken,
                                                          "options" : options]
        
        Alamofire.request(.GET, plaidBaseURL + "/connect", parameters: downloadCredentials)
                 .responseJSON { (request, response, data, error) -> Void in
            if let downloadData = data as? [String: AnyObject] {
                if let transactions = downloadData["transactions"] as? [[String: AnyObject]] {
                    var plaidTransactions = [PlaidTransaction]()
                    for transaction in transactions {
                        println(transaction["_id"]! as String)
                        var hexNumber: CUnsignedInt = 0
                        let scanner = NSScanner(string: transaction["_id"]! as String)
                        scanner.scanHexInt(&hexNumber)
                        println(hexNumber)
                        let plaidTransaction = PlaidTransaction(transaction: transaction)
                        plaidTransactions.append(plaidTransaction)
                    }
                    success(response: response!, plaidTransactions: plaidTransactions)
                }
            }
        }
    }
}



extension NSDecimalNumber {
    
    class func roundTwoDecimalPlaces(#double: Double) -> NSDecimalNumber {
        let handler = NSDecimalNumberHandler(roundingMode: .RoundPlain,
            scale: 2,
            raiseOnExactness: true,
            raiseOnOverflow: true,
            raiseOnUnderflow: true,
            raiseOnDivideByZero: true)
        let number  = NSDecimalNumber(double: double)
        
        return number.decimalNumberByRoundingAccordingToBehavior(handler)
    }
}





extension NSDateFormatter {
    
    class func plaidDate(#date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale     = NSLocale(localeIdentifier: "en_US_PSIX")
        dateFormatter.dateFormat = "yyy-MM-dd"
        
        return dateFormatter.stringFromDate(date)
    }
    
    class func dateFromString(string: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_PSIX")
        dateFormatter.dateFormat = "yyy-MM-dd"
        
        return dateFormatter.dateFromString(string)!
    }
}










