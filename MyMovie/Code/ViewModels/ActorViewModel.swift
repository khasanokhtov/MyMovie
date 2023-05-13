//
//  ActorViewModel.swift
//  MyMovie
//
//  Created by Alex Okhtov on 13.05.2023.
//

import UIKit

/// Just like the MovieViewModel, the ActorViewModel is a viewModel for Actors, consumed by the cells and ActorListViewModel
struct ActorViewModel {
    
    // MARK:- variables for the viewModel
    let fileHandler: FileHandler
    let networkManager: NetworkManager
    
    let imageUrlString: String
    let actorName: String
    
    let id: String
    let movies: ActorFilms
    
    var totalMovies: String {
        return "\(movies.filmography.count) movies"
    }
    
    var actorImageUrl: URL {
        guard let url = URL(string: imageUrlString) else { return URL(string: "")! }
        return url
    }
    
    var actorImage: BoxBind<UIImage?> = BoxBind(nil)
    var isFavorite: BoxBind<Bool?> = BoxBind(nil)
    
    // MARK:- initializer for the viewModel
    init(actorFilms: ActorFilms?, handler: FileHandler = FileHandler(), networkManager: NetworkManager = NetworkManager()) {
        guard let actorFilms = actorFilms, let actorbase = actorFilms.base else {
            self.id = ""
            self.imageUrlString = ""
            self.actorName = ""
            self.movies = ActorFilms(id: "", base: nil, filmography: [])
            
            self.fileHandler = handler
            self.networkManager = networkManager
            return
        }
        id = actorbase.id.components(separatedBy: "/")[2]
        imageUrlString = actorbase.image.url
        actorName = actorbase.name
        movies = actorFilms
        
        self.fileHandler = handler
        self.networkManager = networkManager
        
        self.getActorImage()
    }
    
    // MARK:- functions for the viewModel
    func getActorImage() {
        if (fileHandler.checkIfFileExists(id: id)) {
            self.actorImage.value = UIImage(contentsOfFile: fileHandler.getPathForImage(id: id).path)
        } else {
            networkManager.downloadMoviePoster(url: self.actorImageUrl, id: self.id) { res, error in
                if (error == .none) {
                    self.actorImage.value = UIImage(contentsOfFile: self.fileHandler.getPathForImage(id: self.id).path)
                }
            }
        }
    }
}
