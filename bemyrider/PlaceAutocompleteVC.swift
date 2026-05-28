//
//  PlaceAutocompleteVC.swift
//  bemyrider
//
//  Drop-in replacement for the deprecated GMSAutocompleteViewController.
//  Uses the programmatic Places API (compatible with GooglePlaces 8.5 and 9.x).
//  Present wrapped in UINavigationController.
//
//  Usage:
//    let ac = PlaceAutocompleteVC()
//    ac.onPlaceSelected = { address, lat, lng in ... }
//    present(UINavigationController(rootViewController: ac), animated: true)
//

import UIKit
import GooglePlaces

final class PlaceAutocompleteVC: UIViewController {

    var onPlaceSelected: ((_ address: String, _ latitude: Double, _ longitude: Double) -> Void)?

    // MARK: - Private

    private let searchBar   = UISearchBar()
    private let tableView   = UITableView()
    private let spinner     = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    private var predictions: [GMSAutocompletePrediction] = []
    private let placesClient = GMSPlacesClient.shared()
    private var sessionToken = GMSAutocompleteSessionToken()
    private var searchWorkItem: DispatchWorkItem?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Cerca indirizzo"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        setupSearchBar()
        setupTableView()
        setupSpinner()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

// MARK: - Layout

private extension PlaceAutocompleteVC {

    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Cerca un indirizzo…"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func setupTableView() {
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupSpinner() {
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20)
        ])
    }
}

// MARK: - Autocomplete logic

private extension PlaceAutocompleteVC {

    func fetchPredictions(for query: String) {
        searchWorkItem?.cancel()
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            predictions = []
            tableView.reloadData()
            return
        }
        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.spinner.startAnimating()
            let filter = GMSAutocompleteFilter()
            self.placesClient.findAutocompletePredictions(
                fromQuery: query,
                filter: filter,
                sessionToken: self.sessionToken
            ) { [weak self] results, _ in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.spinner.stopAnimating()
                    self.predictions = results ?? []
                    self.tableView.reloadData()
                }
            }
        }
        searchWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: work)
    }

    func selectPrediction(_ prediction: GMSAutocompletePrediction) {
        spinner.startAnimating()
        let fields = GMSPlaceField(rawValue:
            GMSPlaceField.formattedAddress.rawValue |
            GMSPlaceField.coordinate.rawValue)
        placesClient.fetchPlace(
            fromPlaceID: prediction.placeID,
            placeFields: fields,
            sessionToken: sessionToken
        ) { [weak self] place, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.spinner.stopAnimating()
                guard let place = place else { return }
                let address = place.formattedAddress ?? ""
                let lat     = place.coordinate.latitude
                let lng     = place.coordinate.longitude
                self.sessionToken = GMSAutocompleteSessionToken()   // reset after fetch
                self.dismiss(animated: true) {
                    self.onPlaceSelected?(address, lat, lng)
                }
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension PlaceAutocompleteVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        fetchPredictions(for: searchText)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDataSource / Delegate

extension PlaceAutocompleteVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        predictions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let pred = predictions[indexPath.row]
        cell.textLabel?.text          = pred.attributedFullText.string
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font          = UIFont.systemFont(ofSize: 14)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectPrediction(predictions[indexPath.row])
    }
}
