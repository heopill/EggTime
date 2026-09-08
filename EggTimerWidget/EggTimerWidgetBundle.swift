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
        // Control 위젯은 iOS 18.0 이상에서만 지원된다
        if #available(iOS 18.0, *) {
            EggTimerWidgetControl()
        }
        EggTimerWidgetLiveActivity()
    }
}
