//
//  FlickrConstants.swift
//  VirtualTouristApp
//
//  Created by IbrahimGamal on 6/13/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import Foundation
extension FlickrClient {
    struct Constants {
        
        // MARK: FLICKR
        struct Flickr {
            static let APIScheme = "https"
            static let APIHost = "api.flickr.com"
            static let APIPath = "/services/rest"
        }
        
        // MARK: Flickr Parameter Keys
        struct FlickrParameterKeys {
            static let Method = "method"
            static let APIKey = "api_key"
            static let Latitude = "lat"
            static let Longitude = "lon"
            static let Radius = "radius"
            static let ResultsPerPage = "per_page"
            static let format = "format"
            static let NoJSONCallback = "nojsoncallback"
        }
        
        // MARK: Flickr Parameter Values
        struct FlickrParameterValues {
            static let SearchMethod = "flickr.photos.search"
            static let APIKey = "c9e2bdb5c6d04dfd0c58742eb4215dfc"
            static let ResponseRadius = "1" // 1 mile radius
            static let ResponseResultsPerPage = "100"
            static let ResponseFormat = "json"
            static let DisableJSONCallback = "1" // 1 means "yes"
            
        }
        
        struct Error
        {
            struct Domain
            {
                static let SearchMethod="VT.SEARCH_PHOTOS"
                static let DownloadMethod="VT.DOWNLOAD_PHOTOS"
            }
            
            struct Message
            {
                static let Error_Occurred = "Error occurrred in API response."
                static let Invalid_Response = "API response is not parsable for necessary information."
                static let Download_Not_Possible = "Unable to download pic."
            }
        }
    }
}
