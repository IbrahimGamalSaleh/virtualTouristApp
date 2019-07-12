//
//  TravelLocationsMapViewController.swift
//  VirtualTouristApp
//
//  Created by IbrahimGamal on 6/13/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController , MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet var longGesture: UILongPressGestureRecognizer!
    
   // let pinCoordinate : CLLocationCoordinate2D!
    var dataController: DataController!

   
   
    @IBAction func longGestureTouch(_ sender: Any) {
        
        
        if longGesture.state == .began {
            let point = longGesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
            addLocation(coordinate: coordinate)
        }
        
    }
    func addLocation(coordinate: CLLocationCoordinate2D) {
    
       let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        dataController.save()
    
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        loadPins()
        
        // Do any additional setup after loading the view.
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
      
    }
    
    
    
    
    fileprivate func loadPins() {
        var pins = [Pin]()
        var annotations = [MKAnnotation]()
        
          let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        do
        {
            let results = try dataController.viewContext.fetch(fetchRequest)
            if let results = results as? [Pin]
            {
                pins = results
                print("Number of Pins : \(pins.count)")
            }
        }
        catch
        {
            print("Couldn't find any Pins")
        }
        
        for (_,item) in pins.enumerated()
        {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(item.latitude),longitude: CLLocationDegrees(item.longitude))
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
        
        
        
    }
   

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = UIColor.red
            pinView?.animatesDrop = false
            
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("annotation coordinate: \(view.annotation!.coordinate)")
    
       
            self.performSegue(withIdentifier: "toCollectionView", sender: view.annotation)
         mapView.deselectAnnotation(view.annotation, animated: true)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCollectionView" {
            //send lat & long to new VC
            var pin: Pin!
            do
            {
                let pinAnnotation = sender as! MKAnnotation
                
                let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
                let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [pinAnnotation.coordinate.latitude, pinAnnotation.coordinate.longitude])
                fetchRequest.predicate = predicate
                let pins = try dataController.viewContext.fetch(fetchRequest)
              pin = pins[0]
                
            }
            catch let error as NSError
            {
                print("failed to get pin by object id")
                print(error.localizedDescription)
                return
            }
            
            let vc = segue.destination as! PhotoAlbumViewController
            vc.pin = toPin(sender as! MKAnnotation, pin)
            vc.dataController = dataController
        }
    }
    func toPin (_ from:MKAnnotation, _ to:Pin) -> Pin
    {
        to.latitude = from.coordinate.latitude
        to.longitude = from.coordinate.longitude
        return to
    }
    


}
