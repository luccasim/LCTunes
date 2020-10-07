//
//  ItuneAPI.swift
//  itunesAPI
//
//  Created by owee on 06/10/2020.
//

import Foundation

protocol ItunesAPIInterface {
    func taskMovie(Term:String, Callback: @escaping((Result<LCItunesAPI.MovieReponse, Error>) -> Void))
}

public final class LCItunesAPI : ItunesAPIInterface {

    static let shared = LCItunesAPI()
    
    private let session : URLSession
    
    public init(Session:URLSession?=nil) {
        self.session = Session ?? .shared
    }
    
    enum Endpoint {
        
        case movie(term:String)
        
        /// Note: URL encoding replaces spaces with the plus (+) character and all characters except the following are encoded: letters, numbers, periods (.), dashes (-), underscores (_), and asterisks (*).
        var uri : String {
            let base = "https://itunes.apple.com/search?"
            switch self {
            case .movie(let term):
                let enc = term.replacingOccurrences(of: " ", with: "+")
                return base + "term=\(enc)&media=movie"
            }
        }
    }
    
    enum APIError : Error {
        case unvalidURI
    }
    
    func request(Endpoint:Endpoint) -> URLRequest? {
        guard let url = URLComponents(string: Endpoint.uri)?.url else {
            return nil
        }
        
        return URLRequest(url: url)
    }
    
    func task<Reponse:Codable>(Request:URLRequest, Completion:@escaping (Result<Reponse,Error>) -> Void) {
        
        self.session.dataTask(with: Request) { (Data, Rep, Err) in
            
            if let error = Err {
                return Completion(.failure(error))
            }
            
            else if let data = Data {
                
                do {
                    
                    let reponse = try JSONDecoder().decode(Reponse.self, from: data)
                    Completion(.success(reponse))
                    
                } catch let error  {
                    Completion(.failure(error))
                }
            }
            
        }.resume()
    }
}

public extension LCItunesAPI {
    
    func taskMovie(Term:String, Callback: @escaping((Result<LCItunesAPI.MovieReponse, Error>) -> Void)) {

        guard let request = self.request(Endpoint: Endpoint.movie(term: Term)) else {
            return Callback(.failure(APIError.unvalidURI))
        }
        
        self.task(Request: request, Completion: Callback)
    }
    
    // MARK: - MovieReponse
    struct MovieReponse: Codable {
        public let resultCount: Int
        public let results: [Results]
    }

    // MARK: - Result
    struct Results: Codable {
        
        public let wrapperType: WrapperType
        public let kind: Kind
        public let collectionID: Int?
        public let trackID: Int
        public let artistName: String
        public let collectionName: String?
        public let trackName: String
        public let collectionCensoredName: String?
        public let trackCensoredName: String
        public let collectionArtistID: Int?
        public let collectionArtistViewURL, collectionViewURL: String?
        public let trackViewURL: String
        public let previewURL: String
        public let artworkUrl30, artworkUrl60, artworkUrl100: String
        public let collectionPrice, trackPrice, trackRentalPrice, collectionHDPrice: Double
        public let trackHDPrice, trackHDRentalPrice: Double
        public let releaseDate: String
        public let collectionExplicitness, trackExplicitness: Explicitness
        public let discCount, discNumber, trackCount, trackNumber: Int?
        public let trackTimeMillis: Int
        public let country: Country
        public let currency: Currency
        public let primaryGenreName: String
        public let contentAdvisoryRating: ContentAdvisoryRating
        public let longDescription: String
        public let hasITunesExtras: Bool?
        public let shortDescription: String?

        enum CodingKeys: String, CodingKey {
            case wrapperType, kind
            case collectionID = "collectionId"
            case trackID = "trackId"
            case artistName, collectionName, trackName, collectionCensoredName, trackCensoredName
            case collectionArtistID = "collectionArtistId"
            case collectionArtistViewURL = "collectionArtistViewUrl"
            case collectionViewURL = "collectionViewUrl"
            case trackViewURL = "trackViewUrl"
            case previewURL = "previewUrl"
            case artworkUrl30, artworkUrl60, artworkUrl100, collectionPrice, trackPrice, trackRentalPrice
            case collectionHDPrice = "collectionHdPrice"
            case trackHDPrice = "trackHdPrice"
            case trackHDRentalPrice = "trackHdRentalPrice"
            case releaseDate, collectionExplicitness, trackExplicitness, discCount, discNumber, trackCount, trackNumber, trackTimeMillis, country, currency, primaryGenreName, contentAdvisoryRating, longDescription, hasITunesExtras, shortDescription
        }
    }
    
    enum Explicitness: String, Codable {
        case notExplicit = "notExplicit"
    }

    enum ContentAdvisoryRating: String, Codable {
        case nr = "NR"
        case pg13 = "PG-13"
        case r = "R"
        case unrated = "Unrated"
    }

    enum Country: String, Codable {
        case usa = "USA"
    }

    enum Currency: String, Codable {
        case usd = "USD"
    }

    enum Kind: String, Codable {
        case featureMovie = "feature-movie"
    }

    enum WrapperType: String, Codable {
        case track = "track"
    }
}
