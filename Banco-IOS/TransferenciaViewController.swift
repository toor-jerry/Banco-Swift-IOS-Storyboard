//
//  TransferenciaViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 13/06/22.
//

import UIKit
import FirebaseFirestore

class TransferenciaViewController: UIViewController {

    @IBOutlet weak var barraDeBusqueda: UISearchBar!
    @IBOutlet weak var contactosTableView: UITableView!
    
    private let email: String
    private var data: [String] = ["Sin cuentas que mostrar"]
    private var tituloTabla: String
    private let db = Firestore.firestore()
    private var cuenta = ""
    private var busqueda = ""
    
    init(email: String) {
        self.email = email
        self.tituloTabla = "Cuentas"
        
        super.init(nibName: nil, bundle: nil)
        
        self.getTodosLosUsuarios { (dataDB) in
            self.data = dataDB
            self.tituloTabla += " - (\(self.data.count) registros)"
            DispatchQueue.main.async {
                self.contactosTableView.reloadData()
            }
        }
            }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tranferencias"
        // Do any additional setup after loading the view.
        contactosTableView.dataSource = self
        contactosTableView.delegate = self
        contactosTableView.tableFooterView = UIView()
        contactosTableView.rowHeight = UITableView.automaticDimension
        
        barraDeBusqueda.delegate = self

        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


func getTodosLosUsuarios(callback: @escaping([String]) -> Void) {
    var dataDB:[String] = []
    
    self.db.collection("usuarios").whereField("correo", isNotEqualTo: self.email).addSnapshotListener { querySnapshot, err in
        if let err = err {
            // Alert
            let alertController = UIAlertController(title: "Error", message: "A ocurrido un error. \(err)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
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
    
    func buscarPorCuenta(callback: @escaping([String]) -> Void) {
        var dataDB:[String] = []
        self.db.collection("usuarios").whereField("cuenta", isEqualTo: self.cuenta).addSnapshotListener { querySnapshot, err in
            if let err = err {
                // Alert
                let alertController = UIAlertController(title: "Error", message: "A ocurrido un error. \(err)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                
                self.present(alertController, animated: true, completion: nil)
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
 
    func buscarPorTermino(callback: @escaping([String]) -> Void) {
        var dataDB:[String] = []
        self.db.collection("usuarios").whereField("nombre", isEqualTo: self.barraDeBusqueda.text!).addSnapshotListener { querySnapshot, err in
            if let err = err {
                // Alert
                let alertController = UIAlertController(title: "Error", message: "A ocurrido un error. \(err)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                
                self.present(alertController, animated: true, completion: nil)
                return
            } else {
                var cont = 0
                for document in querySnapshot!.documents {
                    cont += 1
                    var nombre = "Sin nombre"
                    if let nombreTemp = document.data()["nombre"] {
                        nombre = String(describing: nombreTemp)
                    }

                    let contenidoArray = "\(nombre) - \(String(describing: document.data()["cuenta"]!))"
                    
                    if !dataDB.contains(contenidoArray) {
                        if String(describing: document.data()["correo"]!) != self.email {
                        dataDB.append(contenidoArray)
                    }
                    
                }
            }
            }
            callback(dataDB)
        }
        
        self.db.collection("usuarios").whereField("cuenta", isEqualTo: self.barraDeBusqueda.text!).addSnapshotListener { querySnapshot, err in
            if let err = err {
                // Alert
                let alertController = UIAlertController(title: "Error", message: "A ocurrido un error. \(err)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
                
                self.present(alertController, animated: true, completion: nil)
                return
            } else {
                var cont = 0
                for document in querySnapshot!.documents {
                    cont += 1
                    var nombre = "Sin nombre"
                    if let nombreTemp = document.data()["nombre"] {
                        nombre = String(describing: nombreTemp)
                    }

                    let contenidoArray = "\(nombre) - \(String(describing: document.data()["cuenta"]!))"
                    
                    if !dataDB.contains(contenidoArray) {
                        if String(describing: document.data()["correo"]!) != self.email {
                        dataDB.append(contenidoArray)
                    }
                    
                }
            }
            }
            callback(dataDB)
        }
    
    
    self.db.collection("usuarios").whereField("correo", isEqualTo: self.barraDeBusqueda.text!).addSnapshotListener { querySnapshot, err in
        if let err = err {
            // Alert
            let alertController = UIAlertController(title: "Error", message: "A ocurrido un error. \(err)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
            return
        } else {
            var cont = 0
            for document in querySnapshot!.documents {
                cont += 1
                var nombre = "Sin nombre"
                if let nombreTemp = document.data()["nombre"] {
                    nombre = String(describing: nombreTemp)
                }

                let contenidoArray = "\(nombre) - \(String(describing: document.data()["cuenta"]!))"
                
                if !dataDB.contains(contenidoArray) {
                    if String(describing: document.data()["correo"]!) != self.email {
                    dataDB.append(contenidoArray)
                }
                
            }
        }
        }
        callback(dataDB)
    }
}

}


// MARK: - UITableViewDataSource
extension TransferenciaViewController: UITableViewDataSource {

// Número de celdas con base en la data
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        return data.count
}

func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return tituloTabla
}

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
return UITableView.automaticDimension
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    var cell = tableView.dequeueReusableCell(withIdentifier: "mycell")
    if cell == nil {
        cell = UITableViewCell(style: .default, reuseIdentifier: "mycell")
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.textAlignment = .justified
        cell?.accessoryType = .disclosureIndicator
    }
    cell!.textLabel?.text = data[indexPath.row]
    

return cell!
}

}

// MARK: - UITableViewDelegate
extension TransferenciaViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataRow = String(data[indexPath.row])
        self.cuenta = String(dataRow.suffix(from: dataRow.index(dataRow.endIndex, offsetBy: -13)))
        
        self.navigationController?.pushViewController(FormTransferenciaViewController(email: self.email, cuentaADepositar: self.cuenta), animated: true)
        
    }
    
}


extension TransferenciaViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        barraDeBusqueda.resignFirstResponder()
        
        // print("Busqueda: \(barraDeBusqueda.text!)")
        if barraDeBusqueda.text! == "" {
        // Alert
        let alertController = UIAlertController(title: "Alerta", message: "Ingrese un número de cuenta ó nombre del propietario de la cuenta..", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Aceptar", style: .default))
        
        self.present(alertController, animated: true, completion: nil)
        } else {
            self.data = []
            self.buscarPorTermino { (dataDB) in
                self.data = dataDB
                self.tituloTabla = "Resultados - (\(self.data.count) registros)"
                DispatchQueue.main.async {
                    self.contactosTableView.reloadData()
                }
            }

        }
    }
    
}
