//
//  textFieldStyle.swift
//  MeowStar
//
//  Created by Suraj Meharwade on 25/01/24.
//

import UIKit

extension UITextField {
    func designTextField() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1 // Set the desired border width
        self.layer.borderColor = UIColor.gray.cgColor
    }
}
