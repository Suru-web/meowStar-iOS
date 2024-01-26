//
//  LaunchScreenViewController.swift
//  MeowStar
//
//  Created by Suraj Meharwade on 26/01/24.
//

import UIKit
import Firebase

class LaunchScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if (Auth.auth().currentUser != nil){
            performSegue(withIdentifier: "goToMainPageFromSignIn", sender: nil)
            print("not nill")
        }
        else{
            print("nil")
        }

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
