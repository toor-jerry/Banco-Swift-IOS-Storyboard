//
//  MiInformacionViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 09/06/22.
//

import UIKit
import FirebaseFirestore

class MiInformacionViewController: UIViewController {
    
    @IBOutlet weak var nombreTextView: UITextView!
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

        // Do any additional setup after loading the view.
        title = "Mi información"
        db.collection("usuarios").document(email).getDocument {
        (documentSnapshot, error) in
            if let document = documentSnapshot, error == nil {
                if let nombre = document.get("nombre") as? String {                    self.nombreTextView.text = nombre
                } else {
                    self.nombreTextView.text = "No cuenta con un nombre que mostrar, agreguelo en la opción 'Configurar Perfil'"
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
