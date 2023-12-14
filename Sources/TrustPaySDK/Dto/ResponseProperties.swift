import Foundation
import SwiftUI

public class BaseResponse: Decodable {
    public var resultInfo: ResultInfo?
    
    public enum CodingKeys: String, CodingKey {
        case resultInfo = "ResultInfo"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.resultInfo = try container.decodeIfPresent(ResultInfo.self, forKey: .resultInfo)
    }
    
    public func isSuccess() -> Bool {
        resultInfo?.resultCode == 1001000
    }
    
    public func toError() -> TpApiError {
        guard let info = self.resultInfo else {
            return TpApiError()
        }
        return TpApiError(correlationId: info.correlationId, resultCode: info.resultCode, additionalInfo: info.additionalInfo!)
    }
}

public struct ResultInfo: Decodable {
    public var resultCode: Int64?
    public var correlationId: UUID?
    public var additionalInfo: String?
    
    enum CodingKeys: String, CodingKey {
        case resultCode = "ResultCode"
        case correlationId = "CorrelationId"
        case additionalInfo = "AdditionalInfo"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.resultCode = try container.decodeIfPresent(Int64.self, forKey: .resultCode)
        self.correlationId = try container.decodeIfPresent(UUID.self, forKey: .correlationId)
        self.additionalInfo = try container.decodeIfPresent(String.self, forKey: .additionalInfo)
    }
}

public class TokenResponse: BaseResponse {
    public var accessToken: String?
    public var tokenType: String?
    public var expires: Int?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token", tokenType = "token_type", expires = "expires_in"
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
        self.tokenType = try container.decodeIfPresent(String.self, forKey: .tokenType)
        self.expires = try container.decodeIfPresent(Int.self, forKey: .expires)
    }
}

public class PaymentResponse: BaseResponse {
    public var paymentRequestId: Int64?
    public var gatewayUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case paymentRequestId = "PaymentRequestId",
             gatewayUrl = "GatewayUrl"
    }
      
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.paymentRequestId = try container.decodeIfPresent(Int64.self, forKey: .paymentRequestId)
        self.gatewayUrl = try container.decodeIfPresent(String.self, forKey: .gatewayUrl)
    }
    
    @ViewBuilder public func getGatewayView(redirectUrl: String, closeFunction: @escaping (RedirectParameters) -> Void) -> some View {
        if self.gatewayUrl != nil, self.gatewayUrl?.isEmpty == false {
            let paymentViewModel = PaymentViewModel(paymentUrl: URL(string: self.gatewayUrl!)!, redirectUrl: URL(string: redirectUrl)!, afterRedirectFunction: closeFunction, isLoading: true)
            PaymentView(viewModel: paymentViewModel)
                .navigationBarBackButtonHidden()
        }
        EmptyView()
    }
}
