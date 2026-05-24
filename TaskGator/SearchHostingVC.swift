//
//  SearchHostingVC.swift
//  TaskGator
//
//  Hosting Controller for the modern Search & Filter view.
//

import UIKit
import SwiftUI

final class SearchHostingVC: UIViewController {

    // Properties exposed to emulate the old ProviderFilterVC routing
    weak var delegate: ProviderFilterDelegate?
    var paramList: [String: Any]?

    private let vm = SearchViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        vm.presentingVC = self
        
        // Populate initial data if we passed filters in
        vm.loadInitialData(existingParams: paramList)
        
        wireCallbacks()
        embedView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func wireCallbacks() {
        vm.onApplyFilter = { [weak self] params in
            self?.delegate?.getFilterData(dic: params)
            self?.navigationController?.popViewController(animated: true)
        }
        
        vm.onClearFilter = { [weak self] in
            self?.delegate?.clearFilter()
            self?.navigationController?.popViewController(animated: true)
        }
        
        vm.onOpenLocationPicker = { [weak self] in
            let ac = PlaceAutocompleteVC()
            ac.onPlaceSelected = { address, lat, lng in
                self?.vm.locationName = address
                self?.vm.latitude = "\(lat)"
                self?.vm.longitude = "\(lng)"
            }
            self?.present(UINavigationController(rootViewController: ac), animated: true)
        }
    }

    private func embedView() {
        let child = UIHostingController(rootView: SearchView(viewModel: vm))
        addChildViewController(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(child.view)
        
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        child.didMove(toParentViewController: self)
    }
}
