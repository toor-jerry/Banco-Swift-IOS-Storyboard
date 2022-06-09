//
//  ConsultaSaldoViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 08/06/22.
//

import UIKit
import FirebaseFirestore

class ConsultaSaldoViewController: UIViewController {

    @IBOutlet weak var saldoTextView: UITextView!
    
    
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
        title="Consulta de saldo"
        // Do any additional setup after loading the view.
        self.saldoTextView.text = "No cuenta con saldo..."
        self.saldoTextView.textColor = .black
        
        db.collection("usuarios").document(email).getDocument {
        (documentSnapshot, error) in
            if let document = documentSnapshot, error == nil {
                if let saldo = document.get("saldoCuenta") as? Double {                    self.saldoTextView.text = "Su saldo actual en su cuenta es de $ \(saldo) MXN"
                }
            }
         }
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
