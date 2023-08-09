//
//  CamaraTableViewCell.swift
//  CamaraController
//
//  Created by Omar Campos on 09/08/23.
//

import UIKit

class CamaraTableViewCell: UITableViewCell {
    @IBOutlet weak var ip: UILabel!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var Nombre: UILabel!
    @IBOutlet weak var slotb: UILabel!
    @IBOutlet weak var SlotA: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
