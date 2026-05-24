import Foundation

class UserDataCache {
    static let shared = UserDataCache()
    private let defaults = UserDefaults.standard
    
    private let CACHE_EXPIRY_PREFIX = "cache_expiry_"
    private let USER_DATA_KEY = "cached_user_data"
    private let CATEGORIES_KEY = "cached_categories"
    private let CACHE_DURATION: TimeInterval = 3600 // 1 ora
    
    private init() {}
    
    // MARK: - User Data
    func cacheUserData(_ data: [String: Any]) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: data) {
            defaults.set(jsonData, forKey: USER_DATA_KEY)
            defaults.set(Date().timeIntervalSince1970 + CACHE_DURATION, forKey: CACHE_EXPIRY_PREFIX + USER_DATA_KEY)
        }
    }
    
    func getCachedUserData() -> [String: Any]? {
        guard let expiry = defaults.object(forKey: CACHE_EXPIRY_PREFIX + USER_DATA_KEY) as? TimeInterval,
              Date().timeIntervalSince1970 < expiry,
              let data = defaults.data(forKey: USER_DATA_KEY),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
    
    // MARK: - Categories
    func cacheCategories(_ categories: [[String: Any]]) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: categories) {
            defaults.set(jsonData, forKey: CATEGORIES_KEY)
            defaults.set(Date().timeIntervalSince1970 + (CACHE_DURATION * 24), forKey: CACHE_EXPIRY_PREFIX + CATEGORIES_KEY)
        }
    }
    
    func getCachedCategories() -> [[String: Any]]? {
        guard let expiry = defaults.object(forKey: CACHE_EXPIRY_PREFIX + CATEGORIES_KEY) as? TimeInterval,
              Date().timeIntervalSince1970 < expiry,
              let data = defaults.data(forKey: CATEGORIES_KEY),
              let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return nil
        }
        return json
    }
    
    // MARK: - Clear
    func clearAllCache() {
        defaults.removeObject(forKey: USER_DATA_KEY)
        defaults.removeObject(forKey: CATEGORIES_KEY)
    }
}
