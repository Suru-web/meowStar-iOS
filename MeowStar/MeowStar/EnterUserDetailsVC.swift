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
import FirebaseCore
import FirebaseStorage

class EnterUserDetailsVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet var nameOutlet: UITextField!
    @IBOutlet var userNameOutlet: UITextField!
    @IBOutlet var profilePicOutlet: UIImageView!
    @IBOutlet var bioOutlet: UITextField!
    @IBOutlet var transparentView: UIView!
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var confirmPost: UIImage!
    var pickedProfilePic: UIImage!
    var urlString: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transparentView.isHidden = true
        indicatorView.hidesWhenStopped = true
        indicatorView.isHidden = true
        nameOutlet.designTextField()
        userNameOutlet.designTextField()
        bioOutlet.designTextField()
        ref = Database.database().reference().child("users").child("user").child(Auth.auth().currentUser!.uid)
        storageRef = Storage.storage().reference().child(Auth.auth().currentUser!.uid).child("profilePic")
        
        tabBarController?.hidesBottomBarWhenPushed = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
                profilePicOutlet.isUserInteractionEnabled = true
                profilePicOutlet.addGestureRecognizer(tapGesture)
        let hideKeyboard = UITapGestureRecognizer(target: self, action: #selector(keyboardHide))
        view.addGestureRecognizer(hideKeyboard)
    }
    @objc func keyboardHide(){
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profilePicOutlet.contentMode = .scaleAspectFill
        profilePicOutlet.layer.cornerRadius = 
        profilePicOutlet.frame.size.width / 2
        profilePicOutlet.clipsToBounds = true
        profilePicOutlet.layer.borderColor = UIColor.gray.cgColor
        profilePicOutlet.layer.borderWidth = 1
    }
    
    
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        indicatorView.isHidden = false
        transparentView.isHidden = false
        indicatorView.startAnimating()
        
        guard let username = userNameOutlet.text, !username.isEmpty else{
            showAlertBox(title: "Input error", message: "Username cannot be empty")
            indicatorView.stopAnimating()
            return
        }
        guard let name = nameOutlet.text, !name.isEmpty else{
            showAlertBox(title: "Input error", message: "Name cannot be empty")
            indicatorView.stopAnimating()
            return
        }
        guard let bio = bioOutlet.text, !bio.isEmpty else{
            showAlertBox(title: "Input error", message: "Please enter Few things about yourself in bio section")
            indicatorView.stopAnimating()
            return
        }
        guard let imageData = pickedProfilePic.pngData() else {
            indicatorView.stopAnimating()
            return
        }
        
        storageRef.child("file.png").putData(imageData, completion: {_,error in
            guard error == nil else{
                print("Failed to upload")
                return
            }
            self.storageRef.child("file.png").downloadURL { url, error in
                guard let url = url, error == nil else{
                    print("Image uploading failed")
                    return
                }
                self.urlString = url.absoluteString
                UserDefaults.standard.set(url.absoluteString, forKey: "url")
                
                
                let userValues = ["username": username,
                                      "name": name,
                                      "bio": bio,
                                  "profilePic": self.urlString ?? ""]

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
        })
       
    }
    @objc func imageViewTapped() {
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        confirmPost = image
        pickedProfilePic = image
        profilePicOutlet.image = image
        dismiss(animated: true)
        
    }
    
}
