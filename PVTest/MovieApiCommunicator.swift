//
//  MovieApiCommunicator.swift
//  PVTest
//
//  Created by Ashish Mishra on 4/22/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit

protocol MoviesDataConnectionControllerDelegate {
    func requestSucceedWithResults(_ results: Any?, requestType : String?)
     func requestFailedWithError(_ error: String)
}

class MovieApiCommunicator: NSObject {
    var delegate: MoviesDataConnectionControllerDelegate?;

    func getGenreList(){
        
        let APIkey: String = "34747ce9a4b8fd531c6818fe2b2b3155"
        let APIBaseUrl: String = "https://api.themoviedb.org/3/genre/movie/list?language=en-US&api_key=\(APIkey)"
        
        let urlString:String = APIBaseUrl
        
        let url = URL(string: urlString)
        let request = URLRequest(url: url!);
        URLSession.shared.dataTask(with: request, completionHandler: { (data , response, error) -> Void in
            guard data != nil else {
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                self.parseGenres(data!);
            })
        }) .resume()
    
    }
    
    func parseGenres(_ requestData : Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: requestData, options: .allowFragments)
            guard let jsonDictionary: NSDictionary = jsonResult as? NSDictionary else
            {
                self.delegate?.requestFailedWithError("ERROR: conversion from JSON failed")
                return
            }
            guard let results: NSArray = jsonDictionary["genres"] as? NSArray else {
                return
            }
            var genreDic = Dictionary<Int, String>()
            for  obj in results {
                let genreInfo = obj as? NSDictionary;

                genreDic[(genreInfo!["id"] as? Int)!] = genreInfo!["name"] as? String

            }
            self.delegate?.requestSucceedWithResults(genreDic, requestType: "Genre")
        }
        catch {
            self.delegate?.requestFailedWithError("ERROR: conversion from JSON failed")
        }
    }
    
    func retreiveAdditionalParametersForMovie(movieDetail : MovieDetail){
        
        let APIkey: String = "34747ce9a4b8fd531c6818fe2b2b3155"
        let APIBaseUrl: String = "https://api.themoviedb.org/3/movie/\(movieDetail.movieId!)?api_key="
        
        let urlString:String = "\(APIBaseUrl)" + "\(APIkey)";
        
        let url = URL(string: urlString)
        let request = URLRequest(url: url!);
        URLSession.shared.dataTask(with: request, completionHandler: { (data , response, error) -> Void in
            guard data != nil else {
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                self.parseAndUpdateCurrentMovie(data: data!, movieInfo: movieDetail);
            })
        }) .resume()
    }
    
    func parseAndUpdateCurrentMovie(data: Data, movieInfo : MovieDetail) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard let jsonDictionary: NSDictionary = jsonResult as? NSDictionary else
            {
                self.delegate?.requestFailedWithError("ERROR: conversion from JSON failed")
                return
            }
            
            movieInfo.budget = "\(jsonDictionary["budget"]!)"
            if let productionCompanies = jsonDictionary["production_companies"] as? NSArray {
                if productionCompanies.count > 0 {
                    let productionCompany = productionCompanies[0] as! NSDictionary
                    movieInfo.productionCompany = productionCompany.value(forKey: "name") as? String
                }
            }
            
            self.delegate?.requestSucceedWithResults(movieInfo, requestType: nil)
        }
        catch {
            self.delegate?.requestFailedWithError("ERROR: conversion from JSON failed")
        }
        
    }
    
    func retreiveSearchResults(_ queryKeyword : String)
    {
        let APIkey: String = "34747ce9a4b8fd531c6818fe2b2b3155"
        let APIBaseUrl: String = "https://api.themoviedb.org/3/search/movie?api_key="
        let escapedString = queryKeyword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let urlString:String = "\(APIBaseUrl)" + "\(APIkey)"+"&"+"query=" + "\(escapedString)";
        
        let url = URL(string: urlString)
        let request = URLRequest(url: url!);
        URLSession.shared.dataTask(with: request, completionHandler: { (data , response, error) -> Void in
            guard let data = data else {
                self.delegate?.requestFailedWithError(error.debugDescription)
                return
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.parseResults(data);
            })
        }) .resume()
    }
    
    
    func getTopRatedMovies() {
    
        let APIkey: String = "34747ce9a4b8fd531c6818fe2b2b3155"
        let APIBaseUrl: String = "https://api.themoviedb.org/3/movie/top_rated?api_key="
        
        let urlString:String = "\(APIBaseUrl)" + "\(APIkey)";
        
        let url = URL(string: urlString)
        let request = URLRequest(url: url!);
        URLSession.shared.dataTask(with: request, completionHandler: { (data , response, error) -> Void in
            guard data != nil else {
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                self.parseResults(data!);
            })
        }) .resume()
        
    }
    
    
    func parseResults(_ requestData : Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: requestData, options: .allowFragments)
            guard let jsonDictionary: NSDictionary = jsonResult as? NSDictionary else
            {
                self.delegate?.requestFailedWithError("ERROR: conversion from JSON failed")
                return
            }
            guard let results: NSArray = jsonDictionary["results"] as? NSArray else {
                return
            }
            let movies : NSMutableArray = NSMutableArray();
            for  Obj in results {
                let movieDetail = MovieDetail();
                let movieInfo = Obj as? NSDictionary;
                movieDetail.movieTitle = movieInfo!["title"] as? String;
                movieDetail.relaseDate = movieInfo!["release_date"] as? String;
                movieDetail.posterPath = movieInfo!["poster_path"] as? String;
                movieDetail.backDropPath = movieInfo!["backdrop_path"] as? String;
                movieDetail.movieOverView = movieInfo!["overview"] as? String;
                movieDetail.youTubeVideoId = movieInfo!["video"] as? String;
                movieDetail.movieId = movieInfo!["id"] as? Int;
                movieDetail.genres = movieInfo!["genre_ids"] as? Array
                
                movies.add(movieDetail);
            }
            
            self.delegate?.requestSucceedWithResults(movies, requestType: nil)
        }
        catch {
            self.delegate?.requestFailedWithError("ERROR: conversion from JSON failed")
        }
    }
}
