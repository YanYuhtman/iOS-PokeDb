//
//  Environment.swift
//  PokeDb
//
//  Created by Yan  on 27/12/2025.
//
import SwiftUI

private struct IsInPreviewModeKey : EnvironmentKey{
    static let defaultValue: Bool = false
}
extension EnvironmentValues{
    var isInPreviewMode:Bool{
        get {self[IsInPreviewModeKey.self]}
        set {self[IsInPreviewModeKey.self] = newValue}
    }
}
