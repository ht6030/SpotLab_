import Foundation

@objc class URLCodec: NSObject {
    @objc class func encode(_ str: String) -> String {
        let allowed = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]").inverted
        return str.addingPercentEncoding(withAllowedCharacters: allowed) ?? str
    }

    @objc class func decode(_ str: String) -> String {
        return str.removingPercentEncoding ?? str
    }
}
