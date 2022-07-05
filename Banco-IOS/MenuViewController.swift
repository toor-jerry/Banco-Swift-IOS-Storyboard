//
//  MenuViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 08/06/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import UserNotifications

class MenuViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet weak var usuarioLabel: UILabel!
    @IBOutlet weak var cerrarSesionButton: UIButton!
    @IBOutlet weak var configurarPerfilButton: UIButton!
    @IBOutlet weak var consultaSaldoButton: UIButton!
    @IBOutlet weak var miInformacionButton: UIButton!
    @IBOutlet weak var depositoButton: UIButton!
    @IBOutlet weak var retiroButton: UIButton!
    @IBOutlet weak var movimientosButton: UIButton!
    @IBOutlet weak var transferenciaButton: UIButton!
    @IBOutlet weak var inversionesButton: UIButton!
    
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
        
        UNUserNotificationCenter.current().delegate = self
        
            DBManager.shared.verificarInversiones(correoUserLogueado: self.email, clase: self)
        // Do any additional setup after loading the view.
        title="Menú"
        db.collection("usuarios").document(email).getDocument {
        (documentSnapshot, error) in
            if let document = documentSnapshot, error == nil {
                if let nombre = document.get("nombre") as? String {
                    self.usuarioLabel.text = "Logueado como: \(nombre)"
                } else {
                    self.usuarioLabel.text = "Logueado como: \(self.email)"
                }
                if let bonoAsignado = document.get("bonoAsignado") as? Bool, let notificacionBonoVista = document.get("notificacionBonoVista") as? Bool {
                    if bonoAsignado && notificacionBonoVista == false {
                        var saldo = 0.0
                        var bono = 0.0
                        if let saldoTemp = document.get("saldoCuenta") as? Double {
                            saldo = saldoTemp
                        }
                        if let bonoDB = document.get("bono") as? Double {
                            bono = bonoDB
                        }
                        // Alert
                        let alertController = UIAlertController(title: "Información", message: "Felicidades, ha obtenido un bono con un valor de $ 50,000 MXN!! \nSaldo en la cuenta: $ \(saldo) MXN \nSaldo total: $ \(saldo + bono)", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                        // Actualiza la bandera de la alerta para que no sea mostrada de nuevo
                        self.db.collection("usuarios").document(self.email).setData([
                            "notificacionBonoVista": true
                        ],
                        merge: true)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
         }
        
            }
    }
    // Permite mostrar las notificación cuando la aplicación se encuentra en primer plano
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // let userInfo = notification.request.content.subtitle
        print("Data userinfo en menu \(notification.request.content.userInfo["data"])")
        DBManager.shared.mostrarAlerta(msg: "ss", clase: self)
        completionHandler([.banner, .sound])
    }
    
    @IBAction func cerrarSesion(_ sender: Any) {
        if DBManager.shared.cerrarSesion() {
            navigationController?.popViewController(animated: true)
        }
        
        
    }
    
    @IBAction func configurarPerfil(_ sender: Any) {
        self.navigationController?.pushViewController(ConfigurarPerfilViewController(email: email), animated: true)
    }
    
    
    @IBAction func invertir(_ sender: Any) {
        self.navigationController?.pushViewController(EmpresasViewController(email: email), animated: true)
    }
    
    @IBAction func consultarSaldo(_ sender: Any) {
        self.navigationController?.pushViewController(ConsultaSaldoViewController(email: email), animated: true)
    }
    
    
    @IBAction func verMiInformacion(_ sender: Any) {
        self.navigationController?.pushViewController(MiInformacionViewController(email: email), animated: true)
    }
    
    @IBAction func depositar(_ sender: Any) {
        self.navigationController?.pushViewController(DepositoViewController(email: email), animated: true)
    }
    
    @IBAction func retirar(_ sender: Any) {
        self.navigationController?.pushViewController(RetiroViewController(email: email), animated: true)
    }
    
    
    @IBAction func verMovimientos(_ sender: Any) {
        self.navigationController?.pushViewController(MovimientosViewController(email: email), animated: true)
    }
    
    
    @IBAction func tranfererir(_ sender: Any) {
        self.navigationController?.pushViewController(TransferenciaViewController(email: email), animated: true)
    }
    
    
    @IBAction func verInversiones(_ sender: Any) {
        self.navigationController?.pushViewController(InversionesViewController(email: email), animated: true)
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
