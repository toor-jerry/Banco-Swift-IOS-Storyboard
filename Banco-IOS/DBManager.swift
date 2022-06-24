//
//  DBManager.swift
//  Banco-IOS
//
//  Created by user216116 on 23/06/22.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

final class DBManager{
    
    static let shared = DBManager()
    
    private let db = Firestore.firestore()
    private let BONO = 50000.0
    private let SALDO_BONO = 13750.0
    
    struct Usuario {
        var correo: String
        var cuenta: String
        var saldoCuenta: Double
        var bono: Double
        var bonoAsignado: Bool
        var direccion: String?
        var nombre: String?
        
        init() {
            self.correo = ""
            self.cuenta = ""
            self.saldoCuenta = 0.0
            self.bono = 0.0
            self.bonoAsignado = false
        }
    }
    
    func getSaldoAutorizadoBono() -> Double {
        return self.SALDO_BONO
    }
    
    func buscarPorCuenta(cuenta: String, clase: UIViewController, callback: @escaping([String]) -> Void) {
        var dataDB:[String] = []
        self.db.collection("usuarios").whereField("cuenta", isEqualTo: cuenta).addSnapshotListener { querySnapshot, err in
            if let err = err {
                // Alert
                self.mostrarAlerta(msg: "A ocurrido un error. \(err)", clase: clase, titulo: "Error")
                return
            } else {
                var cont = 0
                for document in querySnapshot!.documents {
                    cont += 1
                    var nombre = "Sin nombre"
                    if let nombreTemp = document.data()["nombre"] {
                        nombre = String(describing: nombreTemp)
                    }
                    
                    dataDB.append("\(nombre) - \(String(describing: document.data()["cuenta"]!))")
                    
                }
            }
            callback(dataDB)
        }
    }
 
    func busquedaDentroDeUsuarios(campo: String, email: String, busqueda: String, clase: UIViewController, callback: @escaping([String]) -> Void) {
            var dataDB:[String] = []
            self.db.collection("usuarios").whereField(campo, isEqualTo: busqueda).addSnapshotListener { querySnapshot, err in
                if let err = err {
                    // Alert
                    self.mostrarAlerta(msg: "A ocurrido un error. \(err)", clase: clase, titulo: "Error")
                    return
                } else {
                    var cont = 0
                    for document in querySnapshot!.documents {
                        cont += 1
                        var nombre = "Sin nombre"
                        if let nombreTemp = document.data()["nombre"] {
                            nombre = String(describing: nombreTemp)
                        } else {
                            nombre = String(describing: document.data()["correo"]!)
                        }

                        let contenidoArray = "\(nombre) - \(String(describing: document.data()["cuenta"]!))"
                        
                        if !dataDB.contains(contenidoArray) {
                            if String(describing: document.data()["correo"]!) != email {
                            dataDB.append(contenidoArray)
                        }
                        
                    }
                }
                }
                callback(dataDB)
            }
    }
    func retiro(usuario: Usuario, monto: Double) {
        
        self.db.collection("usuarios").document(usuario.correo).setData([
            "saldoCuenta": usuario.saldoCuenta,
            "bono": usuario.bono
        ], merge: true)
        
        // Registro historial
        self.registroBitacora(email: usuario.correo, descripcionMovimiento: "Se realizón un retiro en la cuenta actual con un monto de \(monto)", tipoMovimiento: "Retiro", complementoIdMovimiento: "Mov-Retiro-")
  
    }
    
