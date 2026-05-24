//
//  StripeCheckoutHostingVC.swift
//  bemyrider
//
//  UIKit wrapper for StripeCheckoutView (PaymentSheet flow)
//

import UIKit
import SwiftUI

final class StripeCheckoutHostingVC: UIViewController {

    // Set these before pushing
    var paymentIntentClientSecret: String = ""
    var totalAmountToCharge: String = ""
    var bookingAmount: String = ""
    var totalFees: String = ""
    var serviceRequestId: String = ""

    private var viewModel: StripeCheckoutViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.16, green: 0.13, blue: 0.40, alpha: 1)

        viewModel = StripeCheckoutViewModel(
            clientSecret: paymentIntentClientSecret,
            bookingAmount: bookingAmount,
            totalFees: totalFees,
            totalAmount: totalAmountToCharge,
            serviceRequestId: serviceRequestId
        )
        viewModel.presentingVC = self

        viewModel.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        viewModel.onPaymentSuccess = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }

        embedView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func embedView() {
        let child = UIHostingController(rootView: StripeCheckoutView(viewModel: viewModel))
        addChildViewController(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(child.view)

        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        child.didMove(toParentViewController: self)
    }
}
