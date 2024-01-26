//
//  HomePageViewController.swift
//  MeowStar
//
//  Created by Suraj Meharwade on 26/01/24.
//

import UIKit
import Firebase

class HomePageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func logOutPressed(_ sender: UIButton) {
        do {
                try Auth.auth().signOut()
                // Log out successful
                print("User logged out successfully")
            self.dismiss(animated: true)
                
                // You can navigate to the login screen or perform any other actions after logout
                // For example, if you are using a navigation controller:
                // navigationController?.popToRootViewController(animated: true)
                
            } catch let signOutError as NSError {
                // If there is an error during logout, handle it here
                print("Error signing out: \(signOutError.localizedDescription)")
            }
    }
}