    func tranferir(usuarioOrigen: Usuario, usuarioDestino: Usuario, clase: UIViewController, monto: Double, idMovimientoText: String = "Mov-Transf-") {
        
        self.db.collection("usuarios").document(usuarioOrigen.correo).setData([
            "saldoCuenta": usuarioOrigen.saldoCuenta,
            "bonoAsignado": usuarioOrigen.bonoAsignado,
            "bono": usuarioOrigen.bono
        ], merge: true)
        
        self.db.collection("usuarios").document(usuarioDestino.correo).setData([
            "saldoCuenta": usuarioDestino.saldoCuenta,
            "bonoAsignado": usuarioDestino.bonoAsignado,
            "bono": usuarioDestino.bono
        ], merge: true)
        // Registro historial de origen
        self.registroBitacora(email: usuarioOrigen.correo, descripcionMovimiento: "Se realizó un movimiento de tipo 'Transferencia' de la cuenta \(usuarioOrigen.cuenta) a la \(usuarioDestino.cuenta) con un monto de \(monto)", tipoMovimiento: "Transferencia", complementoIdMovimiento: idMovimientoText)
        
        // Registro historial de destino de que se recibió la transferencia
        self.registroBitacora(email: usuarioDestino.correo, descripcionMovimiento: "Se recibió una 'Transferencia' de la cuenta \(usuarioOrigen.cuenta) con un monto de \(monto)", tipoMovimiento: "Transferencia")
        
    }
    func buscarPorTermino(email: String, busqueda: String, clase: UIViewController, callback: @escaping([String]) -> Void) {
        var dataDB:[String] = []
        self.busquedaDentroDeUsuarios(campo: "nombre", email: email, busqueda: busqueda, clase: clase){ (busquedaResultado) in
            dataDB.append(contentsOf: busquedaResultado)
            callback(dataDB)
        }
        
        self.busquedaDentroDeUsuarios(campo: "cuenta", email: email, busqueda: busqueda, clase: clase){ (busquedaResultado) in
            dataDB.append(contentsOf: busquedaResultado)
            callback(dataDB)
        }
        self.busquedaDentroDeUsuarios(campo: "email", email: email, busqueda: busqueda, clase: clase){ (busquedaResultado) in
            dataDB.append(contentsOf: busquedaResultado)
            callback(dataDB)
        }
        
    }
    
    func getTodosLosUsuarios(email: String, clase: UIViewController, callback: @escaping([String]) -> Void) {
        var dataDB:[String] = []
        
        self.db.collection("usuarios").whereField("correo", isNotEqualTo: email).addSnapshotListener { querySnapshot, err in
            if let err = err {
                // Alert
                self.mostrarAlerta(msg: "A ocurrido un error. \(err)", clase: clase, titulo: "Error")
                return
            } else {
                var cont = 0
                for document in querySnapshot!.documents {
                    cont += 1
                    var nombre = "Sin nombre"
                    if let nombreTemp = document.data()["nombre"] {
                        nombre = String(describing: nombreTemp)
                    } else {
                        nombre = String(describing: document.data()["correo"]!)
                    }
                    
                    dataDB.append("\(nombre) - \(String(describing: document.data()["cuenta"]!))")
                    
                }
            }
            callback(dataDB)
        }
    }
    
    func getInformacionUsuario(cuenta: String, clase: UIViewController, callback: @escaping([String: Any]) -> Void) {
        self.db.collection("usuarios").whereField("cuenta", isEqualTo: cuenta).getDocuments {
        (documentSnapshot, error) in
            if let err = error {
                // Alert
                // Alert
                self.mostrarAlerta(msg: "A ocurrido un error. \(err)", clase: clase, titulo: "Error")
                return
            } else {
                if documentSnapshot!.documents.count < 0 {
                    // Alert
                    self.mostrarAlerta(msg: "No se ha encontrado la cuenta.", clase: clase, titulo: "Error")
                    
                } else {
                for document in documentSnapshot!.documents {
                    var nombre = "Sin nombre"
                    var bono = 0.0
                    var bonoAsignado = false
                    var direccion = ""
                    var saldoCuenta = 0.0
                    if let nombreTemp = document.data()["nombre"] {
                        nombre = String(describing: nombreTemp)
                    }
                    if let bonoTemp = document.data()["bono"] as? Double {
                    bono = bonoTemp
                    }
                    
                    if let bonoATemp = document.data()["bono"] as? Bool{
                    bonoAsignado = bonoATemp
                    }
                    
                    if let direccionTemp = document.data()["direccion"] as? String{
                    direccion = direccionTemp
                    }
                    
                    if let saldoCuentaTemp = document.data()["saldoCuenta"] as? Double{
                        saldoCuenta = saldoCuentaTemp
                        }
                    
                    
                    
                    callback(["nombre" :nombre,
                              "cuenta" :String(describing: document.data()["cuenta"]!),
                              "correo": String(describing:document.data()["correo"]!),
                              "bono": bono,
                              "bonoAsignado": bonoAsignado,
                              "direccion": direccion,
                              "saldoCuenta": saldoCuenta
                    ])
                }
                }
            }
         }
    }
    
