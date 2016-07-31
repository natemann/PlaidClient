//
//  File.swift
//  Budget
//
//  Created by Nate on 8/12/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

import UIKit
import Alamofire

//Must sign up at Plaid.com to receive unique cliendIDToken and secretToken


public enum AccountInfoRetrevalError: ErrorType {
    
    case Locked(accessToken: String)
    case NotConnected(accessToken: String)
    
}


public enum Environment {

    case Development, Production

}


public struct PlaidURL {

    init(environment: Environment) {
        switch environment {
        case .Development:
            baseURL = "https://tartan.plaid.com"
        case .Production:
            baseURL = "https://api.plaid.com"
        }
    }

    let baseURL: String

    var institutions: String { return baseURL + "/institutions" }
    var intuit: String { return institutions + "/longtail" }
        var connect: String { return baseURL + "/connect" }
        var step: String { return connect + "/step" }

}



public struct PlaidClient {

    public typealias JSON = [String : AnyObject]

    ///Sign up at **Plaid.com** to receive a unique clienID
    private let clientIDToken: String
    
    ///Sign up at **Plaid.com** to receive a unique secretToken
    private let secretToken: String

    private let plaidURL: PlaidURL


    public init(clientIDToken: String, secretToken: String, environment: Environment) {
        self.clientIDToken = clientIDToken
        self.secretToken   = secretToken
        self.plaidURL = PlaidURL(environment: environment)
    }
    
    ///Fetches institutions from *Plaid*.
    /// - parameter completionHandler: returns a *NSHTTPURLResponse* and an Array of *PlaidInstitions*.
    public func plaidInstitutions(_ completionHandler: (response: NSHTTPURLResponse?, institutions: [PlaidInstitution]) -> ()) {
        
        Alamofire.request(.GET, plaidURL.institutions).responseJSON { response in
            guard let institutions = response.result.value as? [JSON] else {
                completionHandler(response: nil, institutions: [])
                return
            }
            
            let plaidInstitutions = institutions.map { PlaidInstitution(institution: $0, source: .plaid) }.flatMap { $0 }
            completionHandler(response: response.response, institutions: plaidInstitutions)
        }
    }
    
    
    ///Fetches institutions from *Intuit*
    /// - parameter count: The number of institutions to return.
    /// - parameter skip:  The number of institutions to skip over.
    /// - parameter completionHandler: returns a *NSHTTPURLResponse* and an Array of *PlaidInstitions*
    public func intuitInstitutions(_ count: Int, skip: Int, completionHandler: (response: NSHTTPURLResponse?, institutions: [PlaidInstitution]) -> ()) {
        let parameters = ["client_id" : clientIDToken, "secret" : secretToken, "count" : String(count), "offset" : String(skip)]
        
        Alamofire.request(.POST, plaidURL.intuit, parameters: parameters, encoding: .JSON).responseJSON { response in
            guard let results = response.result.value as? [String : AnyObject], let json = results["results"] as? [JSON] else {
                completionHandler(response: nil, institutions: [])
                return
            }
            let intuitInstitutions = json.map { PlaidInstitution(institution: $0, source: .intuit) }.flatMap { $0 }
            completionHandler(response: response.response, institutions: intuitInstitutions)
        }
    }
    
    
    ///Fetches a *Plaid* instution with a specified ID.
    /// - parameter id: The institution's id given by **Plaid.com**
    public func plaidInstitutionWithID(id id: String, callBack: (response: NSHTTPURLResponse?, institution: PlaidInstitution?) -> ()) {
        Alamofire.request(.GET, plaidURL.institutions + "/\(id)").responseJSON { response in

            guard let institution = response.result.value as? JSON else {
                callBack(response: response.response, institution: nil)
                return
            }
            callBack(response: response.response, institution: PlaidInstitution(institution: institution, source: .plaid))
        }
    }
    
