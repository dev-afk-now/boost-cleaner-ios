//
//  AllContactsCell.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 9/30/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit

class AllContactsCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet var namelbl: UILabel!
    @IBOutlet var numberlbl: UILabel!
    @IBOutlet var imagev: UIImageView!
    @IBOutlet var shortNamelbl: UILabel!
    @IBOutlet weak var selectedCell: UIButton!
    @IBOutlet weak var maincellView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
