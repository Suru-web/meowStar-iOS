//
//  AddPostViewController.swift
//  MeowStar
//
//  Created by Suraj Meharwade on 30/01/24.
//

import UIKit

class AddPostViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageSelectionView: UIImageView!
    @IBOutlet var pickImageButton: UIButton!
    @IBOutlet var confirmUploadButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmUploadButton.isHidden = true
    }
    
    @IBAction func pickImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        
        imageSelectionView.image = image
        dismiss(animated: true)
        
        pickImageButton.setTitle("Change photo",for: .normal)
        confirmUploadButton.isHidden = false
    }
    
}
