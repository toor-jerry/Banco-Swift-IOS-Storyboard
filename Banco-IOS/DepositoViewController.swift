//
//  DepositoViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 09/06/22.
//

import UIKit
import FirebaseFirestore

class DepositoViewController: UIViewController {
    
    @IBOutlet weak var montoInput: UITextField!
    @IBOutlet weak var depositarButton: UIButton!
    
    private let email: String
    private let db = Firestore.firestore()
    
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Depositar"
        // Do any additional setup after loading the view.
    }
    

    @IBAction func depositar(_ sender: Any) {
        let monto = Double(montoInput.text ?? "0.0") ?? 0.0
        if monto <= 0.0 {
            // Alert
            let alertController = UIAlertController(title: "Advertencia", message: "Por favor ingrese valores positivos y mayores a 0.0", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            // Obtiene valor en saldo
            var saldoCuentaActual = 0.0
            var bonoAsignado = false
            db.collection("usuarios").document(email).getDocument {
            (documentSnapshot, error) in
                if let document = documentSnapshot, error == nil {
                    if let saldo = document.get("saldoCuenta") as? Double {
                        saldoCuentaActual = saldo
                    }
                    if let bonoAsginadoBD = document.get("bonoAsignado") as? Bool {
                        bonoAsignado = bonoAsginadoBD
                    }
             }
                saldoCuentaActual += monto
                
                
            // Verifica si obtiene el bono
                if ( bonoAsignado == false ) && ( saldoCuentaActual > 13750.0 ) {
                    // Guarda el saldo actual y asigna el bono
                self.db.collection("usuarios").document(self.email).setData([
                    "saldoCuenta": saldoCuentaActual,
                    "bonoAsignado": true,
                    "bono": 50000.0,
                    "notificacionBonoVista": true
                ], merge: true)
                    
                    // Registro en bitácora
                        let movimiento = String(Int.random(in: 100000000...999999999))
                    self.db.collection("bitacora").document().setData([
                        "idMovimiento": movimiento,
                        "usuario": self.email,
                        "descripcion": "Se realizó la asignación del bono ($ 50,000.0 MXN) a la cuenta actual el día \(Date()) con número de movimiento 'Mov-\(movimiento)",
                        "tipoMovimiento": "Asginación de bono",
                        "fecha": Timestamp(date: Date())
                    ])
                    // Notifica al usuario
                        // Alert
                        let alertController = UIAlertController(title: "Información", message: "Se ha realizado el despósito correctamente, su nuevo saldo en su cuenta es de $ \(saldoCuentaActual) MXN", preferredStyle: .alert)
                        
                        
                    // Notifica al usuario
                    // Alert
                    let alertBonoController = UIAlertController(title: "Información", message: "Felicidades, ha obtenido un bono con un valor de $ 50,000 MXN!! \nSaldo en la cuenta: $ \(saldoCuentaActual) MXN \nSaldo total: $ \(saldoCuentaActual + 50000.0)", preferredStyle: .alert)
                    alertBonoController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    
                    // Manejo de una alerta detras de otra
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {action in self.present(alertBonoController, animated: true, completion: nil)}))
                    // Presentando la alerta
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                } else {
                    // Guarda el saldo actual
                self.db.collection("usuarios").document(self.email).setData([
                    "saldoCuenta": saldoCuentaActual
                ], merge: true)
                    // Notifica al usuario
                        // Alert
                        let alertController = UIAlertController(title: "Información", message: "Se ha realizado el despósito correctamente, su nuevo saldo en su cuenta es de $ \(saldoCuentaActual) MXN", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                        self.present(alertController, animated: true, completion: nil)
                }
            
                self.montoInput.text = ""
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
