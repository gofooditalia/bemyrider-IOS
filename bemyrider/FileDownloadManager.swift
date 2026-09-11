//
//  FileDownloadManager.swift
//  bemyrider
//
//  Manager per scaricare file (PDF, ZIP) e salvarli in una posizione accessibile
//

import Foundation
import UIKit

/// Manager per gestire il download di file usando URLSession
class FileDownloadManager: NSObject {

    static let shared = FileDownloadManager()
    private override init() {
        super.init()
    }

    /// Scarica un file da URL e lo salva nella cartella Documents
    /// - Parameters:
    ///   - urlString: URL del file da scaricare
    ///   - maxRetries: Numero di tentativi aggiuntivi in caso di errore di rete transitorio
    ///     (connessione persa, timeout). Il download è una GET idempotente, quindi ritentare è sicuro.
    ///   - completion: Callback con il percorso locale del file scaricato o errore
    func downloadFile(from urlString: String, maxRetries: Int = 2, completion: @escaping (Swift.Result<URL, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FileDownloadManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL non valido"])))
            return
        }

        performDownload(url: url, attempt: 0, maxRetries: maxRetries, completion: completion)
    }

    private func performDownload(url: URL, attempt: Int, maxRetries: Int, completion: @escaping (Swift.Result<URL, Error>) -> Void) {
        let configuration = URLSessionConfiguration.default
        // Se la rete manca per qualche istante (es. cambio cella), attende invece di fallire subito.
        configuration.waitsForConnectivity = true
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

        let downloadTask = session.downloadTask(with: url) { [weak self] tempLocalUrl, response, error in
            if let error = error {
                if let self = self, attempt < maxRetries, URLError.isTransient(error) {
                    #if DEBUG
                    print("FileDownloadManager: download failed with '\(error.localizedDescription)' – retry \(attempt + 1)/\(maxRetries)")
                    #endif
                    let delay = Double(attempt + 1) * 2.0
                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        self.performDownload(url: url, attempt: attempt + 1, maxRetries: maxRetries, completion: completion)
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let tempLocalUrl = tempLocalUrl else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "FileDownloadManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "File temporaneo non trovato"])))
                }
                return
            }

            do {
                // Ottieni la cartella Documents
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

                // Estrai il nome del file dall'URL
                let fileName = url.lastPathComponent

                // Crea il percorso di destinazione
                let destinationURL = documentsPath.appendingPathComponent(fileName)

                // Rimuovi il file esistente se presente
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }

                // Sposta il file temporaneo nella destinazione finale
                try FileManager.default.moveItem(at: tempLocalUrl, to: destinationURL)

                DispatchQueue.main.async {
                    completion(.success(destinationURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        downloadTask.resume()
    }

    /// Presenta l'activity view controller per condividere/aprire il file
    /// - Parameters:
    ///   - fileURL: URL locale del file da condividere
    ///   - viewController: View controller da cui presentare l'activity controller
    func presentShareSheet(for fileURL: URL, from viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)

        // Per iPad, configura il popover
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        viewController.present(activityViewController, animated: true)
    }
}

// MARK: - URLSessionDelegate

extension FileDownloadManager: URLSessionDelegate, URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // Questo metodo è richiesto dal protocollo ma la logica è gestita nel completion handler
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // Opzionale: può essere usato per mostrare una progress bar
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        #if DEBUG
        print("Download progress: \(Int(progress * 100))%")
        #endif
    }
}
