import Foundation

@objc class DataManager: NSObject {
    private static let sharedInstance = DataManager()

    @objc class func sharedManager() -> DataManager {
        return sharedInstance
    }

    private override init() {
        super.init()
    }
}
