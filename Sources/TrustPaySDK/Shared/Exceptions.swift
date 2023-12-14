extension String: Error {}
//extension String: LocalizedError {}


import Foundation
public struct TpApiError: Error {
    public var correlationId: UUID?
    public var resultCode: Int64?
    public var additionalInfo: String
    
    public init(correlationId: UUID?, resultCode: Int64?, additionalInfo: String) {
        self.correlationId = correlationId
        self.resultCode = resultCode
        self.additionalInfo = additionalInfo
    }
    
    public init() {
        self.additionalInfo = "No info provided"
    }
}
