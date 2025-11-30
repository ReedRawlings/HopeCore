//
//  HopeCoreWidgetBundle.swift
//  HopeCoreWidget
//
//  Created by Reed Rawlings on 11/30/25.
//
//  Widget Extension - Bundle Entry Point
//  AGENT NOTES:
//  - @main entry point for the widget extension
//  - Only includes HopeCoreWidget (Lock Screen widget)
//  - Control and LiveActivity are not used for this app
//

import WidgetKit
import SwiftUI

@main
struct HopeCoreWidgetBundle: WidgetBundle {
    var body: some Widget {
        HopeCoreWidget()
    }
}
