//
//  NetworkManager.swift
//  MyMovie
//
//  Created by Alex Okhtov on 13.05.2023.
//

import Alamofire
import UIKit

enum APIError: String {
    case networkError
    case apiError
    case decodingError
}

// If the API Response is 429 or just doesn't work -> Create a new token with your credentials here -https://rapidapi.com/apidojo/api/imdb8/ . Replace the apiKey and the APIs will work again
enum APIs: URLRequestConvertible  {
    
    // MARK:- cases containing APIs
    case titleautocomplete(query: String)
    case popularTitles(regionCode: String)
    case moviesComingSoon
    case getTitleMetaData(titleIds: [String])
    case getTitleDetails(titleId: String)
    case getCastForTitle(titleId: String)
    case getFilmsForActor(actorId: String)
    
    // MARK:- variables
    static let endpoint = URL(string: "ttps://utelly-tv-shows-and-movies-availability-v1.p.rapidapi.com/idlookup?source_id=tt3398228&source=imdb&country=us")!
    static let apiKey = "976ac7c8b5mshf5ba9c36dfaf5ddp1a0be4jsn72654c2e9b91"
    static let apiHost = "utelly-tv-shows-and-movies-availability-v1.p.rapidapi.com"
    
    var path: String {
        switch self {
        case .titleautocomplete(_):
            return "/title/auto-complete"
        case .popularTitles(_):
            return "/title/get-most-popular-movies"
        case .moviesComingSoon:
            return "/title/get-coming-soon-movies"
        case .getTitleMetaData(_):
            return "/title/get-meta-data"
        case .getTitleDetails(_):
            return "/title/get-overview-details"
        case.getCastForTitle(_):
            return "/title/get-top-cast"
        case .getFilmsForActor(_):
            return "/actors/get-all-filmography"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var encoding : URLEncoding {
        return URLEncoding.init(destination: .queryString, arrayEncoding: .noBrackets)
    }
    
    func addApiHeaders(request: inout URLRequest) {
        request.addValue(Self.apiHost, forHTTPHeaderField: "x-rapidapi-host")
        request.addValue(Self.apiKey, forHTTPHeaderField: "x-rapidapi-key")
    }
    
    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: Self.endpoint.appendingPathComponent(path))
        var parameters = Parameters()
        
        switch self {
        case .titleautocomplete(let query):
            parameters["q"] = query
        case .popularTitles(let regionCode):
            parameters["currentCountry"] = regionCode
        case .getTitleMetaData(let titleIds):
            parameters["ids"] = titleIds
        case .getTitleDetails(let titleId):
            parameters["tconst"] = titleId
        case .getCastForTitle(let titleId):
            parameters["tconst"] = titleId
        case .getFilmsForActor(let actorId):
            parameters["nconst"] = actorId
        default: break
        }
        
        addApiHeaders(request: &request)
        request.addValue("iphone", forHTTPHeaderField: "User-Agent")
        request = try encoding.encode(request, with: parameters)
        return request
    }
}


struct NetworkManager {
    
    let jsonDecoder = JSONDecoder()
    let fileHandler = FileHandler()
    let imageCompressionScale: CGFloat = 0.25
    
    // functions to call the APIs
    func downloadMoviePoster(url: URL, id: String, completion: @escaping(URL?, APIError?) -> ()) {
        Alamofire.request(URLRequest(url: url)).validate().responseData { res in
            switch res.result {
            case .failure:
                completion(nil, .apiError)
            case .success(let imageData):
                guard let image = UIImage(data: imageData), let compressedData = image.jpegData(compressionQuality: self.imageCompressionScale) else { return }
                do {
                    try compressedData.write(to: self.fileHandler.getPathForImage(id: id))
                    completion(self.fileHandler.getPathForImage(id: id), nil)
                } catch {
                    print(error)
                    completion(nil, .decodingError)
                }
            }
        }
    }
    
    func getTitlesFromSearch(query: String, completion: @escaping([String]?, APIError? ) -> ()) {
        Alamofire.request(APIs.titleautocomplete(query: query)).validate().responseJSON { json in
            switch json.result {
            case .failure:
                print("The API limit has expired, create a new free account. Sadly the API only supports 500 calls, you need to create a new Account and replace the apiKey variable above")
                completion(nil, .apiError)
            case .success(let jsonData):
                if let payload = jsonData as? [String:Any], let arrayData = payload["d"], let jsonData = try? JSONSerialization.data(withJSONObject: arrayData, options: .sortedKeys)  {
                    do {
                        let titles = try self.jsonDecoder.decode([SearchIds].self, from: jsonData)
                        let titleIds = titles.map { $0.id }
                        completion(titleIds, nil)
                    } catch {
                        print(error)
                        completion(nil, .decodingError)
                    }
                } else {
                    completion(nil, .networkError)
                }
            }
        }
    }
    
