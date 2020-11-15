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
    @IBOutlet private var flowLayout: UICollectionViewFlowLayout!
    
    var api : MovieAPI!
    var movies = [Movies]()
    var imageCache = [String:UIImage]()
    
    private let movieAPIKey = "e4fe211a5f904db8260cddc6ab6865bb"
    
    var region: String!
    var language: String!
    var movieURL: URL?
    var width: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        region = Locale.current.regionCode
        language = "\(Locale.preferredLanguages[0])-\(region!)"
    
        let appDelegate:AppDelegate = UIApplication.shared.delegate! as! AppDelegate
        appDelegate.myViewController = self
        api = MovieAPI(APIKey: movieAPIKey, delegate: self)
        movieURL = URL(string: "https://api.themoviedb.org/3/movie/now_playing?&api_key=\(movieAPIKey)&language="+language+"&page=1&region="+region+"")
        api.nowPlayingMovies(movieURL)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        width = getScreenWidth()
    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            let cell = sender as! MovieCellCollectionViewCell
            if let indexPath = self.collectionView!.indexPath(for: cell) {
                let id = self.movies[(indexPath as NSIndexPath).row].id
                let image = cell.moviePoster.image
                let releaseDate = movies[indexPath.row].releaseDate
                (segue.destination as! DetailViewController).poster = image
                (segue.destination as! DetailViewController).detailItem = id
                (segue.destination as! DetailViewController).releaseDate = releaseDate
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        flowLayout.invalidateLayout() // Called to update the cell sizes to fit the new collection view width
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: 250)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCellCollectionViewCell
        
        let movie = self.movies[(indexPath as NSIndexPath).row]
        cell.movieTitle.text = movie.title
        cell.moviePoster.image = UIImage(named: "no-poster.png")
    
        let placeHolderImage = String(Bundle.main.path(forResource: "no-poster", ofType: "png")!)
        let posterPath = movie.posterPath != "" ? String("https://image.tmdb.org/t/p/w500\(movie.posterPath!)") : placeHolderImage
        let imageURL = URL(string: posterPath)
        if let img = self.imageCache[posterPath] {
            cell.moviePoster.image = img
        } else {
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let request: URLRequest = URLRequest(url: imageURL!)
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                if error == nil {
                    DispatchQueue.main.async {
                        let image = UIImage(data: data!)
                        self.imageCache[posterPath] = image
                        cell.moviePoster.alpha = 0
                        cell.moviePoster.image = image
                        UIView.animate(withDuration: 0.3, animations: {
                            cell.moviePoster.alpha = 1
                        })
                    }
                } else {
                    print("Error: \(error!.localizedDescription)")
                }
            })
            task.resume()
        }
        return cell
    }
    
    func didReceiveAPIResults(_ results: NSArray) {
        DispatchQueue.main.async(execute: {
            self.movies = Movies.moviesWithJSON(results)
            self.collectionView!.reloadData()
        })
    }
    
    func showAlert(_ error: String) {
        let alert = UIAlertController(title: "Network Error", message: error, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: false, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView {
            
            switch kind {
                
            case UICollectionView.elementKindSectionHeader:
                
                let headerView =
                collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                withReuseIdentifier: "SegmentHeaderView",
                for: indexPath)
                
                (self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).sectionHeadersPinToVisibleBounds = true

                return headerView
                
            default:
                fatalError("Unexpected element kind")
            }
    }
    
    @objc private func refreshData() {
        api.nowPlayingMovies(movieURL)
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex
        {
        case 0:
            movieURL = URL(string: "https://api.themoviedb.org/3/movie/now_playing?&api_key=\(movieAPIKey)&language="+language+"&page=1&region="+region+"")
            api.nowPlayingMovies(movieURL!)
            self.title = "Now Playing"
        case 1:
            movieURL = URL(string: "https://api.themoviedb.org/3/movie/popular?&api_key=\(movieAPIKey)&language="+language+"&page=1&region="+region+"")
            api.nowPlayingMovies(movieURL!)
            self.title = "Popular"
        case 2:
            movieURL = URL(string: "https://api.themoviedb.org/3/movie/upcoming?&api_key=\(movieAPIKey)&language="+language+"&page=1&region="+region+"")
            api.nowPlayingMovies(movieURL!)
            self.title = "Upcoming"
        default:
            break; 
        }
    }
    
}
        



