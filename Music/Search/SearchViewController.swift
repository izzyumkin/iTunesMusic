//
//  SearchViewController.swift
//  Music
//
//  Created by Иван Изюмкин on 09.03.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchDisplayLogic: class {
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData)
}

class SearchViewController: UIViewController, SearchDisplayLogic {
    
    var interactor: SearchBusinessLogic?
    var router: (NSObjectProtocol & SearchRoutingLogic)?
    
    weak var tabBarDelegate: MainTabBarControllerDelegate?
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchViewModel = SearchViewModel(cells: [])
    
    private lazy var footerView = FooterView()
    
    var timer: Timer?
    
    @IBOutlet weak var searchTableView: UITableView!
    
    // MARK: Setup
    
    private func setup() {
        let viewController        = self
        let interactor            = SearchInteractor()
        let presenter             = SearchPresenter()
        let router                = SearchRouter()
        viewController.interactor = interactor
        viewController.router     = router
        interactor.presenter      = presenter
        presenter.viewController  = viewController
        router.viewController     = viewController
    }
    
    private func setupSearchTableView() {
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        searchTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellID")
        
        let nib = UINib(nibName: "TrackCell", bundle: nil)
        searchTableView.register(nib, forCellReuseIdentifier: TrackCell.reuseId)
        
        searchTableView.tableFooterView = footerView
        
    }
    
    private func setupSearchController() {
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
    }
    
    // MARK: Routing
    
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupSearchTableView()
        setupSearchController()
        
    }
    
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData) {
        
        switch viewModel {
        
        case .displayTracks(let searchViewModel):
            self.searchViewModel = searchViewModel
            searchTableView.reloadData()
            footerView.hideLoader()
            
        case .displayFooterView:
            footerView.showLoader()
            
        }
        
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseId, for: indexPath) as! TrackCell
        
        let track = searchViewModel.cells[indexPath.row]
        
        cell.trackImageView.backgroundColor = .tertiaryLabel
        cell.set(trackViewModel: track)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellViewModel = searchViewModel.cells[indexPath.row]
        print("cellViewModel.trackName:", cellViewModel.trackName)
        
        self.tabBarDelegate?.maximizedTrackDetailController(viewModel: cellViewModel)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 84
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerLabel = UILabel()
        headerLabel.text = "Please enter search term above..."
        headerLabel.textAlignment = .center
        headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        return headerLabel
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return searchViewModel.cells.count > 0 ? 0 : 250
        
    }
    
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            self.interactor?.makeRequest(request: .getTracks(searchText: searchText))
        })
        
    }
    
}

// MARK: - Delegate

extension SearchViewController: TrackMovingDelegate {
    
    private func getTrack(isForwardTrack: Bool) -> SearchViewModel.Cell? {
        
        guard let currentIndexPath = searchTableView.indexPathForSelectedRow else { return nil }
        searchTableView.deselectRow(at: currentIndexPath, animated: false)
        var newIndexPath: IndexPath!
        if isForwardTrack {
            
            newIndexPath = IndexPath(row: currentIndexPath.row + 1, section: currentIndexPath.section)
            if currentIndexPath.row == searchViewModel.cells.count - 1 {
                newIndexPath.row = 0
            }
            
        } else {
            
            newIndexPath = IndexPath(row: currentIndexPath.row - 1, section: currentIndexPath.section)
            if currentIndexPath.row == 0 {
                newIndexPath.row = searchViewModel.cells.count - 1
            }
            
            
        }
        
        searchTableView.selectRow(at: newIndexPath, animated: false, scrollPosition: .none)
        let cellViewModel = searchViewModel.cells[newIndexPath.row]
        return cellViewModel
        
    }
    
    func nextTrack() -> SearchViewModel.Cell? {
        return getTrack(isForwardTrack: true)
    }
    
    func previousTrack() -> SearchViewModel.Cell? {
        return getTrack(isForwardTrack: false)
    }
    
}
