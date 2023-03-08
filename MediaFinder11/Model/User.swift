//
//  User.swift
//  MediaFinder11
//
//  Created by mohamed saad on 13/12/2022.
//

import UIKit
import CryptoKit

import CryptoKit

struct User {
    var name: String!
    var email: String!
    var password: String!
    var address: String!
    var phone: Int64!
    var image: UIImage!
    var gender: String!
}



    




































//
//struct User: Codable{
//     var name: String!
//     var email: String!
//     var password: String!
//     var phone: String!
//     var address: String!
//     var userImage: codableImage!
//}
//
//struct codableImage : Codable{
//    let imageData : Data?
//
//    func getImage() -> UIImage?{
//        guard let imageData = self.imageData else {return nil}
//        return UIImage(data: imageData)
//    }
//
//
//    init(withImage image : UIImage) {
//        self.imageData = image.jpegData(compressionQuality: 0.4)
//
//
//    }
//
//}
