//
//  SignUpVC.swift
//  MeowStar
//
//  Created by Suraj Meharwade on 25/01/24.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseCore
import FirebaseAuth

class SignUpVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var pass1Outlet: UITextField!
    @IBOutlet var emailOutlet: UITextField!
    @IBOutlet var pass2Outlet: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        pass1Outlet.designTextField()
        emailOutlet.designTextField()
        pass2Outlet.designTextField()
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
        
        emailOutlet.delegate = self
        pass1Outlet.delegate = self
        pass2Outlet.delegate = self
        
    }
    @objc func handleSwipeDown() {
            // Dismiss the keyboard
            view.endEditing(true)
        }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // Move to the next text field or dismiss the keyboard
            if textField == emailOutlet {
                pass1Outlet.becomeFirstResponder()
            } else if textField == pass1Outlet {
                pass2Outlet.becomeFirstResponder()
                // Add any additional logic you want to perform when the password field is returned
            }
            else if textField == pass2Outlet{
                textField.resignFirstResponder()
            }

            return true
        }
    
    
    
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        guard let email = emailOutlet.text, !email.isEmpty else {
            showAlertBox(title: "Email is empty", message: "Please enter the email")
            return}
        guard let passOne = pass1Outlet.text,!passOne.isEmpty else {
            showAlertBox(title: "Password is empty", message: "Please enter the password")
            return}
        guard let passTwo = pass2Outlet.text, !passTwo.isEmpty else {
            showAlertBox(title: "Password is empty", message: "Please enter the password")
            return}
        
        if(passOne == passTwo){
            Auth.auth().createUser(withEmail: email, password: passOne) { firebaseResult, error in
                if let _ = error{
                    self.showAlertBox(title: "Sign Up error", message: "Please try again now, or after some time")
                    print(error!)
                }
                else{
                    self.performSegue(withIdentifier: "goToProfilePage", sender: nil)
                }
            }
        }
        else{
            showAlertBox(title: "Password error", message: "Passwords do not match, please re-check")
        }
        
    }
    
    @IBAction func googleSignUPButtonPressed(_ sender: UIButton) {
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
            Auth.auth().signIn(with: credentials) { authResult, error in
                if let error = error {
                    print("Error signing in with Google: \(error.localizedDescription)")
                    return
                }
                
                print("Login successful")
                checkIfUserExists { userExists in
                    if userExists {
                        self.performSegue(withIdentifier: "goToHomePageDirectly", sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "goToProfilePage", sender: nil)
                    }
                }
            }
        }
        
        func checkIfUserExists(completion: @escaping (Bool) -> Void) {
            guard let currentUserID = Auth.auth().currentUser?.uid else {
                completion(false)
                return
            }
            
            let ref = Database.database().reference().child("users").child("user").child(currentUserID)
            ref.observeSingleEvent(of: .value) { snapshot in
                completion(snapshot.exists())
            }
        }
    } 
    
    
    @IBAction func signInButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
