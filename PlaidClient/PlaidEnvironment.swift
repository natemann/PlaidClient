//
//  PlaidEnvironment.swift
//  Pods
//
//  Created by Ji,Jason on 8/23/16.
//
//

import Foundation

public enum PlaidEnvironment {
    case Dev, Production
    
    public var baseURL: String {
        get {
            return self == .Dev ? "https://tartan.plaid.com" : "https://api.plaid.com"
        }
    }
    public var institutionsURL: String {
        get {
            return baseURL + "/institutions"
        }
    }
    public var intuitURL: String {
        get {
            return baseURL + "/longtail"
        }
    }
    public var connectURL: String {
        get {
            return baseURL + "/connect"
        }
    }
    public var stepURL: String {
        get {
            return baseURL + "/step"
        }
    }
}