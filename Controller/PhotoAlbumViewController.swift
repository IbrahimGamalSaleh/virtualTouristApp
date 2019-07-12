//
//  PhotoAlbumViewController.swift
//  VirtualTouristApp
//
//  Created by IbrahimGamal on 6/13/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController , UICollectionViewDataSource, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegate{
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var pin: Pin!
    
    var insertIndexCache: [NSIndexPath]!
    var deleteIndexCache: [NSIndexPath]!
    let flickr = FlickrClient.sharedInstance()
    
    var photosCount : Int = 0
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
 
    @IBOutlet weak var collectionViewFlow: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionbtn: UIBarButtonItem!
    
    var selectedPhotos = [NSIndexPath]()
    {
        didSet
        {
            collectionbtn.title = selectedPhotos.isEmpty ? "New Collection" : "Remove Selected Pictures"
        }
    }
    
    fileprivate func downloadFromFlickr() {
        collectionbtn.isEnabled = false
        downloadPhotos({ (success) in
            if success == true {
                if self.photosCount <= 0
                {
                    self.label.isHidden = false
                }
            }
        })
        collectionbtn.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
       
        setUpMap()
        initializeFlowLayout()
        if fetchedPhotos().isEmpty
        {
            downloadFromFlickr()
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //print("view WILL disappear.")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //print("view DID disappear")
        
        fetchedResultsController = nil
      
    }
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
   
        let photo = fetchedResultsController.object(at: indexPath) as! Photo
       
        if photo.image != nil {
            print("showing fetched image via FRC")
            cell.locationPhoto.image = UIImage(data: photo.image!)
            cell.locationPhoto.alpha = 1.0
            
        }
        else
        {
            cell.activityIndicator.startAnimating()
            
            //Download photos from Flickr API.
            flickr.downloadPhotos(photoURL: photo.name!){ (image, error)  in
                
                //Check if the image data is not nil
                guard let imageData = image,
                    let downloadedImage = UIImage(data: imageData as Data) else
                {
                  
                   cell.activityIndicator.stopAnimating()
                    return
                }
                
                        photo.image = imageData as Data
                        self.dataController.save()
                        
                        if let updateCell = self.collectionView.cellForItem(at: indexPath) as? CollectionViewCell
                        {
                            
                            updateCell.locationPhoto.image = downloadedImage
                            updateCell.activityIndicator.stopAnimating()
                        }
                
               
               
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! CollectionViewCell
        
        
        if let index = selectedPhotos.index(of: indexPath as NSIndexPath)
        {
           
            selectedPhotos.remove(at: index)
        }
        else
        {
         
            selectedPhotos.append(indexPath as NSIndexPath)
           
        }
        configureCellSection(cell: cell, indexPath: indexPath as NSIndexPath)
    }
    
    //Configure the Collection Cell
    func configureCellSection(cell: CollectionViewCell, indexPath: NSIndexPath)
    {
        if let _ = selectedPhotos.index(of: indexPath)
        {
            cell.alpha = 0.5
        }
        else
        {
            cell.alpha = 1.0
        }
    }
  
    @IBAction func newCollectionbtn(_ sender: Any) {
        

      
        if selectedPhotos.isEmpty
        {
            deleteAllPhotos()
            downloadFromFlickr()
        }
        else
        {
        
            deleteSelectedPhotos()
            
        }
        
        
        
        
    }
   
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin2"
        
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
    
   
    
    func setUpMap() {
     
        
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: coordinate, span: mapSpan)
        self.mapView.setRegion(region, animated: true)
        
        self.mapView.addAnnotation(annotation)
    }
    func deleteAllPhotos()
    {
        for pic in fetchedResultsController.fetchedObjects as! [Photo]
    {
     dataController.viewContext.delete(pic)
    }
    try? dataController.viewContext.save()
    }
    
    func deleteSelectedPhotos()
    {
        var photoToDelete = [Photo]()
        //Step 1: Get all the pics to be deleted based on the cell selection.
        for indexPath in selectedPhotos
        {
            photoToDelete.append(fetchedResultsController.object(at: indexPath as IndexPath) as! Photo )
            
        }
        //Step 2: Delete the pics from the stack.
        for photo in photoToDelete
        {
             dataController.viewContext.delete(photo)
        }
        try? dataController.viewContext.save()
        selectedPhotos = []
    }
    
    func initializeFlowLayout()
    {
        // For the image to scale properly.
        collectionView?.contentMode = UIView.ContentMode.scaleAspectFit
        
        collectionView?.backgroundColor = UIColor.white
        
        let space : CGFloat = 2.0
        //decide the dimension based on the orientation of the device.
        let dimension = (UIDevice.current.orientation.isPortrait) ?  (self.view.frame.width - (2 * space)) / 3.0 : (self.view.frame.height - (2 * space)) / 3.0
        collectionViewFlow.minimumInteritemSpacing = space
        collectionViewFlow.minimumLineSpacing = space
        collectionViewFlow.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func fetchedPhotos()->[Photo] {
   
        var result : [Photo]
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin = %@", pin)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            result = fetchedResultsController.fetchedObjects! as! [Photo]
            
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        return result
    }
    func downloadPhotos(_ completionForDownload: @escaping (_ success: Bool) -> Void)
    {
       flickr.isPinContainsPhotos(lat: pin.latitude, lon: pin.longitude) { (success, urls) in
            
            guard let urls = urls else {
                print("no url's returned in completion handler")
                return
            }
            
            if (success == false) {
                print("JSON DL did not complete")
                return
            }
            
        
        self.photosCount = urls.count
            DispatchQueue.main.async {
               
                for url in urls {
                     print("thread during url core data save: \(url)")
                    let photo = Photo(context: self.dataController.viewContext)
                    photo.name = url.absoluteString
                    photo.pin = self.pin
                    self.dataController.save()
                    
                }
    
                completionForDownload(true)
            }
            
            
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type
        {
        case .insert:   insertIndexCache.append(newIndexPath! as NSIndexPath)
        case .delete:   deleteIndexCache.append(indexPath! as NSIndexPath)
        default: break
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //clear arrays
        insertIndexCache = [NSIndexPath]()
        deleteIndexCache = [NSIndexPath]()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates(
            {
                self.collectionView.insertItems(at: self.insertIndexCache as [IndexPath])
                self.collectionView.deleteItems(at: self.deleteIndexCache as [IndexPath])
        }, completion: nil)
    }

   
}
