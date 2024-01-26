//
//  alertBox.swift
//  MeowStar
//
//  Created by Suraj Meharwade on 26/01/24.
//

import Foundation
import UIKit

extension UIViewController{
    func showAlertBox(title: String,message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        

        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}
