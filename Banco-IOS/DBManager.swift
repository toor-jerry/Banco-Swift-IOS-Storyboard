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
import UserNotifications

final class DBManager{
    
    static let shared = DBManager()
    
    private let db = Firestore.firestore()
    private let BONO = 50000.0
    private let SALDO_BONO = 13750.0
    private var logueado = false
    private var hilos: [DispatchWorkItem] = []
    
    struct Usuario {
        var correo: String
        var cuenta: String
        var saldoCuenta: Double
        var bono: Double
        var bonoAsignado: Bool
        var direccion: String?
        var nombre: String?
        var tasaRendimiento: Double?
        var inversiones: [Inversion]?
        var logo: String?
        
        init() {
            self.correo = ""
            self.cuenta = ""
            self.saldoCuenta = 0.0
            self.bono = 0.0
            self.bonoAsignado = false
            self.tasaRendimiento = 0.0
        }
    }
    
    struct Inversion {
        var _id: String
        var autoInvertir: Bool
        var fechaInversion: Timestamp
        var fechaRetiro: Timestamp
        var gananciaAcumulada: Double
        var inversor: String
        var montoInvertido: Double
        var organizacion: Usuario?
        
        init() {
            self._id = ""
            self.autoInvertir = false
            self.gananciaAcumulada = 0.0
            self.inversor = ""
            self.montoInvertido = 0.0
            self.fechaInversion = Timestamp()
            self.fechaRetiro = Timestamp()
        }
    }
    
    func setLogueadoBandera(loggin: Bool) {
        self.logueado = loggin
    }
    
