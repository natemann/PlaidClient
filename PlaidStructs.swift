//
//  PlaidStructs.swift
//  Budget
//
//  Created by Nathan Mann on 11/5/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

import Foundation

struct PlaidURL {
    
    static var baseURL = "https://tartan.plaid.com"
    
    static var institutions: String { return baseURL + "/institutions" }
    static var connect:      String { return baseURL + "/connect" }
    static var step:         String { return connect + "/step" }
}


struct PlaidInstitution {
    
    let credentials: [String : String]
    let has_mfa:     Bool
    let id:          String
    let name:        String
    let type:        String
    let mfa:         [String]
    let products:    [String]
    
    init(institution: [String : AnyObject]) {
        credentials = institution["credentials"]! as [String : String]
        has_mfa     = institution["has_mfa"]! as Int == 1 ? true : false
        id          = institution["id"]! as String
        name        = institution["name"]! as String
        type        = institution["type"]! as String
        mfa         = institution["mfa"]! as [String]
        products    = institution["products"]! as [String]
    }
}


struct PlaidAccount {
    
    let name    = String()
    let number  = String()
    let id      = String()
    let balance = NSDecimalNumber()
    let type    = String()
    
    init(account: [String : AnyObject]) {
        let meta           = account["meta"]! as [String: AnyObject]
        let accountBalance = account["balance"]! as [String: Double]
        
        name    = meta["name"]! as String
        number  = meta["number"]! as String
        id      = account["_id"]! as String
        type    = account["type"]! as String
        balance = NSDecimalNumber(double: accountBalance["current"]! as Double)
    }
}


struct PlaidTransaction {
    
    let account:    String
    let id:         String
    let pendingID:  String?
    let amount:     NSDecimalNumber
    let date:       NSDate
    let pending:    Bool
    let type:       [String : String]
    let categoryID: String
    
    let name:       String
    let address:    String?
    let city:       String?
    let state:      String?
    let zip:        String?
    let telephone:  String?
    let factual:    String?
    let fourSquare: String?
    let latitude:   String?
    let longitude:  String?

    
    init(transaction: [String : AnyObject]) {
        
        name       = transaction["name"]! as String
        account    = transaction["_account"]! as String
        id         = transaction["_id"]! as String
        pendingID  = transaction["_pendingTransaction"] as? String
        amount     = NSDecimalNumber.roundTwoDecimalPlaces(double: transaction["amount"]! as Double * -1)  //Plaid stores withdraws as positves and deposits as negatives
        date       = NSDateFormatter.dateFromString(transaction["date"]! as String)
        pending    = transaction["pending"]! as Bool
        type       = transaction["type"]! as [String : String]
        categoryID = transaction["category_id"]! as String
        
        if let meta = transaction["meta"] as? [String : AnyObject] {
            if let location = meta["location"] as? [String : AnyObject] {
                address    = location["address"] as? String
                city       = location["city"] as? String
                state      = location["state"] as? String
                zip        = location["zip"] as? String
                
                if let coordinates = location["coordinates"] as? [String : String] {
                    latitude   = coordinates["lat"]
                    longitude  = coordinates["lng"]
                }
            }
            if let contact = meta["contact"] as? [String : String] {
                telephone = contact["telephone"]
            }
            
            if let ids = meta["ids"] as? [String : String] {
                factual    = ids["factual"]
                fourSquare = ids["foursquare"]
            }
        }
    }
}







