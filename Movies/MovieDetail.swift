//
//  MovieDetail.swift
//  Movies
//
//  Created by Ronnie Voss on 8/14/15.
//  Copyright (c) 2015 Ronnie Voss. All rights reserved.
//

import Foundation

class MovieDetail {
    
    let id: Int?
    let title: String?
    let posterPath: String?
    let runtime: Int?
    let runtimeString: String?
    let overview: String?
    var genres: String?
    let dateFormatter = DateFormatter()
    let releaseDate: String?
    let voteAverage: Float?
    
    init(results: NSDictionary) {
        
        id = results["id"] as? Int
        title = results["title"] as? String
        
        if let tempRuntime = results["runtime"] as? Int {
            runtime = tempRuntime
            runtimeString = String("\(runtime!) minutes")
        } else {
            runtime = 0
            runtimeString = String("Not Available")
        }
        
        if let tempOverview = results["overview"] as? String {
            overview = tempOverview
        } else {
            overview = "Not Available"
        }
        
        if (results["genres"]! as AnyObject).count == 0 {
            genres = "Not Available"
        } else {
            genres = ((results["genres"] as! NSArray)[0] as AnyObject)["name"] as? String
        }
        
        // get the release date
        let dateString = results["release_date"] as? String
        if dateString != "" {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date:Date! = dateFormatter.date(from: dateString!)
            dateFormatter.dateFormat = "M/d/YYYY"
            releaseDate = dateFormatter.string(from: date) as String?
        } else {
            releaseDate = "Not Available"
        }
    
        posterPath = results["poster_path"] as? String
        
        if let tempVoteAverage = results["vote_average"] as? Float {
            voteAverage = tempVoteAverage
        } else {
            voteAverage = 0.0
        }
    
    }
    
    class Trailer {
        
        let trailer : String?
        
        init(results: NSDictionary) {
            
            if let tempTrailer = results["key"] as? String {
                trailer = tempTrailer
            } else {
                trailer = nil
            }
        }
    }
    

}


