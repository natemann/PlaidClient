//
//  File.swift
//  Budget
//
//  Created by Nate on 8/12/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

import Foundation
import Alamofire

struct PlaidInstitution {
    let credentials = [String : String]()
    let has_mfa     = Bool()
    let id          = String()
    let name        = String()
    let type        = String()
    let mfa         = [String]()
    let products    = [String]()
}



class PlaidSwiftClient {

    //    MARK: Constants & Variables
    
    let plaidBaseURL = "https://tartan.plaid.com"
    let clientID     = "537263a2aabb5764473d9b0d"
    let secret       = "E_meTIsez7jdUF6WmhiEcj"
    
    
    
    //    MARK: Class Functions
    
    class func plaidInstitutions(completionHandler: (response: NSHTTPURLResponse?, institutions: [PlaidInstitution], error: NSError?) -> ()) {
            var plaidInstitutions = [PlaidInstitution]()
            
            Alamofire.request(.GET, "https://tartan.plaid.com/institutions")
                     .responseJSON {(request, response, data, error) -> Void in
                                        for institution in data as [AnyObject]{
                                            if let institutionDictionary = institution as? [String: AnyObject] {
                                                let plaidInstitution = PlaidInstitution(credentials: institutionDictionary["credentials"]! as [String : String],
                                                                                            has_mfa: (institutionDictionary["has_mfa"]! as Int == 1) ? true : false,
                                                                                                 id: institutionDictionary["id"]! as String,
                                                                                               name: institutionDictionary["name"]! as String,
                                                                                               type: institutionDictionary["type"]! as String,
                                                                                                mfa: institutionDictionary["mfa"]! as [String],
                                                                                           products: institutionDictionary["products"]! as [String])
                                        
                                                plaidInstitutions.append(plaidInstitution)
                                            }
                                        }
                                    completionHandler(response: response, institutions: plaidInstitutions, error: error)
                                  }
        }
    
    
    
    class func loginToInstitution( institution: PlaidInstitution,
                                      username: String,
                                      password: String,
                                           pin: String,
                                         email: String,
                             completionHandler: (response: NSHTTPURLResponse, responseData: [String: AnyObject]) -> ()) {
        let credentials = ["username" : username,
                           "password" : password,
                                "pin" : pin]
        
        let parameters: [String: AnyObject] = ["client_id" : "537263a2aabb5764473d9b0d",
                                                  "secret" : "E_meTIsez7jdUF6WmhiEcj",
                                             "credentials" : credentials,
                                                    "type" : institution.type,
                                                   "email" : email]
        
        Alamofire.request(.POST, "https://tartan.plaid.com/connect", parameters: parameters, encoding: .JSON)
                 .responseJSON { (request, response, data, error) -> Void in
                                    let responseObject = data! as [String: AnyObject]
                                    completionHandler(response: response!, responseData: responseObject)
                               }
        
    }
    
    
    
    class func submitMFAResponse(response: String,
                              institution: PlaidInstitution,
                              accessToken: String,
                        completionHandler: (response: NSHTTPURLResponse, responseData: [String: AnyObject]) -> ()) {
                            
        let parameters: [String: AnyObject] = ["client_id" : "537263a2aabb5764473d9b0d",
                                                  "secret" : "E_meTIsez7jdUF6WmhiEcj",
                                                     "mfa" : response,
                                            "access_token" : accessToken,
                                                    "type" : institution.type]
                            
        Alamofire.request(.POST, "https://tartan.plaid.com/connect/step", parameters: parameters, encoding: .JSON)
            .responseJSON { (request, response, data, error) -> Void in
                                let responseObject = data! as [String: AnyObject]
                                completionHandler(response: response!, responseData: responseObject)
                          }
    }
}













