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
        let url = baseURL + "/longtail?client_id=\(clientID)&secret=\(secret)&count=\(String(count))&offset=\(String(skip))"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        return request
    }


    func connect(clientID: String, secret: String, institution: PlaidInstitution, username: String, password: String, pin: String? = nil) -> URLRequest {
        var url = baseURL + "/connect?client_id=\(clientID)&secret=\(secret)&type=\(institution.type)&username=\(username)&password=\(password)"
        if let pin = pin {
            url += "&pin=\(pin)"
        }
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        return request
    }


    func step(clientID: String, secret: String, institution: PlaidInstitution, username: String, password: String, pin: String? = nil, response) -> URLRequest
//    var step: URL { return try! connect.appendingPathComponent("/step") }

}
