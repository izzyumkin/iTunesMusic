//
//  SearchTableViewController.swift
//  Music
//
//  Created by Иван Изюмкин on 09.03.2021.
//

import UIKit
import Alamofire

class SearchTableViewController: UITableViewController {

    var networkService = NetworkService()
    var tracks = [Track]()
    
    var timer: Timer?

    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellId")
        
    }
    
    func setupSearchController() {
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CellId")
        let track = tracks[indexPath.row]
        
        cell.textLabel?.text = track.trackName
        cell.detailTextLabel?.text = track.artistName
        cell.imageView?.image = #imageLiteral(resourceName: "Image")
        
        return cell
    }
    
}

extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            
            self.networkService.fetchTracks(searchText: searchText) { [weak self] (searchResponse) in
                
                self?.tracks = searchResponse?.results ?? []
                self?.tableView.reloadData()
                
            }
            
        })
        
    }
    
}
