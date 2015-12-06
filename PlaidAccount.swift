//
//  PlaidAccount.swift
//  InTheBlack
//
//  Created by Nathan Mann on 12/5/15.
//  Copyright © 2015 Nathan Mann. All rights reserved.
//

import UIKit

public struct PlaidAccount {
    
    ///The name of the account.
    let name: String?
    
    ///The official name of the account.
    let officialName: String?
    
    ///The account sub-type.
    let subType: String?
    
    ///The account type.
    let type: String?
    
    ///The account number.
    let number: String?
    
    ///The Plaid ID of the account.
    let id: String?
    
    ///The item string of the account.  Currently not sure what this is used for.
    let item: String?
    
    ///The user ID of the account.
    let user: String?
    
    ///The current account balance.  This balance only includes cleared transactions.
    let currentBalance: NSDecimalNumber?
    
    ///The available account balance.  The balance includes any pending transactions.
    let availableBalance: NSDecimalNumber?
    
    ///The type of the account.
    let institutionType: String?
    
    //The account limit.  I believe this is only relevent to credit accounts.
    let limit: NSDecimalNumber?
    
    
    ///- institution: JSON formatted data of the account fetched from *Plaid*
    ///- source: Specifies whether the account was pulled directed from *Plaid* or *Intuit*
    init?(account: [String : AnyObject]) {
        guard let meta = account["meta"] as? [String: AnyObject],
            let balance = account["balance"] as? [String: AnyObject]
            else {
                return nil
        }
        
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
            self.currentBalance = type == "credit" ?  NSDecimalNumber(double: current) * -1 : NSDecimalNumber(double: current)
        }
        else {
            self.currentBalance = nil
        }
        
        if let available = balance["availabe"] as? Double {
            self.availableBalance = type == "credit" ?  NSDecimalNumber(double: available) * -1 : NSDecimalNumber(double: available)
        }
        else {
            self.availableBalance = nil
        }
        
        if let limit = meta["limit"] as? Double {
            self.limit = NSDecimalNumber(double: limit)
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
