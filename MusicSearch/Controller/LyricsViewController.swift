//
//  LyricsViewController.swift
//  MusicSearch
//
//  Created by Jimit Shah on 2/11/18.
//  Copyright © 2018 Jimit Shah. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// MARK: - LyricsViewController: UIViewController
class LyricsViewController: UIViewController {
  
  // MARK: Properties
  
  var music: Music?
  var lyricsURL: String?
  
  // MARK: Outlets
  
  @IBOutlet weak var songImageView: UIImageView!
  @IBOutlet weak var trackNameLabel: UILabel!
  @IBOutlet weak var albumLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var lyricsTextView: UITextView!
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    trackNameLabel.text = music?.trackName
    albumLabel.text = music?.album
    artistNameLabel.text = music?.artist
    lyricsTextView.text = ""
    
    // get artwork from url and load imageView
    if let stringURL = music?.imageURL {
      if let imageURL = URL(string: stringURL) {
        let _ = ITunesClient.sharedInstance().taskForGETImage(imageURL, completionHandlerForImage: { imageData, error in
          if let image = UIImage(data: imageData!) {
            performUIUpdatesOnMain {
              self.songImageView?.image = image
            }
          } else {
            print(error ?? "no image available")
          }
        })
      }
    }
    
    // get Lyrics
    let params : [String : String ] = [ "controller": "LyricsApi", "method": "getSong", "artist":music!.artist, "song": music!.trackName, "fmt":"json"]
    
    getLyricsData(url: WikiaClient.lyricsURL, parameters: params)
  }
  
  
  // MARK: - GET MusicData method
  
  func getLyricsData(url: String, parameters: [String:String]) {
    
    Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
      if response.result.isSuccess {
        print("Success! Got the Lyrics Data")
        
        let json: JSON = JSON(response.result.value!)
        
        if let lyrics = json["result"]["lyrics"].string {
          performUIUpdatesOnMain {
            self.lyricsTextView.text = "\(lyrics)"
          }
        } else {
          performUIUpdatesOnMain {
            self.lyricsTextView.text = "No lyrics found for this song."
          }
        }
        
      } else {
        if let error = response.result.error {
          print("Error \(error)")
        }
        print("Connection Issue")
      }
    }
  }
  
  
}
