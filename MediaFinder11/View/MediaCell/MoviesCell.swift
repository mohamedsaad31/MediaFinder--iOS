//
//  MoviesCell.swift
//  MediaFinder11
//
//  Created by mohamed saad on 29/01/2022.
//
import UIKit

class MoviesCell: UITableViewCell {
    //MARK: - Outlets.
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 9
        descriptionLabel.lineBreakMode = .byWordWrapping // set line break mode
       
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
