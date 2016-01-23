# Plaid-Swift-Client

Swift client to interact with Plaid.com.  These classes are a subclas of Alamofire.  You need to add Alamofire as a part of your project for these methods to work.  Search GitHub for Alamofire.

###Prerequisites

Nearly all methods require a Plaid ClientID and a Plaid Secret.  You can sign up to receive these at http://plaid.com

###Methods

####Retrieve All Institutions

```Swift
static func plaidInstitutions(completionHandler: (response: NSHTTPURLResponse?, institutions: [PlaidInstitution], error: NSError?) -> ())
```

####Retrieve Institution By Plaid ID
```Swift
static func plaidInstitutionWithID(id: String, callBack: (response: NSHTTPURLResponse?, institution: PlaidInstitution, error: NSError?) -> ())
```

####Log Into Institution
```Swift
static func loginToInstitution(institution: PlaidInstitution, username: String, password: String, pin: String, email: String, callBack: (response: NSHTTPURLResponse, responseData: [String: AnyObject]) -> ())
```

'pin' is optional.  If the institution does not require one, set to nil.  userAccounts will indicate if an MFA authentication is required.  Default MFA is questions

####MFA Response
Submit the user's MFA response using

```Swift
static func submitMFAResponse(response: String, institution: PlaidInstitution, accessToken: String, callBack: (response: NSHTTPURLResponse, responseData: [String: AnyObject]) -> ()) 
```

userAccounts will either return another MFA response or the list of user accounts

####Download User Account Details And Transactions
```Swift
static func downloadAccountData(#accessToken: String, account: String, pending: Bool, fromDate: NSDate?, toDate: NSDate?, callBack: (response: NSHTTPURLResponse, account: PlaidAccount?, plaidTransactions: [PlaidTransaction]?, error: NSError?) -> ())
```

isPending, accountID, transactionID, fromDate, toDate are all optional fields.  Set to nil if not needed.  If accountID is not set, all transactions for the particular institution will be downloaded

####Patch Institution Log In Details
If user changes log in credentials, update using

```Swift
static func patchInstitution(accessToken: String, username: String, password: String, pin: String, callBack: (response: NSHTTPURLResponse, data: [String : AnyObject]) -> ())
```
```Swift
static func patchSubmitMFAResponse(response: String, accessToken: String, username: String, password: String, callBack: (response: NSHTTPURLResponse, data: [String : AnyObject]) -> ())
```
