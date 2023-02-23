//
//  Charts.swift
//  BLE Tool
//
//  Created by William Chen on 2023/2/23.
//

import SwiftUI
import Charts

struct DistanceChart: View {
    
    var capturedSignals : [DistanceReadings]
    let symbolSize: CGFloat = 100
    let lineWidth: CGFloat = 3
    
    var minDistance: Float = 0.0
    var maxDistance: Float = 10.0
    
    var minReading: DistanceReadings?
    var maxReading: DistanceReadings?
    
    var body: some View {
        
        VStack {
            
            Chart {
                ForEach(capturedSignals, id: \.time) { element in
                    LineMark(
                        x: .value("Time", element.time, unit: .second),
                        y: .value("Distance", element.distance)
                    )
                }
//                .foregroundStyle(by: .value("City", "RSSI Values")) //Comment below out for only line, and uncomment RSSI values in ChartForeGround
                .symbol(by: .value("City", "Distance Values"))
                
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: lineWidth))
                .symbolSize(symbolSize)
                
                if let maxReading = maxReading, let minReading = minReading {
                    PointMark(
                        x: .value("Time", maxReading.time, unit: .second),
                        y: .value("Distance", maxReading.distance)
                    )
                    .foregroundStyle(.purple)
                    .symbolSize(symbolSize)
                    
                    PointMark(
                        x: .value("Time", minReading.time, unit: .second),
                        y: .value("Distance", minReading.distance)
                    )
                    .foregroundStyle(.red)
                    .symbolSize(symbolSize)
                }
                
                
            }.frame(height: 300)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic) { value in
                        AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 1))
                        AxisValueLabel() {
                            if let val = value.as(Double.self) {
                                Text(String(format: "%.2fm", val))
                                .font(.system(size: 10))
                            }
                        }
                    }
            }
            .chartYScale(domain: minDistance...maxDistance)
            .chartForegroundStyleScale([
                    //"RSSI Values": Color.blue,
                    "Minimum": Color.red,
                    "Maximum": Color.purple
                ])
        }
//        .chartForegroundStyleScale([
//            "San Francisco": .purple,
//            "Cupertino": .green
//        ])
    }
}

struct DistanceCharts_Previews: PreviewProvider {
    static var previews: some View {
        let capturedSignals = [DistanceReadings(time: Date.now, distance: 1.8),
                               DistanceReadings(time: Date.now + 1, distance: 0.6),
                               DistanceReadings(time: Date.now + 2, distance: 2.6),
                               DistanceReadings(time: Date.now + 3, distance: 2.9),
                               DistanceReadings(time: Date.now + 4, distance: 3.5)]
        
        let chart = DistanceChart(capturedSignals: capturedSignals)
    }
}
