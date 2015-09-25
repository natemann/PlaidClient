//
//  PlaidStructs.swift
//  Budget
//
//  Created by Nathan Mann on 11/5/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

import Foundation
import UIKit

struct PlaidURL {
    
    static let baseURL      = "https://tartan.plaid.com"
    static let institutions = baseURL + "/institutions"
    static let intuit       = institutions + "/intuit"
    static let connect      = baseURL + "/connect"
    static let step         = connect + "/step"
    
}


public struct PlaidInstitution {
    
    public enum Source {
        case Plaid, Intuit
    }
    
    let credentials: [String : String]
    let has_mfa:     Bool
    let id:          String
    let name:        String
    let type:        String
    let mfa:         [String]?
    let products:    [String]
    let source:      Source
    
    //Attributes unique to Intuit Accounts
    
    let active:         Bool?
    let has_bad_mfa:    Bool?
    let intuit_blocked: Bool?
    let ranking:        Int?
    let url:            String?
    
    public init?(institution: [String : AnyObject]) {
        
        //Common Attributes between Plaid Accounts and Intuit Accounts
        //If these Attributes are not fullfilled, return nil
        
        guard let credentials = institution["credentials"] as? [String : String],
              let has_mfa     = institution["has_mfa"] as? Int,
              let name        = institution["name"] as? String,
              let products    = institution["products"] as? [String],
              let type        = institution["type"] as? String else {
                return nil
        }
        
        //Set common Attributes
        
        self.credentials = credentials
        self.has_mfa     = has_mfa == 1 ? true : false
        self.name        = name
        self.type        = type
        self.products    = products
        self.mfa         = institution["mfa"] as? [String] //This might be an optional field for intuit accounts.  All seem to have credentials though.
        
        //Determine Source by ID field
        
        let plaidID = institution["id"] as? String
        let intuitID = institution["intuit_id"] as? String
        
        switch (plaidID, intuitID) {
        
        case (.Some(let id), _):
            self.id     = id
            self.source = .Plaid
            
        case (_, .Some(let id)):
            self.id     = id
            self.source = .Intuit
            
        default:
            return nil
        }
        
        //Set Intuit Attributes
        
        self.active         = institution["active"] as? Int == 1 ? true : false
        self.has_bad_mfa    = institution["has_bad_mfa"] as? Int == 1 ? true : false
        self.intuit_blocked = institution["intuit_blocked"] as? Int == 1 ? true : false
        self.ranking        = institution["ranking"] as? Int
        self.url            = institution["url"] as? String
    }
}


extension PlaidInstitution: Equatable {}

public func ==(lhs: PlaidInstitution, rhs: PlaidInstitution) -> Bool {
    return lhs.id == rhs.id
}



//public struct IntuitInstitution {
//    
//    let active:         Bool
//    let credentials:    [String : String]
//    let has_bad_mfa:    Bool
//    let has_mfa:        Bool
//    let intuit_blocked: Bool
//    let intuit_id:      String
//    let mfa:            [String : String]?
//    let name:           String
//    let products:       [String]
//    let ranking:        Int
//    let type:           String
//    let url:            String
//    
//    init?(institution: [String : AnyObject]) {
//        guard let active = institution["active"] as? Int,
//              let credentials = institution["credentials"] as? [String : String],
//              let has_bad_mfa = institution["has_bad_mfa"] as? Int,
//              let has_mfa = institution["has_mfa"] as? Int ,
//              let intuit_blocked = institution["intuit_blocked"] as? Int,
//              let intuit_id = institution["intuit_id"] as? String,
//              let name = institution["name"] as? String,
//              let products = institution["products"] as? [String],
//              let ranking = institution["ranking"] as? Int,
//              let type = institution["type"] as? String,
//              let url = institution["url"] as? String
//            else {
//            return nil
//        }
//        
//        self.active         = active == 1 ? true : false
//        self.credentials    = credentials
//        self.has_bad_mfa    = has_bad_mfa == 1 ? true : false
//        self.has_mfa        = has_mfa == 1 ? true : false
//        self.intuit_blocked = intuit_blocked == 1 ? true : false
//        self.intuit_id      = intuit_id
//        self.mfa            = institution["mfa"] as? [String : String] ?? nil
//        self.name           = name
//        self.products       = products
//        self.ranking        = ranking
//        self.type           = type
//        self.url            = url
//    }
//}


