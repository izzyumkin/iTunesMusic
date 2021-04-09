//
//  SearchPresenter.swift
//  Music
//
//  Created by Иван Изюмкин on 09.03.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchPresentationLogic {
    func presentData(response: Search.Model.Response.ResponseType)
}

class SearchPresenter: SearchPresentationLogic {
    weak var viewController: SearchDisplayLogic?
    
    func presentData(response: Search.Model.Response.ResponseType) {
        
        switch response {
        
        case .presentTracks(let searchResponse):
            let cells = searchResponse?.results.map({ (track) in
                cellViewModel(from: track)
            }) ?? []
            let searchViewModel = SearchViewModel.init(cells: cells)
            viewController?.displayData(viewModel: .displayTracks(searchViewModel: searchViewModel))
            
        case .presentFooterView:
            viewController?.displayData(viewModel: .displayFooterView)
            
        }
        
    }
    
    private func cellViewModel(from track: Track) -> SearchViewModel.Cell {
        
        return SearchViewModel.Cell.init(imageUrlString: track.artworkUrl100,
                                         trackName: track.trackName,
                                         artistName: track.artistName,
                                         collectionName: track.collectionName ?? "",
                                         previewUrl: track.previewUrl)
        
    }
    
}
