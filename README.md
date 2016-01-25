# Plaid-Swift-Client

Swift client to interact with Plaid.com.  
###Prerequisites

Nearly all methods require a Plaid ClientID and a Plaid Secret.  You can sign up to receive these at [Plaid](http://plaid.com)

###Installation

####Cocoapods

Add the following to your `Podfile`:

```pod 'PlaidClient', :git => 'https://github.com/natemann/PlaidClient.git'```

###Methods

First, initialize an instance of `PlaidClient` with the unique *clientID* and *secretToken* you get after signing up at[Plaid](http://plaid.com)

####Retrieve Institutions
You can retrieve institutions directly through [Plaid](http://plaid.com), or [Plaid](http://plaid.com) lets you also connect to institutions through *Intuit*

Retrieve **Plaid** institutions

```Swift
func plaidInstitutions(completionHandler: (response: NSHTTPURLResponse?, institutions: [PlaidInstitution]) -> ())
```
Retreive **Intuit** institutions

```Swift
func intuitInstitutions(count: Int, skip: Int, completionHandler: (response: NSHTTPURLResponse?, institutions: [PlaidInstitution]) -> ())
```

####Retrieve Institution By Plaid ID
```Swift
func plaidInstitutionWithID(id: String, callBack: (response: NSHTTPURLResponse?, institution: PlaidInstitution, error: NSError?) -> ())
```

####Log Into Institution
```Swift
func loginToInstitution(institution: PlaidInstitution, username: String, password: String, pin: String, email: String, callBack: (response: NSHTTPURLResponse, responseData: [String: AnyObject]) -> ())
```

'pin' is optional.  If the institution does not require one, set to nil.  userAccounts will indicate if an MFA authentication is required.  Default MFA is questions

####MFA Response
Submit the user's MFA response using

```Swift
func submitMFAResponse(response: String, institution: PlaidInstitution, accessToken: String, callBack: (response: NSHTTPURLResponse, responseData: [String: AnyObject]) -> ()) 
```

userAccounts will either return another MFA response or the list of user accounts

####Download User Account Details And Transactions
```Swift
func downloadAccountData(#accessToken: String, account: String, pending: Bool, fromDate: NSDate?, toDate: NSDate?, callBack: (response: NSHTTPURLResponse, account: PlaidAccount?, plaidTransactions: [PlaidTransaction]?, error: NSError?) -> ())
```

isPending, accountID, transactionID, fromDate, toDate are all optional fields.  Set to nil if not needed.  If accountID is not set, all transactions for the particular institution will be downloaded

####Patch Institution Log In Details
If user changes log in credentials, update using

```Swift
func patchInstitution(accessToken: String, username: String, password: String, pin: String, callBack: (response: NSHTTPURLResponse, data: [String : AnyObject]) -> ())
```
```Swift
func patchSubmitMFAResponse(response: String, accessToken: String, username: String, password: String, callBack: (response: NSHTTPURLResponse, data: [String : AnyObject]) -> ())
```