    func getLogueadoBandera() -> Bool {
        return self.logueado
    }

        
    func getSaldoAutorizadoBono() -> Double {
        return self.SALDO_BONO
    }
    func cerrarSesion() ->Bool {
        var sesionCerrada = false
        if self.getLogueadoBandera() {
        do {
            self.setLogueadoBandera(loggin: false)
            self.limpiezaDeHilos()
            try Auth.auth().signOut()
            sesionCerrada = true
        }  catch let signOutError as NSError {
            self.setLogueadoBandera(loggin: true)
            print("Data Error signing out: %@", signOutError)
          }
        }
        return sesionCerrada
    }
    func buscarPorCuenta(cuenta: String, clase: UIViewController, callback: @escaping([String]) -> Void) {
        var dataDB:[String] = []
        self.db.collection("usuarios").whereField("cuenta", isEqualTo: cuenta).addSnapshotListener { querySnapshot, err in
            if let err = err {
                // Alert
                self.mostrarAlerta(msg: "A ocurrido un error buscando por cuenta. \(err)", clase: clase, titulo: "Error")
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
    
    func buscarInversionesPorCorreoObject(correoInversor: String, clase: UIViewController, callback: @escaping([Inversion]) -> Void) {
        var dataDB:[Inversion] = []
        var empresas:[Usuario] = []
        print("Data \(correoInversor)")
        self.getTodosLosUsuariosObj(email: correoInversor, collection: "empresas", clase: clase) { (empresasDB) in
            empresas = empresasDB
        }
        
        self.db.collection("inversiones").whereField("emailInversor", isEqualTo: correoInversor).addSnapshotListener { querySnapshot, err in
            if let err = err {
                // Alert
                self.mostrarAlerta(msg: "A ocurrido un error buscando las inversiones. \(err)", clase: clase, titulo: "Error")
                return
            } else {
                for documentInversion in querySnapshot!.documents {
                    var inversion = Inversion()
                    if let organizacion = documentInversion.data()["organizacion"] as? DocumentReference{
                        let empresa = empresas.filter { $0.correo == organizacion.documentID }
                        if !empresa.isEmpty{
                            inversion.organizacion = empresa[0]
                        }
                        }
                    
                    inversion._id = documentInversion.documentID
                       
                    if let autoInvertir = documentInversion.data()["autoInvertir"] as? Bool {
                        inversion.autoInvertir = autoInvertir
                    }
                    
                    if let fechaInversion = documentInversion.data()["fechaInversion"] as? Timestamp {
                        inversion.fechaInversion = fechaInversion
                    }
                    
                    if let fechaRetiro = documentInversion.data()["fechaRetiro"] as? Timestamp {
                        inversion.fechaRetiro = fechaRetiro
                    }
                    
                    if let gananciaAcumulada = documentInversion.data()["gananciaAcumulada"] as? Double {
                        inversion.gananciaAcumulada = gananciaAcumulada
                    }
                    
                    if let inversor = documentInversion.data()["inversor"] as? String {
                        inversion.inversor = inversor
                    }
                    
                    if let montoInvertido = documentInversion.data()["montoInvertido"] as? Double {
                        inversion.montoInvertido = montoInvertido
                    }
                dataDB.append(inversion)
                    
                }
            }
            callback(dataDB)
        }
    }
    
    func verificarInversiones(correoUserLogueado: String, clase: UIViewController) {
        // Timestamp(date: fechaRetiroGanancia).compare(Timestamp(date: Date())) != .orderedAscending
        let fecha = Date()
        var inversiones: [String: Inversion] = [:]
        self.buscarInversionesPorCorreoObject(correoInversor: correoUserLogueado, clase: clase) { (dataDB) in
            for data in dataDB {
                if (inversiones[data._id] == nil) {
                    inversiones[data._id] = data
                    //print("Data intervalo \(DateInterval(start: .now, end: data.fechaRetiro.dateValue()).duration)")
                }
            }
            // print("Data inversiones \(String(describing: inversiones)) Total Inversiones: \(inversiones.count)")
        }
        print("Data Fecha actual: \(fecha)\n")
        var data: [Date] = []
        data.append(fecha.addingTimeInterval(60))
        data.append(fecha.addingTimeInterval(50))
        data.append(fecha.addingTimeInterval(40))
        data.append(fecha.addingTimeInterval(120000000))
        data.append(fecha.addingTimeInterval(1))
        data.append(fecha.addingTimeInterval(6))
        data.append(fecha.addingTimeInterval(10))
        data.append(fecha.addingTimeInterval(16))
        data.append(fecha.addingTimeInterval(29))
        data.append(fecha.addingTimeInterval(20))
        data.append(fecha.addingTimeInterval(-10)) // ya no aplica

        print("Data NO Ordenada: \(data)\n")

        data = data.sorted()
        print("Data ORDENADA: \(data)\n")

        for (index, date) in data.enumerated() {
            
            // Si ya se cumplió el lapso de tiempo
          if fecha.compare(date) == .orderedDescending {
              /*
               //////////////////////////////////////
                 let tiempoDeInversion = DateInterval(start: fechaInversion, end: fechaRetiro).duration
                 let tiempoSuperado = DateInterval(start: fechaInversion, end: Date()).duration
               
               print("----- Se paso por \(DateInterval(start: fechaInversion, end: Date()).duration)\n\n")
               return Int(tiempoSuperado/tiempoDeInversi
               */
              data.remove(at: index)
              
          } else {
              let segundos =  DateInterval(start: fecha, end: date).duration
            print("Data ***\(segundos)")
              let workItem = DispatchWorkItem {
                  self.mostrarLocalNotificacion(titulo: "Inversión terminada", subtitulo: "terminada", contenidoNotificacion: "\(segundos)")
                  print("Data Hola \(segundos)")
              }
              self.hilos.append(workItem)

              // Execute the work item after "segundos" second
             // DispatchQueue.main.asyncAfter(deadline: .now() + segundos, execute: workItem)

                }
            // Eliminar DispatchQueue.main.async {
               //  self.endBackgroundUpdateTask(taskID: taskID)
            // }
        }
    }
    

    
    func limpiezaDeHilos() {
        
        DispatchQueue.global(qos: .userInitiated).async {
        print("Data Hilos a eliminar: \(self.hilos)")
            for hilo in self.hilos {
                hilo.cancel()
                if hilo.isCancelled {
                    print("Data: Hilo \(hilo) cancelado satisfactoriamente!")
                }
            }
            self.hilos.removeAll()
            print("Data: Hilos despues de eliminar: \(self.hilos)")
        }
    }
    
    func mostrarLocalNotificacion(titulo: String, subtitulo: String, contenidoNotificacion: String, retardoDeMostrarNotificacion: Double = 1.0){
        // 1. Creamos el Trigger de la Notificación
           let trigger = UNTimeIntervalNotificationTrigger(timeInterval: retardoDeMostrarNotificacion, repeats: false)
         
           // 2. Creamos el contenido de la Notificación
           let content = UNMutableNotificationContent()
           content.title = titulo
           content.subtitle = subtitulo
           content.body = contenidoNotificacion
             content.sound = UNNotificationSound.default
            content.userInfo["data"] = "userInfo"
         
           // 3. Creamos la Request
           let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
         
           // 4. Añadimos la Request al Centro de Notificaciones
           UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
           UNUserNotificationCenter.current().add(request) {(error) in
              if let error = error {
                 print("Se ha producido un error: \(error)")
              }
           }
    }

    func busquedaDentroDeUsuarios(campo: String, email: String, busqueda: String, clase: UIViewController, callback: @escaping([String]) -> Void) {
            var dataDB:[String] = []
            self.db.collection("usuarios").whereField(campo, isEqualTo: busqueda).addSnapshotListener { querySnapshot, err in
                if let err = err {
                    // Alert
                    self.mostrarAlerta(msg: "A ocurrido un error buscando al usuario. \(err)", clase: clase, titulo: "Error")
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
    
    func getTodosLosUsuariosObj(email: String, collection: String = "Usuarios", clase: UIViewController, callback: @escaping([Usuario]) -> Void) {
        var dataDB:[Usuario] = []
        self.db.collection(collection).addSnapshotListener { querySnapshot, err in
            if let err = err {
                // Alert
                self.mostrarAlerta(msg: "A ocurrido un error buscando al usuario por obj. \(err)", clase: clase, titulo: "Error")
                return
            } else {
                for document in querySnapshot!.documents {
                    var usuario = Usuario()
                    usuario.cuenta = String(describing: document.data()["cuenta"]!)
                    usuario.correo = String(describing:document.data()["correo"]!)
  
                    
                    if let nombreTemp = document.data()["nombre"] {
                        usuario.nombre = String(describing: nombreTemp)
                    }
                    if let bonoTemp = document.data()["bono"] as? Double {
                        usuario.bono = bonoTemp
                    }
                    
                    if let bonoATemp = document.data()["bonoAsignado"] as? Bool{
                        usuario.bonoAsignado = bonoATemp
                    }
                    
                    if let direccionTemp = document.data()["direccion"] as? String{
                        usuario.direccion = direccionTemp
                    }
                    
                    if let saldoCuentaTemp = document.data()["saldoCuenta"] as? Double{
                        usuario.saldoCuenta = saldoCuentaTemp
                    }
                    if let logoTemp = document.data()["logo"] as? String{
                        usuario.logo = logoTemp
                    }
                    if let tasa = document.data()["tasaRendimiento"] as? Double{
                        usuario.tasaRendimiento = tasa
                    }
                    
                    dataDB.append(usuario)
                }
                }
                    callback(dataDB)
        }
    }
    
    
    func getTodosLosUsuarios(email: String, clase: UIViewController, callback: @escaping([String]) -> Void) {
        var dataDB:[String] = []
        
        self.db.collection("usuarios").whereField("correo", isNotEqualTo: email).addSnapshotListener { querySnapshot, err in
            if let err = err {
                // Alert
                self.mostrarAlerta(msg: "A ocurrido un error obteniendo todos los usuairos. \(err)", clase: clase, titulo: "Error")
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
    
    func getTodasLasEmpresas(clase: UIViewController, callback: @escaping([String]) -> Void) {
        var dataDB:[String] = []
        
        self.db.collection("empresas").addSnapshotListener { querySnapshot, err in
            if let err = err {
                // Alert
                self.mostrarAlerta(msg: "A ocurrido un error obteniendo todas las empresas. \(err)", clase: clase, titulo: "Error")
                return
            } else {
                var cont = 0
                for document in querySnapshot!.documents {
                    cont += 1
                    var nombre = "Sin nombre"
                    if let nombreTemp = document.data()["nombre"] {
                        nombre = String(describing: nombreTemp)
                    }
                    
                    dataDB.append("\(nombre)\n\tTasa de rendimiento: \(String(describing: document.data()["tasaRendimiento"]!))%\n\tCorreo: \(String(describing: document.data()["correo"]!))")
                    
                }
            }
            callback(dataDB)
        }
    }
    
    func buscarPorTerminoEmpresas(email: String, busqueda: String, clase: UIViewController, callback: @escaping([String]) -> Void) {
        var dataDB:[String] = []
        self.db.collection("empresas").whereField("search", arrayContains: busqueda).addSnapshotListener { querySnapshot, err in
            if let err = err {
                // Alert
                self.mostrarAlerta(msg: "A ocurrido un error buscando por término. \(err)", clase: clase, titulo: "Error")
                return
            } else {
                var cont = 0
                for document in querySnapshot!.documents {
                    cont += 1
                    var nombre = "Sin nombre"
                    if let nombreTemp = document.data()["nombre"] {
                        nombre = String(describing: nombreTemp)
                    }
                    
                    dataDB.append("\(nombre)\n\tTasa de rendimiento: \(String(describing: document.data()["tasaRendimiento"]!))%\n\tCorreo: \(String(describing: document.data()["correo"]!))")
                    
                }
            }
            callback(dataDB)
        }
        
    }
    func getInformacionDeTodosLosUsuarios(clase: UIViewController, callback: @escaping([Usuario]) -> Void) {
        var usuarios: [Usuario] = []
        self.db.collection("usuarios").getDocuments {
        (documentSnapshot, error) in
            if let err = error {
                // Alert
                self.mostrarAlerta(msg: "A ocurrido un error obteniendo la información de todos los usuarios. \(err)", clase: clase, titulo: "Error")
                return
            } else {
                if documentSnapshot!.documents.count < 0 {
                    // Alert
                    self.mostrarAlerta(msg: "No se han encontrado usuarios.", clase: clase, titulo: "Error")
                    
                } else {
                    
                for document in documentSnapshot!.documents {
                    var usuario = Usuario()
                    usuario.correo = String(describing:document.data()["correo"]!)
                    usuario.cuenta = String(describing: document.data()["cuenta"]!)
                    usuario.nombre = "Sin nombre"
                    
                    if let nombreTemp = document.data()["nombre"] {
                        usuario.nombre = String(describing: nombreTemp)
                    }
                    if let bonoTemp = document.data()["bono"] as? Double {
                        usuario.bono = bonoTemp
                    }
                    
                    if let bonoATemp = document.data()["bono"] as? Bool{
                        usuario.bonoAsignado = bonoATemp
                    }
                    
                    if let direccionTemp = document.data()["direccion"] as? String{
                        usuario.direccion = direccionTemp
                    }
                    
                    if let saldoCuentaTemp = document.data()["saldoCuenta"] as? Double{
                        usuario.saldoCuenta = saldoCuentaTemp
                    }
                    if let logoTemp = document.data()["logo"] as? String{
                        usuario.logo = logoTemp
                    }
                    usuarios.append(usuario)
                }
                }
                callback(usuarios)
            }
         }
    }
    
    func getInformacionUsuarioPorCuentaCorreo(cuentaOCorreo: String, clase: UIViewController, campo: String = "cuenta", coleccion: String = "usuarios", callback: @escaping(Usuario) -> Void) {
        var usuario = Usuario()
        self.db.collection("usuarios").whereField(campo, isEqualTo: cuentaOCorreo).getDocuments {
        (documentSnapshot, error) in
            if let err = error {
                // Alert
                // Alert
                self.mostrarAlerta(msg: "A ocurrido un error obteniendo la información del usuairo por cuenta o correo. \(err)", clase: clase, titulo: "Error")
                return
            } else {
                if documentSnapshot!.documents.count < 0 {
                    // Alert
                    self.mostrarAlerta(msg: "No se ha encontrado la cuenta.", clase: clase, titulo: "Error")
                    
                } else {
                for document in documentSnapshot!.documents {
                    usuario.cuenta = String(describing: document.data()["cuenta"]!)
                    usuario.correo = String(describing:document.data()["correo"]!)
                    
                    if let nombreTemp = document.data()["nombre"] {
                        usuario.nombre = String(describing: nombreTemp)
                    }
                    if let bonoTemp = document.data()["bono"] as? Double {
                        usuario.bono = bonoTemp
                    }
                    
                    if let bonoATemp = document.data()["bonoAsignado"] as? Bool{
                        usuario.bonoAsignado = bonoATemp
                    }
                    
                    if let direccionTemp = document.data()["direccion"] as? String{
                        usuario.direccion = direccionTemp
                    }
                    
                    if let saldoCuentaTemp = document.data()["saldoCuenta"] as? Double{
                        usuario.saldoCuenta = saldoCuentaTemp
                    }
                    if let logoTemp = document.data()["logo"] as? String{
                        usuario.logo = logoTemp
                    }
                    if let tasa = document.data()["tasaRendimiento"] as? Double{
                        usuario.tasaRendimiento = tasa
                    }
                }
                }
                callback(usuario)
            }
         }
    }
    
    func getInformacionEmpresa(correo: String, clase: UIViewController, callback: @escaping(Usuario) -> Void) {
        var empresa = Usuario()
        self.db.collection("empresas").whereField("correo", isEqualTo: correo).getDocuments {
        (documentSnapshot, error) in
            if let err = error {
                // Alert
                // Alert
                self.mostrarAlerta(msg: "A ocurrido un error obteniendo la informacion de empresa por correo. \(err)", clase: clase, titulo: "Error")
                return
            } else {
                if documentSnapshot!.documents.count < 0 {
                    // Alert
                    self.mostrarAlerta(msg: "No se ha encontrado la cuenta.", clase: clase, titulo: "Error")
                    
                } else {
                for document in documentSnapshot!.documents {                    empresa.correo = String(describing: document.data()["cuenta"]!)
                    
                    if let nombreTemp = document.data()["nombre"] {
                        empresa.nombre = String(describing: nombreTemp)
                    }
                    
                    if let logoTemp = document.data()["logo"] as? String{
                        empresa.logo = logoTemp
                    }
                    
                    if let tasaRendimientoTemp = document.data()["tasaRendimiento"] as? Double{
                        empresa.tasaRendimiento = tasaRendimientoTemp
                    }
                    
                    callback(empresa)
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
    
    func registrarInversion(inversiorCorreo: String, organizacion: Usuario, montoInvertido: Double, fechaRetiroGanancia: Date, autoInvertir: Bool = false) {
            self.db.collection("inversiones").document().setData([
                "inversor": self.db.document("usuarios/"+inversiorCorreo),
                "emailInversor": inversiorCorreo,
                "organizacion": self.db.document("empresas/"+organizacion.correo),
                "montoInvertido": montoInvertido,
                "gananciaAcumulada": 0.0,
                "fechaInversion": Timestamp(date: Date()),
                "fechaRetiro": Timestamp(date: fechaRetiroGanancia),
                "autoInvertir": autoInvertir
                ])
        
        self.registroBitacora(email: inversiorCorreo, descripcionMovimiento: "Se realizó una inversión en la empresa \(String(describing: organizacion.nombre)), con número de cuenta \(organizacion.cuenta) y correo \(organizacion.correo), invirtiendo $ \(montoInvertido) MXN con una tasa de interés del \(String(describing: organizacion.tasaRendimiento))%", tipoMovimiento: "Inversión", complementoIdMovimiento: "Mov-Inversion-")
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
        clase.viewDidLoad()
        clase.present(alertController, animated: true, completion: nil)
        
    }
    
 
}


