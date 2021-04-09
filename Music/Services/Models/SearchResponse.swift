//
//  SearchResponse.swift
//  Music
//
//  Created by Иван Изюмкин on 09.03.2021.
//

import Foundation

struct SearchResponse: Decodable {
    
    var resultCount: Int
    var results: [Track]
    
}

struct Track: Decodable {
    
    var trackName: String
    var artistName: String
    var collectionName: String?
    var artworkUrl100: String?
    var previewUrl: String?
    
}
