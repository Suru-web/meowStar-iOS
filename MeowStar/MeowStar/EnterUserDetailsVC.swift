//
//  EnterUserDetailsVC.swift
//  MeowStar
//
//  Created by Suraj Meharwade on 05/02/24.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth

class EnterUserDetailsVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet var nameOutlet: UITextField!
    @IBOutlet var userNameOutlet: UITextField!
    @IBOutlet var profilePicOutlet: UIImageView!
    @IBOutlet var bioOutlet: UITextField!
    
    var ref: DatabaseReference!
    var confirmPost: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameOutlet.designTextField()
        userNameOutlet.designTextField()
        bioOutlet.designTextField()
        ref = Database.database().reference().child("users").child("user").child(Auth.auth().currentUser!.uid)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
                profilePicOutlet.isUserInteractionEnabled = true
                profilePicOutlet.addGestureRecognizer(tapGesture)
        
        
    }
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        guard let username = userNameOutlet.text, !username.isEmpty else{
            showAlertBox(title: "Input error", message: "Username cannot be empty")
            return
        }
        guard let name = nameOutlet.text, !name.isEmpty else{
            showAlertBox(title: "Input error", message: "Name cannot be empty")
            return
        }
        guard let bio = bioOutlet.text, !bio.isEmpty else{
            showAlertBox(title: "Input error", message: "Please enter Few things about yourself in bio section")
            return
        }
        let userValues = ["username": username,
                              "name": name,
                              "bio": bio]

        self.ref.setValue(userValues) { (error, ref) in
            if let error = error {
                print("Data could not be saved: \(error.localizedDescription)")
                self.showAlertBox(title: "Error", message: "Failed to save user details. Please try again.")
            } else {
                print("Data saved successfully")
                self.performSegue(withIdentifier: "goToMainPage", sender: nil)
            }
        }
    }
    @objc func imageViewTapped() {
            // Your code here
            print("Image view tapped!")
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        confirmPost = image
        
        profilePicOutlet.image = image
        dismiss(animated: true)
        
    }
    
}
