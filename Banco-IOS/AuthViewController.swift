//
//  AuthViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 08/06/22.
//

import UIKit
import FirebaseAuth

class AuthViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registrarButton: UIButton!
    @IBOutlet weak var accederButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title="Autenticación"
        emailTextField.text = "test@gmail.com"
        passwordTextField.text = "12345678"
    }
    @IBAction func registrarCuenta(_ sender: Any) {
        if let email=emailTextField.text,let password=passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) {
                (result, error) in
                if var result = result, error == nil {
                    // Navegando entre vistas y pasando datos en constructor
                    self.navigationController?.pushViewController(MenuViewController(usuario: email), animated: true)
                } else {
                    // Alert
                    let alertController = UIAlertController(title: "Error", message: "Se ha producido un error al guardar el usuario", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func iniciarSesion(_ sender: Any) {
        if let email=emailTextField.text,let password=passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) {
                (result, error) in
                if let result = result, error == nil {
                    // Navegando entre vistas y pasando datos en constructor
                    self.navigationController?.pushViewController(MenuViewController(usuario: email), animated: true)
                } else {
                    // Alert
                    let alertController = UIAlertController(title: "Error", message: "Se ha producido un error al guardar el usuario", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
}

