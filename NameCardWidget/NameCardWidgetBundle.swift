//
//  NameCardWidgetBundle.swift
//  NameCardWidget
//
//  Created by Harry Ng on 10/1/25.
//

import WidgetKit
import SwiftUI

@main
struct NameCardWidgetBundle: WidgetBundle {
    var body: some Widget {
        RandomContactWidget()
        CategoryChartWidget()
    }
}
