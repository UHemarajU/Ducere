//
//  TableViewCell.swift
//  Task
//
//  Created by Hemaraju MacMini on 25/03/19.
//  Copyright © 2019 incipio. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
