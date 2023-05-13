//
//  MovieViewModel.swift
//  MyMovie
//
//  Created by Alex Okhtov on 13.05.2023.
//

import UIKit

/// The MovieViewModel consumes a movie model and provides the required data to be used by the viewControlers.
/// This viewModel is used by the cells and by the listViewModels for providing the data.
/// This is created for displaying movies anywhere in the app, you could call the api and intialize the model and use it to display all movie related data , thus removing any logical parts from VC.
struct MovieViewModel {
    
    // MARK:- variables for the viewModel
    let fileHandler: FileHandler
    let networkManager: NetworkManager
    
    let titleInfo: TitleInfo
    let id: String
    let rating: TitleRating
    let releaseDate: String
    let genres: [String]
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-DD-MM"
        return formatter
    }()
    
    let readableFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    var moviePosterUrl: URL {
        guard let image = titleInfo.image?.url else { return URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSMZ-kE94eLRVXkJaPCaO-2SJUcoPi7z5Hb7g&usqp=CAU")! }
        guard let url = URL(string: image) else { return URL(string: "")! }
        return url
    }
    
    var moviePosterImage: BoxBind<UIImage?> = BoxBind(nil)
    var isFavorite: BoxBind<Bool?> = BoxBind(nil)
    
    var movieTitle: String {
        titleInfo.title
    }
    
    var movieGenres: String {
        if (genres.count >= 2) {
            return genres[0..<2].joined(separator: ", ")
        } else {
            return genres.joined(separator: ", ")
        }
    }
    
    var movieFans: String {
        guard let ratingCount = self.rating.ratingCount else { return "\(Int.random(in: 1024..<100000))"}
        return "\(ratingCount)"
    }
    
    var movieRating: String {
        guard let rating = self.rating.rating else { return "\(Double.random(in: 5.0..<9.9).rounded(toPlaces: 1))"}
        return "\(rating.rounded(toPlaces: 1))"
    }
    
    var movieRunTime: String {
        var runtime = Int.random(in: 100..<142)
        if (self.titleInfo.runningTimeInMinutes != nil) {
            runtime = self.titleInfo.runningTimeInMinutes!
        }
        let hours = runtime / 60
        let minutes = runtime % 60
        if (hours > 0) {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // MARK:- initializer for the viewModel
    init(meta: TitleMetaData?, handler: FileHandler = FileHandler(), networkManager: NetworkManager = NetworkManager()) {
        guard let meta = meta else {
            self.titleInfo = TitleInfo(runningTimeInMinutes: nil, title: "", titleType: "", year: 0, image: TitlePoster(height: 0, width: 0, url: ""))
            self.id = ""
            self.rating = TitleRating(rating: nil, ratingCount: nil, topRank: nil, bottomRank: nil)
            self.genres = []
            self.releaseDate = ""
            self.fileHandler = handler
            self.networkManager = networkManager
            return
        }
        self.titleInfo = meta.title
        self.id = meta.titleId
        self.rating = meta.ratings
        self.genres = meta.genres
        
        if let date = dateFormatter.date(from: meta.releaseDate) {
            self.releaseDate = readableFormatter.string(from: date)
        } else {
            self.releaseDate = "N/A"
        }
        
        self.fileHandler = handler
        self.networkManager = networkManager
        
        self.getMoviePoster()
    }
    
    func getMoviePoster() {
        if (fileHandler.checkIfFileExists(id: id)) {
            self.moviePosterImage.value = UIImage(contentsOfFile: fileHandler.getPathForImage(id: id).path)
        } else {
            networkManager.downloadMoviePoster(url: self.moviePosterUrl, id: self.id) { res, error in
                if (error == .none) {
                    self.moviePosterImage.value = UIImage(contentsOfFile: self.fileHandler.getPathForImage(id: self.id).path)
                }
            }
        }
    }
}
