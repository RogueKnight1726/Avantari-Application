//
//  SocketIOManager.swift
//  AvantariApp
//
//  Created by Swathy Sudarsanan on 10/08/17.
//  Copyright © 2017 BladeSilver. All rights reserved.
//

import UIKit
import SocketIO
import UserNotifications

class SocketIOManager: NSObject, UNUserNotificationCenterDelegate {
    
    
    var vc = HomeController()
    let requestIdentifier = "SampleRequest"
    var temp = 0
    var socket = SocketIOClient(socketURL: URL(string: "http://ios-test.us-east-1.elasticbeanstalk.com")!, config: [.nsp("/random")])
    override init() {
        super.init()
        
        socket.on("capture") { (dataArray, ack) in
            let responseArray = dataArray as! [Int]
            self.checkResponseEquality(responseArray: responseArray)
            UNUserNotificationCenter.current().delegate = self
        }
        
    }
    
    convenience init(controller: HomeController){
        self.init()
        vc = controller
    }
    
    func checkResponseEquality(responseArray: [Int]){
        
        let currentResponse = responseArray[0]
        
            vc.addToRealm(currentValue: currentResponse)
            if currentResponse == self.temp {
                startNotification(repeatedVale: currentResponse)
            
            temp = currentResponse
        }
        
        
    }
    
    func establishConnection(){
        socket.connect()
    }
    func stopConnection(){
        socket.disconnect()
    }
    
    
    func startNotification(repeatedVale: Int){
        let content = UNMutableNotificationContent()
        content.body = "The number \(repeatedVale) has repeated"
        content.sound = UNNotificationSound.default()
        if let path = Bundle.main.path(forResource: "alert", ofType: "png") {
            let url = URL(fileURLWithPath: path)
            
            do {
                let attachment = try UNNotificationAttachment(identifier: "sampleImage", url: url, options: nil)
                content.attachments = [attachment]
            } catch {
                print("attachment not found.")
            }
        }
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(identifier:requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request){(error) in
            
            if (error != nil){
                
                print(error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.badge,.sound])
    }

}
protocol SocketIOManagerProtocol {
    func addToRealm(currentValue: Int)
}
