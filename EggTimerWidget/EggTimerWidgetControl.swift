//
//  EggTimerWidgetControl.swift
//  EggTimerWidget
//
//  Created by 허성필 on 8/25/26.
//

import AppIntents
import SwiftUI
import WidgetKit

@available(iOS 18.0, *)
struct EggTimerWidgetControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "dev.seongpil.EggTimer.EggTimerWidget",
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Start Timer",
                isOn: value,
                action: StartTimerIntent()
            ) { isRunning in
                Label(isRunning ? "On" : "Off", systemImage: "timer")
            }
        }
        .displayName("Timer")
        .description("A an example control that runs a timer.")
    }
}

@available(iOS 18.0, *)
extension EggTimerWidgetControl {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }

        func currentValue() async throws -> Bool {
            let isRunning = true // Check if the timer is running
            return isRunning
        }
    }
}

struct StartTimerIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Start a timer"

    @Parameter(title: "Timer is running")
    var value: Bool

    func perform() async throws -> some IntentResult {
        // Start / stop the timer based on `value`.
        return .result()
    }
}
