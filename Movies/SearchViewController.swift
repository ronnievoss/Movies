//
//  MasterViewController.swift
//  Movies
//
//  Created by Ronnie Voss on 11/17/14.
//  Copyright (c) 2014 Ronnie Voss. All rights reserved.
//

import UIKit

class SearchViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, MovieAPIProtocol, UITextFieldDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    @IBOutlet private var flowLayout: UICollectionViewFlowLayout!
    
    var api : MovieAPI!
    var movies = [Movies]()
    var imageCache = [String:UIImage]()
    var movieSearch = ""
    var noDataLabel: UILabel!
    private var width: CGFloat!
    let searchController = UISearchController(searchResultsController: nil)
    
    private let movieAPIKey = "e4fe211a5f904db8260cddc6ab6865bb"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Enter Movie Title"
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.white
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
        api = MovieAPI(APIKey: movieAPIKey, delegate: self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let device = traitCollection.userInterfaceIdiom
        let orientation = UIDevice.current.orientation
        let screenWidth = view.bounds.size.width
        noDataLabel.center = self.view.center
        
        if screenWidth == 678.0 || screenWidth == 639.0 {
            width = screenWidth / 3.5
        } else if screenWidth == 981.0 || screenWidth == 694.0 {
            width = screenWidth / 4.5
        } else if screenWidth == 507.0 {
            width = screenWidth / 3.6
        } else if screenWidth == 694.0 {
            width = screenWidth / 4.5
        } else if screenWidth == 438.0 {
            width = screenWidth / 2.3
        } else if screenWidth == 320.0 {
            width = screenWidth / 2.4
        } else if screenWidth == 480.0 {
            width = screenWidth / 3.5
        } else if screenWidth == 414.0 {
            width = screenWidth / 2.3
        } else if screenWidth == 768.0 {
            width = screenWidth / 4.5
        } else if screenWidth == 1366.0 {
            width = screenWidth / 6.2
        } else if orientation.isLandscape && screenWidth == 1024.0 {
            width = screenWidth / 5.3
        } else if screenWidth == 1024.0 {
            width = screenWidth / 4.2
        } else if orientation.isLandscape && device == .phone {
            width = screenWidth / 4.4
        } else {
            width = screenWidth / 2.5
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        flowLayout.invalidateLayout() // Called to update the cell sizes to fit the new collection view width
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
                searchController.searchBar.resignFirstResponder()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: 260)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if movies.count == 0 {
            
            noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
            noDataLabel.center = self.view.center
            noDataLabel.font = UIFont.systemFont(ofSize: 30)
            noDataLabel.text = "No Results"
            noDataLabel.textColor = UIColor.white
            noDataLabel.textAlignment = NSTextAlignment.center
            self.view.addSubview(noDataLabel)
        }
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
        if let img = imageCache[posterPath] {
            cell.moviePoster.image = img
        } else {
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let request: URLRequest = URLRequest(url: imageURL!)
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                if error == nil {
                    let image = UIImage(data: data!)
                    self.imageCache[posterPath] = image
                    DispatchQueue.main.async {
                        cell.moviePoster.alpha = 0
                        cell.moviePoster.image = image
                        UIView.animate(withDuration: 0.5, animations: {
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
            self.collectionView?.reloadData()
            self.noDataLabel.removeFromSuperview()
        })
    }
    
    func showAlert(_ error: String) {
        let alert = UIAlertController(title: "Network Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: false, completion: nil)
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.returnKeyType = .done
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        movieSearch = searchController.searchBar.text!
        if searchController.searchBar.text == "" {
            movieSearch = " "
        }
        api.searchMovies(movieSearch)
    }
    
}
