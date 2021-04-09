//
//  FooterView.swift
//  Music
//
//  Created by Иван Изюмкин on 21.03.2021.
//

import UIKit

class FooterView: UIView {
    
    private var activityLabel: UILabel = {
        
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.631372549, green: 0.6470588235, blue: 0.662745098, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
    }()
    
    private var activityIndicator: UIActivityIndicatorView = {
        
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        
        return indicator
        
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupElements()
    }
    
    private func setupElements() {
        
        addSubview(activityLabel)
        addSubview(activityIndicator)
        
        activityIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        activityIndicator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        activityLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 8).isActive = true
        
    }
    
    public func showLoader() {
        
        activityIndicator.startAnimating()
        activityLabel.text = "LOADING"
        
    }
    
    public func hideLoader() {
        
        activityIndicator.stopAnimating()
        activityLabel.text = ""
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