    ///Logs in to a financial institutions
    /// - parameter institution: A *PlaidInstitution* object
    /// - parameter username: The user's username for the institution.
    /// - parameter password: The user's password for the institution.
    /// - parameter pin: The user's pin for the institution (if required)
    public func loginToInstitution(institution: PlaidInstitution, username: String, password: String, pin: String, callBack: (response:NSHTTPURLResponse?, responseData: JSON?) -> ()) {
        
        let credentials = ["username" : username,
                           "password" : password,
                                "pin" : pin]
        
        let parameters: JSON = ["client_id" : clientIDToken,
                                   "secret" : secretToken,
                              "credentials" : credentials,
                                     "type" : institution.type]
        
        Alamofire.request(.POST, plaidURL.connect, parameters: parameters, encoding: .JSON).responseJSON { response in
            guard let responseObject = response.result.value as? JSON else {
                callBack(response: response.response, responseData: nil)
                return
            }
            
            callBack(response: response.response, responseData: responseObject)
        }
    }
    
    
    public func submitMFAResponse(type: MFAType, response response: String, institution: PlaidInstitution, accessToken: String, callBack: (response:NSHTTPURLResponse?, responseData: JSON?, error: NSError?) -> ()) {
                            
        let parameters: JSON = ["client_id" : clientIDToken,
                                   "secret" : secretToken,
                                      "mfa" : response,
                             "access_token" : accessToken,
                                     "type" : institution.type]

        Alamofire.request(.POST, plaidURL.step, parameters: parameters, encoding: .JSON).responseJSON { response in

            guard let responseObject = response.result.value as? JSON else {
                callBack(response: response.response, responseData: nil, error: response.result.error)
                return
            }
            
            callBack(response: response.response, responseData: responseObject, error: nil)
        }
    }
    
    
    public func patchInstitution(accessToken accessToken: String, username: String, password: String, pin: String, callBack: (response:NSHTTPURLResponse?, data: JSON?) -> ()) {
       
        let parameters = ["client_id" : clientIDToken,
                             "secret" : secretToken,
                           "username" : username,
                           "password" : password,
                                "pin" : pin,
                       "access_token" : accessToken]
        
        Alamofire.request(.PATCH, plaidURL.connect, parameters: parameters, encoding: .JSON).responseJSON { response in
            guard let data = response.result.value as? JSON else {
                callBack(response: response.response, data: nil)
                return
            }
            
            callBack(response: response.response, data: data)
        }
    }
    
    
    public func patchSubmitMFAResponse(response response: String, accessToken: String, callBack: (response:NSHTTPURLResponse?, data: JSON?) -> ()) {
        let parameters = ["client_id" : clientIDToken,
                             "secret" : secretToken,
//                           "username" : username,
//                           "password" : password,
//                                "pin" : pin,
                       "access_token" : accessToken,
                                "mfa" : response]
        Alamofire.request(.PATCH, plaidURL.step, parameters: parameters, encoding: .JSON).responseJSON { response in
            guard let data = response.result.value as? JSON else {
                callBack(response: response.response, data: nil)
                return
            }
            
            callBack(response: response.response, data: data)
        }
    }
    
    
    
    
    
    public func downloadAccountData(accessToken accessToken: String, account: String, pending: Bool, fromDate: NSDate?, toDate: NSDate?, callBack: (response: NSHTTPURLResponse?, account: PlaidAccount?, plaidTransactions: [PlaidTransaction]?, error: AccountInfoRetrevalError?) -> ()) {
        var options: JSON = ["pending" : pending,
                             "account" : account]
        
        if let fromDate = fromDate {
            options["gte"] = NSDateFormatter.plaidDate(fromDate)
        }
        
        if let toDate = toDate {
            options["lte"] = NSDateFormatter.plaidDate(toDate)
        }
        
        let downloadCredentials: [String: AnyObject] = ["client_id" : clientIDToken,
                                                           "secret" : secretToken,
                                                     "access_token" : accessToken,
                                                          "options" : options]
        
        Alamofire.request(.GET, plaidURL.connect, parameters: downloadCredentials).responseJSON { response in
            print("RESPONSE GET:", response)
            guard let data = response.result.value as? JSON else { return }
            
            if let code = data["code"] as? Int {
                switch code {
    
                    case 1200...1209:
                        callBack(response: response.response!, account: nil, plaidTransactions: nil, error: .NotConnected(accessToken:accessToken))
                    
                    default:
                        return
                }
            }
            
            if let transactions = data["transactions"] as? [JSON],
               let accounts = data["accounts"] as? [[String : AnyObject]],
                let accountData = accounts.filter({ $0["_id"] as? String == account }).first {
                let plaidTransactions = transactions.map { PlaidTransaction(transaction: $0) }
                callBack(response: response.response!, account: PlaidAccount(account: accountData), plaidTransactions: plaidTransactions, error: nil)
            }
            callBack(response: response.response!, account: nil, plaidTransactions: nil, error: nil)
        }
    }
    
}





public extension NSDateFormatter {
    
    public class var dateFormatter: NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale     = NSLocale(localeIdentifier: "en_US_PSIX")
        dateFormatter.dateFormat = "yyy-MM-dd"
        
        return dateFormatter
    }
    
    
    public class func plaidDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    
    public class func dateFromString(_ string: String) -> NSDate {
        return dateFormatter.dateFromString(string)!
    }
    
}










