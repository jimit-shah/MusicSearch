//
//  ItunesClient.swift
//  Music Search
//
//  Created by Jimit Shah on 2/11/18.
//  Copyright © 2018 Jimit Shah. All rights reserved.
//

import UIKit

class ITunesClient {
  // example: https://itunes.apple.com/search?term=tom+waits
  
  //Constants
  static let musicURL = "https://itunes.apple.com/search?"
  
  // shared session
  var session = URLSession.shared
  
  init() {
  }
  
  // JSON Response keys
  struct JSONResponseKeys {
    
    static let StatusMessage = "status_message"
    static let StatusCode = "status_code"
    
    static let TrackName = "trackName"
    static let Album = "collectionName"
    static let ArtistName = "artistName"
    static let ArtworkURL = "artworkUrl60"
  }
  
  // MARK: Shared Instance
  
  class func sharedInstance() -> ITunesClient {
    struct Singleton {
      static let sharedInstance = ITunesClient()
    }
    return Singleton.sharedInstance
  }
  
  
  
  // MARK: GET Image
  
  func taskForGETImage(_ url: URL, completionHandlerForImage: @escaping (_ imageData: Data?, _ error: NSError?) -> Void) -> URLSessionTask {
    
    /* Build the URL and configure the request */
    let request = URLRequest(url: url)
    
    /* Make the request */
    let task = session.dataTask(with: request) { (data, response, error) in
      
      func sendError(_ error: String) {
        print(error)
        let userInfo = [NSLocalizedDescriptionKey : error]
        completionHandlerForImage(nil, NSError(domain: "taskForGETImage", code: 1, userInfo: userInfo))
      }
      
      /* GUARD: Was there an error? */
      guard (error == nil) else {
        sendError("There was an error with GET Image request: \(error!)")
        return
      }
      
      /* GUARD: Did we get a successful 2XX response? */
      guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
        sendError("Your request returned a status code other than 2xx!")
        return
      }
      
      /* GUARD: Was there any data returned? */
      guard let data = data else {
        sendError("No data was returned by the request!")
        return
      }
      
      /* Parse the data and use the data (happens in completion handler) */
      completionHandlerForImage(data, nil)
    }
    
    /* 7. Start the request */
    task.resume()
    
    return task
  }
}
