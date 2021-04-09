//
//  SearchInteractor.swift
//  Music
//
//  Created by Иван Изюмкин on 09.03.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchBusinessLogic {
    func makeRequest(request: Search.Model.Request.RequestType)
}

class SearchInteractor: SearchBusinessLogic {
    
    var presenter: SearchPresentationLogic?
    var service: SearchService?
    
    var networkService = NetworkService()
    
    func makeRequest(request: Search.Model.Request.RequestType) {
        if service == nil {
            service = SearchService()
        }
        
        switch request {
         
        case .getTracks(let searchText):
            presenter?.presentData(response: .presentFooterView)
            networkService.fetchTracks(searchText: searchText) { [weak self] (searchResponse) in
                self?.presenter?.presentData(response: .presentTracks(searchResponse: searchResponse))
            }
        }
        
    }
    
}
