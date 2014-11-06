//
//  PlaidStructs.swift
//  Budget
//
//  Created by Nathan Mann on 11/5/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

import Foundation

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
    
    let account:   String
    let id:        String
    let pendingID: String?
    let amount:    NSDecimalNumber
    let date:      NSDate
    let pending:   Bool
    
    init(transaction: [String : AnyObject]) {
        account   = transaction["_account"]! as String
        id        = transaction["_id"]! as String
        pendingID = transaction["_pendingTransaction"] as? String
        amount    = NSDecimalNumber.roundTwoDecimalPlaces(double: transaction["amount"]! as Double * -1)  //Plaid stores withdraws as positve numbers and deposits as negative numbers
        date      = NSDateFormatter.dateFromString(transaction["date"]! as String)
        pending   = transaction["pending"]! as Bool
        
    }
}







