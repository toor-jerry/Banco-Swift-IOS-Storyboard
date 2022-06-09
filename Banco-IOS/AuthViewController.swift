//
//  AuthViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 08/06/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AuthViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registrarButton: UIButton!
    @IBOutlet weak var accederButton: UIButton!
    
    private let db = Firestore.firestore()
    
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
                if let _ = result, error == nil {
                    let cuenta:String = String(Int.random(in: 100000000...999999999))
                    self.db.collection("usuarios").document(email).setData([
                        "cuenta":cuenta,
                        "bono": 0.0,
                        "saldoCuenta": 0.0,
                        "bonoAsignado": false
                    ])
                    // Navegando entre vistas y pasando datos en constructor
                    // Alert
                    let alertController = UIAlertController(title: "Felicidades!!", message: "Su cuenta ha sido creada satisfactoriamente, su número de cuenta es '\(cuenta)' y cuenta al momento con $ 0.0 pesos", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    
                    self.navigationController?.pushViewController(MenuViewController(email: email), animated: true)
                    self.present(alertController, animated: true, completion: nil)
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
                if let _ = result, error == nil {
                    // Navegando entre vistas y pasando datos en constructor
                    self.navigationController?.pushViewController(MenuViewController(email: email), animated: true)
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

