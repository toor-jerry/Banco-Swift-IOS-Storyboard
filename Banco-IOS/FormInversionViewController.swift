//
//  FormInversionViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 27/06/22.
//

import UIKit
import FirebaseFirestore
import Kingfisher

class FormInversionViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var invertirButton: UIButton!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var saldoLabel: UILabel!
    @IBOutlet weak var bonoLabel: UILabel!
    @IBOutlet weak var saldoTotalLabel: UILabel!
    @IBOutlet weak var montoTextField: UITextField!
    @IBOutlet weak var correoEmpresaLabel: UILabel!
    @IBOutlet weak var tasaLabel: UILabel!
    @IBOutlet weak var fechaDatePicker: UIDatePicker!
    @IBOutlet weak var ayudaButton: UIButton!
    @IBOutlet weak var inversionAutomaticaSwitch: UISwitch!
    
    
    private let db = Firestore.firestore()
    private let dbM = DBManager.shared
    
    private var usuario = DBManager.Usuario()
    private var empresa = DBManager.Usuario()
    private let email: String
    private let correoEmpresa: String
 
    
    
    init(email: String, correoEmpresa: String) {
        self.email = email
        self.correoEmpresa = correoEmpresa
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Realizar inversión"
        // Do any additional setup after loading the view.
        self.usuario.correo = self.email
        self.empresa.correo = self.correoEmpresa
        
        // Usuario logueado
        db.collection("usuarios").document(self.usuario.correo).getDocument {
        (documentSnapshot, error) in
            if let document = documentSnapshot, error == nil {
                if let nombre = document.get("nombre") as? String {                    self.usuario.nombre = nombre
                } else {
                    self.nombreLabel.text = self.usuario.correo
                }
                if let saldo = document.get("saldoCuenta") as? Double {
                    self.saldoLabel.text = String(saldo)
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
        // Información del usuario a transferir
        self.dbM.getInformacionEmpresa(correo: self.empresa.correo, clase: self, callback: { (usuario) in
            if let cuenta = usuario["cuenta"] as? String {
                self.empresa.cuenta = cuenta
            }
            
            if let url = usuario["logo"] as? String {
                self.logoImageView.kf.setImage(with: URL(string: url))
            } else {
                self.logoImageView.isHidden = true
            }
            
            if let correo = usuario["correo"] as? String {
                self.correoEmpresaLabel.text = correo
                self.empresa.correo = correo
            }
            if let nombre = usuario["nombre"] as? String {
                self.nombreLabel.text = nombre
                self.empresa.nombre = nombre
            }
            
            if let tasa = usuario["tasaRendimiento"] as? Double {
                self.tasaLabel.text = "Tasa de rendimiento (diaria): \(tasa * 100)%"
                self.empresa.tasaRendimiento = tasa
            }
            
        })
        
        
        
    }

    @IBAction func invertir(_ sender: Any) {
        let monto = Double(montoTextField.text ?? "0.0") ?? 0.0
        let fechaRetiroGanancia = Timestamp(date: Date())
        let autoInvertir = self.inversionAutomaticaSwitch.isOn ? true : false
    
        if monto <= 0.0 {
            // Alert
            self.dbM.mostrarAlerta(msg: "Por favor ingrese valores positivos y mayores a 0.0", clase: self)
            
        } else if Timestamp(date: self.fechaDatePicker.date).compare(Timestamp(date: Date())) == .orderedAscending {
            self.dbM.mostrarAlerta(msg: "Ingrese un lapso de tiempo mayor al actual, debido a que las ganancias se calculan con base al tiempo transcurrido desde que se invirtió.", clase: self)
        } else if self.usuario.saldoCuenta >= monto {
            
            // Se descuenta el monto que se invierte
            self.usuario.saldoCuenta -= monto
            
            self.dbM.registrarInversion(inversiorCorreo: self.usuario.correo, organizacion: self.empresa, montoInvertido: monto, fechaRetiroGanancia: fechaRetiroGanancia, autoInvertir: autoInvertir)
            
            // Actualización de los campos
            self.actualizacionCamposView()
            
            
            // Alert
            self.dbM.mostrarAlerta(msg: "Se realizó con éxito la inversión en la empresa \(String(describing: self.empresa.nombre)) con un monto de \(monto) MXN.", clase: self, titulo: "Información")
            
        } else if ( self.usuario.bono > 0 && self.usuario.saldoCuenta > 0 && ( self.usuario.bono + self.usuario.saldoCuenta >= monto ) ) { // Si tiene el bono y aún alcanza a invertir con el saldo
            let montoBono = (monto - self.usuario.saldoCuenta)
            let saldoCuentaInvertido = self.usuario.saldoCuenta
            
            // Nuevos saldos
            self.usuario.saldoCuenta = 0.0
            self.usuario.bono -= montoBono
            
            self.dbM.registrarInversion(inversiorCorreo: self.usuario.correo, organizacion: self.empresa, montoInvertido: monto, fechaRetiroGanancia: fechaRetiroGanancia, autoInvertir: autoInvertir)
            
            // Dandole seguimiento al bono
            self.dbM.registroBitacora(email: self.usuario.correo, descripcionMovimiento: "Se realizó un movimiento de tipo 'Inversión-BONO' en la empresa \(String(describing: self.empresa.nombre)) con número de cuenta \(self.empresa.cuenta), de la cuenta \(self.usuario.cuenta) con un monto de \(montoBono)", tipoMovimiento: "Transferencia", complementoIdMovimiento: "Mov-Transf-Bono")
            // Actualización de los campos
            self.actualizacionCamposView()
                        
            // Alert
            self.dbM.mostrarAlerta(msg: "Se realizó con éxito la inversión en la empresa \(String(describing: self.empresa.nombre)) con un monto de \(monto) MXN. \n Monto invertido de la cuenta $ \(saldoCuentaInvertido) MXN.\n Monto invertido del bono $ \(montoBono) MXN.", clase: self, titulo: "Información")

            
        } else if monto <= self.usuario.bono { // Si tiene el bono y alcanza a realizar la inversión solo con el bono

            // Nuevos saldos
            self.usuario.bono -= monto
            
            self.dbM.registrarInversion(inversiorCorreo: self.usuario.correo, organizacion: self.empresa, montoInvertido: monto, fechaRetiroGanancia: fechaRetiroGanancia, autoInvertir: autoInvertir)
            
            // Dandole seguimiento al bono
            self.dbM.registroBitacora(email: self.usuario.correo, descripcionMovimiento: "Se realizó un movimiento de tipo 'Inversión-BONO' en la empresa \(String(describing: self.empresa.nombre)) con número de cuenta \(self.empresa.cuenta), de la cuenta \(self.usuario.cuenta) con un monto de \(monto)", tipoMovimiento: "Transferencia", complementoIdMovimiento: "Mov-Transf-Bono")

            // Actualización de los campos
            self.actualizacionCamposView()
            
            
            // Alert
            self.dbM.mostrarAlerta(msg: "Se realizó con éxito la inversión en la empresa \(String(describing: self.empresa.nombre)) con un monto de \(monto) MXN.", clase: self, titulo: "Información")
            
        } else {
            // Alert
            self.dbM.mostrarAlerta(msg: "El monto que quiere invertir es mayor a su saldo total en su cuenta ($ \(self.usuario.saldoCuenta + self.usuario.bono) MXN), realice un depósito para poder realizar la inversión deseada.", clase: self)
        }
    }
    
    @IBAction func ayuda(_ sender: Any) {
        self.dbM.mostrarAlerta(msg: "La función de la inversión automática es invertir el monto original más las ganancias obtenidas una vez el lapso de tiempo haya finalizado, volviendo a calcular el lapso de tiempo tomando como referencia el lapso antes dado (puede desactivar esta función en la la opción \"Mis inversiones\" en el menú principal)", clase: self, titulo: "Información")
    }
    
    
        
    func actualizacionCamposView() {
        self.montoTextField.text = ""
        self.inversionAutomaticaSwitch.isOn = false
        if self.usuario.bonoAsignado {
            self.saldoLabel.text = String(self.usuario.saldoCuenta)
            self.bonoLabel.text = "Monto del bono disponible: $ \(String(self.usuario.bono)) MXN"
            self.saldoTotalLabel.text = "Saldo total: $ \(String(self.usuario.saldoCuenta + self.usuario.bono)) MXN"
        }
    }
    }
