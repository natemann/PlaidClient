//
//  File.swift
//  Budget
//
//  Created by Nate on 8/12/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

import Foundation
//import Alamofire

enum AccountInfoRetrevalError: ErrorType {
    
    case Locked(accessToken: String)
    case NotConnected(accessToken: String)
    
}


struct PlaidSwiftClient {

//    typealias JSON = [String : AnyObject]
//    
//    
//    ///Fetches institutions from *Plaid*.
//    /// - parameter completionHandler: returns a *NSHTTPURLResponse* and an Array of *PlaidInstitions*.
//    static func plaidInstitutions(completionHandler: (response: NSHTTPURLResponse?, institutions: [PlaidInstitution]) -> ()) {
//        Alamofire.request(.GET, PlaidURL.institutions).responseJSON { response in
//            guard let institutions = response.result.value as? [JSON] else {
//                completionHandler(response: nil, institutions: [])
//                return
//            }
//            
//            let plaidInstitutions = institutions.map { PlaidInstitution(institution: $0, source: .Plaid) }.flatMap { $0 }
//            completionHandler(response: response.response, institutions: plaidInstitutions)
//        }
//    }
//    
//    
//    ///Fetches institutions from *Intuit*
//    /// - parameter count: The number of institutions to return.
//    /// - parameter skip:  The number of institutions to skip over.
//    /// - parameter completionHandler: returns a *NSHTTPURLResponse* and an Array of *PlaidInstitions*
//    static func intuitInstitutions(count: Int, skip: Int, completionHandler: (response: NSHTTPURLResponse?, institutions: [PlaidInstitution]) -> ()) {
//        let parameters = ["client_id" : clientIDToken, "secret" : secretToken, "count" : String(count), "offset" : String(skip)]
//        
//        Alamofire.request(.POST, PlaidURL.intuit, parameters: parameters, encoding: .JSON).responseJSON { response in
//            guard let results = response.result.value as? [String : AnyObject], let json = results["results"] as? [JSON] else {
//                completionHandler(response: nil, institutions: [])
//                return
//            }
//            print(json)
//            let intuitInstitutions = json.map { PlaidInstitution(institution: $0, source: .Intuit) }.flatMap { $0 }
//            completionHandler(response: response.response, institutions: intuitInstitutions)
//        }
//    }
//    
//    
//    ///Fetches a *Plaid* instution with a specified ID.
//    /// - paramter id:
//    static func plaidInstitutionWithID(id: String, callBack: (response: NSHTTPURLResponse?, institution: PlaidInstitution?) -> ()) {
//        Alamofire.request(.GET, PlaidURL.institutions + "/\(id)").responseJSON { response in
//
//            guard let institution = response.result.value as? JSON else {
//                callBack(response: response.response, institution: nil)
//                return
//            }
//            callBack(response: response.response, institution: PlaidInstitution(institution: institution, source: .Plaid))
//        }
//    }
//    
//    
//    static func loginToInstitution(institution: PlaidInstitution, username: String, password: String, pin: String, callBack: (response: NSHTTPURLResponse?, responseData: JSON?) -> ()) {
//        
//        let credentials = ["username" : username,
//                           "password" : password,
//                                "pin" : pin]
//        
//        let parameters: JSON = ["client_id" : clientIDToken,
//                                   "secret" : secretToken,
//                              "credentials" : credentials,
//                                     "type" : institution.type]
//        
//        Alamofire.request(.POST, PlaidURL.connect, parameters: parameters, encoding: .JSON).responseJSON { response in
//            guard let responseObject = response.result.value as? JSON else {
//                callBack(response: response.response, responseData: nil)
//                return
//            }
//            
//            callBack(response: response.response, responseData: responseObject)
//        }
//    }
//    
//    
//    static func submitMFAResponse(response: String, institution: PlaidInstitution, accessToken: String, callBack: (response: NSHTTPURLResponse?, responseData: JSON?) -> ()) {
//                            
//        let parameters: JSON = ["client_id" : clientIDToken,
//                                   "secret" : secretToken,
//                                      "mfa" : response,
//                             "access_token" : accessToken,
//                                     "type" : institution.type]
//                            
//        Alamofire.request(.POST, PlaidURL.step, parameters: parameters, encoding: .JSON).responseJSON { response in
//            guard let responseObject = response.result.value as? JSON else {
//                callBack(response: response.response, responseData: nil)
//                return
//            }
//            
//            callBack(response: response.response, responseData: responseObject)
//        }
//    }
//    
//    
//    static func patchInstitution(accessToken: String, username: String, password: String, pin: String, callBack: (response: NSHTTPURLResponse?, data: JSON?) -> ()) {
//       
//        let parameters = ["client_id" : clientIDToken,
//                             "secret" : secretToken,
//                           "username" : username,
//                           "password" : password,
//                                "pin" : pin,
//                       "access_token" : accessToken]
//        
//        Alamofire.request(.PATCH, PlaidURL.connect, parameters: parameters, encoding: .JSON).responseJSON { response in
//            guard let data = response.result.value as? JSON else {
//                callBack(response: response.response, data: nil)
//                return
//            }
//            
//            callBack(response: response.response, data: data)
//        }
//    }
//    
//    
//    static func patchSubmitMFAResponse(response: String, accessToken: String, username: String, password: String, callBack: (response: NSHTTPURLResponse?, data: JSON?) -> ()) {
//        let parameters = ["client_id" : clientIDToken,
//                             "secret" : secretToken,
////                           "username" : username,
////                           "password" : password,
////                                "pin" : pin,
//                       "access_token" : accessToken,
//                                "mfa" : response]
//        Alamofire.request(.PATCH, PlaidURL.step, parameters: parameters, encoding: .JSON).responseJSON { response in
//            guard let data = response.result.value as? JSON else {
//                callBack(response: response.response, data: nil)
//                return
//            }
//            
//            callBack(response: response.response, data: data)
//        }
//    }
//    
//    
//    
//    
//    
//    static func downloadAccountData(accessToken accessToken: String, account: String, pending: Bool, fromDate: NSDate?, toDate: NSDate?, callBack: (response: NSHTTPURLResponse?, account: PlaidAccount?, plaidTransactions: [PlaidTransaction]?, error: AccountInfoRetrevalError?) -> ()) {
//        var options: JSON = ["pending" : pending,
//                             "account" : account]
//        
//        if let fromDate = fromDate {
//            options["gte"] = NSDateFormatter.plaidDate(date: fromDate)
//        }
//        
//        if let toDate = toDate {
//            options["lte"] = NSDateFormatter.plaidDate(date: toDate)
//        }
//        
//        let downloadCredentials: [String: AnyObject] = ["client_id" : clientIDToken,
//                                                           "secret" : secretToken,
//                                                     "access_token" : accessToken,
//                                                          "options" : options]
//        
//        Alamofire.request(.GET, PlaidURL.connect, parameters: downloadCredentials).responseJSON { response in
//            
//            guard let data = response.result.value as? JSON else { return }
//            
//            if let code = data["code"] as? Int {
//                switch code {
////                    case 1205:
////                        callBack(response: response.response!, account: nil, plaidTransactions: nil, error: .Locked(accessToken: accessToken))
//                    
//                    case 1200...1209:
//                        callBack(response: response.response!, account: nil, plaidTransactions: nil, error: .NotConnected(accessToken: accessToken))
//                    
//                    default:
//                        return
//                }
//            }
//            
//            if let transactions = data["transactions"] as? [JSON], accounts = data["accounts"] as? [[String : AnyObject]], accountData = accounts.first {
//                let plaidTransactions = transactions.map { PlaidTransaction(transaction: $0) }
//                callBack(response: response.response!, account: PlaidAccount(account: accountData), plaidTransactions: plaidTransactions, error: nil)
//            }
//            callBack(response: response.response!, account: nil, plaidTransactions: nil, error: nil)
//        }
//    }
    
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










