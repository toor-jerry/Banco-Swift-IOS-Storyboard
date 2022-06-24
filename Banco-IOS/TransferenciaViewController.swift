//
//  TransferenciaViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 13/06/22.
//

import UIKit

class TransferenciaViewController: UIViewController {

    @IBOutlet weak var barraDeBusqueda: UISearchBar!
    @IBOutlet weak var contactosTableView: UITableView!
    
    private let dbM = DBManager.shared
    
    private let email: String
    private var data: [String] = ["Sin cuentas que mostrar"]
    private var tituloTabla: String
    private var cuenta = ""
    private var busqueda = ""
    
    init(email: String) {
        self.email = email
        self.tituloTabla = "Cuentas"
        
        super.init(nibName: nil, bundle: nil)
        
        self.dbM.getTodosLosUsuarios(email: self.email, clase: self) { ( dataDB) in
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
            self.dbM.mostrarAlerta(msg: "Ingrese un número de cuenta ó nombre del propietario de la cuenta..", clase: self)
        } else {
            self.data = []
            self.dbM.buscarPorTermino(email: self.email, busqueda: barraDeBusqueda.text!, clase: self) { (dataDB) in
                self.data = dataDB
                self.tituloTabla = "Resultados - (\(self.data.count) registros)"
                DispatchQueue.main.async {
                    self.contactosTableView.reloadData()
                }
            }

        }
    }
    
}
