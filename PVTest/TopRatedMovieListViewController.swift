//
//  TopRatedMovieListViewController.swift
//  PVTest
//
//  Created by Ashish Mishra on 4/22/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit

class TopRatedMovieListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MoviesDataConnectionControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var topRatedMoviesTableView: UITableView!
    var movieDetail : MovieDetail?
    var topRatedMovies: Array = [MovieDetail]()
    var movieApiCommunicator: MovieApiCommunicator = MovieApiCommunicator()
    
    var genreDictionary : Dictionary<Int, String?>?
    
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var topConstraint : NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.movieSearchBar.isHidden = true
        self.topConstraint.constant = -44
        self.movieApiCommunicator.delegate = self as MoviesDataConnectionControllerDelegate
        self.movieApiCommunicator.getGenreList()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: UIBarButtonItemStyle.done, target: self, action: #selector(TopRatedMovieListViewController.startSearchMode))

    }
    
    func startSearchMode() {
        self.movieSearchBar.isHidden = !self.movieSearchBar.isHidden
        
        if self.movieSearchBar.isHidden == true {
            self.navigationItem.rightBarButtonItem?.title = "Search"
            self.topConstraint.constant = self.topConstraint.constant - 44
            self.movieApiCommunicator.getTopRatedMovies()
        }else {
            self.navigationItem.rightBarButtonItem?.title = "Top Rated"
            self.topConstraint.constant = 0

        }
    }
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return topRatedMovies.count;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier: String = "TopRatedMovieCell"
        
        let cell: TopRatedMovieCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)! as! TopRatedMovieCell
        
        let cellData: MovieDetail = self.topRatedMovies[indexPath.row] 
        cell.movieTitleLabel.text = cellData.movieTitle
        cell.movieDescriptionLabel.text = cellData.movieOverView
        cell.movieReleaseDate.text = cellData.relaseDate
        
        var genreText : String = String()
        
        var count = 0;
        for genreId in cellData.genres! {
            count = count + 1;
            if (self.genreDictionary?[genreId]) != nil {
                if count == cellData.genres?.count {
                    genreText = genreText + ((self.genreDictionary?[genreId])!)!

                }else {
                    genreText = genreText + ((self.genreDictionary?[genreId])!)! + ","

                }
            }
        }
        
        cell.movieGenre.text = genreText
        cellData.genreText = genreText
        
        if let posterPath = cellData.posterPath {
            self.retreiveImageData(posterPath,indexPath: indexPath)
        } else {
            
            let bundlePath = Bundle.main.path(forResource: "download", ofType: "png")
            cell.moviePoster.image = UIImage(contentsOfFile: bundlePath!)
            cell.setNeedsLayout()
        }
        
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.movieSearchBar.resignFirstResponder()
    }
    
    func retreiveImageData(_ posterPath : String?, indexPath: IndexPath) {
        guard let posterPath = posterPath else {
            return
        }
        let baseUrl: String = "http://image.tmdb.org/t/p/w300"
        let urlString: String = "\(baseUrl)" + "\(posterPath)"
        let imgURL: URL = URL(string: urlString)!
        
        URLSession.shared.dataTask(with: imgURL, completionHandler: { (data, response, erro) -> Void in
            guard let data = data else {
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                if let cell : TopRatedMovieCell = self.topRatedMoviesTableView.cellForRow(at: indexPath) as? TopRatedMovieCell {
                    cell.moviePoster.image = UIImage(data: data)
                    cell.setNeedsLayout()
                }
            })
        }) .resume()
        
    }
    
    func requestFailedWithError(_ error: String) {
        let alertController = UIAlertController(title: "Error", message:
            error, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func requestSucceedWithResults(_ results: Any?, requestType : String?){
        
        if requestType == "Genre"{
            self.genreDictionary = results as? Dictionary
            self.movieApiCommunicator.getTopRatedMovies()
            return
        }
        self.topRatedMovies.removeAll(keepingCapacity: true)
        self.topRatedMovies = (results as! NSArray) as! [Any] as! [MovieDetail]
        self.topRatedMoviesTableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.movieDetail = self.topRatedMovies[indexPath.row]
        if let _ = tableView.cellForRow(at: indexPath){
            self.performSegue(withIdentifier: "MovieToDetailVC", sender: self);
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MovieToDetailVC" {
            if let destination = segue.destination as? MovieDetailViewController{
                destination.movieDetail = self.movieDetail;
            }
        }
    }
    
    func searchMovies(_ serachedString : String)
    {
        
        self.movieApiCommunicator
            .retreiveSearchResults(serachedString)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.topRatedMovies.removeAll()
            self.topRatedMoviesTableView.reloadData()
        }
        self.searchMovies(searchText);
    }

}
