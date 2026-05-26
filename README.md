# 🛵 Bemyrider - iOS App

Applicazione nativa iOS per la gestione di servizi on-demand, dedicata a Rider e Provider.
Il progetto è attualmente in fase di **modernizzazione attiva** per aggiornare lo stack tecnologico agli standard del 2026.

Pipeline CI/CD attiva su Codemagic — ogni push su `main` produce automaticamente una build su TestFlight.

## 🛠 Tech Stack

Il progetto utilizza un'architettura ibrida UIKit/SwiftUI basata su pattern MVVM.

*   **Linguaggio**: Swift
*   **Architettura**: MVVM (Model-View-ViewModel)
*   **UI**: SwiftUI (nuove feature) + UIKit (componenti legacy), con `UIHostingController` come bridge
*   **Networking**: URLSession, Codable
*   **Immagini**: AlamofireImage
*   **Pagamenti**: Stripe SDK, StripePaymentSheet
*   **Mappe**: Google Places API
*   **Autenticazione**: Firebase, Facebook Login, Google Sign-In
*   **Notifiche**: NotificationBannerSwift
*   **Gestione dipendenze**: CocoaPods

## 🚀 Setup del Progetto

1.  **Clona il repository**:
    ```bash
    git clone https://github.com/gofooditalia/bemyrider-IOS.git
    ```
2.  **Installa le dipendenze**:
    ```bash
    cd bemyrider-IOS
    pod install
    ```
3.  **Apri il workspace** (non il `.xcodeproj`):
    ```bash
    open bemyrider.xcworkspace
    ```
4.  **Configurazione**:
    *   Assicurati di avere il file `GoogleService-Info.plist` nella cartella `bemyrider/`.
    *   Verifica che `credentials.plist` contenga le chiavi API necessarie.
    *   Copia `Debug.xcconfig.example` → `Debug.xcconfig` e `Release.xcconfig.example` → `Release.xcconfig` con le tue chiavi.

## 📈 Roadmap Modernizzazione

Stiamo lavorando per portare l'app verso uno stack puramente SwiftUI.

### Obiettivi Recenti Raggiunti
*   ✅ Migrazione splash screen a SwiftUI nativo (`SplashAnimationView`)
*   ✅ Rimozione dipendenza `lottie-ios` (incompatibile con iOS 26)
*   ✅ Sostituzione `RangeSeekSlider` con componente custom `RangeSliderView.swift`
*   ✅ Aggiornamento Stripe SDK alla versione 25.7
*   ✅ Rinominazione completa progetto da TaskGator/GoRider → bemyrider

## 🤝 Contribuire

Il ramo principale è `main`.
Per le nuove funzionalità, si prega di seguire lo standard SwiftUI e il pattern MVVM.

---
*Progetto gestito da GoFood Italia*
