//
//  BookmarksClient.swift
//  EggTimer
//

import ComposableArchitecture
import Foundation

// UserDefaults에 북마크한 레시피 id를 저장/로드한다
struct BookmarksClient: Sendable {
    // 저장된 북마크 id 집합을 읽어온다
    var load: @Sendable () -> Set<String>
    // 북마크 id 집합을 저장한다
    var save: @Sendable (Set<String>) -> Void
}

extension BookmarksClient: DependencyKey {
    static let liveValue = BookmarksClient(
        load: {
            Set(UserDefaults.standard.stringArray(forKey: "bookmarkedRecipeIDs") ?? [])
        },
        save: { ids in
            UserDefaults.standard.set(Array(ids), forKey: "bookmarkedRecipeIDs")
        }
    )
}

extension DependencyValues {
    var bookmarks: BookmarksClient {
        get { self[BookmarksClient.self] }
        set { self[BookmarksClient.self] = newValue }
    }
}
