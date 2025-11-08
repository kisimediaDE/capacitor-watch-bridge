import XCTest

@testable import WatchBridgePlugin

class WatchBridgePluginTests: XCTestCase {

    func testSyncJsonWithoutAppGroupIdThrows() {
        XCTAssertThrowsError(
            try WatchBridge.shared.syncJson(appGroupId: nil, key: "test", json: "{}")
        ) { error in
            guard case WatchBridgeError.appGroupIdMissing = error else {
                XCTFail("Expected WatchBridgeError.appGroupIdMissing, got \(error)")
                return
            }
        }
    }

    func testAvailabilityContainsAllKeys() {
        let availability = WatchBridge.shared.availability()

        XCTAssertNotNil(availability["supported"], "supported key should be present")
        XCTAssertNotNil(availability["paired"], "paired key should be present")
        XCTAssertNotNil(availability["appInstalled"], "appInstalled key should be present")
    }
}
