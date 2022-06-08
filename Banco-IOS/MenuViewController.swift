//
//  MenuViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 08/06/22.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var usuarioLabel: UILabel!
    @IBOutlet weak var cerrarSesionButton: UIButton!
    
    
    private let usuario: String
    
    init(usuario: String) {
        self.usuario = usuario
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title="Menú"
    }
    
    @IBAction func cerrarSesion(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
