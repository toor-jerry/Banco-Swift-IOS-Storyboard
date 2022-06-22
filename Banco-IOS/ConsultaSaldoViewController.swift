//
//  ConsultaSaldoViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 08/06/22.
//

import UIKit
import FirebaseFirestore

class ConsultaSaldoViewController: UIViewController {

  
    @IBOutlet weak var saldoLabel: UILabel!
    @IBOutlet weak var bonoLabel: UILabel!
    @IBOutlet weak var saldoTotalLabel: UILabel!
    
    private let email: String
    private let db = Firestore.firestore()
    private var saldo = 0.0
    
    
    
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title="Consulta de saldo"
        // Do any additional setup after loading the view.
        self.saldoLabel.text = "No cuenta con saldo..."
        
        db.collection("usuarios").document(email).getDocument {
        (documentSnapshot, error) in
            if let document = documentSnapshot, error == nil {
                if let saldo = document.get("saldoCuenta") as? Double {
                    self.saldo = saldo
                    self.saldoLabel.text = "Su saldo actual en su cuenta es de: $\(saldo) MXN"
                }
                // Comprobando si esta asignado el bono
                if let bonoAsignado = document.get("bonoAsignado") as? Bool, let bono = document.get("bono") as? Double {
                    if bonoAsignado {
                        self.bonoLabel.text = "El monto actual del bono es de: $\(bono) MXN"
                        self.saldoTotalLabel.text = "Saldo total: $\(self.saldo + bono) MXN"
                    }
                }
                // Registro en bitácora
                let movimiento = String(Int.random(in: 100000000...999999999))
                self.db.collection("bitacora").document().setData([
                    "idMovimiento": movimiento,
                    "usuario": self.email,
                    "descripcion": "Se consultó el saldo en la cuenta el día \(Date()) con número de movimiento 'Con-\(movimiento)",
                    "tipoMovimiento": "Consulta de saldo",
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
