//
//  PlaidAccount.swift
//  InTheBlack
//
//  Created by Nathan Mann on 12/5/15.
//  Copyright © 2015 Nathan Mann. All rights reserved.
//

import Foundation

public struct PlaidAccount {
    
    ///The name of the account.
    public let name: String?
    
    ///The official name of the account.
    public let officialName: String?
    
    ///The account sub-type.
    public let subType: String?
    
    ///The account type.
    public let type: String?
    
    ///The account number.
    public let number: String?
    
    ///The Plaid ID of the account.
    public let id: String?
    
    ///The item string of the account.  Currently not sure what this is used for.
    public let item: String?
    
    ///The user ID of the account.
    public let user: String?
    
    ///The current account balance.  This balance only includes cleared transactions.
    public let currentBalance: NSDecimalNumber?
    
    ///The available account balance.  The balance includes any pending transactions.
    public let availableBalance: NSDecimalNumber?
    
    ///The type of the account.
    public let institutionType: String?
    
    ///The account limit. I believe this is only relevent to credit accounts.
    public let limit: NSDecimalNumber?
    

    public init?(account: [String : Any]) {
        guard let meta = account["meta"] as? [String: Any],
              let balance = account["balance"] as? [String: Any] else { return nil }
        
        self.name             = meta["name"] as? String
        self.officialName     = account["official_name"] as? String
        self.type             = account["type"] as? String
        self.number           = meta["number"] as? String
        self.id               = account["_id"] as? String
        self.item             = account["_item"] as? String
        self.user             = account["_user"] as? String
        self.institutionType  = account["institution_type"] as? String
        self.subType          = account["subType"] as? String
        
        if let current = balance["current"] as? Double {
            self.currentBalance = type == "credit" ?  NSDecimalNumber(value: current).multiplying(by: NSDecimalNumber(value: -1.0)) : NSDecimalNumber(value: current)
        }
        else {
            self.currentBalance = nil
        }
        
        if let available = balance["available"] as? Double {
            self.availableBalance = type == "credit" ?  NSDecimalNumber(value: available).multiplying(by: NSDecimalNumber(value: -1.0)) : NSDecimalNumber(value: available)
        }
        else {
            self.availableBalance = nil
        }
        
        if let limit = meta["limit"] as? Double {
            self.limit = NSDecimalNumber(value: limit)
        }
        else {
            self.limit = nil
        }
    }
    
}


extension PlaidAccount: Equatable {}

public func ==(lhs: PlaidAccount, rhs: PlaidAccount) -> Bool {
    return lhs.id == lhs.id
}
