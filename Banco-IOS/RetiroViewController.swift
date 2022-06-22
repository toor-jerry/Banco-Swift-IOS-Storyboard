//
//  RetiroViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 09/06/22.
//

import UIKit
import FirebaseFirestore

class RetiroViewController: UIViewController {
    
    @IBOutlet weak var montoInput: UITextField!
    @IBOutlet weak var retiroButton: UIButton!
    
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
        title = "Retiro"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func retirar(_ sender: Any) {
        let monto = Double(montoInput.text ?? "0.0") ?? 0.0
        if monto <= 0.0 {
            // Alert
            let alertController = UIAlertController(title: "Advertencia", message: "Por favor ingrese valores positivos y mayores a 0.0", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            // Obtiene valor en saldo
            var saldoCuentaActual = 0.0
            db.collection("usuarios").document(email).getDocument {
            (documentSnapshot, error) in
                if let document = documentSnapshot, error == nil {
                    if let saldo = document.get("saldoCuenta") as? Double {
                        saldoCuentaActual = saldo
                    }
                    if saldoCuentaActual >= monto {
                        // Guarda el saldo actual
                            saldoCuentaActual -= monto
                        self.db.collection("usuarios").document(self.email).setData([
                            "saldoCuenta": saldoCuentaActual
                        ],
                        merge: true)
                        // Notifica al usuario
                            // Alert
                            let alertController = UIAlertController(title: "Información", message: "Se ha realizado el retiro correctamente, su nuevo saldo en su cuenta es de $ \(saldoCuentaActual) MXN. Tome su efectivo en ventanilla.", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                            
                            self.present(alertController, animated: true, completion: nil)
                        // Registro en bitácora
                        let movimiento = String(Int.random(in: 100000000...999999999))
                        self.db.collection("bitacora").document().setData([
                            "idMovimiento": movimiento,
                            "usuario": self.email,
                            "descripcion": "Se realizó un retiro en la cuenta actual el día \(Date()) con número de movimiento 'Mov-\(movimiento)",
                            "tipoMovimiento": "Retiro",
                            "fecha": Timestamp(date: Date())
                        ])
                } else {
                    // Alert
                    let alertController = UIAlertController(title: "Información", message: "No se pudo realizar el retiro debido a que el monto ingresado es mayor al que cuenta en su cuenta; saldo en su cuenta es de $ \(saldoCuentaActual) MXN", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
             }
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
