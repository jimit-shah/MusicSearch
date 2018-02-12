//
//  WikiaClient.swift
//  MusicSearch
//
//  Created by Jimit Shah on 2/11/18.
//  Copyright © 2018 Jimit Shah. All rights reserved.
//

import UIKit

class WikiaClient {
  
  // example: http://lyrics.wikia.com/api.php?func=getSong&artist=Tom+Waits&song=new+coat+of+paint&fmt=json
  // http://lyrics.wikia.com/wikia.php?controller=LyricsApi&method=getSong&artist=Tom%20Waits
  //Constants
  static let lyricsURL = "http://lyrics.wikia.com/wikia.php?"
  
  // shared session
  var session = URLSession.shared
  
  init() {
  }
  
  // JSON Response keys
  struct JSONResponseKeys {
    
    static let Lyrics = "lyrics"
  }
  
  // MARK: Shared Instance
  
  class func sharedInstance() -> WikiaClient {
    struct Singleton {
      static let sharedInstance = WikiaClient()
    }
    return Singleton.sharedInstance
  }
}

