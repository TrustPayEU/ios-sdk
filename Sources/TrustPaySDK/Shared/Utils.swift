import Foundation

class JsonHelper {
    public static var shared = JsonHelper()
    
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    func toJson<T: Encodable>(_ object: T) -> String? {
        guard let jsonData = try? jsonEncoder.encode(object) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }

    func fromJson<T: Decodable>(_ json: String, type: T.Type) -> T? {
        guard let jsonData = json.data(using: .utf8) else { return nil }
        return try? jsonDecoder.decode(T.self, from: jsonData)
    }
}

class HttpHelper {
    static let shared = HttpHelper()
    private var client: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        self.client = URLSession(configuration: config)
    }
    
    func performRequest<T: BaseResponse>(url: String, headers: [String: String], data: String? = nil,
                                         mediaType: String? = nil, now: Date? = nil,
                                         completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }

        if let data = data, !data.isEmpty, let mediaType = mediaType {
            print(data)
            request.httpMethod = "POST"
            request.httpBody = data.data(using: .utf8)
            request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        }

        client.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 
                    httpResponse.statusCode == 200,
                    let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            #if DEBUG
            print(String(bytes: data, encoding: String.Encoding.utf8) ?? "No Data")
            #endif
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                if decodedResponse.isSuccess() {
                    completion(.success(decodedResponse))
                } else {
                    completion(.failure(decodedResponse.toError()))
                }
            } catch let exception {
                print(exception.localizedDescription)
                completion(.failure(exception))
            }
        }.resume()
    }
    
    // TODO
    /*@available(iOS 15.0, *)
    func performRequestAsync<T: BaseResponse>(url: String, headers: [String: String], data: String? = nil,
                                              mediaType: String? = nil, now: Date? = nil) async throws -> Result<T, Error> {
        guard let url = URL(string: url) else {
            return .failure(URLError(.badURL))
        }

        var request = URLRequest(url: url)
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }

        if let data = data, !data.isEmpty, let mediaType = mediaType {
            print(data)
            request.httpMethod = "POST"
            request.httpBody = data.data(using: .utf8)
            request.addValue(mediaType, forHTTPHeaderField: "Content-Type")
        }

        do {
            let response = try await client.data(for: request)
            guard let httpResponse = response.1 as? HTTPURLResponse, 
                    httpResponse.statusCode == 200 else {
                return .failure(URLError(.badServerResponse))
            }
            
            let data = response.0
            
            #if DEBUG
            print(String(bytes: data, encoding: String.Encoding.utf8) ?? "No Data")
            #endif
            
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return.success(decodedResponse)

        } catch let error {
            return .failure(error)
        }
    }*/
}
