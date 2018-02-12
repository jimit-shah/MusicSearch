//
//  Connectivity.swift
//  MusicSearch
//
//  Created by Jimit Shah on 2/11/18.
//  Copyright © 2018 Jimit Shah. All rights reserved.
//

import Foundation
import Alamofire


class Connectivity {
  class func isConnectedToInternet() ->Bool {
    return NetworkReachabilityManager()!.isReachable
  }
}
