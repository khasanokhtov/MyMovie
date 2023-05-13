//
//  Actor.swift
//  MyMovie
//
//  Created by Alex Okhtov on 13.05.2023.
//

import Foundation

struct ActorFilms: Decodable {
    let id: String
    let base: ActorBase?
    let filmography: [ActorFilmography]
}

struct ActorBase: Decodable {
    let id: String
    let name: String
    let image: TitlePoster
}

struct ActorFilmography: Decodable {
    let category: String
    let characters: [String]?
    let image: TitlePoster?
    let status: String?
    let title: String
    let titleType: String
    let year: Int?
}
