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
    
    init(id: Int, title: String, posterPath: String) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
    }
    
    static func moviesWithJSON(results: NSArray) -> [Movies] {
        
        var movies = [Movies]()
        if results.count>0 {
        
            for result in results {
                
                let id = result["id"] as? Int
                let title = result["title"] as? String
                let poster = result["poster_path"] as? String
                let posterPath = poster != nil ? poster : ""
                
                let newMovie = Movies(id: id!, title: title!, posterPath: posterPath!)
                movies.append(newMovie)
            }
        }
        
        return movies
    }
    
}
