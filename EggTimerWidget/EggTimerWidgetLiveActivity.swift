//
//  EggTimerWidgetLiveActivity.swift
//  EggTimerWidget
//
//  Created by 허성필 on 8/25/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct EggTimerWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct EggTimerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EggTimerWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension EggTimerWidgetAttributes {
    fileprivate static var preview: EggTimerWidgetAttributes {
        EggTimerWidgetAttributes(name: "World")
    }
}

extension EggTimerWidgetAttributes.ContentState {
    fileprivate static var smiley: EggTimerWidgetAttributes.ContentState {
        EggTimerWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: EggTimerWidgetAttributes.ContentState {
         EggTimerWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: EggTimerWidgetAttributes.preview) {
   EggTimerWidgetLiveActivity()
} contentStates: {
    EggTimerWidgetAttributes.ContentState.smiley
    EggTimerWidgetAttributes.ContentState.starEyes
}
