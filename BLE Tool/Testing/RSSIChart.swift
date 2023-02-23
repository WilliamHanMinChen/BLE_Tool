//
//  Charts.swift
//  BLE Tool
//
//  Created by William Chen on 2023/2/23.
//

import SwiftUI
import Charts

struct RSSIChart: View {
    
    var capturedSignals : [Readings]
    let symbolSize: CGFloat = 100
    let lineWidth: CGFloat = 3
    
    var minRSSIVal = -70
    var maxRSSIVal = -50
    
    var minReading: Readings?
    var maxReading: Readings?
    
    var body: some View {
        
        
        VStack {
            
            Chart {
                ForEach(capturedSignals, id: \.time) { element in
                    LineMark(
                        x: .value("Time", element.time, unit: .second),
                        y: .value("RSSI", element.RSSI)
                    )
                }
//                .foregroundStyle(by: .value("City", "RSSI Values")) //Comment below out for only line, and uncomment RSSI values in ChartForeGround
                .symbol(by: .value("City", "RSSI Values"))
                
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: lineWidth))
                .symbolSize(symbolSize)
                
                if let maxReading = maxReading, let minReading = minReading {
                    PointMark(
                        x: .value("Time", maxReading.time, unit: .second),
                        y: .value("RSSI", maxReading.RSSI)
                    )
                    .foregroundStyle(.purple)
                    .symbolSize(symbolSize)
                    
                    PointMark(
                        x: .value("Time", minReading.time, unit: .second),
                        y: .value("RSSI", minReading.RSSI)
                    )
                    .foregroundStyle(.red)
                    .symbolSize(symbolSize)
                }
                
                
            }.frame(height: 300)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartYScale(domain: minRSSIVal...maxRSSIVal)
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

struct Charts_Previews: PreviewProvider {
    static var previews: some View {
        let capturedSignals = [Readings(time: Date.now, RSSI: -64),
                               Readings(time: Date.now + 1, RSSI: -67),
                               Readings(time: Date.now + 2, RSSI: -65),
                               Readings(time: Date.now + 3, RSSI: -61),
                               Readings(time: Date.now + 4, RSSI: -63)]
        
        let chart = RSSIChart(capturedSignals: capturedSignals)
    }
}

//round up to x significant digits
func roundUp(_ num: Double, to places: Int) -> Double {
        let p = log10(abs(num))
        let f = pow(10, p.rounded(.up) - Double(places) + 1)
        let rnum = (num / f).rounded(.up) * f
        return rnum
    }
