//
//  File.swift
//  Budget
//
//  Created by Nate on 8/12/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

import UIKit


public enum AccountInfoRetrevalError: ErrorProtocol {
    
    case locked(accessToken: String)
    case notConnected(accessToken: String)
    
}


public enum Environment {

    case development, production

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
    public func plaidInstitutions(session: URLSession = URLSession.shared(), completion: (response: URLResponse?, institutions: [PlaidInstitution]?, error: NSError?) -> Void) {
        session.dataTask(with: plaidURL.institutions()) { data, response, error in
            let json = self.decode(data: data) as? [JSON]
            completion(response: response, institutions: json?.flatMap { PlaidInstitution(institution: $0, source: .plaid) }, error: error)
        }.resume()
    }

    
    ///Fetches institutions from *Intuit*
    /// - parameter count: The number of institutions to return.
    /// - parameter skip: The number of institutions to skip over.
    /// - parameter completionHandler: returns a *NSHTTPURLResponse* and an Array of *PlaidInstitions*
    public func intuitInstitutions(count: Int, skip: Int, session: URLSession = URLSession.shared(), completion: (response: URLResponse?, institutions: [PlaidInstitution]?, error: NSError?) -> ()) {
        session.dataTask(with: plaidURL.intuit(clientID: clientIDToken, secret: secretToken, count: count, skip: skip)) { data, response,
            
            error in
            print("DATA", data)
            print(response)
            print(error)
            let json = self.decode(data: data) as? JSON
            let institutions = json?["results"] as? [JSON]
            completion(response: response, institutions: institutions?.flatMap { PlaidInstitution(institution: $0, source: .intuit) }, error: error)
        }.resume()
    }


    ///Fetches a *Plaid* instution with a specified ID.
    /// - parameter id: The institution's id given by **Plaid.com**
    public func plaidInstitution(withID id: String, session: URLSession = URLSession.shared(), completion: (response: URLResponse?, institution: PlaidInstitution?, error: NSError?) -> ()) {
        session.dataTask(with: plaidURL.institutions(id: id)) { data, response, error in
            if let json = self.decode(data: data) as? JSON {
                completion(response: response, institution: PlaidInstitution(institution: json, source: .plaid), error: error)
                return
            }
            completion(response: response, institution: nil, error: error)
        }.resume()
    }


    ///Logs in to a financial institutions
    /// - parameter institution: A *PlaidInstitution* object
    /// - parameter username: The user's username for the institution.
    /// - parameter password: The user's password for the institution.
    /// - parameter pin: The user's pin for the institution (if required)
    public func login(toInstitution institution: PlaidInstitution, username: String, password: String, pin: String? = nil, session: URLSession = URLSession.shared(), completion: (response:URLResponse?, responseData: JSON?, error: NSError?) -> ()) {
        session.dataTask(with: plaidURL.connect(clientID: clientIDToken, secret: secretToken, institution: institution, username: username, password: password, pin: pin)) { data, response, error in
            completion(response: response, responseData: self.decode(data: data) as? JSON, error: error)
        }.resume()
    }
//
//    
//    public func submitMFAResponse(_ type: MFAType, response: String, institution: PlaidInstitution, accessToken: String, callBack: (response:HTTPURLResponse?, responseData: JSON?, error: NSError?) -> ()) {
//                            
//        let parameters: JSON = ["client_id" : clientIDToken,
//                                   "secret" : secretToken,
//                                      "mfa" : response,
//                             "access_token" : accessToken,
//                                     "type" : institution.type]
//
//        Alamofire.request(.POST, plaidURL.step, parameters: parameters, encoding: .json).responseJSON { response in
//
//            guard let responseObject = response.result.value as? JSON else {
//                callBack(response: response.response, responseData: nil, error: response.result.error)
//                return
//            }
//            
//            callBack(response: response.response, responseData: responseObject, error: nil)
//        }
//    }
//    
//    
//    public func patchInstitution(accessToken: String, username: String, password: String, pin: String, callBack: (response:HTTPURLResponse?, data: JSON?) -> ()) {
//       
//        let parameters = ["client_id" : clientIDToken,
//                             "secret" : secretToken,
//                           "username" : username,
//                           "password" : password,
//                                "pin" : pin,
//                       "access_token" : accessToken]
//        
//        Alamofire.request(.PATCH, plaidURL.connect, parameters: parameters, encoding: .json).responseJSON { response in
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
//    public func patchSubmitMFAResponse(response: String, accessToken: String, callBack: (response:HTTPURLResponse?, data: JSON?) -> ()) {
//        let parameters = ["client_id" : clientIDToken,
//                             "secret" : secretToken,
////                           "username" : username,
////                           "password" : password,
////                                "pin" : pin,
//                       "access_token" : accessToken,
//                                "mfa" : response]
//        Alamofire.request(.PATCH, plaidURL.step, parameters: parameters, encoding: .json).responseJSON { response in
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
//    public func downloadAccountData(accessToken: String, account: String, pending: Bool, fromDate: Date?, toDate: Date?, callBack: (response: HTTPURLResponse?, account: PlaidAccount?, plaidTransactions: [PlaidTransaction]?, error: AccountInfoRetrevalError?) -> ()) {
//        var options: JSON = ["pending" : pending,
//                             "account" : account]
//        
//        if let fromDate = fromDate {
//            options["gte"] = DateFormatter.plaidDate(fromDate)
//        }
//        
//        if let toDate = toDate {
//            options["lte"] = DateFormatter.plaidDate(toDate)
//        }
//        
//        let downloadCredentials: [String: AnyObject] = ["client_id" : clientIDToken,
//                                                           "secret" : secretToken,
//                                                     "access_token" : accessToken,
//                                                          "options" : options]
//        
//        Alamofire.request(.GET, plaidURL.connect, parameters: downloadCredentials).responseJSON { response in
//            print(response)
//            guard let data = response.result.value as? JSON else { return }
//            
//            if let code = data["code"] as? Int {
//                switch code {
//    
//                    case 1200...1209:
//                        callBack(response: response.response!, account: nil, plaidTransactions: nil, error: .notConnected(accessToken:accessToken))
//                    
//                    default:
//                        return
//                }
//            }
//            
//            if let transactions = data["transactions"] as? [JSON], accounts = data["accounts"] as? [[String : AnyObject]], accountData = accounts.first {
//                print(transactions)
//                let plaidTransactions = transactions.map { PlaidTransaction(transaction: $0) }
//                callBack(response: response.response!, account: PlaidAccount(account: accountData), plaidTransactions: plaidTransactions, error: nil)
//            }
//            callBack(response: response.response!, account: nil, plaidTransactions: nil, error: nil)
//        }
//    }


    private func decode(data: Data?) -> AnyObject? {
        do {
            if let data = data {
                return try JSONSerialization.jsonObject(with: data, options: [.mutableContainers])
            }
        } catch {
            print("Could not decode Data: \(error)")
        }
        return nil
    }

}





public extension DateFormatter {
    
    public class var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale     = Locale(localeIdentifier: "en_US_PSIX")
        dateFormatter.dateFormat = "yyy-MM-dd"
        
        return dateFormatter
    }
    
    
    public class func plaidDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    
    public class func dateFromString(_ string: String) -> Date {
        return dateFormatter.date(from: string)!
    }
    
}










