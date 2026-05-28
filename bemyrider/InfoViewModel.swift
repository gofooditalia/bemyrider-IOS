//
//  InfoViewModel.swift
//  bemyrider
//
//  ViewModel for Info screen (CMS pages list).
//

import UIKit

@MainActor
final class InfoViewModel: ObservableObject {

    @Published var infoPages: [infoData] = []
    @Published var isLoading = false

    var onBack: (() -> Void)?
    var onTapPage: ((infoData) -> Void)?

    // MARK: - Load

    func load() {
        guard !isLoading else { return }
        isLoading = true

        Modal.shared.getcmsList(vc: UIViewController(), param: [:]) { [weak self] dic in
            DispatchQueue.main.async {
                self?.infoPages = ResponseKey.fatchDataAsArray(res: dic, valueOf: .data).map({ infoData(dictionary: $0 as! [String:Any]) })
                self?.isLoading = false
            }
        }
    }
}
