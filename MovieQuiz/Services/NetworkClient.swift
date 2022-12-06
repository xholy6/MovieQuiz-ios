import Foundation

struct NetworkClient {
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                handler(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            do {
                if let data = data {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    let errorMessage = json?["errorMessage"] as? String
                    if  errorMessage != ""
                    {
                        handler(.failure(NetworkError.codeError))
                        return
                    }
                    handler(.success(data))
                }
            } catch {
                handler(.failure(error))
            }
        }
        
        task.resume()
    }
}
