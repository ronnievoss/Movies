//
//  MasterViewController.swift
//  Movies
//
//  Created by Ronnie Voss on 11/17/14.
//  Copyright (c) 2014 Ronnie Voss. All rights reserved.
//

import UIKit

class SearchViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, MovieAPIProtocol, UITextFieldDelegate, UISearchBarDelegate, UISearchControllerDelegate {
    
    var api : MovieAPI!
    var movies = [Movies]()
    var imageCache = [String:UIImage]()
    var movieSearch = ""
    
    private let movieAPIKey = "e4fe211a5f904db8260cddc6ab6865bb"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api = MovieAPI(APIKey: movieAPIKey, delegate: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let cell = sender as! MovieCellCollectionViewCell
            if let indexPath = self.collectionView!.indexPathForCell(cell) {
                if let object = self.movies[indexPath.row].id {
                    let image = cell.moviePoster.image
                    (segue.destinationViewController as! DetailViewController).poster = image
                    (segue.destinationViewController as! DetailViewController).detailItem = object
                }
            }
        }
    }
    
    func showAlert(error: String) {
        let alert = UIAlertController(title: "Network Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: false, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.size.width / 2.4, 260)
    }

    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movieCell", forIndexPath: indexPath) as! MovieCellCollectionViewCell
        
        // Configure the cell
        let movie = self.movies[indexPath.row]
        cell.movieTitle.text = movie.title
        cell.moviePoster.image = UIImage(named: "no-poster.png")
        
        let placeHolderImage = String(NSBundle.mainBundle().pathForResource("no-poster", ofType: "png")!)
        let posterPath = movie.posterPath != "" ? String("https://image.tmdb.org/t/p/w342\(movie.posterPath!)") : placeHolderImage
        let imageURL = NSURL(string: posterPath)
        if let img = imageCache[posterPath] {
            cell.moviePoster.image = img
        } else {
            let request: NSURLRequest = NSURLRequest(URL: imageURL!)
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    // Convert the downloaded data in to a UIImage object
                    let image = UIImage(data: data!)
                    // Store the image in to our cache
                    self.imageCache[posterPath] = image
                    // Update the cell
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = collectionView.cellForItemAtIndexPath(indexPath) as? MovieCellCollectionViewCell {
                            cellToUpdate.moviePoster.image = image
                        }
                    })
                } else {
                    print("Error: \(error!.localizedDescription)")
                }
            })
        }
        return cell
    }
    
    func didReceiveAPIResults(results: NSArray) {
        dispatch_async(dispatch_get_main_queue(), {
            self.movies = Movies.moviesWithJSON(results)
            self.collectionView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        movieSearch = searchBar.text!
        searchBar.resignFirstResponder()
        searchBar.text = ""
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        api.searchMovies(movieSearch)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        self.collectionView!.reloadData()
    }
    
    override func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
            
            switch kind {
                
            case UICollectionElementKindSectionHeader:
                
                let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                    withReuseIdentifier: "SearchHeaderView",
                    forIndexPath: indexPath)
                    as! SearchHeaderView
                movieSearch = headerView.searchBar.text!

                return headerView
                
            default:
                
                fatalError("Unexpected element kind")
                
            }
    }
    
}
