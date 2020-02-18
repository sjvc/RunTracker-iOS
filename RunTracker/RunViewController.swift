//
//  RunViewController.swift
//  RunTracker
//
//  Created by Sergio Viudes Carbonell on 17/02/2020.
//  Copyright © 2020 Sergio Viudes Carbonell. All rights reserved.
//

import UIKit
import JJFloatingActionButton
import MapKit
import CoreLocation
import CoreData
import IVBezierPathRenderer

class RunViewController: UIViewController, JJFloatingActionButtonDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    enum RunStatus {
        case Stopped
        case Running
        case Paused
        case Stopping
    }
    
    let mapRegionRadius: CLLocationDistance = 500
    let debug = true
    
    var startRunFab : JJFloatingActionButton? = nil
    var pauseRunFab : JJFloatingActionButton? = nil
    var centerMapFab: JJFloatingActionButton? = nil
    var runStatus = RunStatus.Stopped
    
    let locationManager = LocationManager.shared
    var seconds = 0 // Duración del entrenamiento
    var timer: Timer? // Para actualizar la interfaz
    var distance = Measurement(value: 0, unit: UnitLength.meters) // Distancia del entrenamiento
    var locationList: [Location] = [] // Lista de ubicaciones
    var lastLocation: CLLocation? = nil
    var run: Run? // Último entrenamiento
    var autoCenterMapOnUserLocation = true // Si está a true, el mapa centra la vista en la ubicación del usuario
    var mapChangedFromUserInteraction = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createFabs()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        locationManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
            
        case .restricted, .denied:
            showPermissionAlert()
            break
            
        case .authorizedAlways, .authorizedWhenInUse:
            break
            
        @unknown default: break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        stopLocationUpdates()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.restricted || status == CLAuthorizationStatus.denied) {
            exit(0)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if runStatus != RunStatus.Running {
            return
        }
        
        for location in locations {
            // Descarto la ubicaciones sin precisión o antiguas
            let howRecent = location.timestamp.timeIntervalSinceNow
            guard location.horizontalAccuracy >= 0 && location.horizontalAccuracy < 20 && abs(howRecent) < 10 else {
                if debug {
                    print("Ubicación descartada: \(location.coordinate). Precisión: \(location.horizontalAccuracy). howRecent: \(howRecent)")
                }
                continue
            }
            
            // Crear code data managed object
            let locationObject = Location(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            locationObject.date = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            locationObject.isNewStart = lastLocation == nil
            
            // Incrementar distancia recorrida
            if lastLocation != nil {
                let delta = location.distance(from: lastLocation!)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
                
                mapView.addOverlay(MKPolyline(coordinates: [lastLocation!.coordinate, location.coordinate], count: 2))
            }
            
            // Guardar ubicación
            locationList.append(locationObject)
            lastLocation = location
            
            if debug {
                print("Ubicación almacenada: \(location.coordinate). Precisión: \(location.horizontalAccuracy). howRecent: \(howRecent)")
            }
        }
    }
    
    func showPermissionAlert() {
        let alertController = UIAlertController(title: "Permiso de ubicación", message: "Has de dar permiso de ubicación desde la pantalla de ajustes", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            exit(0)
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: mapRegionRadius, longitudinalMeters: mapRegionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func createFabs() {
        // START FLOATING ACTION BUTTON
        startRunFab = JJFloatingActionButton()
        startRunFab!.handleSingleActionDirectly = true
        startRunFab!.addItem(image: UIImage(systemName: "play.fill")) { item in
            self.setRunStatus(newStatus: RunStatus.Running)
        }
        startRunFab!.buttonDiameter = 64
        startRunFab!.buttonImageSize = CGSize(width: 32, height: 32)
        startRunFab!.buttonImage = UIImage(systemName: "play.fill")
        startRunFab!.buttonColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        startRunFab!.buttonImageColor = UIColor(red:0.30, green:0.69, blue:0.31, alpha:1.0)
        view.addSubview(startRunFab!)
        startRunFab!.translatesAutoresizingMaskIntoConstraints = false
        startRunFab!.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startRunFab!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        
        // PAUSE FLOATING ACTION BUTTON
        pauseRunFab = JJFloatingActionButton()
        pauseRunFab!.buttonAnimationConfiguration = JJButtonAnimationConfiguration.transition(toImage: UIImage(systemName: "play.fill")!)
        pauseRunFab!.handleSingleActionDirectly = false
        pauseRunFab!.addItem(image: UIImage(systemName: "stop.fill")) { item in
            self.setRunStatus(newStatus: RunStatus.Stopping)
        }
        pauseRunFab!.items[pauseRunFab!.items.count - 1].buttonColor = UIColor(red:0.96, green:0.26, blue:0.21, alpha:1.0)
        pauseRunFab!.items[pauseRunFab!.items.count - 1].buttonImageColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        
        pauseRunFab!.buttonDiameter = 64
        pauseRunFab!.buttonImageSize = CGSize(width: 32, height: 32)
        pauseRunFab!.buttonImage = UIImage(systemName: "pause.fill")
        pauseRunFab!.buttonColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        pauseRunFab!.buttonImageColor = UIColor(red:0.96, green:0.26, blue:0.21, alpha:1.0)
        pauseRunFab!.isHidden = true
        pauseRunFab!.delegate = self
        view.addSubview(pauseRunFab!)
        pauseRunFab!.translatesAutoresizingMaskIntoConstraints = false
        pauseRunFab!.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pauseRunFab!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        
        // CENTER MAP FLOATING ACTION BUTTON
        centerMapFab = JJFloatingActionButton()
        centerMapFab!.handleSingleActionDirectly = true
        centerMapFab!.addItem(image: UIImage(systemName: "location.fill")) { item in
            if (self.mapView.userLocation.location != nil) {
                self.centerMapOnLocation(location: self.mapView.userLocation.location!)
            }
            self.autoCenterMapOnUserLocation = true
            self.centerMapFab!.isHidden = true
        }
        centerMapFab!.buttonDiameter = 48
        centerMapFab!.buttonImageSize = CGSize(width: 24, height: 24)
        centerMapFab!.buttonImage = UIImage(systemName: "location.fill")
        centerMapFab!.buttonColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        centerMapFab!.buttonImageColor = UIColor(red:0.13, green:0.59, blue:0.95, alpha:1.0)
        centerMapFab!.isHidden = true
        view.addSubview(centerMapFab!)
        centerMapFab!.translatesAutoresizingMaskIntoConstraints = false
        centerMapFab!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        centerMapFab!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
    }
    
    func floatingActionButtonWillOpen(_ button: JJFloatingActionButton) {
        setRunStatus(newStatus: RunStatus.Paused)
    }
    
    func floatingActionButtonDidClose(_ button: JJFloatingActionButton) {
        if (runStatus == RunStatus.Paused) {
            setRunStatus(newStatus: RunStatus.Running)
        } else if (self.runStatus == RunStatus.Stopping) {
            setRunStatus(newStatus: RunStatus.Stopped)
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if (autoCenterMapOnUserLocation) {
            centerMapOnLocation(location: userLocation.location!)
        }
    }
    
    func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizer.State.began || recognizer.state == UIGestureRecognizer.State.ended ) {
                    return true
                }
            }
        }
        return false
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        if (mapChangedFromUserInteraction) {
            self.autoCenterMapOnUserLocation = false
            centerMapFab!.isHidden = false
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = IVBezierPathRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red:0.17, green:0.47, blue:0.96, alpha:1.0)
        renderer.lineWidth = 18
        // renderer.borderColor = renderer.strokeColor
        // renderer.borderMultiplier = 1.5
        return renderer
    }

