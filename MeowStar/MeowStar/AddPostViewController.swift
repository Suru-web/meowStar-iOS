//
//  AddPostViewController.swift
//  MeowStar
//
//  Created by Suraj Meharwade on 30/01/24.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class AddPostViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageSelectionView: UIImageView!
    @IBOutlet var pickImageButton: UIButton!
    @IBOutlet var confirmUploadButton: UIButton!
    
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var confirmPost: UIImage!
    
    var postLinkReference: DatabaseReference!
    var userDatabaseLink: DatabaseReference!
    var userName: String!
    var userProfilePic: String!
    var postStorageReference: StorageReference!
    var urlString: String!
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedbackGenerator.prepare()
        transparentView.isHidden = true
        activityIndicator.hidesWhenStopped = true
        
        confirmUploadButton.isHidden = true
        postLinkReference = Database.database().reference().child("posts")
        userDatabaseLink = Database.database().reference().child("users").child("user").child(Auth.auth().currentUser!.uid)
        postStorageReference = Storage.storage().reference().child(Auth.auth().currentUser!.uid).child("posts")
        
        
        userDatabaseLink.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                print("USer data not found")
                return
            }
            if let userData = snapshot.value as? [String: Any] {
                self.userProfilePic = userData["profilePic"] as? String
                self.userName = userData["username"] as? String
                }
            else {
                    print("User data format is incorrect")
                }
            }
            
        }
    
    @IBAction func pickImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func confirmUploadAction(_ sender: UIButton) {
        feedbackGenerator.impactOccurred()
        tabBarController?.tabBar.alpha = 0.5
        
        self.transparentView.isHidden = false
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        guard let postData = confirmPost.pngData() else{
            return
        }
        let id = postLinkReference.childByAutoId().key
        postStorageReference.child(id ?? "invalid").putData(postData, completion: {_, error in
            guard error == nil else{
                print("Uploading image failed")
                return
            }
            self.postStorageReference.child(id ?? "invalid").downloadURL { url, error in
                guard let url = url, error == nil else{
                    print("Image uploading failed")
                    return
                }
                self.urlString = url.absoluteString
                
                
                let userValues = ["username": self.userName,
                                  "postLink": self.urlString,
                                  "profilePic": self.userProfilePic]

                self.postLinkReference.child(id ?? "invalid").setValue(userValues) { (error, ref) in
                    if let error = error {
                        print("Data could not be saved: \(error.localizedDescription)")
                        
                        self.showAlertBox(title: "Error", message: "Failed to upload post. Please try again.")
                        self.feedbackGenerator.impactOccurred()
                        self.feedbackGenerator.impactOccurred()
                        
                        
                    } else {
                        self.showAlertBox(title: "Success", message: "Image was uploaded successfully!")
                        self.tabBarController?.selectedIndex = 0
                        self.tabBarController?.tabBar.alpha = 1
                        self.transparentView.isHidden = true
                        self.activityIndicator.isHidden = true
                        self.feedbackGenerator.impactOccurred()
                        self.confirmUploadButton.isHidden = true
                        self.pickImageButton.setTitle("Pick an Image", for: .normal)
                        self.imageSelectionView.image = UIImage(systemName: "photo")
                        
                    }
                }
            }
        })
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        confirmPost = image
        
        imageSelectionView.image = image
        dismiss(animated: true)
        
        pickImageButton.setTitle("Change photo",for: .normal)
        confirmUploadButton.isHidden = false
    }
    
}
