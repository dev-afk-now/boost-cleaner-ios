//
//  ResultHistoryTVC.swift
//  Boost Cleaner
//
//  Created by HABIB on 28/10/2020.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit

class ResultHistoryTVC: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet var lblip: UILabel!
    @IBOutlet var lblNetworkName: UILabel!
    @IBOutlet var imageNetwork: UIImageView!
    @IBOutlet var lblUpSpeed: UILabel!
    @IBOutlet var lblDownSpeed: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.dropShadow2()
        cellView.layer.cornerRadius = 18
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