private func startLocationUpdates() {
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.activityType = .fitness
    locationManager.distanceFilter = 10
    locationManager.startUpdatingLocation()
}

private func stopLocationUpdates() {
    locationManager.stopUpdatingLocation()
}

func setRunStatus(newStatus: RunStatus) {
    if (newStatus == self.runStatus) {
        return
    }
    
    if debug {
        print("Cambio de estado: \(self.runStatus) -> \(newStatus)")
    }
    
    startRunFab?.isHidden = newStatus != RunStatus.Stopped
    pauseRunFab?.isHidden = !startRunFab!.isHidden
    pauseRunFab?.buttonImage = newStatus == RunStatus.Paused || newStatus == RunStatus.Stopping ? UIImage(systemName: "play.fill") : UIImage(systemName: "pause.fill")
    pauseRunFab!.buttonImageColor = newStatus == RunStatus.Paused || newStatus == RunStatus.Stopping ? UIColor(red:0.30, green:0.69, blue:0.31, alpha:1.0) : UIColor(red:0.96, green:0.26, blue:0.21, alpha:1.0)
    
    switch newStatus {
    case RunStatus.Running:
        if self.runStatus == RunStatus.Stopped {
            seconds = 0
            distance = Measurement(value: 0, unit: UnitLength.meters)
            locationList.removeAll()
            mapView.removeOverlays(mapView.overlays)
        }
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        lastLocation = nil
        startLocationUpdates()
        break
        
    case RunStatus.Paused:
        timer?.invalidate()
        stopLocationUpdates()
        break
        
    case RunStatus.Stopped:
        timer?.invalidate()
        stopLocationUpdates()
        saveRun()
        break
        
    default:
        break
    }
    
    self.runStatus = newStatus
}

private func saveRun() {
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let newRun = Run(context: managedContext)
    newRun.distance = distance.value
    newRun.duration = Int32(seconds)
    newRun.date = Date()
    for location in locationList {
        newRun.addToLocations(location)
    }
    
    try! managedContext.save()
    
    run = newRun
}

func eachSecond() {
    seconds += 1
    updateDisplay()
}

private func updateDisplay() {
    //        let formattedDistance = FormatDisplay.distance(distance)
    //        let formattedTime = FormatDisplay.time(seconds)
    //        let formattedPace = FormatDisplay.pace(distance: distance,
    //                                               seconds: seconds,
    //                                               outputUnit: UnitSpeed.minutesPerMile)
    //
    //        distanceLabel.text = "Distance:  \(formattedDistance)"
    //        timeLabel.text = "Time:  \(formattedTime)"
    //        paceLabel.text = "Pace:  \(formattedPace)"
}

}
