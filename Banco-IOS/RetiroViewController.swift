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
    @IBOutlet weak var bonoLabel: UILabel!
    @IBOutlet weak var saldoTotalLabel: UILabel!
    @IBOutlet weak var saldoLabel: UILabel!
    private let email: String
    private let db = Firestore.firestore()
    private let dbM = DBManager.shared
    private var usuario = DBManager.Usuario()
    
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
        self.usuario.correo = self.email
        // Usuario logueado
        db.collection("usuarios").document(self.usuario.correo).getDocument {
        (documentSnapshot, error) in
            if let document = documentSnapshot, error == nil {
                
                if let saldo = document.get("saldoCuenta") as? Double {
                    self.saldoLabel.text = "Saldo en la cuenta: $ \(saldo) MXN"
                    self.usuario.saldoCuenta = saldo
                } else {
                    self.saldoLabel.text = "Error"
                }
                
                if let cuenta = document.get("cuenta") as? String {
                    self.usuario.cuenta = cuenta
                }
                
                if let bonoAsignado =  document.get("bonoAsignado") as? Bool {
                    self.usuario.bonoAsignado = bonoAsignado
                }
                
                if let bono =  document.get("bono") as? Double {
                    self.usuario.bono = bono
                    self.bonoLabel.text = "Monto del bono disponible: $ \(String(bono)) MXN"
                    if self.usuario.bonoAsignado && bono > 0.0 {
                        
                        self.bonoLabel.isHidden = false
                        self.saldoTotalLabel.isHidden = false
                        self.saldoTotalLabel.text = "Saldo Total: $ \(self.usuario.saldoCuenta + bono)"
                    }
                    
                }
                
            }
         }
    }
    
    @IBAction func retirar(_ sender: Any) {
        let monto = Double(montoInput.text ?? "0.0") ?? 0.0
        
            if monto <= 0.0 {
                // Alert
                self.dbM.mostrarAlerta(msg: "Por favor ingrese valores positivos y mayores a 0.0", clase: self)
            } else if self.usuario.saldoCuenta >= monto {
                
                // Se descuenta el monto que se retira
                self.usuario.saldoCuenta -= monto
                
                self.dbM.retiro(usuario: self.usuario, monto: monto)
                
                // Actualización de los campos
                self.actualizacionCamposView()
                
                // Alert
                self.dbM.mostrarAlerta(msg: "Se ha realizado el retiro correctamente, su nuevo saldo total en su cuenta es de $ \(usuario.saldoCuenta + usuario.bono) MXN. Tome su efectivo en ventanilla.", clase: self, titulo: "Información")

                
            } else if ( self.usuario.bono > 0 && self.usuario.saldoCuenta > 0 && ( self.usuario.bono + self.usuario.saldoCuenta >= monto ) ) { // Si tiene el bono y aún alcanza a retirar con el saldo
                // Se descuenta el monto que se tranfiere y se carga al destinatario
                let montoRetiroBono = (monto - self.usuario.saldoCuenta)
                let saldoCuentaRetirado = self.usuario.saldoCuenta
                
                // Nuevos saldos
                self.usuario.saldoCuenta = 0.0
                self.usuario.bono -= montoRetiroBono
                
                self.dbM.retiro(usuario: self.usuario, monto: monto)
                
                // Dandole seguimiento al bono
                self.dbM.registroBitacora(email: self.usuario.correo, descripcionMovimiento: "Se realizó un movimiento de tipo 'Retiro-BONO' de la cuenta \(usuario.cuenta) con un monto de \(montoRetiroBono)", tipoMovimiento: "Retiro", complementoIdMovimiento: "Mov-Retiro-Bono")
                
                // Actualización de los campos
                self.actualizacionCamposView()
               
                // Alert
                self.dbM.mostrarAlerta(msg: "Se realizó con éxito el retiro de la cuenta \(self.usuario.cuenta) con un monto de \(monto) MXN. \n Monto retirado de la cuenta $ \(saldoCuentaRetirado) MXN.\n Monto retirado del bono $ \(montoRetiroBono) MXN.\nTome su efectivo en ventanilla.", clase: self, titulo: "Información")

                
            } else if monto <= self.usuario.bono { // Si tiene el bono y alcanza a realizar el retiro solo con el bono

                // Nuevos saldos
                self.usuario.bono -= monto
                
                self.dbM.retiro(usuario: self.usuario, monto: monto)
                // Dandole seguimiento al bono
                self.dbM.registroBitacora(email: self.usuario.correo, descripcionMovimiento: "Se realizó un movimiento de tipo 'Retiro-BONO' de la cuenta \(usuario.cuenta) con un monto de \(monto)", tipoMovimiento: "Retiro", complementoIdMovimiento: "Mov-Retiro-Bono")
                
                // Actualización de los campos
                self.actualizacionCamposView()
                
                // Alert
                self.dbM.mostrarAlerta(msg: "Se realizó con éxito el retiro de la cuenta \(usuario.cuenta) con un monto de \(monto) MXN. \n Monto retirado del bono $ \(monto) MXN.\nTome su efectivo en ventanilla.", clase: self, titulo: "Información")
                
            } else {
                // Alert
                self.dbM.mostrarAlerta(msg: "El monto que quiere retirar es mayor a su saldo total en su cuenta ($ \(self.usuario.saldoCuenta + self.usuario.bono) MXN), realice un depósito para poder realizar la operación deseada.", clase: self)
            }
            
    }
    
    func actualizacionCamposView() {
        if self.usuario.bonoAsignado {
            self.saldoLabel.text = "Saldo en la cuenta: $ \(String(self.usuario.saldoCuenta)) MXN"
            self.bonoLabel.text = "Monto del bono disponible: $ \(String(self.usuario.bono)) MXN"
            self.saldoTotalLabel.text = "Saldo total: $ \(String(self.usuario.saldoCuenta + self.usuario.bono)) MXN"
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
