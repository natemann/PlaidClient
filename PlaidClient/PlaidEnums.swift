//
//  PlaidHTTPResponseCodes.swift
//  Budget
//
//  Created by Nate on 8/15/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

import UIKit

public enum ResponseCode: Int {

    case success       = 200
    case mfaRequired   = 201
    case badRequest    = 400
    case unauthorized  = 401
    case requestFailed = 402
    case cannotBeFound = 404

}

public enum MFAType: String {

    case Questions = "questions"
    case Device    = "device"
    case List      = "list"
}

