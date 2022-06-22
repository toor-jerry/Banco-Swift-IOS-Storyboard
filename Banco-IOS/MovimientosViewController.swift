//
//  MovimientosViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 10/06/22.
//

import UIKit
import FirebaseFirestore

class MovimientosViewController: UIViewController {
    
    
    @IBOutlet weak var movimientosTableView: UITableView!
    
    private let email: String
    private var data: [String] = ["Sin movimientos que mostrar"]
    private var tituloTabla: String
    private let db = Firestore.firestore()
    
    init(email: String) {
        self.email = email
        self.tituloTabla = "Todos los movimientos"
        
        super.init(nibName: nil, bundle: nil)
        
        self.getTodosLosMovimientos { (dataDB) in
            self.data = dataDB
            self.tituloTabla += " - (\(self.data.count) registros)"
            DispatchQueue.main.async {
                self.movimientosTableView.reloadData()
            }
        }
            }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movimientos"
        // Do any additional setup after loading the view.
        movimientosTableView.dataSource = self
        movimientosTableView.tableFooterView = UIView()
        movimientosTableView.rowHeight = UITableView.automaticDimension
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
        
        func getTodosLosMovimientos(callback: @escaping([String]) -> Void) {
            var dataDB:[String] = []
            self.db.collection("bitacora").whereField("usuario", isEqualTo: self.email).addSnapshotListener { querySnapshot, err in
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
                        dataDB.append("[\(cont)] - \(String(describing: document.data()["descripcion"]!))")
                        
                    }
                }
                callback(dataDB)
            }
        }
    
}


// MARK: - UITableViewDataSource
extension MovimientosViewController: UITableViewDataSource {
    
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
            }
            cell!.textLabel?.text = data[indexPath.row]
            

        return cell!
    }
    
}