    func getPopularTitles(completion: @escaping([String]?, APIError?) -> ()) {
        Alamofire.request(APIs.popularTitles(regionCode: "IN")).validate().responseJSON { json in
            switch json.result {
            case .failure:
                print("The API limit has expired, create a new free account. Sadly the API only supports 500 calls, you need to create a new Account and replace the apiKey variable above")
                completion(nil, .apiError)
                break
            case .success(let jsonData):
                if let jsonData = try? JSONSerialization.data(withJSONObject: jsonData, options: .sortedKeys)  {
                    do {
                        let popularTitles = try self.jsonDecoder.decode([String].self, from: jsonData)
                        completion(popularTitles.map { $0.components(separatedBy: "/")[2] }, nil)
                    } catch {
                        print(error)
                        completion(nil, .decodingError)
                    }
                } else {
                    completion(nil, .networkError)
                }
            }
        }
    }
    
    func getComingSoonTitles(completion: @escaping([String]?, APIError?) -> ()) {
        Alamofire.request(APIs.moviesComingSoon).validate().responseJSON { json in
            switch json.result {
            case .failure:
                completion(nil, .apiError)
                break
            case .success(let jsonData):
                if let jsonData = try? JSONSerialization.data(withJSONObject: jsonData, options: .sortedKeys)  {
                    do {
                        let popularTitles = try self.jsonDecoder.decode([String].self, from: jsonData)
                        completion(popularTitles.map { $0.components(separatedBy: "/")[2] }, nil)
                    } catch {
                        print(error)
                        completion(nil, .decodingError)
                    }
                } else {
                    completion(nil, .networkError)
                }
            }
        }
    }
    
    func getTitlesMetaData(titleIds: [String], completion: @escaping([TitleMetaData]?, APIError?) -> ()) {
        Alamofire.request(APIs.getTitleMetaData(titleIds: titleIds)).validate().responseJSON { json in
            switch json.result {
            case .failure:
                print("The API limit has expired, create a new free account. Sadly the API only supports 500 calls, you need to create a new Account and replace the apiKey variable above")
                completion(nil, .apiError)
            case .success(let jsonData):
                if let payload = try? JSONSerialization.data(withJSONObject: jsonData, options: .sortedKeys) {
                    do {
                        let decodedData = try self.jsonDecoder.decode(DecodedTitleMetaData.self, from: payload)
                        completion(decodedData.titlesMetaData, nil)
                    } catch {
                        print(error)
                        completion(nil, .decodingError)
                    }
                } else {
                    completion(nil, .networkError)
                }
            }
        }
    }
    
    func getTitleDetails(titleId: String, completion: @escaping(TitleDetail?, APIError?) -> ()) {
        Alamofire.request(APIs.getTitleDetails(titleId: titleId)).validate().responseJSON { json in
            switch json.result {
            case .failure:
                completion(nil, .apiError)
            case .success(let jsonData):
                if let payload = try? JSONSerialization.data(withJSONObject: jsonData, options: .sortedKeys) {
                    do {
                        let titleDetails = try self.jsonDecoder.decode(TitleDetail.self, from: payload)
                        completion(titleDetails, nil)
                    } catch {
                        print(error)
                        completion(nil, .decodingError)
                    }
                } else {
                    completion(nil, .networkError)
                }
            }
        }
    }
    
    func getCastForTitle(titleId: String, completion: @escaping([String]?, APIError?) -> ()) {
        Alamofire.request(APIs.getCastForTitle(titleId: titleId)).validate().responseJSON { json in
            switch json.result {
            case .failure:
                print("The API limit has expired, create a new free account. Sadly the API only supports 500 calls, you need to create a new Account and replace the apiKey variable in the APIs enum")
                completion(nil, .apiError)
                break
            case .success(let jsonData):
                if let jsonData = try? JSONSerialization.data(withJSONObject: jsonData, options: .sortedKeys)  {
                    do {
                        let titleCast = try self.jsonDecoder.decode([String].self, from: jsonData)
                        completion(titleCast.map { $0.components(separatedBy: "/")[2] }, nil)
                    } catch {
                        print(error)
                        completion(nil, .decodingError)
                    }
                } else {
                    completion(nil, .networkError)
                }
            }
        }
    }
    
    func getMoviesForActor(actorId: String, completion: @escaping(ActorFilms?, APIError?) -> ()) {
        Alamofire.request(APIs.getFilmsForActor(actorId: actorId)).validate().responseJSON { json in
            switch json.result {
            case .failure:
                completion(nil, .apiError)
            case .success(let jsonData):
                if let payload = try? JSONSerialization.data(withJSONObject: jsonData, options: .sortedKeys) {
                    do {
                        let actorFilms = try self.jsonDecoder.decode(ActorFilms.self, from: payload)
                        completion(actorFilms, nil)
                    } catch {
                        print(error)
                        completion(nil, .decodingError)
                    }
                } else {
                    completion(nil, .networkError)
                }
            }
        }
    }
}
