//
//  File.swift
//  Budget
//
//  Created by Nate on 8/12/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

import Foundation
import Alamofire

enum AccountInfoRetrevalError: ErrorType {
    
    case Locked(accessToken: String)
    case NotConnected(accessToken: String)
    
    
}


struct PlaidSwiftClient {

    typealias JSON = [String : AnyObject]
    
    
    //    MARK: Class Functions
    
    static func plaidInstitutions(completionHandler: (response: NSHTTPURLResponse?, institutions: [PlaidInstitution]?) -> ()) {
        Alamofire.request(.GET, PlaidURL.institutions).responseJSON { _, response, result in
            guard let institutions = result.value as? [JSON] else {
                completionHandler(response: nil, institutions: nil)
                return
            }
            
            let plaidInstitutions = institutions.map { PlaidInstitution(institution: $0) }
            completionHandler(response: response, institutions: plaidInstitutions)
        }
    }
    
    
    static func plaidInstitutionWithID(id: String, callBack: (response: NSHTTPURLResponse?, institution: PlaidInstitution?) -> ()) {
        Alamofire.request(.GET, PlaidURL.institutions + "/\(id)").responseJSON { _, response, result in
            guard let institution = result.value as? JSON else {
                callBack(response: response, institution: nil)
                return
            }
            
            callBack(response: response, institution: PlaidInstitution(institution: institution))
        }
    }
    
    
    static func loginToInstitution(institution: PlaidInstitution, username: String, password: String, pin: String, email: String, callBack: (response: NSHTTPURLResponse?, responseData: JSON?) -> ()) {
        
        let credentials = ["username" : username,
                           "password" : password,
                                "pin" : pin]
        
        let parameters: JSON = ["client_id" : clientIDToken,
                                   "secret" : secretToken,
                              "credentials" : credentials,
                                     "type" : institution.type,
                                    "email" : email]
        
        Alamofire.request(.POST, PlaidURL.connect, parameters: parameters, encoding: .JSON).responseJSON { _, response, result in
            guard let responseObject = result.value as? JSON else {
                callBack(response: response, responseData: nil)
                return
            }
            
            callBack(response: response, responseData: responseObject)
            
        }
    }
    
    
    static func submitMFAResponse(response: String, institution: PlaidInstitution, accessToken: String, callBack: (response: NSHTTPURLResponse?, responseData: JSON?) -> ()) {
                            
        let parameters: JSON = ["client_id" : clientIDToken,
                                   "secret" : secretToken,
                                      "mfa" : response,
                             "access_token" : accessToken,
                                     "type" : institution.type]
                            
        Alamofire.request(.POST, PlaidURL.step, parameters: parameters, encoding: .JSON).responseJSON { _, response, result in
            guard let responseObject = result.value as? JSON else {
                callBack(response: response, responseData: nil)
                return
            }
            
            callBack(response: response, responseData: responseObject)
        }
    }
    
    
    static func patchInstitution(accessToken: String, username: String, password: String, pin: String, callBack: (response: NSHTTPURLResponse?, data: JSON?) -> ()) {
       
        let parameters = ["client_id" : clientIDToken,
                             "secret" : secretToken,
                           "username" : username,
                           "password" : password,
                                "pin" : pin,
                       "access_token" : accessToken]
        
        Alamofire.request(.PATCH, PlaidURL.connect, parameters: parameters, encoding: .JSON).responseJSON { (_, response, result) in
            guard let data = result.value as? JSON else {
                callBack(response: response, data: nil)
                return
            }
            
            callBack(response: response, data: data)
        }
    }
    
    
    static func patchSubmitMFAResponse(response: String, accessToken: String, username: String, password: String, callBack: (response: NSHTTPURLResponse?, data: JSON?) -> ()) {
        let parameters = ["client_id" : clientIDToken,
                             "secret" : secretToken,
//                           "username" : username,
//                           "password" : password,
//                                "pin" : pin,
                       "access_token" : accessToken,
                                "mfa" : response]
        Alamofire.request(.PATCH, PlaidURL.step, parameters: parameters, encoding: .JSON).responseJSON { _, response, result in
            guard let data = result.value as? JSON else {
                callBack(response: response, data: nil)
                return
            }
            
            callBack(response: response, data: data)
        }
    }
    
    
    
    
    
    static func downloadAccountData(accessToken accessToken: String, account: String, pending: Bool, fromDate: NSDate?, toDate: NSDate?, callBack: (response: NSHTTPURLResponse?, account: PlaidAccount?, plaidTransactions: [PlaidTransaction]?, error: AccountInfoRetrevalError?) -> ()) {
        var options: JSON = ["pending" : pending,
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
        
        Alamofire.request(.GET, PlaidURL.connect, parameters: downloadCredentials).responseJSON { _, response, result in
            guard let data = result.value as? JSON else { return }
            
            if let code = data["code"] as? Int {
                switch code {
                case 1205:
                    callBack(response: response!, account: nil, plaidTransactions: nil, error: .Locked(accessToken: accessToken))
                    
                case 1206, 1215:
                    callBack(response: response!, account: nil, plaidTransactions: nil, error: .NotConnected(accessToken: accessToken))
                    
                default:
                    return
                }
            }
            
            if let transactions = data["transactions"] as? [JSON], accounts = data["accounts"] as? [[String : AnyObject]], accountData = accounts.first {
                let plaidTransactions = transactions.map { PlaidTransaction(transaction: $0) }
                callBack(response: response!, account: PlaidAccount(account: accountData), plaidTransactions: plaidTransactions, error: nil)
            }
            callBack(response: response!, account: nil, plaidTransactions: nil, error: nil)
        }
    }
    
}





extension NSDecimalNumber {
    
    class func roundTwoDecimalPlaces(double double: Double) -> NSDecimalNumber {
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
    
    class func plaidDate(date date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    class func dateFromString(string: String) -> NSDate {
        return dateFormatter.dateFromString(string)!
    }
}










