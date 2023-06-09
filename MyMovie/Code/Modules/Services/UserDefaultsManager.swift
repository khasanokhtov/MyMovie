//
//  UserDefaultsManager.swift
//  MyMovie
//
//  Created by Alex Okhtov on 13.05.2023.
//

import Foundation


class UserDefaultsManager {
    // MARK:- getter functions
    func getPopularTitlesList() -> [String] {
        guard let ids = UserDefaults.standard.array(forKey: "popularTitles") as? [String]  else { return [] }
        return ids
    }
    
    func getComingSoonTitlesList() -> [String] {
        guard let ids = UserDefaults.standard.array(forKey: "comingSoonTitles") as? [String]  else { return [] }
        return ids
    }
    
    func getFavorites(type: Favorites) -> [String] {
        guard let ids = UserDefaults.standard.array(forKey: type.rawValue) as? [String]  else { return [] }
        return ids
    }
    
    // MARK:- setter functions
    func setPopularTitlesList(titles: [String]) {
        UserDefaults.standard.set(titles, forKey: "popularTitles")
    }
    
    func setComingSoonitlesList(titles: [String]) {
        UserDefaults.standard.set(titles, forKey: "comingSoonTitles")
    }
    
    func setFavorites(ids: [String], for type: Favorites) {
        UserDefaults.standard.set(ids, forKey: type.rawValue)
    }
    
    
    // MARK:- favorite Movies
    @discardableResult
    func toggleFavorites(id: String, type: Favorites) -> Bool {
        let favorites = getFavorites(type: type)
        if (favorites.contains(id)) {
            self.removeFromFavorites(id: id, favorites: favorites, type: type)
            return false
        } else {
            self.addToFavorites(ids: id, favorites: favorites, type: type)
            return true
        }
    }
    
    @discardableResult
    func checkIfFavorite(id: String, type: Favorites) ->Bool {
        let favorites = getFavorites(type: type)
        if (favorites.contains(id)) {
            return true
        } else {
            return false
        }
    }
    
    @discardableResult
    func addToFavorites(ids: String, favorites: [String], type: Favorites) -> Bool {
        var newFavorites = favorites
        newFavorites.append(ids)
        self.setFavorites(ids: newFavorites, for: type)
        return true
    }
    
    @discardableResult
    func removeFromFavorites(id: String, favorites: [String], type: Favorites) -> Bool {
        self.setFavorites(ids: favorites.filter( {$0 != id}), for: type)
        return true
    }
    
    func clearUserDefaults() {
        UserDefaults.resetStandardUserDefaults()
    }
}
