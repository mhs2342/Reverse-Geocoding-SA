//  Reverse-Geocoding
//
//  Created by Matthew Sanford on 6/19/18.
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    let manager = CLLocationManager()
    let addressMarker = AddressMarkerView(frame: .zero)

    // All of these properties in the closure are run and evaluated when they are first referenced in the app
    let mapView: MKMapView = {
        // initialize map with zero frame since we are going to set constraints
        let map = MKMapView(frame: .zero)
        map.translatesAutoresizingMaskIntoConstraints = false
        map.userTrackingMode = .follow
        map.showsUserLocation = false
        return map
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reverse Geocoding"
        view.backgroundColor = .white
        view.addSubview(mapView)

        mapView.delegate = self

        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()

        createAnnotation()
        setupConstraints()
    }

    // For performance reasons, we won't add the annotation to the map itself, but rather place
    // the annotation as a subview of self.view that is constrained to the center of the map
    // we do this so we can leverage the mapView.centerCoordinate property later on
    private func createAnnotation() {
        view.addSubview(addressMarker)
        view.bringSubview(toFront: addressMarker)
        addressMarker.isHidden = true
    }
}

// Follow single responsibilty pattern for location manager delegate
extension ViewController: CLLocationManagerDelegate {

    // Here we get the users location, and subsequently zoom into a calculated region
    // with the user's location at the center
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let mostRecentLocation = locations.first {

            // One degree of change is ~69 miles (111 Km) near the equator
            // 69 * 0.005 gives about a 1.5 mile bounding box around the zoomed in location
            let delta = 0.005
            let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            let region = MKCoordinateRegion(center: mostRecentLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    // If authorization alert is not acted upon immediately
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.requestLocation()
            UIView.animate(withDuration: 0.5) {
                self.addressMarker.isHidden = false
            }
        } else {
            let alert = UIAlertController(title: "Womp",
                                          message: "This app needs location authorization to perform the reverse geolocation",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            present(alert, animated: true)
            manager.requestWhenInUseAuthorization()
        }
    }

    // Should definitely handle the failure if you're planning to "productionize" this
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// Follow single responsibility pattern for map delegate
extension ViewController: MKMapViewDelegate {
    /*
     When the map view stops moving, start reverse geocoding for the location
     the marker is at, which is conveniently placed above the exact center of the
     screen.
     */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let centerCoordinate = mapView.centerCoordinate
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude,
                                        longitude: centerCoordinate.longitude)

        // Perform computation on location and hope to get an address back
        getAddressForLocation(centerLocation) { (address) in
            guard let address = address else {
                self.addressMarker.addressLabel.text = "Try dragging to a new area"
                return
            }
            self.addressMarker.toggleLoadingState(isSearching: false)
            self.addressMarker.addressLabel.text = address
        }
    }

    /*
     Whenever the map view is about to start moving, show the loading state
     */
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        addressMarker.toggleLoadingState(isSearching: true)
    }

    /*
     We want to put in a location, and get back an address formatted in this way:
     1234 streetname.
     City, State, 12345
     When the function is done working and has found either an address or has hit an error,
     we are going to pass either the address or nil to the completion handler, so the caller
     of the function will be responsible for doing something with the result we give it.
     */
    func getAddressForLocation(_ location: CLLocation, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil {
                completion(nil)
                return
            }
            // If for some reason there is not an error but no placemarks, this is undefined
            // behavior and should notify the caller of the function
            guard let placemarks = placemarks, let first = placemarks.first else {
                completion("Couldn't determine address")
                return
            }

            // We are going to build the address string as we parse the placemark
            // -> If the placemark has x property, add that to the address, if it doesn't add nothing
            var address = ""
            if let subThoroughfare = first.subThoroughfare {
                address.append("\(subThoroughfare) ")
            }
            if let thoroughfare = first.thoroughfare {
                address.append("\(thoroughfare).\n")
            }
            if let locality = first.locality {
                address.append("\(locality), ")
            }
            if let administrativeArea = first.administrativeArea {
                address.append("\(administrativeArea). ")
            }
            if let postalCode = first.postalCode {
                address.append("\(postalCode)")
            }
            completion(address)
        }
    }
}