public struct PlaidAccount {
    
    let name:     String
    let number:   String
    let id:       String
    let balance:  NSDecimalNumber
    let type:     String
    
    init(account: [String : AnyObject]) {
        let meta           = account["meta"]! as! [String: AnyObject]
        let accountBalance = account["balance"]! as! [String: AnyObject]
        
        name    = meta["name"]! as! String
        number  = meta["number"]! as! String
        id      = account["_id"]! as! String
        type    = account["type"]! as! String
        balance = account["type"]! as! NSString == "credit" ?  NSDecimalNumber(double: accountBalance["current"]! as! Double) * -1 : NSDecimalNumber(double: accountBalance["current"]! as! Double)
    }
}


extension PlaidAccount: Equatable {}

public func ==(lhs: PlaidAccount, rhs: PlaidAccount) -> Bool {
    return lhs.id == lhs.id
}





public struct PlaidTransaction {
    
    public var account:    String
    public var id:         String
    public var pendingID:  String?
    public var amount:     NSDecimalNumber
    public var date:       NSDate
    public var pending:    Bool
    public var type:       [String : String]
    public var categoryID: String?
    
    public var name:       String
    public var address:    String?
    public var city:       String?
    public var state:      String?
    public var zip:        String?
    public var telephone:  String?
    public var factual:    String?
    public var fourSquare: String?
    public var latitude:   String?
    public var longitude:  String?
    
    
    public init(transaction: [String : AnyObject]) {

        let meta        = transaction["meta"] as! [String : AnyObject]
        let location    = meta["location"] as? [String : AnyObject]
        let coordinates = location?["coordinates"] as? [String : AnyObject]
        let ids         = meta["ids"] as? [String : AnyObject]
        let contact     = meta["contact"] as? [String : AnyObject]

        name       = transaction["name"]! as! String
        account    = transaction["_account"]! as! String
        id         = transaction["_id"]! as! String
        pendingID  = transaction["_pendingTransaction"] as? String
        amount     = NSDecimalNumber(double: transaction["amount"] as! Double).roundTo(2) * -1 //Plaid stores withdraws as positves and deposits as negatives
        date       = NSDateFormatter.dateFromString(transaction["date"]! as! String)
        pending    = transaction["pending"]! as! Bool
        type       = transaction["type"]! as! [String : String]
        categoryID = transaction["category_id"] as? String
        address    = location?["address"] as? String
        city       = location?["city"] as? String
        state      = location?["state"] as? String
        zip        = location?["zip"] as? String
        latitude   = coordinates?["lat"] as? String
        longitude  = coordinates?["lng"] as? String
        telephone  = contact?["telephone"] as? String
        factual    = ids?["factual"] as? String
        fourSquare = ids?["foursquare"] as? String

    }
    
}


extension PlaidTransaction: Equatable {}

public func ==(lhs: PlaidTransaction, rhs: PlaidTransaction) -> Bool {
    return lhs.id == lhs.id
}





protocol Roundable {
    
    func roundTo(places: Int16) -> NSDecimalNumber
    
}


extension Roundable where Self: NSDecimalNumber {
    
    func roundTo(places: Int16) -> NSDecimalNumber {
        return self.decimalNumberByRoundingAccordingToBehavior(NSDecimalNumberHandler(roundingMode: .RoundPlain, scale: places, raiseOnExactness: true, raiseOnOverflow: true, raiseOnUnderflow: true,raiseOnDivideByZero: true))
    }
    
}


extension NSDecimalNumber: Roundable { }

