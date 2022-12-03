import Foundation
import UIKit

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
private enum DecodeError: Error {
    case codeError
}
struct MoviesLoader: MoviesLoading {
    private let networkClient = NetworkClient()
    
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/MostPopularMovies/k_ixqybnm5") else {
            preconditionFailure("Mnable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case.failure(let error):
                handler(.failure(error))
            case .success(let data):
                let movieList = try? JSONDecoder().decode(MostPopularMovies.self, from: data)
                if let movieList = movieList {
                    handler(.success(movieList))
                } else {
                    handler(.failure(DecodeError.codeError))
                }
            }
        }
    }
}
