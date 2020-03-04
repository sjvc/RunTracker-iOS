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
    
    var run : Run?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        loadMap()
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
    
    // Devuelve una polilínea con el recorrido
    private func polyLine() -> MKPolyline {
        guard let locations = run!.locations else {
            return MKPolyline()
        }
        
        let coords: [CLLocationCoordinate2D] = locations.map { location in
            let location = location as! Location
            return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        }
        return MKPolyline(coordinates: coords, count: coords.count)
    }
    
    // Carga el mapa
    private func loadMap() {
        guard let locations = run!.locations, locations.count > 0, let region = mapRegion() else {
            print("No se han encontrado ubicaciones almacenadas en el entrenamiento")
            return
        }
        mapView.setRegion(region, animated: true)
        mapView.addOverlay(polyLine())
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension RunDetailsViewController: MKMapViewDelegate {
    // Se llama a este método cuando se va a pintar sobre el mapa
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = IVBezierPathRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red:0.17, green:0.47, blue:0.96, alpha:1.0)
        renderer.lineWidth = 18
        // renderer.borderColor = renderer.strokeColor
        // renderer.borderMultiplier = 1.5
        return renderer
    }
    
}

