//
//  FloatingActionButton.swift
//  TaskGator
//
//  Floating Action Button component per iOS
//  Ispirato al FAB di Material Design (Android)
//

import SwiftUI

/// Floating Action Button (FAB) - pulsante circolare flottante
/// Utilizzato per azioni principali come download bulk invoices
struct FloatingActionButton: View {
    let icon: String
    let backgroundColor: SwiftUI.Color
    let foregroundColor: SwiftUI.Color
    let size: CGFloat
    let action: () -> Void

    init(
        icon: String = "arrow.down.circle.fill",
        backgroundColor: SwiftUI.Color = SwiftUI.Color(red: 0.0, green: 0.75, blue: 0.44, opacity: 1.0), // #00BF70 (tema verde app)
        foregroundColor: SwiftUI.Color = .white,
        size: CGFloat = 56,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(foregroundColor)
                .frame(width: size, height: size)
                .background(backgroundColor)
                .clipShape(Circle())
                .shadow(color: SwiftUI.Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(FABButtonStyle())
    }
}

/// Custom button style per FAB con animazione press
struct FABButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// View modifier per posizionare il FAB in basso a destra dello schermo
struct FABModifier: ViewModifier {
    let icon: String
    let action: () -> Void

    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content

            FloatingActionButton(icon: icon, action: action)
                .padding(.trailing, 16)
                .padding(.bottom, 16)
        }
    }
}

extension View {
    /// Aggiunge un Floating Action Button in basso a destra
    /// - Parameters:
    ///   - icon: Nome dell'icona SF Symbol (default: "arrow.down.circle.fill")
    ///   - action: Azione da eseguire al tap
    func floatingActionButton(icon: String = "arrow.down.circle.fill", action: @escaping () -> Void) -> some View {
        self.modifier(FABModifier(icon: icon, action: action))
    }
}

// MARK: - Preview

struct FloatingActionButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Schermata di esempio")
                .font(.largeTitle)
            Spacer()
        }
        .floatingActionButton {
            print("FAB tapped!")
        }
    }
}
