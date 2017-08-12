//
//  GraphView.swift
//  AvantariApp
//
//  Created by Swathy Sudarsanan on 12/08/17.
//  Copyright © 2017 BladeSilver. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class GraphView: UIView, ChartViewDelegate {
    let realm = try! Realm()
    var lineChart = LineChartView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        lineChart.delegate = self
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //Update the values of the chart with Values passed from the Controller Object (HomeController)
    func update(values: List<ServerValue>, frame: CGRect){
        print("Values count: \(values.count)")
        let gradientColors = [UIColor.cyan.cgColor, UIColor.cyan.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor] as CFArray
        let colorLocations:[CGFloat] = [1.0, 0.58, 0.57, 0.0]
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
        var yValues : [ChartDataEntry] = [ChartDataEntry]()
        
        for i in 0 ..< values.count {
            yValues.append(ChartDataEntry(x: Double(i + 1), y: Double(values[i].value)))
        }
        
        let data = LineChartData()
        let ds = LineChartDataSet(values: yValues, label: nil)
        ds.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
        ds.drawFilledEnabled = true
        ds.drawCirclesEnabled = false
        
        data.addDataSet(ds)
        self.lineChart.data?.clearValues()
        self.lineChart.data = data
        self.addSubview(self.lineChart)
        //        self.lineChart.animate(xAxisDuration: 0.2, easing: nil)
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        lineChart.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        lineChart.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        lineChart.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        lineChart.leftAxis.axisMaximum = 12
        lineChart.autoresizesSubviews = false
        lineChart.chartDescription?.text = ""
        lineChart.data?.notifyDataChanged()
        lineChart.notifyDataSetChanged()
        
        
        
    }
    
    
}
