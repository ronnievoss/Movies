//
//  Movies.swift
//  Movies
//
//  Created by Ronnie Voss on 8/2/15.
//  Copyright (c) 2015 Ronnie Voss. All rights reserved.
//

import Foundation

class Movies {
    
    let id: Int?
    let title: String?
    let posterPath: String?
    let releaseDate: String?
    
    init(id: Int, title: String, posterPath: String, releaseDate: String) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseDate = releaseDate
    }
    
    static func moviesWithJSON(_ results: NSArray) -> [Movies] {
        
        var movies = [Movies]()
        if results.count>0 {
        
            for result in results as Array {
                let releaseDate: String?
                let dateFormatter = DateFormatter()
                let id = result["id"] as? Int
                let title = result["title"] as? String
                let poster = result["poster_path"] as? String
                let posterPath = poster != nil ? poster : ""
                let dateString = result["release_date"] as? String
                if dateString != "" {
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let date:Date! = dateFormatter.date(from: dateString!)
                    dateFormatter.dateFormat = "M/d/YYYY"
                    releaseDate = dateFormatter.string(from: date) as String?
                } else {
                    releaseDate = "Not Available"
                }
                                
                let newMovie = Movies(id: id!, title: title!, posterPath: posterPath!, releaseDate: releaseDate!)
                movies.append(newMovie)
            }
        }
        
        return movies
    }
    
}
