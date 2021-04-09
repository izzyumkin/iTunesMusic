//
//  NetworkService.swift
//  Music
//
//  Created by Иван Изюмкин on 09.03.2021.
//

import Foundation
import Alamofire

class NetworkService {
    
    func fetchTracks(searchText: String, complition: @escaping (SearchResponse?) -> Void) {
        
        let url = "https://itunes.apple.com/search?term=\(searchText)"
        
        let parameters = ["term":"\(searchText)",
                          "limit":"10",
                          "media":"music"
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: nil).responseData { (dataResponse) in
            
            if let error = dataResponse.error {
                print("ResponseData error: \(error.localizedDescription)")
                complition(nil)
                return
            }
            
            guard let data = dataResponse.data else { return }
            
            let decoder = JSONDecoder()
            
            do {
                
                let objects = try decoder.decode(SearchResponse.self, from: data)
                complition(objects)
                
            } catch let error {
                
                complition(nil)
                print("JSON Decoder error: \(error)")
                
            }
            
        }
        
    }
    
}
