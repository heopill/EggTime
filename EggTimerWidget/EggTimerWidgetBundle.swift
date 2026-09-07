//
//  EggTimerWidgetBundle.swift
//  EggTimerWidget
//
//  Created by 허성필 on 8/25/26.
//

import WidgetKit
import SwiftUI

@main
struct EggTimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        EggTimerWidget()
        EggTimerWidgetControl()
        EggTimerWidgetLiveActivity()
    }
}
