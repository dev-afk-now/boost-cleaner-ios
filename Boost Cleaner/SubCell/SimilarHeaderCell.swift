//
//  SimilarHeaderCell.swift
//  Boost Cleaner
//
//  Created by Fresh Brain on 10/2/20.
//  Copyright © 2020 Fresh Brain. All rights reserved.
//

import UIKit

class SimilarHeaderCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var maincellView: UIView!
    @IBOutlet weak var maincellView2: UIView!

    @IBOutlet var namelbl: UILabel!
    @IBOutlet var numberlbl: UILabel!
    @IBOutlet var imagev: UIImageView!
    @IBOutlet var shortNamelbl: UILabel!
    @IBOutlet weak var selectedHeader: UIButton!
    @IBOutlet weak var selectedContacts: UIButton!
    @IBOutlet weak var mergeContactlbl: UILabel!
    @IBOutlet weak var selectContactsToMergelbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.mergeContactlbl.text = "Merged Contact".localized
        self.selectContactsToMergelbl.text = "Select Contacts to Merge".localized
        self.selectedContacts.setTitle("Select".localized, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
