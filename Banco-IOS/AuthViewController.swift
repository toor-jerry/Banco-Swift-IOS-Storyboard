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
                    let cuenta:String = "Cue-\(String(Int.random(in: 100000000...999999999)))"
                    self.db.collection("usuarios").document(email).setData([
                        "cuenta":cuenta,
                        "bono": 0.0,
                        "saldoCuenta": 0.0,
                        "bonoAsignado": false,
                        "fechaCreacionCuenta": Timestamp(date: Date())
                    ])
                    // Registro en bitácora
                    let movimiento = String(Int.random(in: 100000000...999999999))
                    self.db.collection("bitacora").document().setData([
                        "idMovimiento": movimiento,
                        "usuario": email,
                        "descripcion": "Se aperturó la cuenta '\(cuenta)' el día \(Timestamp(date: Date())) con número de movimiento '0000-\(movimiento)",
                        "tipoMovimiento": "Creación de cuenta"
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
                let movimiento = String(Int.random(in: 100000000...999999999))
                if let _ = result, error == nil {
                    // Registro en bitácora
                    self.db.collection("bitacora").document().setData([
                        "idMovimiento": movimiento,
                        "usuario": email,
                        "descripcion": "Se inició sesión el día \(Timestamp(date: Date())) con número de movimiento 'IN-\(movimiento)",
                        "tipoMovimiento": "Inicio de sesión"
                    ])
                    // Navegando entre vistas y pasando datos en constructor
                    self.navigationController?.pushViewController(MenuViewController(email: email), animated: true)
                } else {
                    // Registro en bitácora
                    self.db.collection("bitacora").document().setData([
                        "idMovimiento": movimiento,
                        "usuario": email,
                        "descripcion": "Se intentó iniciar sesión el día \(Timestamp(date: Date())) con número de movimiento 'IN-ERROR-\(movimiento)",
                        "tipoMovimiento": "Inicio de sesión incorrecto"
                    ])
                    // Alert
                    let alertController = UIAlertController(title: "Advertencia", message: "Verifique su usuario y/o contraseña", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
}

