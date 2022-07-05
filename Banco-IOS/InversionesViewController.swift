//
//  InversionesViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 27/06/22.
//

import UIKit

class InversionesViewController: UIViewController {
    @IBOutlet weak var inversionesTableView: UITableView!
    private let dbM = DBManager.shared
    
    private let email: String
    private var data: [DBManager.Inversion]
    private var tituloTabla: String
    private var busqueda = ""
    
    init(email: String) {
        self.email = email
        self.tituloTabla = "Sin Inversiones"
        self.data = []
        
        super.init(nibName: nil, bundle: nil)
        
        self.dbM.buscarInversionesPorCorreoObject(correoInversor: email, clase: self) { ( dataDB) in
            self.data = dataDB
            self.tituloTabla = "Inversiones - (\(self.data.count) registros)"
            DispatchQueue.main.async {
                self.inversionesTableView.reloadData()
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
        inversionesTableView.dataSource = self
        inversionesTableView.delegate = self
        inversionesTableView.tableFooterView = UIView()
        
        inversionesTableView.register(UINib(nibName: "CeldaPersonalizadaTableViewCell", bundle: nil), forCellReuseIdentifier: "celdaPersonalizada")
        
        inversionesTableView.rowHeight = UITableView.automaticDimension
    
    }

}


// MARK: - UITableViewDataSource
extension InversionesViewController: UITableViewDataSource {

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
    let cell = tableView.dequeueReusableCell(withIdentifier: "celdaPersonalizada", for: indexPath) as? CeldaPersonalizadaTableViewCell
    cell?.nombreEmpresaLabel.text = data[indexPath.row].organizacion?.nombre
    cell?.montoLabel.text = "$ \(data[indexPath.row].montoInvertido) MXN"
    cell?.fechaLabel.text = "\(data[indexPath.row].fechaInversion.dateValue())"
    let logo = data[indexPath.row].organizacion?.logo
    if logo == "" {
        cell?.logoImagen.isHidden = true
    } else {
        cell?.logoImagen.kf.setImage(with: URL(string: logo ?? ""))
    }
    
return cell!
}

}

// MARK: - UITableViewDelegate
extension InversionesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(InversionViewController(email: self.email, inversion: data[indexPath.row]), animated: true)
        
    }
    
}
