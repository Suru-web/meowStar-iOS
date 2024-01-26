//
//  LoginVC.swift
//  MeowStar
//
//  Created by Suraj Meharwade on 24/01/24.
//

import UIKit
import Firebase
import FirebaseCore
import GoogleSignIn

class LoginVC: UIViewController, UITextFieldDelegate {

    
    @IBOutlet var emailInputOutlet: UITextField!
    @IBOutlet var passwordInputOutlet: UITextField!
    @IBOutlet var googleLoginOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailInputOutlet.designTextField()
        passwordInputOutlet.designTextField()
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
        emailInputOutlet.delegate = self
        passwordInputOutlet.delegate = self
        
        if (Auth.auth().currentUser != nil){
            performSegue(withIdentifier: "goToMainPageFromSignIn", sender: nil)
        }

    }
    @objc func handleSwipeDown() {
            // Dismiss the keyboard
            view.endEditing(true)
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // Move to the next text field or dismiss the keyboard
            if textField == emailInputOutlet {
                passwordInputOutlet.becomeFirstResponder()
            } else if textField == passwordInputOutlet {
                textField.resignFirstResponder()
                // Add any additional logic you want to perform when the password field is returned
            }

            return true
        }
    
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "ToSignUp", sender: nil)
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        guard let email = emailInputOutlet.text, !email.isEmpty else {
            showAlertBox(title: "Email is empty", message: "Please enter the credentials properly")
            return
        }
        guard let password = passwordInputOutlet.text, !password.isEmpty else {
            showAlertBox(title: "Password is empty", message: "Please enter the credentials properly")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { firebaseResult, error in
            if let _ = error{
                self.showAlertBox(title: "Check Details", message: "Invalid login credentials")
                return
            }
            else{
                self.performSegue(withIdentifier: "goToMainPageFromSignIn", sender: nil)
            }
            
        }
    }
    
    @IBAction func googleSignInButton(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) {  result, error in
          guard error == nil else {
              return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
              return
          }

          let credentials = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credentials){result, error in
                if(error == nil){
                    print("Login successfull")
                    self.performSegue(withIdentifier: "goToMainPageFromSignIn", sender: nil)
                }
                else{
                    print("Login could not be done")
                }
            }
        }
    }
    
    
}
