//
//  AccountCell.swift
//  Ledger
//
//  Created by Derek Quach on 7/30/15.
//  Copyright (c) 2015 Derek Quach. All rights reserved.
//

import Foundation
import UIKit

class AccountCell: UITableViewCell {
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var transactionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}