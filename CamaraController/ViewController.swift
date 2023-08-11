//
//  ViewController.swift
//  CamaraController
//
//  Created by Omar Campos on 07/08/23.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var sswtc: UISwitch!
    @IBOutlet weak var enableLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var table: UITableView!
    var configMode = true
    var grabando = false
    var camarass = [CamaraAction]()
    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(UINib(nibName: "CamaraTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(self.panGestureSettings(_:))))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))

            // Configure Tap Gesture Recognizer
            tapGestureRecognizer.numberOfTapsRequired = 2

            // Add Tap Gesture Recognizer
            view.addGestureRecognizer(tapGestureRecognizer)
    }
    @objc func didTapView(_ sender : UITapGestureRecognizer)
    {
        debugPrint("gesture")
        enableLabel.isHidden = true
        sswtc.isHidden = true
        addButton.isHidden = true
    }
    @objc func panGestureSettings(_ sender : UIPinchGestureRecognizer)
    {
        debugPrint("gesture")
        enableLabel.isHidden = false
        sswtc.isHidden = false
        addButton.isHidden = false
    }
    @IBAction func changeSetting(_ sender: UISwitch) {
        if sender.isOn
        {
            configMode = false
            camarass.forEach { c in
                c.SetTimer()
            }
            table.reloadData()
            enableLabel.text = "Deshabilitar Monitoreo"
        }
        else
        {
            enableLabel.text = "Habilitar Monitoreo"
            configMode = true
            camarass.forEach { c in
                c.stopTimerTest()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recordButton.layer.cornerRadius = 50
        recordButton.layer.borderColor = UIColor.green.cgColor
        recordButton.layer.borderWidth = 2
        recordButton.setTitle("StandBy", for: .normal)
    }
    override func viewDidAppear(_ animated: Bool) {
        camarass = CamaraEntity.getCamaras() ?? [CamaraAction]()
        table.reloadData()
        
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
        if !configMode
        {
            grabando.toggle()
            if grabando
            {
                recordButton.layer.cornerRadius = 50
                recordButton.layer.borderColor = UIColor.green.cgColor
                recordButton.layer.borderWidth = 2
                recordButton.setTitle("Grabando", for: .normal)
            }
            else
            {
                recordButton.layer.cornerRadius = 50
                recordButton.layer.borderColor = UIColor.green.cgColor
                recordButton.layer.borderWidth = 2
                recordButton.setTitle("StandBy", for: .normal)
            }
            if camarass.count > 0
            {
                camarass.forEach { c in
                    if c.Grabando != grabando && c.grabarGeneral
                    {
                        c.SetRecording()
                    }
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
    }
    @IBAction func AddCamara(_ sender: UIButton) {
        if configMode
        {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "config") as! AddCamViewController
            self.present(vc, animated: true, completion: nil)
        }
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
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if configMode
        {
            let leftAction = UIContextualAction(style: .normal, title:  "Eliminar", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                let alert  = UIAlertController(title: "Cuidado", message: "¿Quieres borrar esta camara?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: .destructive,handler: { _ in
                    let y = self.camarass[indexPath.row].ip
                    self.camarass.removeAll(where: {$0.ip == y})
                    DispatchQueue.main.async {
                        CamaraEntity.deleteCamera(ip: y!)
                        self.table.reloadData()
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
                
                success(true)
            })
            
            leftAction.image = UIImage(named: "")
            leftAction.backgroundColor = UIColor.red
            
            return UISwipeActionsConfiguration(actions: [leftAction])
        }
        return nil
    }
}

