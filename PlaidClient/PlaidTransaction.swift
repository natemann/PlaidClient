//
//  PlaidStructs.swift
//  Budget
//
//  Created by Nathan Mann on 11/5/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

import Foundation


public struct PlaidTransaction {
    
    public let account:    String
    public let id:         String
    public let pendingID:  String?
    public let amount:     NSDecimalNumber
    public let date:       Date
    public let pending:    Bool
    public let type:       [String : String]
    public let categoryID: String?
    public let category:   [String]?
    public let name:       String
    public let address:    String?
    public let city:       String?
    public let state:      String?
    public let zip:        String?
    public let latitude:   String?
    public let longitude:  String?
    
    public init(transaction: [String : Any]) {

        let meta        = transaction["meta"] as! [String : Any]
        let location    = meta["location"] as? [String : Any]
        let coordinates = location?["coordinates"] as? [String : Any]

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        account    = transaction["_account"]! as! String
        id         = transaction["_id"]! as! String
        pendingID  = transaction["_pendingTransaction"] as? String
        amount     = NSDecimalNumber(value: transaction["amount"] as! Double).roundTo(2).multiplying(by: NSDecimalNumber(value: -1.0)) //Plaid stores withdraws as positves and deposits as negatives
        date       = formatter.date(from: transaction["date"] as! String)!
        pending    = transaction["pending"]! as! Bool
        type       = transaction["type"]! as! [String : String]
        categoryID = transaction["category_id"] as? String
        category   = transaction["category"] as? [String]
        name       = transaction["name"]! as! String
        address    = location?["address"] as? String
        city       = location?["city"] as? String
        state      = location?["state"] as? String
        zip        = location?["zip"] as? String
        latitude   = coordinates?["lat"] as? String
        longitude  = coordinates?["lng"] as? String
    }
    
}



extension PlaidTransaction: Equatable {}

public func ==(lhs: PlaidTransaction, rhs: PlaidTransaction) -> Bool {
    return lhs.id == lhs.id
}



protocol Roundable {
    func roundTo(_ places: Int16) -> NSDecimalNumber
    
}




extension NSDecimalNumber: Roundable {

    func roundTo(_ places: Int16) -> NSDecimalNumber {
        return self.rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: .plain, scale: places, raiseOnExactness: true, raiseOnOverflow: true, raiseOnUnderflow: true,raiseOnDivideByZero: true))
    }
}

