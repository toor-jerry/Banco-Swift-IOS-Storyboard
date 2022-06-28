//
//  EmpresasViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 24/06/22.
//

import UIKit

class EmpresasViewController: UIViewController {
    @IBOutlet weak var barraBusqueda: UISearchBar!
    @IBOutlet weak var empresasTableView: UITableView!
    private let dbM = DBManager.shared
    
    private let email: String
    private var data: [String] = ["Sin cuentas que mostrar"]
    private var tituloTabla: String
    private var correoEmpresa = ""
    private var busqueda = ""
    
    init(email: String) {
        self.email = email
        self.tituloTabla = "Empresas"
        
        super.init(nibName: nil, bundle: nil)
        
        self.dbM.getTodasLasEmpresas(email: self.email, clase: self) { ( dataDB) in
            self.data = dataDB
            self.tituloTabla += " - (\(self.data.count) registros)"
            DispatchQueue.main.async {
                self.empresasTableView.reloadData()
            }
        }
            }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Inversiones"
        // Do any additional setup after loading the view.
        empresasTableView.dataSource = self
        empresasTableView.delegate = self
        empresasTableView.tableFooterView = UIView()
        empresasTableView.rowHeight = UITableView.automaticDimension
        
        barraBusqueda.delegate = self

        
    }

}


// MARK: - UITableViewDataSource
extension EmpresasViewController: UITableViewDataSource {

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
        cell?.accessoryType = .disclosureIndicator
    }
    cell!.textLabel?.text = data[indexPath.row]
    

return cell!
}

}

// MARK: - UITableViewDelegate
extension EmpresasViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataRow = String(data[indexPath.row])
        self.correoEmpresa = dataRow.components(separatedBy: "Correo:")[1].trimmingCharacters(in: .whitespaces)
        self.navigationController?.pushViewController(FormInversionViewController(email: self.email, correoEmpresa: self.correoEmpresa), animated: true)
        
    }
    
}


extension EmpresasViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        barraBusqueda.resignFirstResponder()
        
        // print("Busqueda: \(barraDeBusqueda.text!)")
        if barraBusqueda.text! == "" {
        // Alert
            self.dbM.mostrarAlerta(msg: "Ingrese un correo ó nombre de la empresa..", clase: self)
        } else {
            self.data = []
            self.dbM.buscarPorTerminoEmpresas(email: self.email, busqueda: barraBusqueda.text!, clase: self) { (dataDB) in
                self.data = dataDB
                self.tituloTabla = "Resultados - (\(self.data.count) registros)"
                DispatchQueue.main.async {
                    self.empresasTableView.reloadData()
                }
            }

        }
    }
    
}
