//
//  GCDBlackBox.swift
//  MusicSearch
//
//  Created by Jimit Shah on 2/10/18.
//  Copyright © 2018 Jimit Shah. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
  DispatchQueue.main.async {
    updates()
  }
}
