//
//  RunDetailsViewController.swift
//  RunTracker
//
//  Created by Sergio Viudes Carbonell on 04/03/2020.
//  Copyright © 2020 Sergio Viudes Carbonell. All rights reserved.
//

import UIKit
import MapKit
import IVBezierPathRenderer

class RunDetailsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceAndTimeLabel: UILabel!
    @IBOutlet weak var avgSpeedLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
    var run : Run?
    
    var globalAvgSpeed : Double?
    var globalMaxSpeed : Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        loadMap()
        
        addMapAnnotations()
        
        fillRunDetails()
    }
    
    private func fillRunDetails() {
        dateLabel.text = DateFormatter.localizedString(from: (run?.date!)!, dateStyle: .short, timeStyle: .medium)
        distanceAndTimeLabel.set(html: "Has hecho <b>\(FormatDisplay.distance(meters: run!.distance)) km</b> en <b>\(FormatDisplay.timeWithSuffixes(seconds: Int(run!.distance)))</b>,")
        avgSpeedLabel.set(html: "con una <i>velocidad media</i> de <b>\(FormatDisplay.speed(metersPerSeconds: globalAvgSpeed!)) km/h</b>,")
        maxSpeedLabel.set(html: "<i>velocidad máxima</i> de <b>\(FormatDisplay.speed(metersPerSeconds: globalMaxSpeed!)) km/h</b>,")
        paceLabel.set(html: "a un <i>ritmo</i> de <b>\(FormatDisplay.pace(secondsPerMeter: NSNumber(value: Double(run!.duration) / run!.distance))) min/km</b>")
    }
    
    // Carga el mapa
    private func loadMap() {
        guard let locations = run!.locations, locations.count > 0, let region = mapRegion() else {
            print("No se han encontrado ubicaciones almacenadas en el entrenamiento")
            return
        }
        mapView.setRegion(region, animated: true)
        mapView.addOverlays(polyLine())
    }
    
    // Devuelve la región del mapa a mostrar según el entrenamiento guardado en "run"
    private func mapRegion() -> MKCoordinateRegion? {
        guard
            let locations = run!.locations,
            locations.count > 0
            else {
                return nil
        }
        
        let latitudes = locations.map { location -> Double in
            let location = location as! Location
            return location.latitude
        }
        
        let longitudes = locations.map { location -> Double in
            let location = location as! Location
            return location.longitude
        }
        
        let maxLat = latitudes.max()!
        let minLat = latitudes.min()!
        let maxLong = longitudes.max()!
        let minLong = longitudes.min()!
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLong + maxLong) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3, longitudeDelta: (maxLong - minLong) * 1.3)
        return MKCoordinateRegion(center: center, span: span)
    }
    
    // Devuelve un array de polilíneas, con color, con el recorrido
    private func polyLine() -> [MulticolorPolyline] {
        // Preparamos para recoger las coordenadas que forman los segmentos de las polilíneas, y sus velocidades
        let locations = run!.locations?.array as! [Location]
        var coordinates: [(CLLocation, CLLocation)] = []
        var speeds: [Double] = []
        var minSpeed = Double.greatestFiniteMagnitude
        var maxSpeed = 0.0
        
        // Convertir cada ubicación en CLLocation, y guardar en coordinates los puntos correspondientes a los extremos de los segmentos
        for (first, second) in zip(locations, locations.dropFirst()) {
            let start = CLLocation(latitude: first.latitude, longitude: first.longitude)
            let end = CLLocation(latitude: second.latitude, longitude: second.longitude)
            // Si la segunda coordenada es un nuevo comienzo (tras una pausa), no tengo en cuenta ese tramo
            if !second.isNewStart {
                coordinates.append((start, end))
            } else {
                continue
            }
            
            // Calcular la velocidad para el segmento, así como comprobar si es la máxima o la mínima del recorrido
            let distance = end.distance(from: start)
            let time = second.date!.timeIntervalSince(first.date! as Date)
            let speed = time > 0 ? distance / time : 0
            speeds.append(speed)
            minSpeed = min(minSpeed, speed)
            maxSpeed = max(maxSpeed, speed)
        }
        
        // Calcular la velocidad media del recorrido
        let midSpeed = speeds.reduce(0, +) / Double(speeds.count)
        
        // Mediante los pares de coordenadas anteriores, creamos las polilíneas coloreadas
        var segments: [MulticolorPolyline] = []
        for ((start, end), speed) in zip(coordinates, speeds) {
            let coords = [start.coordinate, end.coordinate]
            let segment = MulticolorPolyline(coordinates: coords, count: 2)
            segment.color = segmentColor(speed: speed, midSpeed: midSpeed, slowestSpeed: minSpeed, fastestSpeed: maxSpeed)
            segments.append(segment)
        }
        
        globalAvgSpeed = midSpeed
        globalMaxSpeed = maxSpeed
        
        return segments
    }
    
    // Devuelve un color en función de la velocidad
    private func segmentColor(speed: Double, midSpeed: Double, slowestSpeed: Double, fastestSpeed: Double) -> UIColor {
        enum BaseColors {
            // Color lento (verde)
            static let slow_red: CGFloat = 76 / 255
            static let slow_green: CGFloat = 175 / 255
            static let slow_blue: CGFloat = 80 / 255
            
            // Color medio (amarillo)
            static let mid_red: CGFloat = 1
            static let mid_green: CGFloat = 235 / 255
            static let mid_blue: CGFloat = 59 / 255
            
            // Color rápido (verde)
            static let fast_red: CGFloat = 244 / 255
            static let fast_green: CGFloat = 67 / 255
            static let fast_blue: CGFloat = 54 / 255
        }
        
        let red, green, blue: CGFloat
        
        if speed < midSpeed {
            let ratio = CGFloat((speed - slowestSpeed) / (midSpeed - slowestSpeed))
            red = BaseColors.slow_red + ratio * (BaseColors.mid_red - BaseColors.slow_red)
            green = BaseColors.slow_green + ratio * (BaseColors.mid_green - BaseColors.slow_green)
            blue = BaseColors.slow_blue + ratio * (BaseColors.mid_blue - BaseColors.slow_blue)
        } else {
            let ratio = CGFloat((speed - midSpeed) / (fastestSpeed - midSpeed))
            red = BaseColors.mid_red + ratio * (BaseColors.fast_red - BaseColors.mid_red)
            green = BaseColors.mid_green + ratio * (BaseColors.fast_green - BaseColors.mid_green)
            blue = BaseColors.mid_blue + ratio * (BaseColors.fast_blue - BaseColors.mid_blue)
        }
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "run_annotation")
        annotationView.image =  UIImage(systemName: (annotation as! MapRunAnnotation).imageName!)
        annotationView.contentMode = .bottom
        annotationView.canShowCallout = false
        return annotationView
    }
    
    private func addMapAnnotation(coordinate: CLLocationCoordinate2D, index: Int) {
        let imageName = String((index % 49) + 1) + ".circle"
        let pin = MapRunAnnotation(coordinate: coordinate, imageName: imageName)
        self.mapView.addAnnotation(pin)
    }
    
    // Recorre el array de locations y añade las annotations al mapa
    private func addMapAnnotations() {
        var locationIndex=0
        var annotationIndex = 0
        let lastLocationIndex = (run?.locations!.array.count)! - 1
        for location in (run?.locations!.array)! {
            let location = location as! Location
            
            if locationIndex == 0 || (locationIndex+1<lastLocationIndex && (run?.locations!.array[locationIndex+1] as! Location).isNewStart) || location.isNewStart || locationIndex == lastLocationIndex {
                addMapAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), index: annotationIndex)
                annotationIndex += 1
            }
            locationIndex += 1
        }
    }
    
}

extension RunDetailsViewController: MKMapViewDelegate {
    // Se llama a este método cuando se va a pintar sobre el mapa
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = IVBezierPathRenderer(overlay: overlay)
        renderer.strokeColor = (overlay as! MulticolorPolyline).color
        renderer.lineWidth = 18
        // renderer.borderColor = renderer.strokeColor
        // renderer.borderMultiplier = 1.5
        return renderer
    }
    
}

