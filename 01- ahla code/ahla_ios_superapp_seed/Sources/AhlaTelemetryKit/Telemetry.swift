import Foundation

public struct Telemetry {
    public static func start(serviceName: String) {
        // Integrate OpenTelemetry Swift in the host app; export OTLP to collector endpoint.
    }
    public static func trace(_ name: String) {
        // add span here
    }
}
