//
//  FirstLoginOnboardingView.swift
//  TaskGator
//
//  SwiftUI wizard for first-login onboarding.
//  Shows a step indicator header and embeds existing profile/service views.
//

import SwiftUI

struct FirstLoginOnboardingView: View {

    @ObservedObject var onboardingVM: FirstLoginOnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            onboardingHeader
            stepContent
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }

    // MARK: - Onboarding Header

    private var onboardingHeader: some View {
        VStack(spacing: 12) {
            // Back button + Title
            ZStack {
                // Centered title
                VStack(spacing: 4) {
                    SwiftUI.Text(onboardingVM.stepTitle)
                        .font(AppTheme.Fonts.bold(22))
                        .foregroundColor(.white)

                    if onboardingVM.totalSteps > 1 {
                        SwiftUI.Text(onboardingVM.stepSubtitle)
                            .font(AppTheme.Fonts.regular(14))
                            .foregroundColor(SwiftUI.Color.white.opacity(0.7))
                    }
                }

                // Left-aligned back button
                if onboardingVM.currentStep > 0 {
                    HStack {
                        Button(action: { onboardingVM.goBackToPreviousStep() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(SwiftUI.Color.white.opacity(0.18))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                }
            }

            // Progress bar
            StepProgressBar(
                currentStep: onboardingVM.currentStep,
                totalSteps: onboardingVM.totalSteps,
                labels: onboardingVM.stepLabels
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
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

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        if onboardingVM.currentStep == 0 {
            profileStep
        } else if onboardingVM.currentStep == 1 {
            servicesStep
        } else {
            stripeStep
        }
    }

    @ViewBuilder
    private var profileStep: some View {
        if onboardingVM.userType == "c", let vm = onboardingVM.editCustomerVM {
            EditProfileCustomerView(viewModel: vm, showHeader: false)
        } else if let vm = onboardingVM.editProviderVM {
            EditProfileProviderView(viewModel: vm, showHeader: false)
        }
    }

    @ViewBuilder
    private var servicesStep: some View {
        if let vm = onboardingVM.addServiceVM {
            AddServiceView(viewModel: vm, showHeader: false)
        }
    }

    @ViewBuilder
    private var stripeStep: some View {
        if let vm = onboardingVM.stripeConnectVM {
            StripeConnectOnboardingView(viewModel: vm)
        }
    }
}

// MARK: - Step Progress Bar

private struct StepProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    let labels: [String]

    var body: some View {
        VStack(spacing: 6) {
            // Bar segments
            HStack(spacing: 4) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentStep
                              ? AppTheme.Colors.orange
                              : SwiftUI.Color.white.opacity(0.25))
                        .frame(height: 4)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }

            // Labels
            if labels.count > 1 {
                HStack {
                    ForEach(0..<labels.count, id: \.self) { index in
                        if index > 0 { Spacer() }
                        SwiftUI.Text(labels[index])
                            .font(AppTheme.Fonts.medium(11))
                            .foregroundColor(index <= currentStep
                                             ? SwiftUI.Color.white
                                             : SwiftUI.Color.white.opacity(0.5))
                    }
                }
            }
        }
    }
}
