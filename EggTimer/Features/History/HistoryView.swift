//
//  HistoryView.swift
//  EggTimer
//

import SwiftUI
import ComposableArchitecture

struct HistoryView: View {
    @Bindable var store: StoreOf<HistoryFeature>

    var body: some View {
        Text("기록 화면")
    }
}

#Preview {
    HistoryView(
        store: Store(initialState: HistoryFeature.State()) {
            HistoryFeature()
        }
    )
}
