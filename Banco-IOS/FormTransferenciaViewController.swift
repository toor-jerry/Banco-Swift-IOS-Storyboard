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
    @IBOutlet weak var saldoTotal: UILabel!
    @IBOutlet weak var bonoLabel: UILabel!
    
    private let db = Firestore.firestore()
    private let dbM = DBManager.shared
    
    private var usuarioOrigen = DBManager.Usuario()
    private var usuarioDestino = DBManager.Usuario()
    private let email: String
    private let cuentaDestino: String
 
    
    
    init(email: String, cuentaADepositar: String) {
        self.email = email
        self.cuentaDestino = cuentaADepositar
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.usuarioOrigen.correo = self.email
        self.usuarioDestino.cuenta = self.cuentaDestino
        // Usuario logueado
        db.collection("usuarios").document(self.usuarioOrigen.correo).getDocument {
        (documentSnapshot, error) in
            if let document = documentSnapshot, error == nil {
                if let nombre = document.get("nombre") as? String {                    self.nombreLabel.text = nombre
                    self.usuarioOrigen.nombre = nombre
                } else {
                    self.nombreLabel.text = self.usuarioOrigen.correo
                }
                if let saldo = document.get("saldoCuenta") as? Double {
                    self.saldoLabel.text = String(saldo)
                    self.usuarioOrigen.saldoCuenta = saldo
                } else {
                    self.saldoLabel.text = "Error"
                }
                
                if let cuenta = document.get("cuenta") as? String {
                    self.usuarioOrigen.cuenta = cuenta
                }
                
                if let bonoAsignado =  document.get("bonoAsignado") as? Bool {
                    self.usuarioOrigen.bonoAsignado = bonoAsignado
                }
                
                if let bono =  document.get("bono") as? Double {
                    self.usuarioOrigen.bono = bono
                    self.bonoLabel.text = "Monto del bono disponible: $ \(String(bono)) MXN"
                    if self.usuarioOrigen.bonoAsignado && bono > 0.0 {
                        
                        self.bonoLabel.isHidden = false
                        self.saldoTotal.isHidden = false
                        self.saldoTotal.text = "Saldo Total: $ \(self.usuarioOrigen.saldoCuenta + bono)"
                    }
                    
                }
                
            }
         }
        // Información del usuario a transferir
        self.dbM.getInformacionUsuarioPorCuentaCorreo(cuentaOCorreo: self.usuarioDestino.cuenta, clase: self, callback: { ( usuario) in
            self.usuarioDestino = usuario
            self.cuentaContactoLabel.text = usuario.cuenta
            self.correoContactoLabel.text = usuario.correo
            self.nombreContactoLabel.text = usuario.nombre
            
        })
        
        
    }
    
    
    @IBAction func transferir(_ sender: Any) {
        let monto = Double(montoInput.text ?? "0.0") ?? 0.0
    
        if monto <= 0.0 {
            // Alert
            self.dbM.mostrarAlerta(msg: "Por favor ingrese valores positivos y mayores a 0.0", clase: self)
            
        } else if self.usuarioOrigen.saldoCuenta >= monto {
            
            // Se descuenta el monto que se tranfiere y se carga al destinatario
            self.usuarioOrigen.saldoCuenta -= monto
            self.usuarioDestino.saldoCuenta += monto
            
            self.dbM.tranferir(usuarioOrigen: usuarioOrigen, usuarioDestino: usuarioDestino,clase: self, monto: monto)
            
            // Actualización de los campos
            self.actualizacionCamposView()
            
            // Se verifica que el usuario destino es apto para el bono
            self.asignarBonoCuentaDestino()
            
            // Alert
            self.dbM.mostrarAlerta(msg: "Se realizó con éxito la transferencia de la cuenta \(usuarioOrigen.cuenta) a la cuenta \(usuarioDestino.cuenta) con un monto de $ \(monto) MXN", clase: self, titulo: "Información")

            
        } else if ( self.usuarioOrigen.bono > 0 && self.usuarioOrigen.saldoCuenta > 0 && ( self.usuarioOrigen.bono + self.usuarioOrigen.saldoCuenta >= monto ) ) { // Si tiene el bono y aún alcanza a retirar con el saldo
            // Se descuenta el monto que se tranfiere y se carga al destinatario
            let montoBono = (monto - self.usuarioOrigen.saldoCuenta)
            let saldoCuentaTransferido = self.usuarioOrigen.saldoCuenta
            
            // Nuevos saldos
            self.usuarioOrigen.saldoCuenta = 0.0
            self.usuarioOrigen.bono -= montoBono
            self.usuarioDestino.saldoCuenta += monto
            
            self.dbM.tranferir(usuarioOrigen: usuarioOrigen, usuarioDestino: usuarioDestino,clase: self, monto: monto)
            
            // Dandole seguimiento al bono
            self.dbM.registroBitacora(email: self.usuarioOrigen.correo, descripcionMovimiento: "Se realizó un movimiento de tipo 'Transferencia-BONO' de la cuenta \(usuarioOrigen.cuenta) a la \(usuarioDestino.cuenta) con un monto de \(montoBono)", tipoMovimiento: "Transferencia", complementoIdMovimiento: "Mov-Transf-Bono")
            // Actualización de los campos
            self.actualizacionCamposView()
            
            // Se verifica que el usuario destino es apto para el bono
            self.asignarBonoCuentaDestino()
            
            // Alert
            self.dbM.mostrarAlerta(msg: "Se realizó con éxito la transferencia de la cuenta \(usuarioOrigen.cuenta) a la cuenta \(usuarioDestino.cuenta) con un monto de \(monto) MXN. \n Monto transferido de la cuenta $ \(saldoCuentaTransferido) MXN.\n Monto transferido del bono $ \(montoBono) MXN.", clase: self, titulo: "Información")

            
        } else if monto <= self.usuarioOrigen.bono { // Si tiene el bono y alcanza a realizar la transferencia solo con el bono

            // Nuevos saldos
            self.usuarioOrigen.bono -= monto
            self.usuarioDestino.saldoCuenta += monto
            
            self.dbM.tranferir(usuarioOrigen: usuarioOrigen, usuarioDestino: usuarioDestino,clase: self, monto: monto)
            
            // Dandole seguimiento al bono
            self.dbM.registroBitacora(email: self.usuarioOrigen.correo, descripcionMovimiento: "Se realizó un movimiento de tipo 'Transferencia-BONO' de la cuenta \(usuarioOrigen.cuenta) a la \(usuarioDestino.cuenta) con un monto de \(monto)", tipoMovimiento: "Transferencia", complementoIdMovimiento: "Mov-Transf-Bono")
            
            // Actualización de los campos
            self.actualizacionCamposView()
            
            // Se verifica que el usuario destino es apto para el bono
            self.asignarBonoCuentaDestino()
            
            // Alert
            self.dbM.mostrarAlerta(msg: "Se realizó con éxito la transferencia de la cuenta \(usuarioOrigen.cuenta) a la cuenta \(usuarioDestino.cuenta) con un monto de \(monto) MXN. \n Monto transferido del bono $ \(monto) MXN.", clase: self, titulo: "Información")
            
        } else {
            // Alert
            self.dbM.mostrarAlerta(msg: "El monto que quiere transferir es mayor a su saldo total en su cuenta ($ \(self.usuarioOrigen.saldoCuenta + self.usuarioOrigen.bono) MXN), realice un depósito para poder realizar la transferencia deseada.", clase: self)
        }
    }
    
    func asignarBonoCuentaDestino() {
        if usuarioDestino.bonoAsignado == false && usuarioDestino.saldoCuenta >= self.dbM.getSaldoAutorizadoBono() {
            self.dbM.registrarBono(saldoCuentaActual: self.usuarioDestino.saldoCuenta, email: self.usuarioDestino.correo, clase: self, notificacionBonoVista: false)
        }

    }
    
    func actualizacionCamposView() {
        if self.usuarioOrigen.bonoAsignado {
            self.saldoLabel.text = String(self.usuarioOrigen.saldoCuenta)
            self.bonoLabel.text = "Monto del bono disponible: $ \(String(self.usuarioOrigen.bono)) MXN"
            self.saldoTotal.text = "Saldo total: $ \(String(self.usuarioOrigen.saldoCuenta + self.usuarioOrigen.bono)) MXN"
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
