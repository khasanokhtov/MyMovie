//
//  Generic-Protocols.swift
//  MyMovie
//
//  Created by Alex Okhtov on 13.05.2023.
//

import UIKit

enum Favorites: String {
    case favoriteActors = "favoriteActors"
    case favoriteMovies = "favoriteMovies"
}

struct Generic {
    let colors = [UIColor.systemRed, UIColor.systemTeal, UIColor.systemIndigo, UIColor.systemOrange, UIColor.systemGreen, UIColor.systemYellow]
    
    static var shared: Generic {
        return Generic()
    }
    
    func getRandomColor() -> UIColor {
        return colors.randomElement()!
    }
}


protocol ComponentShimmers {
    var animationDuration: Double { get }

    func hideViews()
    func showViews()
    func setShimmer()
    func removeShimmer()
}

protocol Likeable {
    var favoriteType: Favorites { get }
    
    func likePressed(id: String) -> Bool
    func checkIfFavorite(id: String) -> Bool
}
