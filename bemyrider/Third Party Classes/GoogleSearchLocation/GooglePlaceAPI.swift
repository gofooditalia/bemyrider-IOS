//
//  GooglePlaceAPI.swift
//

import UIKit
import GooglePlaces

protocol GooglePlaceAPIDelegate {
    func didSelectedLocation(_ lat: CLLocationDegrees, _ long: CLLocationDegrees, _ addr: String)
}

class GooglePlaceAPI: NSObject {
    //Signtin object
    static let shared = GooglePlaceAPI()
    
    //MARK: - Internal Properties
    var googlePlaceBlock: ((_ lat: CLLocationDegrees, _ long: CLLocationDegrees, _ addr: String) -> Void)?
    var delegatePlace: GooglePlaceAPIDelegate?
    
    //Properties
    fileprivate var currentVC: UIViewController?
    
    func showGooglePlaceView(vc: UIViewController) {
        currentVC = vc
        self.delegatePlace = currentVC as? GooglePlaceAPIDelegate
        let ac = PlaceAutocompleteVC()
        ac.onPlaceSelected = { [weak self] address, lat, lng in
            guard let self = self else { return }
            self.googlePlaceBlock?(lat, lng, address)
            self.delegatePlace?.didSelectedLocation(lat, lng, address)
        }
        currentVC?.present(UINavigationController(rootViewController: ac), animated: true)
    }
}
