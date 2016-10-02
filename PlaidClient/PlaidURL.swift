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
        var request = URLRequest(url: URL(string: baseURL + "/institutions/longtail")!)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        let bodyObject = ["client_id" : clientID,
                          "secret"    : secret,
                          "count"     : "\(count)",
                          "offset"    : "\(skip)"]

        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        return request
    }


    func connect(clientID: String, secret: String, institution: PlaidInstitution, username: String, password: String, pin: String? = nil) -> URLRequest {
        var request = URLRequest(url: URL(string: baseURL + "/connect")!)
        request.httpMethod = "POST"
        let bodyObject = ["client_id" : clientID,
                          "secret"    : secret,
                          "type"      : institution.type,
                          "username"  : username,
                          "password"  : password,
                          "pin"       : pin ?? "0"]

        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        return request
    }


    func step(clientID: String, secret: String, institution: PlaidInstitution, username: String, password: String, pin: String? = nil) -> URLRequest {
        var request = connect(clientID: clientID, secret: secret, institution: institution, username: username, password: password)
        request.url = request.url?.appendingPathComponent("/step")
        return request
    }


    func mfaResponse(clientID: String, secret: String, institution: PlaidInstitution, accessToken: String, response: String) -> URLRequest {
        var request = URLRequest(url: URL(string: baseURL + "/connect/step")!)
        request.httpMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        let bodyObject = ["client_id"    : "test_id",
                          "secret"       : "test_secret",
                          "mfa"          : response,
                          "type"         : institution.type,
                          "access_token" : accessToken]

        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        return request
    }

}



