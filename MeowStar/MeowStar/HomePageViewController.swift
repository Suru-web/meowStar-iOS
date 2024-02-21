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
import SDWebImage

class HomePageViewController: UIViewController, UITableViewDataSource {
    
    struct post{
        let profilePic: String!
        let username: String!
        let postImage: String!
    }
    var posts: [post] = []
    var tempPosts: [post] = []
    
    
    @IBOutlet var table: UITableView!
    @IBOutlet var circularImageViewHomePage: UIImageView!
    var profilePicImage: UIImage!
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    var databaseRef: DatabaseReference!
    var postsRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedbackGenerator.prepare()
        databaseRef = Database.database().reference().child("users").child("user").child(Auth.auth().currentUser!.uid).child("profilePic")
        databaseRef.keepSynced(true)
        getPostsFromFirebase()
        
        getProfileImage(databaseRef: databaseRef) { urlString in
            guard let urlString = urlString, let url = URL(string: urlString) else {
                return
            }
            
            DispatchQueue.main.async {
                            // Use SDWebImage to load and cache the profile picture
                            self.circularImageViewHomePage.sd_setImage(with: url, completed: { _, error, _, _ in
                                if let error = error {
                                    print("Error loading profile picture: \(error)")
                                }
                            })
                        }
        }
        
        table.dataSource = self
        
        let profilePictapGesture = UITapGestureRecognizer(target: self, action: #selector(logoutAlertBox))
        circularImageViewHomePage.isUserInteractionEnabled = true
        circularImageViewHomePage.addGestureRecognizer(profilePictapGesture)
        
    }
    
    
    func getPostsFromFirebase() {
        postsRef = Database.database().reference().child("posts")
        postsRef.keepSynced(true)
        postsRef.observe(.value) { snapshot  in
            self.posts.removeAll() // Clear existing posts
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let postDict = childSnapshot.value as? [String: Any],
                   let profilePic = postDict["profilePic"] as? String,
                   let username = postDict["username"] as? String,
                   let postImage = postDict["postLink"] as? String {
                    let post = post(profilePic: profilePic, username: username, postImage: postImage)
                    self.tempPosts.append(post)
                }
            }
            self.posts = self.tempPosts.reversed()
            
            // Reload table view data after fetching posts
            self.table.reloadData()
        }
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
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        let catPost = posts[indexPath.row]
        print(catPost.postImage!)
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! mainPageTableViewCell
        
        
        loadImageFromURL(urlString: catPost.postImage) { image in
            if let image = image {
                DispatchQueue.main.async {
                    cell.postImageView.image = image
                }
            } else {
                print("Failed to load post image")
            }
        }
        loadImageFromURL(urlString: catPost.profilePic) { image in
            if let image = image {
                DispatchQueue.main.async {
                    cell.profilePicImageView.image = image
                }
            } else {
                print("Failed to load profile image")
            }
        }
        cell.userNameLable.text = catPost.username
        designRowElements(cell: cell)
        return cell
    }
    
    func designRowElements(cell: mainPageTableViewCell){
        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.frame.size.width / 2
        cell.profilePicImageView.contentMode = .scaleAspectFit
        cell.profilePicImageView.clipsToBounds = true
        cell.postImageView.contentMode = .scaleAspectFill
        cell.postImageView.layer.cornerRadius = 18
    }
    
    
    func loadImageFromURL(urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { image, data, error, _, _, _ in
            if let error = error {
                print("Error loading image: \(error)")
                completion(nil)
                return
            }
            
            guard let imageData = data, let image = image ?? UIImage(data: imageData) else {
                print("Invalid image data")
                completion(nil)
                return
            }
            
            completion(image)
        }
    }
}


