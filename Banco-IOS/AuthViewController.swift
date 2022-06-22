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
    @IBOutlet weak var recordarmeSwitch: UISwitch!
    
    private let db = Firestore.firestore()
    private let KEY_EMAIL = "EMAIL"
    private let KEY_PASSWORD = "PASWORD"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title="Autenticación"
        // Recuperando datos de userDefaults
        if let emailUserDef = UserDefaults.standard.string(forKey: KEY_EMAIL), let passwordUserDef = UserDefaults.standard.string(forKey: KEY_PASSWORD) {
            emailTextField.text = emailUserDef
            passwordTextField.text = passwordUserDef
        } else {
            emailTextField.text = ""
            passwordTextField.text = ""
        }
        
    }
    
    func validarEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    @IBAction func registrarCuenta(_ sender: Any) {
        if emailTextField.text! == "" {
            // Alert
            let alertController = UIAlertController(title: "Alerta!", message: "Ingrese un email!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        }
        else if !validarEmail(email: emailTextField.text!){
            // Alert
            let alertController = UIAlertController(title: "Alerta!", message: "Ingrese un email correcto!!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        }
        
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
                        "correo": email,
                        "fechaCreacionCuenta": Timestamp(date: Date())
                    ])
                    // Registro en bitácora
                    let movimiento = String(Int.random(in: 100000000...999999999))
                    self.db.collection("bitacora").document().setData([
                        "idMovimiento": movimiento,
                        "usuario": email,
                        "descripcion": "Se aperturó la cuenta '\(cuenta)' el día \(Date()) con número de movimiento '0000-\(movimiento)",
                        "tipoMovimiento": "Creación de cuenta",
                        "fecha": Timestamp(date: Date()),
                        "notificacionBonoVista": false
                    ])
                    self.guardarUserDefaults()
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
    
    @IBAction func recordarme(_ sender: Any) {
        guardarUserDefaults()
    }
    
    func guardarUserDefaults() {
        if recordarmeSwitch.isOn {
            UserDefaults.standard.set(self.emailTextField.text!, forKey: KEY_EMAIL)
            UserDefaults.standard.set(self.passwordTextField.text!, forKey: KEY_PASSWORD)
            UserDefaults.standard.synchronize()
        } else {
            UserDefaults.standard.removeObject(forKey: KEY_EMAIL)
            UserDefaults.standard.removeObject(forKey: KEY_PASSWORD)
            UserDefaults.standard.synchronize()
        }
    }
    
    @IBAction func iniciarSesion(_ sender: Any) {
    if emailTextField.text! == "" {
            // Alert
            let alertController = UIAlertController(title: "Alerta!", message: "Ingrese un email!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        }
        else if !validarEmail(email: emailTextField.text!){
            // Alert
            let alertController = UIAlertController(title: "Alerta!", message: "Ingrese un email correcto!!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        
        if let email=emailTextField.text,let password=passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) {
                (result, error) in
                let movimiento = String(Int.random(in: 100000000...999999999))
                if let _ = result, error == nil {
                    // Registro en bitácora
                    self.db.collection("bitacora").document().setData([
                        "idMovimiento": movimiento,
                        "usuario": email,
                        "descripcion": "Se inició sesión el día \(Date()) con número de movimiento 'IN-\(movimiento)",
                        "tipoMovimiento": "Inicio de sesión",
                        "fecha": Date()
                    ])
                    self.guardarUserDefaults()
                    // Navegando entre vistas y pasando datos en constructor
                    self.navigationController?.pushViewController(MenuViewController(email: email), animated: true)
                } else {
                    // Registro en bitácora
                    self.db.collection("bitacora").document().setData([
                        "idMovimiento": movimiento,
                        "usuario": email,
                        "descripcion": "Se intentó iniciar sesión el día \(Date()) con número de movimiento 'IN-ERROR-\(movimiento)",
                        "tipoMovimiento": "Inicio de sesión incorrecto",
                        "fecha": Date()
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

