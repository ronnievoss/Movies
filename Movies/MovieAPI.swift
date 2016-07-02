//
//  MovieAPI.swift
//  Movies
//
//  Created by Ronnie Voss on 8/2/15.
//  Copyright (c) 2015 Ronnie Voss. All rights reserved.
//

import Foundation
import UIKit

@objc protocol MovieAPIProtocol {
    optional func didReceiveAPIResults(results: NSArray)
    optional func didReceiveDetailAPIResults(results: NSDictionary)
    optional func didReceiveTrailerAPIResults(results: NSDictionary)
    optional func showAlert(error: String)
}

class MovieAPI {
    
    var delegate : MovieAPIProtocol
    let movieAPIKey: String
    
    init(APIKey: String, delegate: MovieAPIProtocol) {
        self.delegate = delegate
        movieAPIKey = APIKey
    }
    
    func nowPlayingMovies(movieListURL: NSURL?) {
        
        if let movieURL = movieListURL {
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(movieURL, completionHandler: {data, response, error -> Void in
            
                if(error != nil) {
                    self.delegate.showAlert!(error!.localizedDescription)
                    return
                }
                
                do {
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        
                        if let results: NSArray = jsonResult["results"] as? NSArray {
                        self.delegate.didReceiveAPIResults!(results)
                        
                        }
                    }
                    
                } catch let error as NSError {
                    self.delegate.showAlert!(error.localizedDescription)
                    return
                }
            })
            
            task.resume()
        }
    }
    
    func searchMovies(searchString: String) {
        
        let encodedURL = searchString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())
        let movieSearchUrl = NSURL(string: "https://api.themoviedb.org/3/search/movie?query=\(encodedURL!)&api_key=e4fe211a5f904db8260cddc6ab6865bb")
        
        if let movieURL = movieSearchUrl {
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(movieURL, completionHandler: {data, response, error -> Void in
                
                if(error != nil) {
                    self.delegate.showAlert!(error!.localizedDescription)
                    return
                }
                
                do {
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        
                        if let results: NSArray = jsonResult["results"] as? NSArray {
                            self.delegate.didReceiveAPIResults!(results)
                            
                        }
                    }
                    
                } catch let error as NSError {
                    self.delegate.showAlert!(error.localizedDescription)
                    return
                }
            })
            
            task.resume()
        }
    }

    
    func movieDetail(id: Int) {
        
        let movieDetailUrl = NSURL(string: "https://api.themoviedb.org/3/movie/\(id)?&api_key=e4fe211a5f904db8260cddc6ab6865bb")!
        if let movieURL = movieDetailUrl as NSURL? {
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(movieURL, completionHandler: {data, response, error -> Void in
                
                if(error != nil) {
                    print(error!.localizedDescription)
                    self.delegate.showAlert!(error!.localizedDescription)
                    return
                }
                
                do {
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        if let results = jsonResult as NSDictionary? {
                            self.delegate.didReceiveDetailAPIResults!(results)
                            
                        }
                    }
                    
                } catch let error as NSError {
                    self.delegate.showAlert!(error.localizedDescription)
                }
            })
        
        task.resume()
            
        }
    }
    
    func getTrailer(id: Int) {
        
        let trailerlUrl = NSURL(string: "https://api.themoviedb.org/3/movie/\(id)/videos?&api_key=e4fe211a5f904db8260cddc6ab6865bb")
        if let movieURL = trailerlUrl {
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(movieURL, completionHandler: {data, response, error -> Void in
                
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    self.delegate.showAlert!(error!.localizedDescription)
                    return
                }
                
                do {
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        let resultCount = jsonResult["results"]!.count as Int
                        if resultCount == 0 {
                            let results = [:]
                            self.delegate.didReceiveTrailerAPIResults!(results)
                        } else {
                            if let results = jsonResult["results"] as? [[String:AnyObject]] {
                                let result = results[0]
                                self.delegate.didReceiveTrailerAPIResults!(result)
                            }
                        }
                    }
                } catch let error as NSError {
                    self.delegate.showAlert!(error.localizedDescription)
                    return
                }
            })
            
            task.resume()
        }
    }
    
}