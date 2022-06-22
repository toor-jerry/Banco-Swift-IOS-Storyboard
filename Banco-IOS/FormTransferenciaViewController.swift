//
//  FormTransferenciaViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 16/06/22.
//

import UIKit
import FirebaseFirestore

class FormTransferenciaViewController: UIViewController {

    
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var saldoLabel: UILabel!
    @IBOutlet weak var montoInput: UITextField!
    @IBOutlet weak var transferirButton: UIButton!
    @IBOutlet weak var nombreContactoLabel: UILabel!
    @IBOutlet weak var cuentaContactoLabel: UILabel!
    @IBOutlet weak var correoContactoLabel: UILabel!
    
    
    private let email: String
    private var saldo: Double = 0.0
    private let cuentaADepositar: String
    private let db = Firestore.firestore()
    
    init(email: String, cuentaADepositar: String) {
        self.email = email
        self.cuentaADepositar = cuentaADepositar
        
        super.init(nibName: nil, bundle: nil)

            }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Usuario logueado
        db.collection("usuarios").document(email).getDocument {
        (documentSnapshot, error) in
            if let document = documentSnapshot, error == nil {
                if let nombre = document.get("nombre") as? String {                    self.nombreLabel.text = nombre
                } else {
                    self.nombreLabel.text = self.email
                }
                if let saldo = document.get("saldoCuenta") as? Double {
                    self.saldoLabel.text = String(saldo)
                    self.saldo = saldo
                } else {
                    self.saldoLabel.text = "Error"
                }
                
            }
         }
        // Información del usuario a transferir
        db.collection("usuarios").whereField("cuenta", isEqualTo: cuentaADepositar).getDocuments {
        (documentSnapshot, error) in
            if let err = error {
                // Alert
                let alertController = UIAlertController(title: "Error", message: "A ocurrido un error. \(err)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                
                self.present(alertController, animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
                return
            } else {
                if documentSnapshot!.documents.count < 0 {
                    // Alert
                    let alertController = UIAlertController(title: "Error", message: "No se ha encontrado la cuenta.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.navigationController?.popViewController(animated: true)
                    self.present(alertController, animated: true, completion: nil)
                    
                } else {
                for document in documentSnapshot!.documents {
                    var nombre = "Sin nombre"
                    if let nombreTemp = document.data()["nombre"] {
                        nombre = String(describing: nombreTemp)
                    }
                    self.cuentaContactoLabel.text = String(describing: document.data()["cuenta"]!)
                    self.correoContactoLabel.text = String(describing:document.data()["correo"]!)
                    self.nombreContactoLabel.text = nombre
                    return
                }
                }
            }
         }

        
    }
    
    
    @IBAction func transferir(_ sender: Any) {
        let monto = Double(montoInput.text ?? "0.0") ?? 0.0
        if monto <= 0.0 {
            // Alert
            let alertController = UIAlertController(title: "Advertencia", message: "Por favor ingrese valores positivos y mayores a 0.0", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        } else if self.saldo < monto {
            // Alert
            let alertController = UIAlertController(title: "Advertencia", message: "El monto que quiere transferir es mayor a su saldo ($ \(saldo) MXN), realice un depósito para poder realizar la transferencia deseada.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        }
            else {
            // Obtiene valor en saldo
            var saldoCuentaActual = 0.0
            db.collection("usuarios").document(email).getDocument {
            (documentSnapshot, error) in
                if let document = documentSnapshot, error == nil {
                    if let saldo = document.get("saldoCuenta") as? Double {
                        saldoCuentaActual = saldo
                    }
             }
            // Guarda el saldo actual
                saldoCuentaActual += monto
            self.db.collection("usuarios").document(self.email).setData([
                "saldoCuenta": saldoCuentaActual
            ],
            merge: true)
            // Notifica al usuario
                // Alert
                let alertController = UIAlertController(title: "Información", message: "Se ha realizado el abono correctamente, su nuevo saldo en su cuenta es de $ \(saldoCuentaActual) MXN", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                
                self.present(alertController, animated: true, completion: nil)
            // Registro en bitácora
            let movimiento = String(Int.random(in: 100000000...999999999))
            self.db.collection("bitacora").document().setData([
                "idMovimiento": movimiento,
                "usuario": self.email,
                "descripcion": "Se realizó un depósito a la cuenta actual el día \(Date()) con número de movimiento 'Mov-\(movimiento)",
                "tipoMovimiento": "Depósito",
                "fecha": Timestamp(date: Date())
            ])
        }
        }
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
