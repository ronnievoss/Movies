//
//  CollectionViewController.swift
//  Movies
//
//  Created by Ronnie Voss on 3/7/15.
//  Copyright (c) 2015 Ronnie Voss. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, MovieAPIProtocol {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl?
    
    var api : MovieAPI!
    var movies = [Movies]()
    var imageCache = [String:UIImage]()
    var poster:[UIImage]?
    
    private let movieAPIKey = "e4fe211a5f904db8260cddc6ab6865bb"
    
    var movieURL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        appDelegate.myViewController = self
        api = MovieAPI(APIKey: movieAPIKey, delegate: self)
        movieURL = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?&api_key=\(movieAPIKey)")
        api.nowPlayingMovies(movieURL)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetail" {
            let cell = sender as! MovieCellCollectionViewCell
            if let indexPath = self.collectionView!.indexPathForCell(cell) {
                let id = self.movies[indexPath.row].id
                let image = cell.moviePoster.image
                (segue.destinationViewController as! DetailViewController).poster = image
                (segue.destinationViewController as! DetailViewController).detailItem = id
                
            }
        }
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
    
    func showAlert(error: String) {
        let alert = UIAlertController(title: "Network Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: false, completion: nil)
    }
    
    override func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
            
            switch kind {
                
            case UICollectionElementKindSectionHeader:
                
                let headerView =
                collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                withReuseIdentifier: "SegmentHeaderView",
                forIndexPath: indexPath) 

                return headerView
                
            default:
                fatalError("Unexpected element kind")
            }
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex
        {
        case 0:
            movieURL = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?&api_key=\(movieAPIKey)")
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            api.nowPlayingMovies(movieURL!)
            self.title = "Now Playing"
        case 1:
            movieURL = NSURL(string: "https://api.themoviedb.org/3/movie/popular?&api_key=\(movieAPIKey)")
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            api.nowPlayingMovies(movieURL!)
            self.title = "Popular"
        case 2:
            movieURL = NSURL(string: "https://api.themoviedb.org/3/movie/upcoming?&api_key=\(movieAPIKey)")
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            api.nowPlayingMovies(movieURL!)
            self.title = "Upcoming"
        default:
            break; 
        }
    }
    
}
        



