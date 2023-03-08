//
//  UIViewController+Alert.swift
//  MediaFinder11
//
//  Created by mohamed saad on 20/12/2022.
//

import UIKit

extension UIViewController{
     func showAlert(title: String, message: String){
        let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}
