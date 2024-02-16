//
//  HomePageViewController.swift
//  MeowStar
//
//  Created by Suraj Meharwade on 28/01/24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseStorage

class HomePageViewController: UIViewController, UITableViewDataSource {
    
    struct posts{
        let profilePic: UIImage!
        let username: String!
        let postImage: UIImage!
    }
    let data: [posts] = [
        posts(profilePic: UIImage(named: "FELV-cat"), username: "Cat King 1", postImage: UIImage(named: "bluecat")),
        posts(profilePic: UIImage(named: "cat1"), username: "Cat King 2", postImage: UIImage(named: "cat1")),
        posts(profilePic: UIImage(named: "cat2"), username: "Cat King 3", postImage: UIImage(named: "cat2")),
        posts(profilePic: UIImage(named: "cat3"), username: "Cat King 4", postImage: UIImage(named: "cat3")),
        posts(profilePic: UIImage(named: "cat4"), username: "Cat King 5", postImage: UIImage(named: "cat4")),
        posts(profilePic: UIImage(named: "cat5"), username: "Cat King 6", postImage: UIImage(named: "cat5")),
        posts(profilePic: UIImage(named: "cat6"), username: "Cat King 7", postImage: UIImage(named: "cat6"))
    ]
    
    
    @IBOutlet var table: UITableView!
    @IBOutlet var circularImageViewHomePage: UIImageView!
    var profilePicImage: UIImage!
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedbackGenerator.prepare()
        databaseRef = Database.database().reference().child("users").child("user").child(Auth.auth().currentUser!.uid).child("profilePic")
        
        getProfileImage(databaseRef: databaseRef) { urlString in
                    guard let urlString = urlString, let url = URL(string: urlString) else {
                        return
                    }
                    
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let error = error {
                            print("Error loading profile picture: \(error)")
                            return
                        }
                        
                        guard let data = data, let image = UIImage(data: data) else {
                            print("Invalid image data")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.circularImageViewHomePage.image = image
                        }
                    }.resume()
                }

        table.dataSource = self
        
        
        let profilePictapGesture = UITapGestureRecognizer(target: self, action: #selector(logoutAlertBox))
        circularImageViewHomePage.isUserInteractionEnabled = true
        circularImageViewHomePage.addGestureRecognizer(profilePictapGesture)
        
    }
    
    @objc func logoutAlertBox(){
        feedbackGenerator.impactOccurred()
        do {
                try Auth.auth().signOut()
                print("User logged out successfully")
            
            } catch let signOutError as NSError {
                print("Error signing out: \(signOutError.localizedDescription)")
            }
    }
    
    func getProfileImage(databaseRef: DatabaseReference, completion: @escaping (String?) -> Void) {
            databaseRef.observeSingleEvent(of: .value) { (snapshot) in
                guard snapshot.exists(), let profilePicLink = snapshot.value as? String else {
                    completion(nil)
                    return
                }
                
                completion(profilePicLink)
            }
        }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        circularImageViewHomePage.contentMode = .scaleAspectFill
        circularImageViewHomePage.layer.cornerRadius = circularImageViewHomePage.frame.size.width / 2
        circularImageViewHomePage.clipsToBounds = true
        circularImageViewHomePage.layer.borderColor = UIColor.gray.cgColor
        circularImageViewHomePage.layer.borderWidth = 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        let catPost = data[indexPath.row]
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! mainPageTableViewCell
        cell.postImageView.image = catPost.postImage
        cell.profilePicImageView.image = catPost.profilePic
        cell.userNameLable.text = catPost.username
        designRowElements(cell: cell)
        return cell
    }
    
    func designRowElements(cell: mainPageTableViewCell){
        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.frame.size.width / 2
        cell.profilePicImageView.contentMode = .scaleAspectFill
        cell.profilePicImageView.clipsToBounds = true
        cell.profilePicImageView.layer.borderColor = UIColor.gray.cgColor
        cell.profilePicImageView.layer.borderWidth = 1
        cell.postImageView.contentMode = .scaleAspectFit
        cell.postImageView.layer.cornerRadius = 18
    }
}


