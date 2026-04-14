//
//  ThemeStore.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-04-13.
//

import CoreData
import SwiftUI

final class ThemeStore {
    static let shared = ThemeStore()

    private let context = PersistenceController.shared.container.viewContext

    private let keyId = "main"

    func loadColor() -> String {
        let request = AppTheme.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", keyId)

        if let result = try? context.fetch(request).first {
            return result.backgroundColor ?? "#1C1C1E"
        }

        return "#1C1C1E"
    }

 
    func saveColor(_ hex: String) {
        let request = AppTheme.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", keyId)

        let theme = (try? context.fetch(request).first) ?? AppTheme(context: context)

        theme.id = keyId
        theme.backgroundColor = hex

        try? context.save()
    }
}
