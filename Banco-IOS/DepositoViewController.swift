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
    private let dbM = DBManager.shared
    
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
            dbM.mostrarAlerta(msg: "Por favor ingrese valores positivos y mayores a 0.0", clase: self)
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
                if ( bonoAsignado == false ) && ( saldoCuentaActual > self.dbM.getSaldoAutorizadoBono() ) {
                    // Guarda el saldo actual y asigna el bono
                    self.dbM.registrarBono(saldoCuentaActual: saldoCuentaActual, email: self.email, clase: self, mensajePrimerAlerta: "Se ha realizado el despósito correctamente")
                    
                } else {
                    // Guarda el saldo actual
                self.db.collection("usuarios").document(self.email).setData([
                    "saldoCuenta": saldoCuentaActual
                ], merge: true)
                    // Notifica al usuario
                        // Alert
                    self.dbM.mostrarAlerta(msg: "Se ha realizado el despósito correctamente, su nuevo saldo en su cuenta es de $ \(saldoCuentaActual) MXN", clase: self, titulo: "Información")
                }
            
                self.montoInput.text = ""
            // Registro en bitácora
                self.dbM.registroBitacora(email: self.email, descripcionMovimiento: "Se realizó un depósito a la cuenta actual", tipoMovimiento: "Depósito", complementoIdMovimiento: "Mov-")
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
