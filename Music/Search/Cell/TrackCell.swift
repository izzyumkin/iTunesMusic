//
//  TrackCell.swift
//  Music
//
//  Created by Иван Изюмкин on 11.03.2021.
//

import UIKit
import SDWebImage

protocol TrackCellViewModel {
    
    var trackName: String { get }
    var artistName: String { get }
    var collectionName: String { get }
    var imageUrlString: String? { get }
    
}

class TrackCell: UITableViewCell {
    
    static let reuseId = "TrackCell"

    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var collectionNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        trackImageView.image = nil
        
    }
    
    func set(trackViewModel: TrackCellViewModel) {
        
        trackNameLabel.text = trackViewModel.trackName
        artistNameLabel.text = trackViewModel.artistName
        collectionNameLabel.text = trackViewModel.collectionName
        
        guard let url = URL(string: trackViewModel.imageUrlString ?? "") else { return }
        trackImageView.sd_setImage(with: url, completed: nil)
        
    }

}
