//
//  CeldaPersonalizadaTableViewCell.swift
//  Banco-IOS
//
//  Created by user216116 on 28/06/22.
//

import UIKit

class CeldaPersonalizadaTableViewCell: UITableViewCell {

    @IBOutlet weak var nombreEmpresaLabel: UILabel!
    @IBOutlet weak var montoLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var logoImagen: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        accessoryType = .disclosureIndicator
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
