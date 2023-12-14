import Foundation

public class TokenProvider {
    private var projectId: String
    private var secret: String

    private var tokenCached: TokenResponse?
    private var tokenExpire: Date?

    public init(projectId: String, secret: String) {
        self.projectId = projectId
        self.secret = secret
    }

    public func getToken(completion: @escaping (Result<TokenResponse, Error>) -> Void) {
        if let tokenExpire = tokenExpire, Date() < tokenExpire, let tokenCached = tokenCached {
            completion(.success(tokenCached))
            return
        }

        let requestHeaders = ["Authorization": encodeCredentials(projectId: projectId, secret: secret)]
        let requestData = "grant_type=client_credentials"
        let mediaType = "application/x-www-form-urlencoded"
        let now = Date().addingTimeInterval(-1)
        
        HttpHelper.shared.performRequest(url: Constants.authEndpoint, headers: requestHeaders,
                                         data: requestData, mediaType: mediaType, now: now, completion: {
            (result: Result<TokenResponse, Error>) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let tokenObject):
                if let accessToken = tokenObject.accessToken, !accessToken.isEmpty {
                    let exp: Double = Double(tokenObject.expires!)
                    self.tokenExpire = now.addingTimeInterval(exp)
                    self.tokenCached = tokenObject
                    completion(.success(tokenObject))
                } else {
                    completion(.failure(tokenObject.toError()))
                }
            }
        })
    }

    // TODO
    /*
    @available(iOS 15.0, *)
    public func getTokenAsync() async -> Result<TokenResponse, Error> {
        if let tokenExpire = tokenExpire, Date() < tokenExpire, let tokenCached = tokenCached {
            return .success(tokenCached)
        }
        
        let requestHeaders = ["Authorization": encodeCredentials(projectId: projectId, secret: secret)]
        let requestData = "grant_type=client_credentials"
        let mediaType = "application/x-www-form-urlencoded"
        let now = Date().addingTimeInterval(-1)
        
        do {
            let response: Result<TokenResponse, Error> = try await HttpHelper.shared.performRequestAsync(url: Constants.authEndpoint, 
                                                                               headers: requestHeaders,
                                                                               data: requestData, mediaType: mediaType, now: now)
            switch response {
            case .failure(let error):
                return .failure(error)
            case .success(let tokenObject):
                if let accessToken = tokenObject.accessToken, !accessToken.isEmpty {
                    let exp: Double = Double(tokenObject.expires!)
                    self.tokenExpire = now.addingTimeInterval(exp)
                    self.tokenCached = tokenObject
                    return .success(tokenObject)
                } else {
                    return .failure(tokenObject.toError())
                }
            }
        } catch let error {
            return .failure(error)
        }
    }*/
    
    private func encodeCredentials(projectId: String, secret: String) -> String {
        let credentials = "\(projectId):\(secret)"
        guard let data = credentials.data(using: .utf8) else { return "" }
        return "Basic \(data.base64EncodedString())"
    }
}
