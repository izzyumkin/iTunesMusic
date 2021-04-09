//
//  SearchModels.swift
//  Music
//
//  Created by Иван Изюмкин on 09.03.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

enum Search {
    
    enum Model {
        struct Request {
            enum RequestType {
                case getTracks(searchText: String)
            }
        }
        struct Response {
            enum ResponseType {
                case presentTracks(searchResponse: SearchResponse?)
                case presentFooterView
            }
        }
        struct ViewModel {
            enum ViewModelData {
                case displayTracks(searchViewModel: SearchViewModel)
                case displayFooterView
            }
        }
    }
    
}

struct SearchViewModel {
    
    struct Cell: TrackCellViewModel {
        
        var imageUrlString: String?
        var trackName: String
        var artistName: String
        var collectionName: String
        var previewUrl: String?
        
    }
    
    let cells: [Cell]
    
}
