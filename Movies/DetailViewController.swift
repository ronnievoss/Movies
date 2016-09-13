//
//  DetailViewController.swift
//  Movies
//
//  Created by Ronnie Voss on 11/17/14.
//  Copyright (c) 2014 Ronnie Voss. All rights reserved.
//

import UIKit
import MediaPlayer

class DetailViewController: UIViewController, UIScrollViewDelegate, MovieAPIProtocol, YTPlayerViewDelegate {
    
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
    @IBOutlet weak var VisualEffectTopConstraint: NSLayoutConstraint!
    
    
    var api : MovieAPI!
    private let movieAPIKey = "e4fe211a5f904db8260cddc6ab6865bb"
    var movies = [MovieDetail]()
    var poster : UIImage?
    var timer : Timer?
    var detailItem: Any? {
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
        
        self.playerView.isHidden = true
        self.playButton.isHidden = true
        self.watchTrailerLabel.isHidden = true
        
        let notificationCenter = NotificationCenter.default
        let mainQueue = OperationQueue.main
        
        notificationCenter.addObserver(forName: NSNotification.Name.UIWindowDidBecomeVisible, object: nil, queue: mainQueue) { _ in
            self.timer?.invalidate()
            self.watchTrailerLabel.text = "Watch Trailer"
            self.activityIndicatorView.stopAnimating()
            notificationCenter.removeObserver(self)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.view.bounds.size.width == 768.0 || self.view.bounds.size.width == 438.0 {
            VisualEffectTopConstraint.constant = 630
        }
        
        if self.view.bounds.size.width == 507.0 || self.view.bounds.size.width == 694.0 {
            VisualEffectTopConstraint.constant = 430
        }
        
        if self.view.bounds.size.width == 639.0 {
            VisualEffectTopConstraint.constant = 980
        }
        
        if self.view.bounds.size.width == 1024.0 {
            if UIDevice.current.orientation.isLandscape {
                VisualEffectTopConstraint.constant = 420
            } else {
                VisualEffectTopConstraint.constant = 980
            }
        }
        
        if self.view.bounds.size.width == 1366.0 {
            VisualEffectTopConstraint.constant = 650
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert(_ error: String) {
        let alert = UIAlertController(title: "Network Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        UIApplication.shared.delegate?.window!?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func didReceiveDetailAPIResults(_ results: NSDictionary) {
        DispatchQueue.main.async(execute: {
            
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
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }
    
    func didReceiveTrailerAPIResults(_ results: NSDictionary) {
        
        if let movieTrailer = MovieDetail.Trailer(results: results) as MovieDetail.Trailer? {
        
            if movieTrailer.trailer != nil {
          
            DispatchQueue.main.async {
                self.playButton.isHidden = false
                self.watchTrailerLabel.isHidden = false
                self.playerView.load(withVideoId: "\(movieTrailer.trailer!)")
                }
            
            } else {
            
            DispatchQueue.main.async {
                self.playerView.isHidden = true
                self.playButton.isHidden = true
                self.watchTrailerLabel.isHidden = true
                }
            }
        }
    }
    
    func delayedLoad() {
        let alert = UIAlertController(title: "Trailer Unavailable", message: "Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        UIApplication.shared.delegate?.window!?.rootViewController?.present(alert, animated: true, completion: nil)
        self.activityIndicatorView.stopAnimating()
        self.watchTrailerLabel.text = "Watch Trailer"
        self.playerView.stopVideo()
    }
    
    @IBAction func playTrailer() {
        
        self.watchTrailerLabel.text = "Loading..."
        self.activityIndicatorView.startAnimating()
        self.playerView.playVideo()
        self.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(DetailViewController.delayedLoad), userInfo: nil, repeats: false)
        
        
    
    }
}

