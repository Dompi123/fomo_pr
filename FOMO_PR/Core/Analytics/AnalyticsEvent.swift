import Foundation

public struct AnalyticsEvent {
    public let name: String
    public let metadata: [String: Any]
    public let timestamp: Date
    
    public init(name: String, metadata: [String: Any] = [:], timestamp: Date = Date()) {
        self.name = name
        self.metadata = metadata
        self.timestamp = timestamp
    }
}

extension AnalyticsEvent {
    static func networkRequest(_ metrics: [String: Any]) -> AnalyticsEvent {
        AnalyticsEvent(name: "network_request", metadata: metrics)
    }
    
    static func apiResponse(_ metrics: [String: Any]) -> AnalyticsEvent {
        AnalyticsEvent(name: "api_response", metadata: metrics)
    }
    
    static func apiError(_ metrics: [String: Any]) -> AnalyticsEvent {
        AnalyticsEvent(name: "api_error", metadata: metrics)
    }
    
    static let rateLimitExceeded = AnalyticsEvent(name: "rate_limit_exceeded")
    static let authFailure = AnalyticsEvent(name: "auth_failure")
    
    static func featureFlagChanged(flag: String, enabled: Bool) -> AnalyticsEvent {
        AnalyticsEvent(name: "feature_flag_changed", metadata: [
            "flag": flag,
            "enabled": enabled
        ])
    }
    
    static func sessionExpired(id: UUID) -> AnalyticsEvent {
        AnalyticsEvent(name: "session_expired", metadata: [
            "session_id": id.uuidString
        ])
    }
    
    static func environmentSynced(version: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "environment_synced", metadata: [
            "version": version
        ])
    }
    
    static func metricRecorded(metric: String, value: Double) -> AnalyticsEvent {
        AnalyticsEvent(name: "metric_recorded", metadata: [
            "metric": metric,
            "value": value
        ])
    }
    
    static func rollbackExecuted(reason: String) -> AnalyticsEvent {
        AnalyticsEvent(name: "rollback_executed", metadata: [
            "reason": reason
        ])
    }
} 