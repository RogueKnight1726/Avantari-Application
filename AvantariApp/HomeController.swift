//
//  HomeController.swift
//  AvantariApp
//
//  Created by Swathy Sudarsanan on 10/08/17.
//  Copyright © 2017 BladeSilver. All rights reserved.
//

import UIKit
import UserNotifications
import RealmSwift
import Charts

class HomeController: UIViewController,UNUserNotificationCenterDelegate,ChartViewDelegate {
    @IBOutlet weak var stopContainer: UIView!
    @IBOutlet weak var startContainer: UIView!
    @IBOutlet weak var containerView: UIView!
    var graphView = GraphView()
    let realm = try! Realm()
    var storedValues = List<ServerValue>()
    var valueForChart = [Int]()
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFromRealm()
        UIView.animate(withDuration: 0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.stopContainer.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height / 2)
        }, completion: nil)
    }
    
    func populateChart() {
        self.graphView.removeFromSuperview()
        self.graphView.update(values: self.storedValues, frame: self.graphView.frame)
        self.view.addSubview(self.graphView)
        graphView.translatesAutoresizingMaskIntoConstraints = false
        graphView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        graphView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        graphView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        graphView.bottomAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
    }
    
    func updateFromRealm(){
        let valueList: Results<ServerValue> = {self.realm.objects(ServerValue.self)}()
        self.storedValues = List(valueList)
        if (self.storedValues.count != 0){
            if storedValues.count > 9 {
                fetchLastTenItems()
                return
            }
            populateChart()
        }
    }
    
    @IBAction func startServer(_ sender: Any) {
        SocketIOManager.sharedInstance.establishConnection()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.stopContainer.transform = .identity
        }, completion: nil)
    }
    @IBAction func stopServer(_ sender: Any) {
        SocketIOManager.sharedInstance.stopConnection()
        UIView.animate(withDuration: 0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.stopContainer.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height / 2)
        }, completion: nil)
    }
    
    func addToRealm(currentValue: Int){
        let valueObject = ServerValue()
        valueObject.value = currentValue
        valueObject.id = UUID().uuidString
        valueObject.save()
        if storedValues.count > 9 {
            fetchLastTenItems()
            return
        }
        
        let valueList: Results<ServerValue> = {self.realm.objects(ServerValue.self)}()
        self.storedValues = List(valueList)
        self.valueForChart.append(valueObject.value)
        
        populateChart()
        
    }
    
    func fetchLastTenItems(){
        let valueList: Results<ServerValue> = {self.realm.objects(ServerValue.self)}()
        let size = valueList.count
        self.valueForChart.removeAll()
        self.storedValues.removeAll()
        for i in 1 ... 10 {
            self.storedValues.append(valueList[size - (11 - i)])
            self.valueForChart.append(valueList[size - (11 - i)].value)
        }
        print(storedValues.count)
        populateChart()
    }
    
}
