//
//  File.swift
//  Budget
//
//  Created by Nate on 8/12/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

import UIKit


public enum AccountInfoRetrevalError: Error {
    
    case locked(accessToken: String)
    case notConnected(accessToken: String)
    
}


public enum Environment {

    case development, production

}





public struct PlaidClient {

    public typealias JSON = [String : Any]

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
    public func plaidInstitutions(session: URLSession = URLSession.shared, completion: @escaping (_ response: URLResponse?, _ institutions: [PlaidInstitution]?, _ error: NSError?) -> Void) {
        session.dataTask(with: plaidURL.institutions()) { data, response, error in
            let json = self.decode(data: data) as? [JSON]
            completion(response, json?.flatMap { PlaidInstitution(institution: $0, source: .plaid) }, error as NSError?)
        }.resume()
    }

    
    ///Fetches institutions from *Intuit*
    /// - parameter count: The number of institutions to return.
    /// - parameter skip: The number of institutions to skip over.
    /// - parameter completionHandler: returns a *NSHTTPURLResponse* and an Array of *PlaidInstitions*
    public func intuitInstitutions(count: Int, skip: Int, session: URLSession = URLSession.shared, completion: @escaping (_ response: URLResponse?, _ institutions: [PlaidInstitution]?, _ error: NSError?) -> ()) {
        session.dataTask(with: plaidURL.intuit(clientID: clientIDToken, secret: secretToken, count: count, skip: skip)) { data, response, error in
            let json = self.decode(data: data) as? JSON
            let institutions = json?["results"] as? [JSON]
            completion(response, institutions?.flatMap { PlaidInstitution(institution: $0, source: .intuit) }, error as NSError?)
        }.resume()
    }


    ///Fetches a *Plaid* instution with a specified ID.
    /// - parameter id: The institution's id given by **Plaid.com**
    public func plaidInstitution(withID id: String, session: URLSession = URLSession.shared, completion: @escaping (_ response: URLResponse?, _ institution: PlaidInstitution?, _ error: NSError?) -> ()) {

        session.dataTask(with: plaidURL.institutions(id: id)) { data, response, error in
            if let json = self.decode(data: data) as? JSON {
                completion(response, PlaidInstitution(institution: json, source: .plaid), error as NSError?)
                return
            }
            completion(response, nil, error as NSError?)
        }.resume()
    }


    ///Logs in to a financial institutions
    /// - parameter institution: A *PlaidInstitution* object
    /// - parameter username: The user's username for the institution.
    /// - parameter password: The user's password for the institution.
    /// - parameter pin: The user's pin for the institution (if required)
    public func login(toInstitution institution: PlaidInstitution, username: String, password: String, pin: String? = nil, session: URLSession = URLSession.shared, completion: @escaping (_ response: URLResponse?, _ responseData: JSON?, _ error: Error?) -> ()) {

        let url = plaidURL.connect(clientID: clientIDToken, secret: secretToken, institution: institution, username: username, password: password)

        session.dataTask(with: url) { (data, response, error) in
            completion(response, self.decode(data: data) as? JSON, error)
        }.resume()
    }


    ///Submits the user's answer to the MFA Question / Code
    /// - parameter response: The user's answer to the given MFA Question / Code
    /// - parameter institution: A *PlaidInstitution* object
    /// - parameter accessToken: The institutions's access_Token received from logging in through *Plaid.com*
    public func submitMFAResponse(response: String, institution: PlaidInstitution, accessToken: String, session: URLSession = URLSession.shared, completion: @escaping (_ response: URLResponse?, _ responseData: JSON?, _ error: Error?) -> ()) {

        let urlRequest = plaidURL.mfaResponse(clientID: clientIDToken, secret: secretToken, institution: institution, accessToken: accessToken, response: response)

        session.dataTask(with: urlRequest) { (data, response, error) in
            completion(response, self.decode(data: data) as? JSON, error)
        }.resume()
    }


    ///Resubmits a user's credentials to a given Institution.
    /// - parameter accessToken: The institution's accessToken.
    /// - parameter username: The user's username for the institution.
    /// - parameter password: The user's password for the institution.
    /// - parameter pin: The user's pin for the institution (if required)
    public func patchInstitution(accessToken: String, username: String, password: String, pin: String? = nil, session: URLSession = URLSession.shared, completion: @escaping (_ response: URLResponse?, _ data: JSON?, _ error: Error?) -> ()) {
       
        let urlRequest = plaidURL.patchConnect(clientID: clientIDToken, secret: secretToken, accessToken: accessToken, username: username, password: password)

        session.dataTask(with: urlRequest) { (data, response, error) in
            completion(response, self.decode(data: data) as? JSON, error)
        }.resume()

    }
    

    ///Submits the user's answer to the MFA Question / Code
    /// - parameter response: The user's answer to the given MFA Question / Code
    /// - parameter accessToken: The institutions's access_Token received from logging in through *Plaid.com*
    public func patchSubmitMFAResponse(response: String, accessToken: String, session: URLSession = URLSession.shared, completion: @escaping (_ response: URLResponse?, _ data: JSON?, _ error: Error?) -> ()) {

        let urlRequest = plaidURL.patchMFAResponse(clientID: clientIDToken, secret: secretToken, accessToken: accessToken, response: response)

        session.dataTask(with: urlRequest) { (data, response, error) in
            completion(response, self.decode(data: data) as? JSON, error)
        }.resume()
    }


    ///Downloads account data and transactions for the given accessToken
    /// - parameter accessToken: The institution's accessToken
    /// - parameter accountID: If set to an account's id, will only download transactions for that account
    /// - parameter pending: If true, include pending transactions. defaults to false
    /// - parameter fromDate: If set, include only transaction after the given date
    /// - parameter toDate: If set, include onlt transactions before the given date
    public func downloadTransactions(accessToken: String, accountID: String? = nil, pending: Bool = false, fromDate: Date? = nil, toDate: Date? = nil, session: URLSession = URLSession.shared, completion: @escaping (_ response: URLResponse?, _ accounts: [PlaidAccount], _ plaidTransactions: [PlaidTransaction], _ error: AccountInfoRetrevalError?) -> ()) {

        let request = plaidURL.transactions(clientID: clientIDToken, secret: secretToken, accessToken: accessToken, accountID: accountID, pending: pending, fromDate: fromDate, toDate: toDate)

        session.dataTask(with: request) { (data, response, error) in
            print(response)

            let responseData = self.decode(data: data) as? JSON

            print(responseData)
            print(error)
            if let code = responseData?["code"] as? Int {
                switch code {

                case 1200...1209:
                    completion(response, [], [], .notConnected(accessToken:accessToken))

                default:
                    return
                }
            }

            if let transactions = responseData?["transactions"] as? [JSON], let accounts = responseData?["accounts"] as? [[String : Any]] {
                let plaidTransactions = transactions.map { PlaidTransaction(transaction: $0) }
                let plaidAccounts = accounts.flatMap { PlaidAccount(account: $0) }
                completion(response, plaidAccounts, plaidTransactions, nil)
            } else {
                completion(response, [], [], nil)
            }
        }.resume()
    }


    private func decode(data: Data?) -> Any? {
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
        
        dateFormatter.locale     = Locale(identifier: "en_US_PSIX")
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










