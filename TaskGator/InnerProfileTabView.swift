//
//  InnerProfileTabView.swift
//  TaskGator
//
//  Profile tab for ServiceDetailView — about, address, stats, basic info.
//

import SwiftUI

struct InnerProfileTabView: View {
    @ObservedObject var viewModel: ServiceDetailViewModel

    var body: some View {
        ScrollView {
            if let profile = viewModel.providerProfile {
                VStack(spacing: 14) {
                    // About
                    sectionCard(
                        title: "Chi Sono",
                        icon: "person.text.rectangle",
                        content: profile.description.isEmpty
                            ? "Non ci sono informazioni da mostrare."
                            : profile.description
                    )

                    // Lavori Svolti
                    statBox(
                        icon: "briefcase.fill",
                        value: profile.task_assigned,
                        label: "Lavori Svolti"
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            } else {
                VStack {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)
            }
        }
    }

    // MARK: - Section card

    private func sectionCard(title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.Colors.gradientStart)
                SwiftUI.Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }

            SwiftUI.Text(content)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(AppTheme.Colors.textDisabled)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Stat box

    private func statBox(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(AppTheme.Colors.gradientStart)

            SwiftUI.Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.Colors.gradientStart)

            SwiftUI.Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.Colors.textCaption)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

}
