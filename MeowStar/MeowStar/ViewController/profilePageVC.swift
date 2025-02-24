//
//  profilePageVC.swift
//  MeowStar
//
//  Created by Suraj Meharwade on 22/02/24.
//

import UIKit
import Firebase
import FirebaseCore
import SDWebImage
import FirebaseAuth

class profilePageVC: UIViewController {
    @IBOutlet weak var profilePicOutlet: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var usernameOutlet: UILabel!
    @IBOutlet weak var bioOutlet: UILabel!
    
    var profileReference: DatabaseReference!
    
    
    
    struct userDetails{
        var name: String
        var username: String
        var bio: String
        var profileLink: String
    }
    var details: userDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDataFromFirebase()
        
        
    }
    
    func loadDataFromFirebase(){
        profileReference = Database.database().reference().child("users").child("user").child(Auth.auth().currentUser!.uid)
        profileReference.keepSynced(true)
        
        profileReference.observe(.value) { snapshot in
                   guard let value = snapshot.value as? [String: Any] else { return }
                   let name = value["name"] as? String ?? ""
                   let bio = value["bio"] as? String ?? ""
                   let username = value["username"] as? String ?? ""
                   let profilePic = value["profilePic"] as? String ?? ""
                   
                   let userDetails = userDetails(name: name, username: username, bio: bio, profileLink: profilePic)
                   DispatchQueue.main.async {
                        self.nameOutlet.text = userDetails.name
                        self.bioOutlet.text = userDetails.bio
                        self.usernameOutlet.text = userDetails.username
                        guard let url = URL(string: userDetails.profileLink) else {
                           return
                        }
                        self.profilePicOutlet.sd_setImage(with: url, completed: { _, error, _, _ in
                           if let error = error {
                               print("Error loading profile picture: \(error)")
                           }
                       })
                        
                    }
               }
                   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profilePicOutlet.contentMode = .scaleAspectFill
        profilePicOutlet.layer.cornerRadius = profilePicOutlet.frame.size.width / 2
        profilePicOutlet.clipsToBounds = true
    }
    
    
    @IBAction func backButton(_ sender: UIButton) {
        performSegue(withIdentifier: "backToMainPage", sender: nil)
    }
    
}
