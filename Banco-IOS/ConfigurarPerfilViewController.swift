//
//  ConfigurarPerfilViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 08/06/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ConfigurarPerfilViewController: UIViewController {
    
    @IBOutlet weak var nombreCompletoInputTextField: UITextField!
    @IBOutlet weak var direccionInputTextField: UITextField!
    @IBOutlet weak var guardarButton: UIButton!
    @IBOutlet weak var eliminarCuentaButton: UIButton!
    
    private let db = Firestore.firestore()
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
        title = "Configuración de perfil"
        // Do any additional setup after loading the view.
        db.collection("usuarios").document(email).getDocument {
        (documentSnapshot, error) in
            if let document = documentSnapshot, error == nil {
                if let nombre = document.get("nombre") as? String {
                    self.nombreCompletoInputTextField.text = nombre
                }
                if let direccion = document.get("direccion") as? String {
                    self.direccionInputTextField.text = direccion
                }
            }
         }
    }
    
    @IBAction func eliminarCuenta(_ sender: Any) {
        let alertController = UIAlertController(title: "Alerta!!", message: "Esta a punto de eliminar su cuenta!!, ¿desea continuar?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancelar 😎", style: .cancel) { (action) in
        // ... Do something
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Continuar 🥹", style: .default) { [self] (action) in
            do {
                
                self.db.collection("bitacora").whereField("usuario", isEqualTo: self.email)
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                self.db.collection("bitacora").document(document.documentID).delete()
                            }
                            self.db.collection("usuarios").document(self.email).delete()
                        }
                }
                Auth.auth().currentUser?.delete()
                try Auth.auth().signOut()
                navigationController?.popViewController(animated: true)
                navigationController?.popViewController(animated: true)
            } catch {
                // Manejo de errores si no se pudo salir de la sesion (alerta)
            }
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true)
        
    }
    
    @IBAction func guardarDatos(_ sender: Any) {
        
        self.db.collection("usuarios").document(self.email).setData([
            "nombre": self.nombreCompletoInputTextField.text ?? "",
            "direccion": self.direccionInputTextField.text ?? ""
        ],
        merge: true)
        // Registro en bitácora
        let movimiento = String(Int.random(in: 100000000...999999999))
        self.db.collection("bitacora").document().setData([
            "idMovimiento": movimiento,
            "usuario": self.email,
            "descripcion": "Se realizó actualización de datos el día \(Timestamp(date: Date())) con número de movimiento 'Mov-\(movimiento)",
            "tipoMovimiento": "Actualización datos"
        ])
        
    }
    
}
