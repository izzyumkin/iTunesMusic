//
//  MainTabBarController.swift
//  Music
//
//  Created by Иван Изюмкин on 09.03.2021.
//

import UIKit
import SwiftUI

protocol MainTabBarControllerDelegate: class {
    
    func minimizedTrackDetailController()
    func maximizedTrackDetailController(viewModel: SearchViewModel.Cell?)
    
}

class MainTabBarController: UITabBarController {
    
    let searchViewController: SearchViewController = SearchViewController.loadFromStoryboard()
    let trackDetailView: TrackDetailView = TrackDetailView.loadFromNib()
    
    var minimizedTopAnchorConstraint: NSLayoutConstraint!
    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        tabBar.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.3764705882, alpha: 1)
        
        let viewController = UIViewController()
        
        searchViewController.tabBarDelegate = self
        setupTrackDetailView()
        
        viewControllers = [
            generateViewController(rootViewController: viewController, image: #imageLiteral(resourceName: "library"), title: "Library"),
            generateViewController(rootViewController: searchViewController, image: #imageLiteral(resourceName: "search"), title: "Search")
        ]
        
    }
    
    private func generateViewController(rootViewController: UIViewController, image: UIImage, title: String) -> UIViewController {
        
        let navigationViewController = UINavigationController(rootViewController: rootViewController)
        navigationViewController.navigationBar.prefersLargeTitles = true
        navigationViewController.tabBarItem.image = image
        navigationViewController.tabBarItem.title = title
        rootViewController.navigationItem.title = title
        
        return navigationViewController
        
    }
    
    private func setupTrackDetailView() {
        
        trackDetailView.tabBarDelegate = self
        trackDetailView.delegate = searchViewController
        trackDetailView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(trackDetailView, belowSubview: tabBar)
        
        
        maximizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        minimizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        bottomAnchorConstraint = trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        
        maximizedTopAnchorConstraint.isActive = true
        bottomAnchorConstraint.isActive = true
        
        trackDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trackDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
    }

}

extension MainTabBarController: MainTabBarControllerDelegate {
    
    func minimizedTrackDetailController() {
        
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.alpha = 1
            self.trackDetailView.detailStack.alpha = 0
            self.trackDetailView.miniDetailView.alpha = 1
            }, completion: nil)
        
    }
    
    func maximizedTrackDetailController(viewModel: SearchViewModel.Cell?) {
        
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchorConstraint.constant = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.alpha = 0
            self.trackDetailView.detailStack.alpha = 1
            self.trackDetailView.miniDetailView.alpha = 0
            }, completion: nil)
        
        guard let cellViewModel = viewModel else { return }
        self.trackDetailView.set(viewModel: cellViewModel)
        
    }

    
}
