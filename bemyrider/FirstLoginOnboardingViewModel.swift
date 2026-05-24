//
//  FirstLoginOnboardingViewModel.swift
//  bemyrider
//
//  Orchestrates the first-login onboarding wizard steps.
//  Holds references to the existing child ViewModels without duplicating logic.
//

import SwiftUI

@MainActor
final class FirstLoginOnboardingViewModel: ObservableObject {

    // MARK: - Step state

    @Published var currentStep: Int = 0

    let userType: String          // "c" or "p"
    var totalSteps: Int { userType == "c" ? 1 : 3 }

    var stepTitle: String {
        if userType == "c" || currentStep == 0 {
            return "Completa il tuo profilo"
        } else if currentStep == 1 {
            return "Aggiungi un servizio"
        } else {
            return "Ricevi pagamenti"
        }
    }

    var stepSubtitle: String {
        return "Passo \(currentStep + 1) di \(totalSteps)"
    }

    var stepLabels: [String] {
        if userType == "c" {
            return ["Profilo"]
        } else {
            return ["Profilo", "Servizi", "Pagamenti"]
        }
    }

    // MARK: - Child ViewModels (created by HostingVC)

    var editProviderVM: EditProfileProviderViewModel?
    var editCustomerVM: EditProfileCustomerViewModel?
    var myServicesVM: MyServicesViewModel?
    var addServiceVM: AddServiceViewModel?
    var stripeConnectVM: StripeConnectOnboardingViewModel?

    // MARK: - Callbacks (wired by HostingVC)

    var onComplete: (() -> Void)?

    // MARK: - Actions

    func advanceToNextStep() {
        // Save that the current step is completed
        UserData.shared.setOnboardingCompletedStep(currentStep)

        if currentStep < totalSteps - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
            // Fetch Stripe URL when entering step 3
            if currentStep == 2 {
                stripeConnectVM?.fetchConnectURL()
            }
        } else {
            finish()
        }
    }

    func goBackToPreviousStep() {
        guard currentStep > 0 else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep -= 1
        }
    }

    func finish() {
        // Mark onboarding as fully complete
        UserData.shared.setOnboardingCompletedStep(totalSteps)
        onComplete?()
    }

    /// Resume from the step after the last completed one
    func resumeFromSavedProgress() {
        let completed = UserData.shared.onboardingCompletedStep
        if completed >= 0 && completed < totalSteps {
            currentStep = completed + 1
            // Trigger Stripe fetch if resuming to step 3
            if currentStep == 2 {
                stripeConnectVM?.fetchConnectURL()
            }
        }
    }

    // MARK: - Init

    init(userType: String) {
        self.userType = userType
    }
}
