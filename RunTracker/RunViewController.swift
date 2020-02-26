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
import CoreMotion
import CoreData
import IVBezierPathRenderer

// TODO: AutoPause con detector de actividad de CoreMotion (nos indica qué actividad estamos haciendo). ¿O usar GPS?

class RunViewController: UIViewController, JJFloatingActionButtonDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
 
    @IBOutlet weak var dataContainerView: UIView!
    
    @IBOutlet weak var secondsLabel: UILabel! // Tiempo en HH:MM
    @IBOutlet weak var kmLabel: UILabel!   // Distancia en kilómetros
    @IBOutlet weak var mpkLabel: UILabel!  // Ritmo (Minutos Por Kilómetro)
    @IBOutlet weak var spmLabel: UILabel!  // Cadencia (Pasos Por Minuto)
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var cadenceLabel: UILabel!
    
    @IBOutlet weak var bigLabelIconImage: UIImageView!
    
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
    
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    
    var runResumeDate : Date?
    let locationManager = LocationManager.shared
    var seconds = 0 // Duración del entrenamiento
    var timer: Timer? // Para actualizar la interfaz
    var distance = Measurement(value: 0, unit: UnitLength.meters) // Distancia del entrenamiento
    var locationList: [Location] = [] // Lista de ubicaciones
    var lastLocation: CLLocation? = nil
    var run: Run? // Último entrenamiento
    var autoCenterMapOnUserLocation = true // Si está a true, el mapa centra la vista en la ubicación del usuario
    var mapChangedFromUserInteraction = false
    
    var dataContainerConstraints : Dictionary<String, [NSLayoutConstraint]> = Dictionary() // key = name, value = [top, left, width, height]
    
    var dataValuesLabels : Dictionary<String, UILabel> = Dictionary()
    var dataLabelsLabels : Dictionary<String, UILabel> = Dictionary()
    var dataIconsImages: Dictionary<String, UIImage> = Dictionary()
    
    override func loadView() {
        super.loadView()
        
        dataValuesLabels["time"] = secondsLabel
        dataValuesLabels["distance"] = kmLabel
        dataValuesLabels["pace"] = mpkLabel
        dataValuesLabels["cadence"] = spmLabel
        
        dataLabelsLabels["time"] = timeLabel
        dataLabelsLabels["distance"] = distanceLabel
        dataLabelsLabels["pace"] = paceLabel
        dataLabelsLabels["cadence"] = cadenceLabel
        
        dataIconsImages["time"] = UIImage(systemName: "clock")
        dataIconsImages["distance"] = UIImage(systemName: "mappin.and.ellipse")
        dataIconsImages["pace"] = UIImage(systemName: "stopwatch")
        dataIconsImages["cadence"] = UIImage(systemName: "metronome")
        
        dataContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // DEFINIR CONSTRAINTS DE LOS VALORES DE LOS CAMPOS DE INFORMACIÓN (LEFT Y TOP A 0, YA QUE SE ASIGNAN EN refreshDataContainerConstraints())
        secondsLabel.translatesAutoresizingMaskIntoConstraints = false
        dataContainerConstraints["time"] = [
            secondsLabel.leftAnchor.constraint(equalTo: self.dataContainerView.leftAnchor, constant: 0),
            secondsLabel.topAnchor.constraint(equalTo: self.dataContainerView.topAnchor, constant: 0),
            secondsLabel.widthAnchor.constraint(equalToConstant: 144),
            secondsLabel.heightAnchor.constraint(equalToConstant: 64)
        ]
        NSLayoutConstraint.activate(dataContainerConstraints["time"]!)

        
        kmLabel.translatesAutoresizingMaskIntoConstraints = false
        dataContainerConstraints["distance"] = [
            kmLabel.leftAnchor.constraint(equalTo: self.dataContainerView.leftAnchor, constant: 0),
            kmLabel.topAnchor.constraint(equalTo: self.dataContainerView.topAnchor, constant: 0),
            kmLabel.widthAnchor.constraint(equalToConstant: 144),
            kmLabel.heightAnchor.constraint(equalToConstant: 64),
        ]
        NSLayoutConstraint.activate(dataContainerConstraints["distance"]!)
        
        mpkLabel.translatesAutoresizingMaskIntoConstraints = false
        dataContainerConstraints["pace"] = [
            mpkLabel.leftAnchor.constraint(equalTo: self.dataContainerView.leftAnchor, constant: 0),
            mpkLabel.topAnchor.constraint(equalTo: self.dataContainerView.topAnchor, constant: 0),
            mpkLabel.widthAnchor.constraint(equalToConstant: 144),
            mpkLabel.heightAnchor.constraint(equalToConstant: 64)
        ]
        NSLayoutConstraint.activate(dataContainerConstraints["pace"]!)
        
        spmLabel.translatesAutoresizingMaskIntoConstraints = false
        dataContainerConstraints["cadence"] = [
            spmLabel.leftAnchor.constraint(equalTo: self.dataContainerView.leftAnchor, constant: 0),
            spmLabel.topAnchor.constraint(equalTo: self.dataContainerView.topAnchor, constant: 0),
            spmLabel.widthAnchor.constraint(equalToConstant: 144),
            spmLabel.heightAnchor.constraint(equalToConstant: 64)
        ]
        NSLayoutConstraint.activate(dataContainerConstraints["cadence"]!)
        
        // DEFINIR CONSTRAINTS DE LOS LABELS DE LOS CAMPOS DE INFORMACIÓN
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.leftAnchor.constraint(equalTo: secondsLabel.leftAnchor, constant: 0).isActive = true
        timeLabel.topAnchor.constraint(equalTo: secondsLabel.topAnchor, constant: 24).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 144).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.leftAnchor.constraint(equalTo: kmLabel.leftAnchor, constant: 0).isActive = true
        distanceLabel.topAnchor.constraint(equalTo: kmLabel.topAnchor, constant: 24).isActive = true
        distanceLabel.widthAnchor.constraint(equalToConstant: 144).isActive = true
        distanceLabel.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        paceLabel.translatesAutoresizingMaskIntoConstraints = false
        paceLabel.leftAnchor.constraint(equalTo: mpkLabel.leftAnchor, constant: 0).isActive = true
        paceLabel.topAnchor.constraint(equalTo: mpkLabel.topAnchor, constant: 24).isActive = true
        paceLabel.widthAnchor.constraint(equalToConstant: 144).isActive = true
        paceLabel.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        cadenceLabel.translatesAutoresizingMaskIntoConstraints = false
        cadenceLabel.leftAnchor.constraint(equalTo: spmLabel.leftAnchor, constant: 0).isActive = true
        cadenceLabel.topAnchor.constraint(equalTo: spmLabel.topAnchor, constant: 24).isActive = true
        cadenceLabel.widthAnchor.constraint(equalToConstant: 144).isActive = true
        cadenceLabel.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createFabs()
        refreshDataContainerConstraints("time", "distance", "pace", "cadence", duration: 0) // TODO: secuencia inicial de shared prefs
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        locationManager.delegate = self
        
        secondsLabel.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(timeLabelTapped)) )
        kmLabel.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(kmLabelTapped)) )
        mpkLabel.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(mpkLabelTapped)) )
        spmLabel.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(spmLabelTapped)) )
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
    
    private func startPedometerUpdates() {
        if CMPedometer.isCadenceAvailable() && CMPedometer.isPaceAvailable() {
            pedometer.startUpdates(from: runResumeDate!) { pedometerData, error in
                
            }
        }
    }
    
    private func stopPedometerUpdates() {
        pedometer.stopUpdates()
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
            runResumeDate = Date()
            updateDisplay()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.eachSecond()
            }
            lastLocation = nil
            startLocationUpdates()
            startPedometerUpdates()
            break
            
        case RunStatus.Paused:
            timer?.invalidate()
            stopLocationUpdates()
            stopPedometerUpdates()
            break
            
        case RunStatus.Stopped:
            timer?.invalidate()
            stopLocationUpdates()
            stopPedometerUpdates()
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
        
        secondsLabel.text = FormatDisplay.time(seconds: seconds)
        kmLabel.text = FormatDisplay.distance(meters: distance.value)
        
        pedometer.queryPedometerData(from: runResumeDate!, to: Date()) {
            [weak self] pedometerData, error in
            if let pedometerData = pedometerData {
                DispatchQueue.main.async {
                    self?.mpkLabel.text = FormatDisplay.pace(secondsPerMeter: pedometerData.currentPace)
                    self?.spmLabel.text = FormatDisplay.cadence(stepsPerSeconds: pedometerData.currentCadence)
                }
            }
        }
    }
    
    @objc func timeLabelTapped(sender: UITapGestureRecognizer) {
        refreshDataContainerConstraints("time", "distance", "pace", "cadence")
    }
    
    @objc func kmLabelTapped(sender: UITapGestureRecognizer) {
        refreshDataContainerConstraints("distance", "time", "pace", "cadence")
    }
    
    @objc func mpkLabelTapped(sender: UITapGestureRecognizer) {
        refreshDataContainerConstraints("pace", "distance", "time", "cadence")
    }
    
    @objc func spmLabelTapped(sender: UITapGestureRecognizer) {
        refreshDataContainerConstraints("cadence", "distance", "pace", "time")
    }
    
    func refreshDataContainerConstraints(_ labelId0: String, _ labelId1: String, _ labelId2: String, _ labelId3: String, duration : Double = 0.3) {
        let labelWidth = 144.0 as CGFloat
        let bigLabelHOffset = 36.0 as CGFloat
        let bigLabelTop = 16.0 as CGFloat
        let smallLabelLeft = 16.0 as CGFloat
        let smallLabelTop = 76.0 as CGFloat
        
        // Cambiar left y top de los constraints de los labels de los valores de los datos
        dataContainerConstraints[labelId0]![0].constant = (dataContainerView.bounds.width - labelWidth + bigLabelHOffset) * 0.5
        dataContainerConstraints[labelId0]![1].constant = bigLabelTop
        
        dataContainerConstraints[labelId1]![0].constant = smallLabelLeft
        dataContainerConstraints[labelId1]![1].constant = smallLabelTop
        
        dataContainerConstraints[labelId2]![0].constant = (dataContainerView.bounds.width - labelWidth) * 0.5
        dataContainerConstraints[labelId2]![1].constant = smallLabelTop
        
        dataContainerConstraints[labelId3]![0].constant = dataContainerView.bounds.width - labelWidth - smallLabelLeft
        dataContainerConstraints[labelId3]![1].constant = smallLabelTop
        
        // Animar transición de los datos
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut , animations: {
            self.dataLabelsLabels[labelId0]?.alpha = 0
            self.dataLabelsLabels[labelId1]?.alpha = 1
            self.dataLabelsLabels[labelId2]?.alpha = 1
            self.dataLabelsLabels[labelId3]?.alpha = 1
            
            self.dataValuesLabels[labelId0]!.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.dataValuesLabels[labelId1]!.transform = CGAffineTransform(scaleX: 0.67, y: 0.67)
            self.dataValuesLabels[labelId2]!.transform = CGAffineTransform(scaleX: 0.67, y: 0.67)
            self.dataValuesLabels[labelId3]!.transform = CGAffineTransform(scaleX: 0.67, y: 0.67)
            self.dataContainerView.layoutIfNeeded()
        }, completion: { finished in

        })
        
        // Animar transición del icono
        UIView.animate(withDuration: duration * 0.5, delay: 0.0, options: .curveEaseInOut , animations: {
            self.bigLabelIconImage.alpha = 0
        }, completion: { finished in
            UIView.animate(withDuration: duration * 0.5, delay: 0.0, options: .curveEaseInOut , animations: {
                self.bigLabelIconImage.image = self.dataIconsImages[labelId0]
                self.bigLabelIconImage.alpha = 1
            })
        })
    }
}
