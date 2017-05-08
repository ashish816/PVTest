//
//  MovieDetailViewController.swift
//  PVTest
//
//  Created by Ashish Mishra on 4/22/17.
//  Copyright © 2017 Ashish Mishra. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController, MoviesDataConnectionControllerDelegate {

    
    @IBOutlet weak var posterImage : UIImageView!
    @IBOutlet weak var descriptionView : UITextView!
    @IBOutlet weak var releaseDateLabel : UILabel!
    @IBOutlet weak var genreLabel : UILabel!
    @IBOutlet weak var prodcutionLabel : UILabel!
    @IBOutlet weak var budgetLabel : UILabel!
    
    @IBOutlet weak var youTubeVideo: UIWebView!
    
    var movieApiCommunicator: MovieApiCommunicator = MovieApiCommunicator()
    var movieDetail : MovieDetail?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.movieApiCommunicator.delegate = self as MoviesDataConnectionControllerDelegate
        self.movieApiCommunicator.retreiveAdditionalParametersForMovie(movieDetail: self.movieDetail!);
        
        self.arrangeSubviews()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Watch Promo", style: UIBarButtonItemStyle.done, target: self, action: #selector(MovieDetailViewController.retreiveVideoId))
        
    }
    
    func retreiveImageData(_ posterPath : String?) {
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
                self.posterImage.image = UIImage(data: data)
            })
        }) .resume()
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let contentSize = self.descriptionView.sizeThatFits(self.descriptionView.bounds.size)
        var frame = self.descriptionView.frame
        frame.size.height = contentSize.height > 180 ? 180 :  contentSize.height
        self.descriptionView.frame = frame
        
        let aspectRatioTextViewConstraint = NSLayoutConstraint(item: self.descriptionView, attribute: .height, relatedBy: .equal, toItem: self.descriptionView, attribute: .width, multiplier: descriptionView.bounds.height/descriptionView.bounds.width, constant: 1)
        
        self.descriptionView.addConstraint(aspectRatioTextViewConstraint)
        
    }
    
     func arrangeSubviews() {
        self.descriptionView.text = self.movieDetail?.movieOverView!
        self.budgetLabel.text = self.movieDetail?.budget
        self.prodcutionLabel.text = self.movieDetail?.productionCompany
        self.releaseDateLabel.text = self.movieDetail?.relaseDate
        self.genreLabel.text = self.movieDetail?.genreText
        self.retreiveImageData(self.movieDetail?.backDropPath)
    }

    func requestFailedWithError(_ error: String) {
        let alertController = UIAlertController(title: "Error", message:
            error, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func requestSucceedWithResults(_ results: Any?, requestType : String?){
        let movie = results as! MovieDetail
        self.movieDetail = movie
        self.arrangeSubviews()
    }
    
    func retreiveVideoId() {
        
        self.youTubeVideo.isHidden = false
        
        let APIkey: String = "34747ce9a4b8fd531c6818fe2b2b3155"
        let APIBaseUrl: String = "https://api.themoviedb.org/3/movie/"+"\(self.movieDetail!.movieId!)"+"/videos?api_key="
        let urlString:String = "\(APIBaseUrl)" + "\(APIkey)";
        
        let url = URL(string: urlString)
        let request = URLRequest(url: url!);
        URLSession.shared.dataTask(with: request, completionHandler: { (data , response, error) -> Void in
            guard let data = data else {
                NSLog("Failure");
                return
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.showVideo(data);
            })
        }) .resume()
        
    }
    
    func showVideo(_ data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard let jsonDictionary: NSDictionary = jsonResult as? NSDictionary else
            {
                NSLog("Conversion from JSON failed");
                return
            }
            if let results: NSArray = jsonDictionary["results"] as? NSArray {
                if results.count > 0 {
                    if let videoInfo = results[0] as? NSDictionary {
                        let youTubeVideoId = videoInfo["key"] as! String;
                        self.playVideo(youTubeVideoId);
                    }
                }
                else {
                    let noPreviewAvailable : String = "No Preview available for the movie";
                    self.youTubeVideo.loadHTMLString(noPreviewAvailable.replacingOccurrences(of: "\n", with: "<br/>"), baseURL: nil);
                }
            }
        }
        catch {
            NSLog("Conversion from JSON failed");
        }
    }
    
    func playVideo(_ videoId : String){
        youTubeVideo.allowsInlineMediaPlayback = true
        let youTubelink: String = "http://www.youtube.com/embed/\(videoId)"
        
        let width = self.youTubeVideo.bounds.width;
        let height = self.youTubeVideo.bounds.height;
        let frame = 10;
        
        
        let Code:String = "<iframe width =\(width) height = \(height) src = \(youTubelink) frameborder = \(frame)></iframe>";
        self.youTubeVideo.loadHTMLString(Code as String, baseURL: nil);
    }
    
}
