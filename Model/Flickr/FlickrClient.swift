//
//  FlickrClient.swift
//  VirtualTouristApp
//
//  Created by IbrahimGamal on 6/13/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import Foundation
import CoreData

class FlickrClient: NSObject {
    
    var dataController: DataController!
    
    struct Photos: Decodable {
        let photos: PhotoInfo
        let stat: String
    }
    
    struct PhotoInfo: Decodable {
        let photo: [Photo]
        let page: Int
        let pages: Int
    }
    
    struct Photo: Decodable {
      
        let farm: Int
        let server: String
        let id: String
        let secret: String
        let url_m: String
    }
    
    
    var photoResults: [Data] = []
    var searchResultsCount = 0
    var photoURLs: [URL] = []
    
    // MARK: HELPER FUNCTIONS
    
    // create a URL from parameters
    // SOURCE: used in The Movie Manager udacity sub-project (Section 5: Network Requests)
    func clearFlickrResults() {
        photoResults = []
        photoURLs = []
    }
    
    
    func isPinContainsPhotos(lat: Double, lon: Double, _ completionHandlerForDownload: @escaping (_ result: Bool, _ urls: [URL]?) -> Void) {
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(FlickrClient.Constants.FlickrParameterValues.APIKey)&lat=\(lat)&lon=\(lon)&radius=1&per_page=21&extras=url_m&format=json&nojsoncallback=1"
        let url = URL(string: urlString)
        
        let session = URLSession.shared
        
        let request = URLRequest(url: url!)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard (error == nil) else{
                print("error downloading photos: \(error!)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("request returned status code other than 2XX")
                return
            }
            
            guard let data = data else {
                print("could not download data")
                return
            }
            
            guard let photosInfo = try? JSONDecoder().decode(Photos.self, from: data) else {
                print("error in decoding process")
                return
            }
            
            // HOW MANY SEARCH RESULTS DID YOU GET?
            self.searchResultsCount = photosInfo.photos.photo.count
            print("search results count: \(self.searchResultsCount)")
            
            // PULL PAGES INFO HERE
            let totalPages = photosInfo.photos.pages
            
            // CREATE RANDOM PAGE
            let pageLimit = min(totalPages, 100)
            let randomPageNumber = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            print("random page number = \(randomPageNumber)")
            
            // TODO: CALL FUNC THAT EXECUTES SECOND NETWORK REQUEST WITH PAGE NUMBER
            self.getRandomPhotos(urlString: urlString, pageNumber: randomPageNumber, completionHandlerfForRandomPhotoSearch: { (success, photosUrls) in
                guard let photosUrls = photosUrls else {
                    print("no urls returned from random search")
                    return
                }
                
                if success {
                    self.photoURLs.append(contentsOf: photosUrls)
                    completionHandlerForDownload(success, photosUrls)
                }
            })
            
        }
        task.resume()
    }
    
    
    func getRandomPhotos(urlString: String, pageNumber: Int, completionHandlerfForRandomPhotoSearch: @escaping (_ result: Bool, _ urls: [URL]?) -> Void) {
        //print("***search for random photos called")
        //take urlString parameter from previous method
        //append page number to it
        let urlStringWithPageNumber = urlString.appending("&page=\(pageNumber)")
        //print("new urlString: \(urlStringWithPageNumber)")
        
        let url = URL(string: urlStringWithPageNumber)
        
        let session = URLSession.shared
        
        let request = URLRequest(url: url!)
        //print("request: \(request)")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard (error == nil) else{
                print("error downloading photos: \(error!)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("request returned status code other than 2XX")
                return
            }
            
            guard let data = data else {
                print("could not download data")
                return
            }
            
            guard let randomPhotosInfo = try? JSONDecoder().decode(Photos.self, from: data) else {
                print("error in decoding process")
                return
            }
            
            var urlArray = [URL]()
            
            //use url in result
            for photo in randomPhotosInfo.photos.photo {
                if let photoURL = URL(string: photo.url_m) {
                    urlArray.append(photoURL)
                }
            }
           
            completionHandlerfForRandomPhotoSearch(true, urlArray)
            
        }
        task.resume()
        
    }
  
    func downloadPhotos(photoURL:String, completionHandlerForDownloadPhotos: @escaping (_ image: NSData?, _ error: NSError?) -> Void)
    {
        let url = NSURL(string: photoURL)
        let session = URLSession.shared
        let request = URLRequest(url: url! as URL)
        
        let task = session.dataTask(with: request){ data, response, error in
            guard let data = data else
            {
                completionHandlerForDownloadPhotos(nil, NSError(domain:  FlickrClient.Constants.Error.Domain.DownloadMethod, code: 6001, userInfo: [NSLocalizedDescriptionKey: FlickrClient.Constants.Error.Message.Download_Not_Possible]))
                return
            }
            completionHandlerForDownloadPhotos(data as NSData, nil)
        }
        task.resume()
    }
    
    // MARK: SHARED INSTANCE
    
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static let sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}
