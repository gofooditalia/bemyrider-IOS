//
//  BulkInvoiceDownloadViewModel.swift
//  bemyrider
//
//  ViewModel per gestire il download multiplo di ricevute (bulk invoices)
//

import SwiftUI
import Combine

@MainActor
class BulkInvoiceDownloadViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var showPeriodSelector = false
    @Published var errorMessage: String?

    /// Avvia il processo di download bulk invoices
    func startBulkDownload() {
        showPeriodSelector = true
    }

    /// Gestisce la selezione del periodo e avvia il download
    /// - Parameter period: Periodo selezionato dall'utente
    func handlePeriodSelection(_ period: InvoicePeriod) {
        Task {
            await downloadBulkInvoices(for: period)
        }
    }

    /// Esegue il download bulk invoices per il periodo specificato
    /// - Parameter period: Periodo per cui scaricare le ricevute
    private func downloadBulkInvoices(for period: InvoicePeriod) async {
        isLoading = true
        errorMessage = nil

        do {
            let (dateFrom, dateTo) = period.dateRange()

            // Chiamata API per ottenere il file ZIP
            let response = try await APIClient.shared.downloadBulkInvoices(
                period: period.apiValue,
                dateFrom: dateFrom,
                dateTo: dateTo
            )

            guard let fileName = response["file_name"] as? String,
                  let count = response["count"] as? Int else {
                throw NSError(domain: "BulkInvoiceDownload", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Risposta server non valida"
                ])
            }

            // Download del file ZIP
            try await downloadZipFile(from: fileName, invoiceCount: count)

        } catch let error as APIError {
            errorMessage = error.message
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Scarica il file ZIP e lo salva localmente
    /// - Parameters:
    ///   - urlString: URL del file ZIP sul server
    ///   - invoiceCount: Numero di ricevute nel file ZIP
    private func downloadZipFile(from urlString: String, invoiceCount: Int) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            FileDownloadManager.shared.downloadFile(from: urlString) { [weak self] result in
                guard let self = self else { return }

                Task { @MainActor in
                    switch result {
                    case .success(let fileURL):
                        // Apre direttamente lo Share Sheet senza alert intermedio
                        self.presentShareSheet(for: fileURL)
                        continuation.resume()

                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    /// Presenta il share sheet per il file scaricato
    /// - Parameter fileURL: URL locale del file
    private func presentShareSheet(for fileURL: URL) {
        // Ottieni il top view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }

        var topViewController = rootViewController
        while let presented = topViewController.presentedViewController {
            topViewController = presented
        }

        FileDownloadManager.shared.presentShareSheet(for: fileURL, from: topViewController)
    }

    /// Resetta i messaggi di errore/successo
    func clearMessages() {
        errorMessage = nil
    }
}
