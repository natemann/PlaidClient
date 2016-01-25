//
//  PlaidURLs.swift
//  InTheBlack
//
//  Created by Nathan Mann on 12/5/15.
//  Copyright © 2015 Nathan Mann. All rights reserved.
//


public struct PlaidURL {
    
    static let baseURL      = "https://tartan.plaid.com"
    static let institutions = baseURL + "/institutions"
    static let intuit       = institutions + "/longtail"
    static let connect      = baseURL + "/connect"
    static let step         = connect + "/step"
    
}