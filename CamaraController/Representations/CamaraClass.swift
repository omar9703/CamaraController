//
//  CamaraClass.swift
//  CamaraController
//
//  Created by Omar Campos on 09/08/23.
//

import Foundation
import UIKit
import CoreData
import Alamofire

struct camaStruct : Codable
{
    let ip : String
    let nombre : String
    let habilitado : Bool
}
class CamaraEntity
{
    public static func saveCam(ip : String, nombre : String)
    {
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        
        // 1
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
                let entity =
                  NSEntityDescription.entity(forEntityName: "Camara",
                                             in: managedContext)!
        
                let cam = NSManagedObject(entity: entity,
                                             insertInto: managedContext)
        cam.setValue(ip, forKeyPath: "ip")
        cam.setValue(nombre, forKey: "nombre")
        cam.setValue(false, forKey: "habilitado")
        do {
          try managedContext.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
    public static func deleteCamera(ip : String)
    {
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        
        // 1
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "Camara")
        
        fetchRequest.predicate = NSPredicate(format: "ip = %@", ip)
            do
            {
                let cl = try managedContext.fetch(fetchRequest)

                for entity in cl {

                    managedContext.delete(entity)
                }
                try managedContext.save()
            }
            catch _ {
                print("Could not delete")

            }
    }
    public static func getCamaras() -> [CamaraAction]?
    {
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        let managedContext =
        appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "Camara")
        
        //3
        do {
            let cl = try managedContext.fetch(fetchRequest)
            var ck = [CamaraAction]()
                cl.forEach { ns in
                    let cam = CamaraAction(ip: ns.value(forKey: "ip") as? String ?? "", nombre: ns.value(forKey: "nombre") as? String ?? "", Habilitado: ns.value(forKey: "habilitado") as? Bool ?? false)
                        ck.append(cam)
                }
                return ck
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    public static func searchCam(ip : String) -> Bool
    {
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        
        // 1
        let managedContext =
        appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "Camara")
        fetchRequest.predicate = NSPredicate(format: "ip = %@", ip)
        do
        {
            let array = try managedContext.fetch(fetchRequest)
            if let us = array.last
            {
                return true
            }
            return false
        }
        catch
        {
            debugPrint(error)
            return false
        }
    }
}


class CamaraAction
{
    var ip : String?
    var nombre : String?
    var Habilitado : Bool?
    var SlotA : String?
    var SlotB : String?
    var Grabando : Bool = false
    var timer : Timer?
    var grabarGeneral = true
    init(ip: String? = nil, nombre: String? = nil, Habilitado: Bool? = nil,SlotA: String? = nil,SlotB: String? = nil) {
        self.ip = ip
        self.nombre = nombre
        self.Habilitado = Habilitado
        self.SlotA = SlotA
        self.SlotB = SlotB
    }
    
    
    public func SetTimer()
    {
        guard timer == nil else {return}
        self.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.status(_:)), userInfo: nil, repeats: true)
        self.status(timer!)

    }
    @objc private func status(_ timer : Timer)
    {
        self.getStatus()
        
    }
    public func stopTimerTest() {
      timer?.invalidate()
      timer = nil
    }
    private func getStatus()
    {
        debugPrint("http://\(self.ip ?? "")/command/inquiry.cgi?inq=indicator")
        AF.request("http://\(self.ip ?? "")/command/inquiry.cgi?inq=indicator").authenticate(username: "admin", password: "Avs2020.").responseData { (responseObject) -> Void in
            if let data = responseObject.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                let elements = utf8Text.components(separatedBy:"&")
                if let SlotAIndicator = elements.filter({$0.contains("IndicatorSlotARemainState")}).first
                {
                    debugPrint(SlotAIndicator)
                    let sA = SlotAIndicator.components(separatedBy:"=")
                    let minutos = Float(sA[1])!/60
                    debugPrint(String(Int(minutos)))
                    self.SlotA = String(Int(minutos))
                }
                if let SlotBIndicator = elements.filter({$0.contains("IndicatorSlotBRemainState")}).first
                {
                    debugPrint(SlotBIndicator)
                    let sB = SlotBIndicator.components(separatedBy:"=")
                    let minutos = Float(sB[1])!/60
                    debugPrint(String(Int(minutos)))
                    self.SlotB = String(Int(minutos))
                }
                if utf8Text.contains("standby")
                {
                    self.Grabando = false
                }
                else
                {
                    self.Grabando = true
                }
                }
        }
    }
    public func SetRecording()
    {
        self.Grabando.toggle()
        AF.request("http://\(self.ip ?? "")/command/cameraoperation.cgi?MediaRecording=press").authenticate(username: "admin", password: "Avs2020.").responseData { (responseObject) -> Void in
            
            AF.request("http://\(self.ip ?? "")/command/cameraoperation.cgi?MediaRecording=release").authenticate(username: "admin", password: "Avs2020.").responseData { (responseObject) -> Void in
                
                
            }
        }
    }
}
