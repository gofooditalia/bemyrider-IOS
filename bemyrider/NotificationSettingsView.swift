//
//  NotificationSettingsView.swift
//  bemyrider
//
//  Modernized SwiftUI view for Notification Settings with gradient header
//  and toggle cards.
//

import SwiftUI

struct NotificationSettingsView: View {

    @ObservedObject var viewModel: NotificationSettingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            contentArea
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear { viewModel.load() }
        .overlay(toastOverlay, alignment: .bottom)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 12) {
            Button(action: { viewModel.onBack?() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(SwiftUI.Color.white.opacity(0.18))
                    .clipShape(Circle())
            }

            SwiftUI.Text("Impostazioni Notifiche")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                colors: [
                    AppTheme.Colors.gradientStart,
                    AppTheme.Colors.gradientMid,
                    AppTheme.Colors.gradientEnd
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: - Content

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isLoading && viewModel.settings.isEmpty {
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        } else if viewModel.settings.isEmpty {
            emptyState
        } else {
            settingsList
        }
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppTheme.Colors.border)

            SwiftUI.Text("Nessuna impostazione disponibile")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.placeholder)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - List

    private var settingsList: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.settings) { setting in
                        settingRow(setting)

                        if setting.id != viewModel.settings.last?.id {
                            Divider()
                                .padding(.leading, 20)
                        }
                    }
                }
                .background(SwiftUI.Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 16)
            }

            saveButton
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
        }
    }

    // MARK: - Row

    private func settingRow(_ setting: NotificationSettingsViewModel.Setting) -> some View {
        HStack(spacing: 14) {
            SwiftUI.Text(setting.title)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Toggle("", isOn: Binding(
                get: { setting.isOn },
                set: { _ in viewModel.toggle(id: setting.id) }
            ))
            .labelsHidden()
            .toggleStyle(SwitchToggleStyle(tint: AppTheme.Colors.orange))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .onTapGesture { viewModel.toggle(id: setting.id) }
    }

    // MARK: - Save button

    private var saveButton: some View {
        Button {
            viewModel.save()
        } label: {
            HStack(spacing: 8) {
                if viewModel.isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                SwiftUI.Text("Salva modifiche")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [AppTheme.Colors.gradientStart, AppTheme.Colors.gradientEnd],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: AppTheme.Colors.gradientStart.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(viewModel.isSaving)
        .opacity(viewModel.isSaving ? 0.7 : 1)
    }

    // MARK: - Toast

    @ViewBuilder
    private var toastOverlay: some View {
        if let msg = viewModel.toastMessage {
            SwiftUI.Text(msg)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(AppTheme.Colors.textPrimary.opacity(0.9))
                .clipShape(Capsule())
                .padding(.bottom, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { viewModel.toastMessage = nil }
                    }
                }
                .animation(.easeInOut, value: viewModel.toastMessage)
        }
    }
}
