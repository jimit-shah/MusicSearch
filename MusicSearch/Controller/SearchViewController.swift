//
//  ViewController.swift
//  Music Search
//
//  Created by Jimit Shah on 2/10/18.
//  Copyright © 2018 Jimit Shah. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// MARK: - SearchViewController: UIViewController

class SearchViewController: UIViewController {
  
  // MARK: - Properties
  var musics = [Music]()
  var searchTask: URLSessionDataTask?
  var dataRequest: Request?
  var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
  
  // MARK: Outlets
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    createSearchBar()
  }
  
  // MARK: createSearchBar
  
  func createSearchBar() {
    let musicSearchBar = UISearchBar()
    musicSearchBar.showsCancelButton = true
    musicSearchBar.delegate = self
    musicSearchBar.placeholder = "Search Music"
    musicSearchBar.tintColor = .white
    UITextField.appearance(whenContainedInInstancesOf: [type(of: musicSearchBar)]).tintColor = .darkGray
    
    self.navigationItem.titleView = musicSearchBar
  }
  
  // MARK: - Helper Methods
  
  // get MusicData method
  func getMusicData(url: String, parameters: [String:String]) -> Request {
    musics = [Music]()
    startActivityIndicator(for: self, activityIndicator, .gray)
    let networkRequest = Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
      if response.result.isSuccess {
        print("Success! Got the Music Data")
        
        let musicJSON: JSON = JSON(response.result.value!)
        self.parseMusicData(json: musicJSON)
        
        // update UI
        performUIUpdatesOnMain {
          self.tableView.reloadData()
          self.stopActivityIndicator(for: self, self.activityIndicator)
        }
        
      } else if response.result.isFailure {
        if let error = response.result.error as? AFError, error.responseCode == 499 {
          //INVALID SESSION RESPONSE
          print("Error \(error)")
        } else {
          //NETWORK FAILURE
          print("Something went wrong.")
        }
      }
    }
    return networkRequest
  }
  
  // Parse JSON data
  func parseMusicData(json: JSON) {
    for result in json["results"].arrayValue {
      
      let trackName = result["trackName"].stringValue
      let album = result["collectionName"].stringValue
      let artist = result["artistName"].stringValue
      let imageURL = result["artworkUrl60"].stringValue
      
      let music = Music(trackName: trackName, album: album, artist: artist, imageURL: imageURL)
      musics.append(music)
    }
  }
  
}

// MARK: - MoviePickerViewController: UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    //searchBar.showsCancelButton = true
  }
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
    // cancel the last request
    if let request = dataRequest {
      request.cancel()
      musics = [Music]()
      tableView?.reloadData()
      stopActivityIndicator(for: self, activityIndicator)
    }
    
    // if the text is empty clear search
    if searchText == "" {
      musics = [Music]()
      tableView?.reloadData()
      stopActivityIndicator(for: self, activityIndicator)
      return
    }
    
    // check connection
    if Connectivity.isConnectedToInternet() {
      print("Yes! internet is available.")
      
      // new search
      let params : [String : String ] = [ "term": searchText, "entity":"song", "kind": "song"]
      dataRequest = getMusicData(url: ITunesClient.musicURL, parameters: params)
    } else {
      showAlert("Internet Issue", message: "Searching music requires internet connection, please check your network settings.")
    }
    
  }
}


// MARK: UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return musics.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MusicItemCell", for: indexPath) as! TrackTableViewCell
    
    let music = self.musics[(indexPath as NSIndexPath).row]
    cell.trackNameLabel.text = music.trackName
    cell.albumLabel.text = music.album
    cell.artistLabel.text = music.artist
    
    // get artwork from url and load imageView
    if let stringURL = music.imageURL {
      if let imageURL = URL(string: stringURL) {
        let _ = ITunesClient.sharedInstance().taskForGETImage(imageURL, completionHandlerForImage: { imageData, error in
          if let image = UIImage(data: imageData!) {
            performUIUpdatesOnMain {
              cell.trackImageView?.image = image
            }
          } else {
            print(error ?? "no image available")
          }
        })
      }
    }
    
    return cell
  }
  
  // didSelectRowAt
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let music = musics[(indexPath as NSIndexPath).row]
    
    let controller = storyboard!.instantiateViewController(withIdentifier: "LyricsViewController") as! LyricsViewController
    controller.music = music
    self.navigationController!.pushViewController(controller, animated: true)
  }
  
}

// MARK: Activity Indicators

extension SearchViewController {
  
  // Get New Activity Indicator and Start Animating
  func startActivityIndicator(for controller: UIViewController, _ activityIndicator: UIActivityIndicatorView, _ style: UIActivityIndicatorViewStyle) {
    activityIndicator.center = controller.view.center
    activityIndicator.hidesWhenStopped = true
    activityIndicator.activityIndicatorViewStyle = style
    
    if style == .whiteLarge || style == .white {
      for subview in controller.view.subviews {
        subview.alpha = 0.6
      }
      controller.view.backgroundColor = UIColor.darkGray
    }
    controller.view.addSubview(activityIndicator)
    activityIndicator.alpha = 1.0
    activityIndicator.startAnimating()
  }
  
  // Stop Activity Indicator
  func stopActivityIndicator(for controller: UIViewController, _ activityIndicator: UIActivityIndicatorView) {
    guard activityIndicator.isAnimating else {
      return
    }
    if (activityIndicator.activityIndicatorViewStyle == .whiteLarge || activityIndicator.activityIndicatorViewStyle == .white) {
      controller.view.backgroundColor = UIColor.white
      for subview in controller.view.subviews {
        subview.alpha = 1.0
      }
    }
    activityIndicator.stopAnimating()
  }
  
}

extension UIViewController {
  func showAlert(_ title: String?, message: String, handler: @escaping() -> Void = {}) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: { (action) -> Void in
      handler()
    })
    alert.addAction(dismissAction)
    self.present(alert, animated: true, completion: nil)
  }
  
}

