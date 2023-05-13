//
//  TitleCollectionViewCell.swift
//  MyMovie
//
//  Created by Alex Okhtov on 13.05.2023.
//

import UIKit

class TitleCollectionViewCell: UICollectionViewCell, ComponentShimmers {
    
    // MARK:- outlets for the cell
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieGenreLabel: UILabel!
    
    // MARK:- variables for the cell
    override class func description() -> String {
        return "TitleCollectionViewCell"
    }
    
    let cellHeight: CGFloat = 240
    let cornerRadius: CGFloat = 12
    
    let animationDuration: Double = 0.25
    var shimmer: ShimmerLayer = ShimmerLayer()
    
    // MARK:- lifeCycle methods for the cell
    override func awakeFromNib() {
        super.awakeFromNib()
        self.hideViews()
        
        self.containerView.setCornerRadius(radius: 12)
        self.moviePosterImageView.setCornerRadius(radius: 12)
        self.moviePosterImageView.setShadow(shadowColor: UIColor.label, shadowOpacity: 1, shadowRadius: 10, offset: CGSize(width: 0, height: 2))
        self.moviePosterImageView.setBorder(with: UIColor.label.withAlphaComponent(0.15), 2)
    }
    
    // MARK:- delegate functions for collectionView
    func hideViews() {
        ViewAnimationFactory.makeEaseOutAnimation(duration: animationDuration, delay: 0) {
            self.moviePosterImageView.setOpacity(to: 0)
            self.movieTitleLabel.setOpacity(to: 0)
            self.movieGenreLabel.setOpacity(to: 0)
        }
    }
    
    func showViews() {
        ViewAnimationFactory.makeEaseOutAnimation(duration: animationDuration, delay: 0) {
            self.moviePosterImageView.setOpacity(to: 1)
            self.movieTitleLabel.setOpacity(to: 1)
            self.movieGenreLabel.setOpacity(to: 1)
        }
    }
    
    func setShimmer() {
        DispatchQueue.main.async { [unowned self] in
            self.shimmer.removeLayerIfExists(self)
            self.shimmer = ShimmerLayer(for: self.moviePosterImageView, cornerRadius: 12)
            self.layer.addSublayer(self.shimmer)
        }
    }
    
    func removeShimmer() {
        shimmer.removeFromSuperlayer()
    }
    
    // MARK:- functions for the cell
    func setupCell(viewModel: MovieViewModel) {
        setShimmer()
        self.movieTitleLabel.text = viewModel.movieTitle
        self.movieGenreLabel.text = viewModel.movieGenres
        
        DispatchQueue.global().async {
            viewModel.moviePosterImage.bind {
                guard let posterImage = $0 else { return }
                DispatchQueue.main.async { [unowned self] in
                    self.moviePosterImageView.image = posterImage
                    self.removeShimmer()
                    self.showViews()
                }
            }
        }
    }
}
