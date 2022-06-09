//
//  MenuViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 08/06/22.
//

import UIKit
import FirebaseAuth

class MenuViewController: UIViewController {

    @IBOutlet weak var usuarioLabel: UILabel!
    @IBOutlet weak var cerrarSesionButton: UIButton!
    @IBOutlet weak var configurarPerfilButton: UIButton!
    @IBOutlet weak var consultaSaldoButton: UIButton!
    @IBOutlet weak var miInformacionButton: UIButton!
    @IBOutlet weak var depositoButton: UIButton!
    
    private let email: String
    
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title="Menú"
        
        usuarioLabel.text = "Logueado como: \(email)"
    }
    
    @IBAction func cerrarSesion(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popViewController(animated: true)
        } catch {
            // Manejo de errores si no se pudo salir de la sesion (alerta)
        }
        
        
    }
    
    @IBAction func configurarPerfil(_ sender: Any) {
        self.navigationController?.pushViewController(ConfigurarPerfilViewController(email: email), animated: true)
    }
    
    @IBAction func consultarSaldo(_ sender: Any) {
        self.navigationController?.pushViewController(ConsultaSaldoViewController(email: email), animated: true)
    }
    
    
    @IBAction func verMiInformacion(_ sender: Any) {
        self.navigationController?.pushViewController(MiInformacionViewController(email: email), animated: true)
    }
    
    @IBAction func depositar(_ sender: Any) {
        self.navigationController?.pushViewController(DepositoViewController(email: email), animated: true)
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
