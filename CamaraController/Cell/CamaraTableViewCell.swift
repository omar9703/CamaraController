//
//  CamaraTableViewCell.swift
//  CamaraController
//
//  Created by Omar Campos on 09/08/23.
//

import UIKit

class CamaraTableViewCell: UITableViewCell {
    @IBOutlet weak var swtc: UISwitch!
    @IBOutlet weak var ip: UILabel!
    var grabar = true
    var cam : CamaraAction?
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var Nombre: UILabel!
    @IBOutlet weak var slotb: UILabel!
    @IBOutlet weak var SlotA: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setup(c : CamaraAction)
    {
        cam = c
        grabar = c.grabarGeneral
        swtc.isOn = c.grabarGeneral
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func grabarEnable(_ sender: UISwitch) {
        cam?.grabarGeneral = sender.isOn
        
    }
    
}
