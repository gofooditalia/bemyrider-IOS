//
//  APIClient.swift
//  TaskGator
//
//  Async/await networking layer for new SwiftUI screens.
//  UIKit screens continue to use Modal.swift / WebRequester.swift unchanged.
//

import Foundation

// MARK: - Error

struct APIError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

// MARK: - Codable models

struct PhoneCountry: Decodable, Identifiable {
    let id: String
    let country_name: String
    let country_code: String
}

// MARK: - Client

final class APIClient {

    static let shared = APIClient()
    private init() {}

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60

        // CACHE
        config.urlCache = URLCache(
            memoryCapacity: 10_000_000,  // 10 MB
            diskCapacity: 50_000_000,    // 50 MB
            diskPath: "api_cache"
        )
        config.requestCachePolicy = .returnCacheDataElseLoad

        // PERFORMANCE
        config.waitsForConnectivity = true
        config.httpMaximumConnectionsPerHost = 6

        return URLSession(configuration: config)
    }()

    // Sessione con timeout esteso per operazioni lunghe (es. bulk invoice)
    private let sessionLongTimeout: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        config.timeoutIntervalForResource = 180
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()
    
    // Sessione senza cookie per chiamate fire-and-forget
    private let sessionNoCookies: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 30
        config.httpShouldSetCookies = false
        config.urlCache = URLCache(
            memoryCapacity: 5_000_000,
            diskCapacity: 25_000_000,
            diskPath: "api_cache_no_cookies"
        )
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }()

    // MARK: - Core

    /// POST form-encoded request.
    /// Injects `lId` and `login_userid` automatically (mirrors Modal.addLanguageId).
    /// Throws `APIError` on network failure or when the server returns `status: false`.
    /// Returns the full response envelope as `[String: Any]` on success.
    func post(_ path: String, params: [String: Any] = [:], useCookies: Bool = true, useLongTimeout: Bool = false) async throws -> [String: Any] {
        var allParams = params
        allParams["lId"] = UserData.shared.languageID
        if let user = UserData.shared.getUser(), !user.user_id.isEmpty {
            allParams["login_userid"] = user.user_id
        }

        guard let url = URL(string: Domain.main + path) else {
            throw APIError(message: "Invalid URL: \(Domain.main + path)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var allowedCharacters = CharacterSet.urlQueryAllowed
        allowedCharacters.remove(charactersIn: "+&=")

        request.httpBody = allParams
            .sorted { $0.key < $1.key }
            .compactMap { key, value -> String? in
                guard
                    let k = key.addingPercentEncoding(withAllowedCharacters: allowedCharacters),
                    let v = "\(value)".addingPercentEncoding(withAllowedCharacters: allowedCharacters)
                else { return nil }
                return "\(k)=\(v)"
            }
            .joined(separator: "&")
            .data(using: .utf8)

        let activeSession: URLSession
        if useLongTimeout {
            activeSession = sessionLongTimeout
        } else if useCookies {
            activeSession = session
        } else {
            activeSession = sessionNoCookies
        }

        let data: Data = try await withCheckedThrowingContinuation { continuation in
            activeSession.dataTask(with: request) { data, _, error in
                if let error = error {
                    continuation.resume(throwing: APIError(message: error.localizedDescription))
                } else {
                    continuation.resume(returning: data ?? Data())
                }
            }.resume()
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError(message: "Invalid server response")
        }

        let status = json["status"] as? Bool ?? false
        guard status else {
            throw APIError(message: json["message"] as? String ?? "Request failed")
        }
        return json
    }
}

// MARK: - Auth

extension APIClient {

    func login(email: String, password: String) async throws -> [String: Any] {
        try await post(EndPoint.login, params: [
            "email": email,
            "password": password,
            "device_type": "i",
            "device_token": UserData.shared.deviceToken
        ])
    }

    func socialLogin(params: [String: Any]) async throws -> [String: Any] {
        var p = params
        p["device_type"] = "i"
        p["device_token"] = UserData.shared.deviceToken
        return try await post(EndPoint.socialLogin, params: p)
    }

    func socialSignUp(params: [String: Any]) async throws -> [String: Any] {
        var p = params
        p["device_type"] = "i"
        p["device_token"] = UserData.shared.deviceToken
        return try await post(EndPoint.socialSignUp, params: p)
    }

    func signUp(params: [String: Any]) async throws -> [String: Any] {
        var p = params
        p["device_type"] = "i"
        p["device_token"] = UserData.shared.deviceToken
        return try await post(EndPoint.register, params: p)
    }

    func forgotPassword(email: String) async throws -> String {
        let response = try await post(EndPoint.forgotPassword, params: ["email": email])
        return response["message"] as? String ?? ""
    }

    func resendActivation(email: String) async throws -> String {
        let response = try await post(EndPoint.resendMail, params: ["email": email])
        return response["message"] as? String ?? ""
    }

    func changePassword(userId: String, currentPassword: String, newPassword: String, confirmPassword: String) async throws -> String {
        let response = try await post(EndPoint.changepassword, params: [
            "user_id": userId,
            "currentpwd": currentPassword,
            "newpwd": newPassword,
            "renewpwd": confirmPassword
        ])
        return response["message"] as? String ?? "Password cambiata con successo"
    }

    /// Send a text-only chat message in the background (no blocking overlay).
    /// Returns the sent `Message` data dict on success.
    /// Uses `useCookies: false` to avoid locking the backend PHP session,
    /// so the user can navigate freely to other tabs immediately.
    func sendTextMessage(params: [String: Any]) async throws -> [String: Any] {
        let response = try await post(EndPoint.sendMessage, params: params, useCookies: false)
        return response["data"] as? [String: Any] ?? [:]
    }

    func getCountryCodes() async throws -> [PhoneCountry] {
        let response = try await post(EndPoint.getCountryCode)
        let raw = response["data"] as? [[String: Any]] ?? []
        return try raw.map { dict in
            let data = try JSONSerialization.data(withJSONObject: dict)
            return try JSONDecoder().decode(PhoneCountry.self, from: data)
        }
    }
    
    func getUserProfile(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.profile, params: params)
    }

    func getWalletDetails(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.walletDetail, params: params)
    }

    func getRedeemHistory(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.redeemHistory, params: params)
    }
    
    func redeemRequest(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.redeemRequest, params: params)
    }

    func getProviderServiceData(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.providerservice, params: params)
    }

    func getSiteSettings() async throws -> [String: Any] {
        return try await post(EndPoint.getSiteSettingDataIos, params: [:])
    }

    func getServiceList(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.serviceList, params: params)
    }

    func getFavoriteService(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.getFavoriteService, params: params)
    }

    func getNotificationListing(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.getNotificationListing, params: params)
    }

    func getNotificationSettings(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.getNotificationList, params: params)
    }

    func updateNotificationSettings(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.updatenotification, params: params)
    }

    func getProviderList(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.providerList, params: params)
    }

    func getProviderServices(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.providerServices, params: params)
    }

    func getProviderServiceDetail(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.providerServiceDetail, params: params)
    }

    func getCustomerServices(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.getService, params: params)
    }

    func getProviderTasks(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.providerTasks, params: params)
    }

    func likeDislikeService(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.likeDislikeServices, params: params)
    }

    func updateAvailableStatus(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.updateavAvailablestatus, params: params)
    }

    func raiseDispute(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.raisedDispute, params: params)
    }

    func escalateToAdmin(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.escalateToAdmin, params: params)
    }

    func getDisputeDetails(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.getDisputedetails, params: params)
    }

    func sendDisputeMessage(params: [String: Any]) async throws -> [String: Any] {
        return try await post(EndPoint.sendDisputeMessage, params: params)
    }

    /// Download bulk invoices for a period as a ZIP file
    /// - Parameters:
    ///   - period: "last_week", "last_month", or "custom"
    ///   - dateFrom: Start date in "YYYY-MM-DD" format (required if period is "custom")
    ///   - dateTo: End date in "YYYY-MM-DD" format (required if period is "custom")
    /// - Returns: Dictionary containing "file_name" (ZIP URL) and "count" (number of invoices)
    /// - Throws: APIError if request fails or no bookings found
    func downloadBulkInvoices(period: String, dateFrom: String? = nil, dateTo: String? = nil) async throws -> [String: Any] {
        guard let user = UserData.shared.getUser() else {
            throw APIError(message: "User not logged in")
        }

        var params: [String: Any] = [
            "user_id": user.user_id,
            "user_type": user.user_type,
            "period": period
        ]

        if period == "custom", let from = dateFrom, let to = dateTo {
            params["date_from"] = from
            params["date_to"] = to
        }

        // Usa timeout esteso per la generazione di molti PDF
        let response = try await post(EndPoint.bulkInvoices, params: params, useLongTimeout: true)
        return response["data"] as? [String: Any] ?? [:]
    }
}
