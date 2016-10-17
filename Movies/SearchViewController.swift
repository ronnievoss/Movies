//
//  MasterViewController.swift
//  Movies
//
//  Created by Ronnie Voss on 11/17/14.
//  Copyright (c) 2014 Ronnie Voss. All rights reserved.
//

import UIKit

class SearchViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, MovieAPIProtocol, UITextFieldDelegate, UISearchBarDelegate, UISearchControllerDelegate {
    
    @IBOutlet private var flowLayout: UICollectionViewFlowLayout!
    
    var api : MovieAPI!
    var movies = [Movies]()
    var imageCache = [String:UIImage]()
    var movieSearch = ""
    var searchController: UISearchController!
    private var width: CGFloat!
    
    private let movieAPIKey = "e4fe211a5f904db8260cddc6ab6865bb"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api = MovieAPI(APIKey: movieAPIKey, delegate: self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let device = traitCollection.userInterfaceIdiom
        let orientation = UIDevice.current.orientation
        let screenWidth = view.bounds.size.width
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            let cell = sender as! MovieCellCollectionViewCell
            if let indexPath = self.collectionView!.indexPath(for: cell) {
                let id = self.movies[(indexPath as NSIndexPath).row].id
                let image = cell.moviePoster.image
                (segue.destination as! DetailViewController).poster = image
                (segue.destination as! DetailViewController).detailItem = id
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: 260)
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
        let posterPath = movie.posterPath != "" ? String("https://image.tmdb.org/t/p/w342\(movie.posterPath!)") : placeHolderImage
        let imageURL = URL(string: posterPath!)
        if let img = imageCache[posterPath!] {
            cell.moviePoster.image = img
        } else {
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let request: URLRequest = URLRequest(url: imageURL!)
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                if error == nil {
                    let image = UIImage(data: data!)
                    self.imageCache[posterPath!] = image
                    DispatchQueue.main.async {
                        cell.moviePoster.image = image
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
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }
    
    func showAlert(_ error: String) {
        let alert = UIAlertController(title: "Network Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: false, completion: nil)
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        movieSearch = searchBar.text!
        searchBar.resignFirstResponder()
        //searchBar.text = ""
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        api.searchMovies(movieSearch)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        self.collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView {
            
            switch kind {
                
            case UICollectionElementKindSectionHeader:
                
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                    withReuseIdentifier: "SearchHeaderView",
                    for: indexPath)
                    as! SearchHeaderView
                movieSearch = headerView.searchBar.text!
                
                (self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).sectionHeadersPinToVisibleBounds = true

                return headerView
                
            default:
                
                fatalError("Unexpected element kind")
                
            }
    }
    
}
