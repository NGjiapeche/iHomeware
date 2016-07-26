//
//  SearchedGatwayCell.swift
//  iHomewre_swift
//
//  Created by mac on 16/7/13.
//  Copyright © 2016年 mac. All rights reserved.
//

import UIKit

class SearchedGatwayCell: UITableViewCell {

    @IBOutlet weak var gatwayIPlab: UILabel!
      
    var cellTapped: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
