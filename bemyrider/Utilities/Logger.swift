import Foundation

enum Logger {
    #if DEBUG
    static func log(_ items: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        print("[\(fileName):\(line)] \(function):", items)
    }
    #else
    static func log(_ items: Any..., file: String = #file, function: String = #function, line: Int = #line) {}
    #endif
}
