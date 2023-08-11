//
//  AddCamViewController.swift
//  CamaraController
//
//  Created by Omar Campos on 09/08/23.
//

import UIKit

protocol camaraAddedDelegate {
    func cameradded()
}

class AddCamViewController: UIViewController {
    var delegate : camaraAddedDelegate?
    @IBOutlet weak var nombreField: UITextField!
    @IBOutlet weak var ipField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        if nombreField.text != "" && ipField.text != ""
        {
            if !CamaraEntity.searchCam(ip: ipField.text ?? "")
            {
                CamaraEntity.saveCam(ip: ipField.text ?? "", nombre: nombreField.text ?? "")
                self.dismiss(animated: true)
                delegate?.cameradded()
            }
            else
            {
                let alert  = UIAlertController(title: "Error", message: "Esa ip ya se esta usando", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
                self.present(alert, animated: true)
            }
        }
        else
        {
            let alert  = UIAlertController(title: "Error", message: "Faltan datos por llenar", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    

}
