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
    @IBOutlet weak var recordarmeSwitch: UISwitch!
    
    private let KEY_EMAIL = "EMAIL"
    private let KEY_PASSWORD = "PASWORD"
    private let db = DBManager.shared
    
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
            db.mostrarAlerta(msg: "Ingrese un email!", clase: self)
        }
        else if !validarEmail(email: emailTextField.text!){
            // Alert
            db.mostrarAlerta(msg: "Ingrese un email correcto!!", clase: self)        }else if let email=emailTextField.text,let password=passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) {
                (result, error) in
                if let _ = result, error == nil {
                    
                    let cuenta = self.db.obtenerIdMovimiento(complemento: "Cue-")
                    self.db.crearCuenta(cuenta: cuenta, email: email)
                    // Registro en bitácora
                    self.db.registroBitacora(email: email, descripcionMovimiento: "Se aperturó la cuenta '\(cuenta)'", tipoMovimiento: "Creación de cuenta", complementoIdMovimiento: "0000-")

                    self.guardarUserDefaults()
                    // Navegando entre vistas y pasando datos en constructor
                    self.navigationController?.pushViewController(MenuViewController(email: email), animated: true)
                    // Alert
                    self.db.mostrarAlerta(msg: "Su cuenta ha sido creada satisfactoriamente, su número de cuenta es '\(cuenta)' y cuenta al momento con $ 0.0 pesos", clase: self, titulo: "Felicidades!!")
                } else {
                    // Alert
                    self.db.mostrarAlerta(msg: "Se ha producido un error al guardar el usuario", clase: self, titulo: "Error")
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
            db.mostrarAlerta(msg: "Ingrese un email!", clase: self)
        }
        else if !validarEmail(email: emailTextField.text!){
            // Alert
            db.mostrarAlerta(msg: "Ingrese un email correcto!!", clase: self)        }else if let email=emailTextField.text,let password=passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) {
                (result, error) in
                if let _ = result, error == nil {
                    // Registro en bitácora
                    self.db.registroBitacora(email: email, descripcionMovimiento: "Se inició sesión", tipoMovimiento: "Inicio de sesión", complementoIdMovimiento: "IN-")
                    
                    self.guardarUserDefaults()
                    // Navegando entre vistas y pasando datos en constructor
                    self.navigationController?.pushViewController(MenuViewController(email: email), animated: true)
                } else {
                    // Registro en bitácora
                    self.db.registroBitacora(email: email, descripcionMovimiento: "Intento de inició sesión fallido", tipoMovimiento: "Inicio de sesión incorrecto", complementoIdMovimiento: "IN-Error-")
                    
                    // Alert
                    self.db.mostrarAlerta(msg: "Verifique su usuario y/o contraseña", clase: self)
                }
            }
        }
    }
    
}

