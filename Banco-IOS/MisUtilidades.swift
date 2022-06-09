//
//  MisUtilidades.swift
//  Banco-IOS
//
//  Created by user216116 on 09/06/22.
//

import Foundation
import UIKit

func miAlerta(self: Any) {
    let alertController = UIAlertController(title: "Advertencia", message: "Verifique su usuario y/o contraseña", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
    
    return (self as AnyObject).present(alertController, animated: true, completion: nil)
}
