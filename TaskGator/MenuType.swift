//
//  MenuType.swift
//  TaskGator
//

import Foundation

// Global dictionary used by ServiceDetailVC / innerServiceTabVC / ProviderFilterVC
// to pass the selected booking address across the service-detail flow.
var searchAddrDic: [String: String] = [:]
var is_from_myservices: Bool = false

enum MenuOption {
    case notifications
    case resolutionCenter
    case paymentHistory
    case accountSetting
    case information
    case feedback
    case contactUs
    case stripe
    case myServices
    case financialInfo
    case login
    case logout
}
