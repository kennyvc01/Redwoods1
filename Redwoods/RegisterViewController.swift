//
//  RegisterViewController.swift
//  Redwoods
//
//  Created by Ken Churchill on 3/23/16.
//  Copyright © 2016 Ken Churchill. All rights reserved.
//

import Alamofire

class RegisterViewController: UIViewController {

    
    //Outlet variables
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //indicator hidden by default
        self.indicator.hidden = true
        
        txtEmail.becomeFirstResponder()
        
    }

    //submit button.  on submit, performs POST to api/user/register using username and password parameters.  If result returns "username already exists", a series of alert controllers are used to have them register or re-enter their credentials.  Else, open FeedViewController.
    @IBAction func btnSubmit(sender: AnyObject) {
        
        
        
        let user = txtEmail.text as String!
        let password = txtPassword.text as String!
        let parameters = [
            "username": user,
            "password": password
        ]
        
        //first validation:  passwords match
        if self.txtPassword.text! != self.txtConfirmPassword.text! {
            //Alert if passwords don't match.
            let alertController = UIAlertController(title: "Password Error.", message: "The passwords you entered didn't match.", preferredStyle: .Alert)
            //Ok button on alert
            let OKAction = UIAlertAction(title: "Ok", style: .Default) { (action) in
            }
            alertController.addAction(OKAction)
            //present view controller
            self.presentViewController(alertController, animated: true) {
            }
        //second validation:  valid email.  Uses validateEmail function.
        } else if !validateEmail(txtEmail.text!) {
            
            //Alert if passwords don't match.
            let alertController = UIAlertController(title: "Invalid Email.", message: "Please enter a valid email address.", preferredStyle: .Alert)
            //Ok button on alert
            let OKAction = UIAlertAction(title: "Ok", style: .Default) { (action) in
            }
            alertController.addAction(OKAction)
            //present view controller
            self.presentViewController(alertController, animated: true) {
            }
        
        } else {
            //indicator animates until user is registered
            self.indicator.hidden = false
            self.indicator.startAnimating()
        
        //POST to api/user/register
        Alamofire.request(.POST, "https://redwoods-engine-test.herokuapp.com/api/users/register", parameters: parameters, encoding: .JSON)
                .responseJSON { response in
                    if let _ = response.result.error {//error in response
                        print("Connection error")
                        print(response)
                    } else { //No connection error
                       
                       //get JSON result
                        if let JSON = response.result.value {
                        let response = JSON as! NSDictionary
                        //get value of msg key from JSON string
                            if let msg = response.objectForKey("msg"){
                                
                                //stop indicator if error
                                self.indicator.hidden = true
                                self.indicator.stopAnimating()
                            
                                if msg as! String == "username already exists"{
                                    print("user already exists")
                                
                                    //Alert if user already exists.  Two buttons on the alert:  Ok and Reset Account
                                    let alertController = UIAlertController(title: "Username already exists", message: "Please enter a different username or reset your account.", preferredStyle: .Alert)
                                    //Ok button on alert
                                    let OKAction = UIAlertAction(title: "Ok", style: .Default) { (action) in
                                    }
                                    alertController.addAction(OKAction)
                                    //reset button on alert.  Reset button will present a popup form for user to enter email account
                                    let resetAction = UIAlertAction(title: "Reset Account", style: .Default) { (action) in
                                        //Reset popup form.  Two buttons: Reset and Cancel
                                        let resetController = UIAlertController(title: "Account Reset", message: "Enter your Email to reset your account.", preferredStyle: .Alert)
                                        //reset text field for email address
                                        resetController.addTextFieldWithConfigurationHandler { (textField) in
                                            textField.placeholder = "Email"
                                            textField.keyboardType = .EmailAddress
                                        
                                        }
                                        //reset action
                                        let resetAction = UIAlertAction(title: "Reset", style: .Default) { (_) in }
                                        resetController.addAction(resetAction)
                                        //cancel action
                                        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
                                        resetController.addAction(cancelAction)
                                        //preset reset view controller
                                        self.presentViewController(resetController, animated: true, completion: nil)
                                    }
                                    alertController.addAction(resetAction)
                                    //preset view controller
                                    self.presentViewController(alertController, animated: true) {
                                    }

                                }
                                
                            }
                            else {
                                
                                //hide indicator
                                self.indicator.hidden = true
                                self.indicator.stopAnimating()
                                
                                
                                print("successfully registered")
                                KeychainWrapper.setString(self.txtEmail.text!, forKey: "username")
                                KeychainWrapper.setString(self.txtPassword.text!, forKey: "password")
                                
                                self.performSegueWithIdentifier("Segue", sender: sender)
                                
                            }
                        }
                    }
                    
                }
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //validate email
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
    
}
