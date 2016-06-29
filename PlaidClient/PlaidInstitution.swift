//
//  PlaidInstitution.swift
//  InTheBlack
//
//  Created by Nathan Mann on 12/5/15.
//  Copyright © 2015 Nathan Mann. All rights reserved.
//

public struct PlaidInstitution {
    
    ///Identifies where the institution was fetched from, either **Plaid** or **Intuit**.  Plaid supplies Intuit data through longtail access.
    public enum Source {
        case plaid, intuit
    }
    
    ///The source of the data, either **Plaid** or **Intuit**.  Plaid supplies Intuit data through longtail access.
    public let source: Source
    
    ///Institution specific description of *username* and *password*.
    public let credentials: [String : String]
    
    ///Boolean to determine if institution requires *Multi-Factor Authentication*.
    public let has_mfa: Bool
    
    ///The name of the institution.
    public let name: String
    
    ///For **Plaid** accounts, the *type* is a short-hand description of the institution.
    ///For **Intuit** accounts, the *type* is a unique identifier.
    public let type: String
    
    ///An array of *Multi-Factor Authentication* methods.
    public let mfa: [String]?
    
    ///The type of connections allowed through *Plaid.com*.
    public let products: [String]
    
    
    ///The accessToken for the institution.  The field is created once the user has logged into the institution
    public var accessToken: String?
    
    /****** Properties Unique to Plaid Accounts ********/
    
    ///*Plaid* institution ID.  Only available for institutions directly from *Plaid*.
    public let id: String?
    
    /******* Properties Unique to Intuit Accounts *********/
     
    ///The institution's website.  Only available for *Intuit* acounts.
    public let url: String?
    
    
    ///- institution: JSON formatted data of the institution fetched from *Plaid*
    ///- source: Specifies whether the institution was pulled directed from *Plaid* or *Intuit*
    public init?(institution: [String : AnyObject], source: Source) {
        print(institution)
        //Common attributes between Plaid accounts and Intuit accounts
        //If these attributes are not fullfilled, return nil
        
        guard let credentials = institution["credentials"] as? [String : String],
            let has_mfa     = institution["has_mfa"] as? Int,
            let name        = institution["name"] as? String,
            let products    = institution["products"] as? [String],
            let type        = institution["type"] as? String
            else {
                return nil
        }
        
        self.source      = source
        self.credentials = credentials
        self.has_mfa     = has_mfa == 1 ? true : false
        self.name        = name
        self.products    = products
        self.type        = type
        
        self.mfa         = institution["mfa"] as? [String] //This might be an optional field for intuit accounts.  All seem to have credentials though.
        self.url         = institution["url"] as? String
        
        switch source {
        case .intuit:
            self.id = institution["type"] as? String
        case .plaid:
            self.id = institution["id"] as? String
        }
        
    }
}





extension PlaidInstitution: Equatable {}

public func ==(lhs: PlaidInstitution, rhs: PlaidInstitution) -> Bool {
    return lhs.id == rhs.id
}



