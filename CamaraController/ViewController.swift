//
//  ViewController.swift
//  CamaraController
//
//  Created by Omar Campos on 07/08/23.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var table: UITableView!
    var camarass = [CamaraAction]()
    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(UINib(nibName: "CamaraTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        camarass = CamaraEntity.getCamaras() ?? [CamaraAction]()
        table.reloadData()
        camarass.forEach { c in
            c.SetTimer()
        }
        if camarass.count > 0
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                let timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.status(_:)), userInfo: nil, repeats: true)
                self.status(timer)
            }
        }
    }
    @objc private func status(_ timer : Timer)
    {
        table.reloadData()
    }

    @IBAction func grabarTodo(_ sender: UIButton) {
        if camarass.count > 0
        {
            camarass.forEach { c in
                c.SetRecording()
            }
            table.reloadData()
        }
        else
        {
            let alert  = UIAlertController(title: "Error", message: "No hay camaras disponibles", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
            self.present(alert, animated: true)
        }
    }
    @IBAction func AddCamara(_ sender: UIButton) {
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return camarass.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CamaraTableViewCell else
        {
            return UITableViewCell()
        }
        cell.Nombre.text = camarass[indexPath.row].nombre
        cell.ip.text = camarass[indexPath.row].ip
        cell.SlotA.text = (camarass[indexPath.row].SlotA ?? "0") + " Min"
        cell.slotb.text = (camarass[indexPath.row].SlotB ?? "0") + " Min"
        if camarass[indexPath.row].Grabando
        {
            cell.button.layer.cornerRadius = 43
            cell.button.layer.borderColor = UIColor.red.cgColor
            cell.button.layer.borderWidth = 2
            cell.button.setTitle("Grabando", for: .normal)
        }
        
        else
        {
            cell.button.layer.cornerRadius = 43
            cell.button.layer.borderColor = UIColor.green.cgColor
            cell.button.layer.borderWidth = 2
            cell.button.setTitle("StandBy", for: .normal)
        }
        cell.button.addTarget(self, action: #selector(changeRecordingStatus(_:)), for: .touchUpInside)
        cell.button.tag = indexPath.row
        
        cell.selectionStyle = .none
        return cell
    }
    @objc func changeRecordingStatus(_ sender : UIButton)
    {
        camarass[sender.tag].SetRecording()
        if camarass[sender.tag].Grabando
        {
            sender.layer.cornerRadius = 43
            sender.layer.borderColor = UIColor.red.cgColor
            sender.layer.borderWidth = 2
            sender.setTitle("Grabando", for: .normal)
        }
        else
        {
            sender.layer.cornerRadius = 43
            sender.layer.borderColor = UIColor.green.cgColor
            sender.layer.borderWidth = 2
            sender.setTitle("StandBy", for: .normal)
        }
    }
    
}

