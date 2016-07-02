//
//  DetailViewController.swift
//  Movies
//
//  Created by Ronnie Voss on 11/17/14.
//  Copyright (c) 2014 Ronnie Voss. All rights reserved.
//

import UIKit
import MediaPlayer

class DetailViewController: UIViewController, UIScrollViewDelegate, MovieAPIProtocol {
    
    @IBOutlet var movieTitle: UILabel!
    @IBOutlet var relDate: UILabel!
    @IBOutlet var runtime: UILabel!
    @IBOutlet var category: UILabel!
    @IBOutlet var content: UITextView!
    @IBOutlet var posterImage: UIImageView!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet var playerView: YTPlayerView!
    @IBOutlet weak var watchTrailerLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    var api : MovieAPI!
    private let movieAPIKey = "e4fe211a5f904db8260cddc6ab6865bb"
    var movies = [MovieDetail]()
    var poster : UIImage?
    var timer : NSTimer?
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
            
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        api = MovieAPI(APIKey: movieAPIKey, delegate: self)
        let id = self.detailItem as! Int
        _ = self.poster
        api.movieDetail(id)
        api.getTrailer(id)
        self.hidesBottomBarWhenPushed = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playerView.hidden = true
        self.playButton.hidden = true
        self.watchTrailerLabel.hidden = true
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        notificationCenter.addObserverForName(UIWindowDidBecomeVisibleNotification, object: nil, queue: mainQueue) { _ in
            self.timer?.invalidate()
            self.watchTrailerLabel.text = "Watch Trailer"
            self.activityIndicatorView.stopAnimating()
            notificationCenter.removeObserver(self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert(error: String) {
        let alert = UIAlertController(title: "Network Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alert: UIAlertAction!) in self.navigationController?.popViewControllerAnimated(true)}))
        UIApplication.sharedApplication().delegate?.window!?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    func didReceiveDetailAPIResults(results: NSDictionary) {
        dispatch_async(dispatch_get_main_queue(), {
            
            let movie = MovieDetail(results: results)
            
            self.movieTitle.text = movie.title
            self.relDate.text = "Released: \(movie.releaseDate!)"
            self.runtime.text = "Runtime: \(movie.runtimeString!)"
            self.runtime.text = "Runtime: \(movie.runtimeString!)"
            self.category.text = "Genre: \(movie.genres!)"
            if movie.voteAverage != 0.0 {
                self.popularityLabel.text = "Popularity: \(movie.voteAverage!)★"
            } else {
                self.popularityLabel.text = "Popularity: Not Available"
            }
            self.content.text = movie.overview
            self.posterImage.image = self.poster
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    func didReceiveTrailerAPIResults(results: NSDictionary) {
        
        if let movieTrailer = MovieDetail.Trailer(results: results) as MovieDetail.Trailer? {
        
            if movieTrailer.trailer != nil {
          
            dispatch_async(dispatch_get_main_queue()) {
                self.playerView.hidden = false
                self.playButton.hidden = false
                self.watchTrailerLabel.hidden = false
                self.playerView.loadWithVideoId("\(movieTrailer.trailer!)", playerVars: ["enablejsapi":1, "controls":0, "fs":0])
                }
            
            } else {
            
            dispatch_async(dispatch_get_main_queue()) {
                self.playerView.hidden = true
                self.playButton.hidden = true
                self.watchTrailerLabel.hidden = true
                }
            }
        }
    }
    
    func delayedLoad() {
        print("Timer called")
        let alert = UIAlertController(title: "Trailer Unavailable", message: "Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        UIApplication.sharedApplication().delegate?.window!?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        self.activityIndicatorView.stopAnimating()
        self.watchTrailerLabel.text = "Watch Trailer"
        self.playerView.stopVideo()
    }
    
    @IBAction func playTrailer() {
        
        self.watchTrailerLabel.text = "Loading..."
        self.activityIndicatorView.startAnimating()
        self.playerView.playVideo()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: Selector("delayedLoad"), userInfo: nil, repeats: false)
        
        
    
    }
}

