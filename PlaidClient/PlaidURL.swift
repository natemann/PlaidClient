//
//  PlaidURL.swift
//  PlaidClient
//
//  Created by Nathan Mann on 8/14/16.
//  Copyright © 2016 Nathan Mann. All rights reserved.
//

import Foundation


internal struct PlaidURL {

    init(environment: Environment) {
        switch environment {
        case .development:
            baseURL = "https://tartan.plaid.com"
        case .production:
            baseURL = "https://api.plaid.com"
        }
    }

    let baseURL: String

    func institutions(id: String? = nil) -> URLRequest {
        var url = baseURL + "/institutions"
        if let id = id {
            url += "/\(id)"
        }
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        return request
    }


    func intuit(clientID: String, secret: String, count: Int, skip: Int) -> URLRequest {

        let bodyObject = ["client_id" : clientID,
                          "secret"    : secret,
                          "count"     : "\(count)",
                          "offset"    : "\(skip)"]

        return URLRequest("POST", url: URL(string: baseURL + "/institutions/longtail")!, body: bodyObject)
    }


    func connect(clientID: String, secret: String, institution: PlaidInstitution, username: String, password: String, pin: String? = nil) -> URLRequest {

        let bodyObject = ["client_id" : clientID,
                          "secret"    : secret,
                          "type"      : institution.type,
                          "username"  : username,
                          "password"  : password,
                          "pin"       : pin ?? "0"]

        return URLRequest("POST", url: URL(string: baseURL + "/connect")!, body: bodyObject)
    }


    func step(clientID: String, secret: String, institution: PlaidInstitution, username: String, password: String, pin: String? = nil) -> URLRequest {
        var request = connect(clientID: clientID, secret: secret, institution: institution, username: username, password: password)
        request.url = request.url?.appendingPathComponent("/step")
        return request
    }


    func mfaResponse(clientID: String, secret: String, institution: PlaidInstitution, accessToken: String, response: String) -> URLRequest {

        let bodyObject = ["client_id"    : "test_id",
                          "secret"       : "test_secret",
                          "mfa"          : response,
                          "type"         : institution.type,
                          "access_token" : accessToken]

        return URLRequest("POST", url: URL(string: baseURL + "/connect/step")!, body: bodyObject)
    }


    func patchConnect(clientID: String, secret: String, accessToken: String, username: String, password: String, pin: String? = nil) -> URLRequest {

        let bodyObject = ["client_id"    : clientID,
                          "secret"       : secret,
                          "access_token" : accessToken,
                          "username"     : username,
                          "password"     : password,
                          "pin"          : pin ?? "0"]

        return URLRequest("PATCH", url: URL(string: baseURL + "/connect")!, body: bodyObject)

    }


    func patchMFAResponse(clientID: String, secret: String, accessToken: String, response: String) -> URLRequest {

        let bodyObject = ["client_id"    : "test_id",
                          "secret"       : "test_secret",
                          "mfa"          : response,
                          "access_token" : accessToken]

        return URLRequest("PATCH", url: URL(string: baseURL + "/connect/step")!, body: bodyObject)
    }


    func transactions(clientID: String, secret: String, accessToken: String, accountID: String?, pending: Bool?, fromDate: Date?, toDate: Date?) -> URLRequest {

        var options: [String : Any] = [:]

        if let accountID = accountID {
            options["account"] = accountID
        }

        if let pending = pending {
            options["pending"] = pending
        }

        if let fromDate = fromDate {
            options["gte"] = DateFormatter.plaidDate(fromDate)
        }

        if let toDate = toDate {
            options["lte"] = DateFormatter.plaidDate(toDate)
        }

        let bodyObject: [String: Any] = ["client_id"    : clientID,
                                         "secret"       : secret,
                                         "access_token" : accessToken,
                                         "options"      : options]

        return URLRequest("POST", url: URL(string: baseURL + "/connect/get")!, body: bodyObject)
    }
}




fileprivate extension URLRequest {

    init(_ method: String, url: URL, body: [String : Any]) {
        self.init(url: url)
        self.httpMethod = method
        self.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        self.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
    }

}


