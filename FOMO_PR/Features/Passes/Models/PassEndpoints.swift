import Foundation

enum PassEndpoint {
    case getAll
    case getDetails(id: String)
    case purchase
    case validate(id: String)
    case cancel(id: String)
    case getHistory
    case getActive
    case getUpcoming
    
    static let base = "passes"
    
    var path: String {
        switch self {
        case .getAll:
            return "/\(Self.base)"
        case .getDetails(let id):
            return "/\(Self.base)/\(id)"
        case .purchase:
            return "/\(Self.base)/purchase"
        case .validate(let id):
            return "/\(Self.base)/\(id)/validate"
        case .cancel(let id):
            return "/\(Self.base)/\(id)/cancel"
        case .getHistory:
            return "/\(Self.base)/history"
        case .getActive:
            return "/\(Self.base)/active"
        case .getUpcoming:
            return "/\(Self.base)/upcoming"
        }
    }
    
    var method: String {
        switch self {
        case .purchase, .validate, .cancel:
            return "POST"
        default:
            return "GET"
        }
    }
    
    var operationId: String {
        switch self {
        case .getAll: return "getAllPasses"
        case .getDetails: return "getPassDetails"
        case .purchase: return "purchasePass"
        case .validate: return "validatePass"
        case .cancel: return "cancelPass"
        case .getHistory: return "getPassHistory"
        case .getActive: return "getActivePasses"
        case .getUpcoming: return "getUpcomingPasses"
        }
    }
}

#if DEBUG
extension PassEndpoint {
    static let previewEndpoints: [PassEndpoint] = [
        .getAll,
        .getDetails(id: "pass_123"),
        .purchase,
        .getHistory,
        .getActive,
        .getUpcoming
    ]
}
#endif 