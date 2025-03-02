import Foundation

enum OrderEndpoint {
    case getAll
    case getDetails(id: String)
    case create
    case cancel(id: String)
    case getHistory
    case getActive
    case getUpcoming
    case getReceipt(id: String)
    
    static let base = "orders"
    
    var path: String {
        switch self {
        case .getAll:
            return "/\(Self.base)"
        case .getDetails(let id):
            return "/\(Self.base)/\(id)"
        case .create:
            return "/\(Self.base)/create"
        case .cancel(let id):
            return "/\(Self.base)/\(id)/cancel"
        case .getHistory:
            return "/\(Self.base)/history"
        case .getActive:
            return "/\(Self.base)/active"
        case .getUpcoming:
            return "/\(Self.base)/upcoming"
        case .getReceipt(let id):
            return "/\(Self.base)/\(id)/receipt"
        }
    }
    
    var method: String {
        switch self {
        case .create, .cancel:
            return "POST"
        default:
            return "GET"
        }
    }
    
    var operationId: String {
        switch self {
        case .getAll: return "getAllOrders"
        case .getDetails: return "getOrderDetails"
        case .create: return "createOrder"
        case .cancel: return "cancelOrder"
        case .getHistory: return "getOrderHistory"
        case .getActive: return "getActiveOrders"
        case .getUpcoming: return "getUpcomingOrders"
        case .getReceipt: return "getOrderReceipt"
        }
    }
}

#if DEBUG
extension OrderEndpoint {
    static let previewEndpoints: [OrderEndpoint] = [
        .getAll,
        .getDetails(id: "order_123"),
        .create,
        .getHistory,
        .getActive,
        .getUpcoming,
        .getReceipt(id: "order_123")
    ]
}
#endif 