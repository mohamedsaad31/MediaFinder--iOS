//
//  MediaResponse.swift
//  MediaFinder11
//
//  Created by mohamed saad on 24/02/2023.
//

import Foundation


struct MediaResponse : Codable{
    var resultCount :Int
    var results: [Media]
}
struct Media : Codable{
    var artistName: String?
    var artworkUrl: String!
    var trackName: String?
    var longDescription: String?
    var previewUrl: String!
    var artworkUrl100: String?
    var kind: String?
}


struct ParameterKey {
    static let term = "term"
    static let media = "media"
}
