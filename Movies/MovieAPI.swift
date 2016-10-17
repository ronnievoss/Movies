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
    @objc optional func didReceiveAPIResults(_ results: NSArray)
    @objc optional func didReceiveDetailAPIResults(_ results: NSDictionary)
    @objc optional func didReceiveTrailerAPIResults(_ results: NSDictionary)
    @objc optional func showAlert(_ error: String)
}

class MovieAPI {
    
    var delegate : MovieAPIProtocol
    let movieAPIKey: String
    var posterImage: UIImage!
    
    init(APIKey: String, delegate: MovieAPIProtocol) {
        self.delegate = delegate
        movieAPIKey = APIKey
    }
    
    func nowPlayingMovies(_ movieListURL: URL?) {
        
        if let movieURL = movieListURL {
            
            let session = URLSession.shared
            let task = session.dataTask(with: movieURL, completionHandler: {data, response, error -> Void in
            
                if(error != nil) {
                    self.delegate.showAlert!(error!.localizedDescription)
                    return
                }
                
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        
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
    
    func searchMovies(_ searchString: String) {
        
        let encodedURL = searchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
        let movieSearchUrl = URL(string: "https://api.themoviedb.org/3/search/movie?query=\(encodedURL!)&api_key=e4fe211a5f904db8260cddc6ab6865bb")
        
        if let movieURL = movieSearchUrl {
            
            let session = URLSession.shared
            let task = session.dataTask(with: movieURL, completionHandler: {data, response, error -> Void in
                
                if(error != nil) {
                    self.delegate.showAlert!(error!.localizedDescription)
                    return
                }
                
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        
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

    
    func movieDetail(_ id: Int) {
        
        let movieDetailUrl = URL(string: "https://api.themoviedb.org/3/movie/\(id)?&api_key=e4fe211a5f904db8260cddc6ab6865bb")!
        if let movieURL = movieDetailUrl as URL? {
            let session = URLSession.shared
            let task = session.dataTask(with: movieURL, completionHandler: {data, response, error -> Void in
                
                if(error != nil) {
                    print(error!.localizedDescription)
                    self.delegate.showAlert!(error!.localizedDescription)
                    return
                }
                
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
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
    
    func getTrailer(_ id: Int) {
        
        let trailerlUrl = URL(string: "https://api.themoviedb.org/3/movie/\(id)/videos?&api_key=e4fe211a5f904db8260cddc6ab6865bb")
        if let movieURL = trailerlUrl {
            
            let session = URLSession.shared
            let task = session.dataTask(with: movieURL, completionHandler: {data, response, error -> Void in
                
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    self.delegate.showAlert!(error!.localizedDescription)
                    return
                }
                
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        let resultCount = (jsonResult["results"]! as AnyObject).count as Int
                        if resultCount == 0 {
                            let results = [String:Any]()
                            self.delegate.didReceiveTrailerAPIResults!(results as NSDictionary)
                        } else {
                            if let results = jsonResult["results"] as? [[String:AnyObject]] {
                                let result = results[0]
                                self.delegate.didReceiveTrailerAPIResults!(result as NSDictionary)
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
    
    func getPoster(_ imageURL: URL) {
        let session = URLSession.shared
        let request: URLRequest = URLRequest(url: imageURL)
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            print("task completed")
            DispatchQueue.main.async {
            self.posterImage = UIImage(data: data!)
            }
            
        })
        
        task.resume()
    }
    
}
