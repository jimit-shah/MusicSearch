//
//  TrackTableViewCell.swift
//  MusicSearch
//
//  Created by Jimit Shah on 2/10/18.
//  Copyright © 2018 Jimit Shah. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {

  @IBOutlet weak var trackImageView: UIImageView!
  @IBOutlet weak var trackNameLabel: UILabel!
  @IBOutlet weak var albumLabel: UILabel!
  @IBOutlet weak var artistLabel: UILabel!
  
  override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
