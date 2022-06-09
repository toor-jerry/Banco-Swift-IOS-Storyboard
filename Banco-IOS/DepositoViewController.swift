//
//  DepositoViewController.swift
//  Banco-IOS
//
//  Created by user216116 on 09/06/22.
//

import UIKit
import FirebaseFirestore

class DepositoViewController: UIViewController {
    
    @IBOutlet weak var montoInput: UITextField!
    @IBOutlet weak var depositarButton: UIButton!
    
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
        title = "Depositar"
        // Do any additional setup after loading the view.
    }
    

    @IBAction func depositar(_ sender: Any) {
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
