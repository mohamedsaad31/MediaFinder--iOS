//
//  APIManger.swift
//  MediaFinder11
//
//  Created by mohamed saad on 13/02/2023.
//
import Alamofire

class APIManger {
    
    // Define a completion handler that will be called when the API request is complete
    typealias MediaCompletionHandler = (Result<[Media], Error>) -> Void
    
    static func fetchData(for mediaType: String, searchTerm: String, completion: @escaping MediaCompletionHandler) {

        // Construct the URL with the given parameters
        let url = "https://itunes.apple.com/search?media=\(mediaType)&term=\(searchTerm)"
        
        // Make the API request using Alamofire and parse the response into a MediaResponse object
        AF.request(url).validate().responseDecodable(of: MediaResponse.self) { response in
            
            switch response.result {
            case .success(let mediaResponse):
                // If the response is successful, return the results to the completion handler
                completion(.success(mediaResponse.results))
            case .failure(let error):
                // If the response fails, return the error to the completion handler
                completion(.failure(error))
            }
        }
    }
}
