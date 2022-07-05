//
//  InversionViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 01/07/22.
//

import UIKit
import UIKit
import FirebaseFirestore
import Kingfisher

class InversionViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var invertirButton: UIButton!
    @IBOutlet weak var fechaDatePicker: UIDatePicker!
    @IBOutlet weak var inversionAutomaticaSwitch: UISwitch!
    @IBOutlet weak var ayudaButton: UIButton!
    @IBOutlet weak var tasaLabel: UILabel!
    @IBOutlet weak var correoEmpresaLabel: UILabel!
    @IBOutlet weak var montoTextField: UITextField!
    @IBOutlet weak var saldoTotalLabel: UILabel!
    @IBOutlet weak var bonoLabel: UILabel!
    @IBOutlet weak var saldoLabel: UILabel!
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var gananciaLabel: UILabel!
    @IBOutlet weak var montoOriginalLabel: UILabel!
    
    private let db = Firestore.firestore()
    private let dbM = DBManager.shared
    
    private var usuario = DBManager.Usuario()
    private var empresa = DBManager.Usuario()
    private var inversion: DBManager.Inversion
    private let email: String
 
    
    
    init(email: String, inversion: DBManager.Inversion) {
        self.email = email
        self.inversion = inversion
        if let empresa = inversion.organizacion {
            self.empresa = empresa
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Realizar inversión"
        // Do any additional setup after loading the view.
        
        // Usuario logueado
        self.dbM.getInformacionUsuarioPorCuentaCorreo(cuentaOCorreo: self.email, clase: self, campo: "correo") { (usuarioDB) in
            self.usuario = usuarioDB
            if self.usuario.nombre == "" {
                    self.nombreLabel.text = self.usuario.correo
            }
            
            self.saldoLabel.text = String(self.usuario.saldoCuenta)
            self.bonoLabel.text = "Monto del bono disponible: $ \(String(self.usuario.bono)) MXN"
            self.montoOriginalLabel.text = "Monto original invertido: $ \(self.inversion.montoInvertido) MXN"
            self.gananciaLabel.text = "Ganancias $ \(self.inversion.gananciaAcumulada) MXN"
            if self.usuario.bonoAsignado && self.usuario.bono > 0.0 {
                        
                        self.bonoLabel.isHidden = false
                        self.saldoTotalLabel.isHidden = false
                self.saldoTotalLabel.text = "Saldo Total: $ \(self.usuario.saldoCuenta + self.usuario.bono)"
                
            }
         }
        
        if self.empresa.logo == "" {
            self.logoImageView.isHidden = true
        } else {
            self.logoImageView.kf.setImage(with: URL(string: self.empresa.logo ?? ""))
        }
        
        // Información del usuario a transferir
        self.correoEmpresaLabel.text = self.empresa.correo
        
        self.nombreLabel.text = self.empresa.nombre
        self.tasaLabel.text = "Tasa de rendimiento (diaria): \((self.empresa.tasaRendimiento ?? 0.0) * 100)%"
 
    }

    @IBAction func invertir(_ sender: Any) {
        let monto = Double(montoTextField.text ?? "0.0") ?? 0.0
        let fechaRetiroGanancia = self.fechaDatePicker.date
        let autoInvertir = self.inversionAutomaticaSwitch.isOn ? true : false
    
        if monto <= 0.0 {
            // Alert
            self.dbM.mostrarAlerta(msg: "Por favor ingrese valores positivos y mayores a 0.0", clase: self)
            
        } else if Timestamp(date: fechaRetiroGanancia).compare(Timestamp(date: Date())) == .orderedAscending {
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

