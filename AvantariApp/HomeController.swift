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

class HomeController: UIViewController,UNUserNotificationCenterDelegate,ChartViewDelegate, SocketIOManagerProtocol {
    @IBOutlet weak var currentResponseValue: UILabel!
    @IBOutlet weak var totalResponseNumber: UILabel!
    var socketManager: SocketIOManager!
    @IBOutlet weak var stopContainer: UIView!
    @IBOutlet weak var startContainer: UIView!
    @IBOutlet weak var containerView: UIView!
    var graphView = GraphView()
    let realm = try! Realm()
    var storedValues = List<ServerValue>()
    var valueForChart = [Int]()
    override func viewDidLoad() {
        super.viewDidLoad()
        socketManager = SocketIOManager(controller: self)
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
    
    
    //Get the values straight from Realm.
    func updateFromRealm(){
        let valueList: Results<ServerValue> = {self.realm.objects(ServerValue.self)}()
        self.storedValues = List(valueList)
        if (self.storedValues.count != 0){
            if storedValues.count > 9 {
                self.totalResponseNumber.text = String(storedValues.count)
                fetchLastTenItems()
                return
            }
            populateChart()
        }
    }
    
    
    @IBAction func startServer(_ sender: Any) {
        self.socketManager.establishConnection()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.stopContainer.transform = .identity
        }, completion: nil)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    @IBAction func stopServer(_ sender: Any) {
        self.socketManager.stopConnection()
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.stopContainer.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height / 2)
        }, completion: nil)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
    //This method is called from the SocketIOManager class to update Realm
    func addToRealm(currentValue: Int){
        let valueObject = ServerValue()
        valueObject.value = currentValue
        valueObject.id = UUID().uuidString
        valueObject.save()
        let valueList: Results<ServerValue> = {self.realm.objects(ServerValue.self)}()
        self.storedValues = List(valueList)
        self.currentResponseValue.text = String(valueObject.value)
        self.totalResponseNumber.text = String(storedValues.count)
        if storedValues.count > 9 {
            fetchLastTenItems()
            return
        }
        
        
        self.valueForChart.append(valueObject.value)
        populateChart()
        
    }
    
    //If there are more than 10 values stored in Realm, we fetch the last 10 values to build the Chart
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
    
    @IBAction func clearHistoryButtonPressed(_ sender: Any) {
        clearHistory()
    }
    
    func clearHistory(){
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
            updateFromRealm()
        }
    }
    
}
