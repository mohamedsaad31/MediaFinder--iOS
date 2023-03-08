//
//  MapVC.swift
//  MediaFinder11
//
//  Created by mohamed saad on 22/12/2022.
//
import MapKit

protocol MessageDelegation: AnyObject {
    func sendMessage(message : String)
}
class MapVC: UIViewController {
    //MARK: - Outlets.
    @IBOutlet weak var userAddressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Propreties.
    private let locationManager = CLLocationManager()
    weak var delegate: MessageDelegation?
    
    //MARK: - Life Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationService()
    }
    override func viewDidAppear(_ animated: Bool) {
        centerMapOnCurrentLocation()
    }
    //MARK: - Actions.
    @IBAction func confirmBtnTapped(_ sender: UIButton) {
        let message = userAddressLabel.text ?? ""
        delegate?.sendMessage(message: message)
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: extension CLLocationManagerDelegate
extension MapVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let lat = mapView.centerCoordinate.latitude
        let long = mapView.centerCoordinate.latitude
        let location = CLLocation(latitude: lat, longitude: long)
        setAddress(from: location)
    }
}
//MARK: - private Methods.
extension MapVC{
    private func checkLocationService() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            showAlert(title: "Sorry", message: "Your location is disable. \nPlease enable it")
        }
    }
    private func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedAlways, .authorizedWhenInUse:
            //  centerMapTestLocation()
            centerMapOnCurrentLocation()
        case .restricted, .denied:
            showAlert(title: "Sorry", message: "Can't Get Location Open GPS. \n To Get Location")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            showAlert(title: "Sorry", message: "Error With Geting Location \n Try Again Later")
        }
    }
    /// for test
    //    private func centerMapTestLocation(){
    //        let location = CLLocation(latitude: 29.982611, longitude: 31.3162252)
    //        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
    //        mapView.setRegion(region, animated: true)
    //        setAddress(location: location)
    //    }
    private func centerMapOnCurrentLocation() {
        if let location = locationManager.location {
            let region = MKCoordinateRegion(center: location.coordinate,
                                            latitudinalMeters: 10000,
                                            longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
            setAddress(from: location)
        }
    }
    private func setAddress(from location : CLLocation){
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { placemark, error in
            if let error = error {
                print("Error is \(error)")
            }else if let firstPlaceMarks = placemark?.first {
                self.userAddressLabel.text = firstPlaceMarks.compactAddress
            }
        }
    }
}
