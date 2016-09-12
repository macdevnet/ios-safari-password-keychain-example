//
//  ViewController.swift
//  safaripasswordexample
//
//  Created by Scotty on 11/09/2016.
//  Copyright © 2016 Streambyte Limited. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
}



/// This extension handle reading credentials from the Safari Keychain
extension ViewController {

    @IBAction func getSafariCredentialsButtonPressed(_ sender: AnyObject) {
        checkSafariCredentials { (userName, password) in

            if userName != nil {
                self.userNameField.text = userName
            }
            
            if password != nil {
                self.passwordField.text = password
            }
        }
    }
    
    
    fileprivate func checkSafariCredentials(completion: @escaping (_: String?, _:String?) -> Void) {
        
        let domain: CFString = "streambyte.com" as CFString
        
        SecRequestSharedWebCredential(domain, .none, {
            (credentials: CFArray?, error: CFError?) -> Void in
            
            // If there are no matching web credentials this will also be returned as an error
            if let error = error {
                print("error: \(error)")
                completion(nil,nil)
                return
            }
            
            var userName: String?
            var password: String?
            
            // The selected webcredential is returned as an array of dictionary
            // however there will never be more than one
            if CFArrayGetCount(credentials) > 0 {
                let unsafeCred = CFArrayGetValueAtIndex(credentials, 0)
                let credential: CFDictionary = unsafeBitCast(unsafeCred, to: CFDictionary.self)
                let dict: Dictionary<String, String> = credential as! Dictionary<String, String>
                
                // The credential details in the dictionary can be accessed using the
                // kSecAttrAccount and kSecSharedPassword constants
                userName = dict[kSecAttrAccount as String]
                password = dict[kSecSharedPassword as String]
            }
            
            DispatchQueue.main.async {
                completion(userName,password)
            }
        });
    }
}



/// This extenion handles updating and deleting credetnials in the Safari keychain
extension ViewController {
    
    @IBAction func saveSafariCredentialsButtonPressed(_ sender: AnyObject) {
        guard let userName = userNameField.text, let password = passwordField.text else { return }
        saveSafariCredentials(userName: userName, password: password)
    }

    
    fileprivate func saveSafariCredentials(userName: String, password: String) {
        
        let domain: CFString = "streambyte.com" as CFString
        
        SecAddSharedWebCredential(domain,
                                  userName as CFString,
                                  password.characters.count > 0 ? password as CFString : .none,
                                  {(error: CFError?) -> Void in
                                    print("error: \(error)")
            }
        );
    }
}



/// This section handle using the Safari keychain to generate passwords
extension ViewController {
    
    @IBAction func generatePasswordButtonPressed(_ sender: AnyObject) {
        if let password = SecCreateSharedWebCredentialPassword() {
            passwordField.text = password as String
        }
    }
}