    func registrarBono(saldoCuentaActual: Double, email: String, clase: UIViewController, notificacionBonoVista: Bool = true, mensajePrimerAlerta: String = "") {
        self.db.collection("usuarios").document(email).setData([
            "saldoCuenta": saldoCuentaActual,
            "bonoAsignado": true,
            "bono": self.BONO,
            "notificacionBonoVista": notificacionBonoVista
        ], merge: true)
        
        // Registro en bitácora
        self.registroBitacora(email: email, descripcionMovimiento: "Se realizó la asignación del bono ($ 50,000.0 MXN) a la cuenta actual", tipoMovimiento: "Asginación de bono", complementoIdMovimiento: "Mov-")
        if notificacionBonoVista {
            // Notifica al usuario
                // Alert
                let alertController = UIAlertController(title: "Información", message: "; su nuevo saldo en su cuenta es de $ \(saldoCuentaActual) MXN", preferredStyle: .alert)
                
                
            // Notifica al usuario
            // Alert
            let alertBonoController = UIAlertController(title: "Información", message: "Felicidades, ha obtenido un bono con un valor de $ 50,000 MXN!! \nSaldo en la cuenta: $ \(saldoCuentaActual) MXN \nSaldo total: $ \(saldoCuentaActual + self.BONO)", preferredStyle: .alert)
            alertBonoController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            
            // Manejo de una alerta detras de otra
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {action in clase.present(alertBonoController, animated: true, completion: nil)}))
            // Presentando la alerta
            clase.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func registroBitacora(email: String, descripcionMovimiento: String, tipoMovimiento: String, complementoIdMovimiento: String = "") {
        let movimientoId = self.obtenerIdMovimiento(complemento: complementoIdMovimiento)
        self.db.collection("bitacora").document().setData([
            "idMovimiento": movimientoId,
            "usuario": email,
            "descripcion": "\(descripcionMovimiento); el día \(Date()) con número de movimiento '\(movimientoId)",
            "tipoMovimiento": tipoMovimiento,
            "fecha": Timestamp(date: Date())
            ])
    }
    
    func crearCuenta(cuenta: String, email: String) {
        self.db.collection("usuarios").document(email).setData([
            "cuenta": cuenta,
            "bono": 0.0,
            "saldoCuenta": 0.0,
            "bonoAsignado": false,
            "correo": email,
            "rolUsuario": "USER_ROLE",
            "fechaCreacionCuenta": Timestamp(date: Date())
        ])
    }
    
    func obtenerEmailUsuarioLogueado() -> String {
        let usuario = Auth.auth().currentUser
        return usuario?.email ?? "Error"
    }
    
    func obtenerIdMovimiento(complemento: String = "") -> String {
        return complemento + String(Int.random(in: 100000000...999999999))
    }
    
    func mostrarAlerta(msg: String, clase: UIViewController, titulo: String = "Alerta!") {
        let alertController = UIAlertController(title: titulo, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
        
        clase.present(alertController, animated: true, completion: nil)
    }
    
 
}


