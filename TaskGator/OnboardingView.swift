import SwiftUI

struct OnboardingView: View {

    private static let themeOrange = AppTheme.Colors.orange

    struct Page {
        let topImage: String?
        let middleImage: String
        let bottomImage: String?
        let text: String
    }

    private let pages: [Page] = [
        Page(topImage: "onboarding_1_top",
             middleImage: "onboarding_1_middle",
             bottomImage: nil,
             text: "Benvenuto nella prima community di riders autonomi della tua città"),
        Page(topImage: nil,
             middleImage: "onboarding_1_middle",
             bottomImage: "onboarding_2_bottom",
             text: "Rider che cerchi, professionista che trovi"),
        Page(topImage: nil,
             middleImage: "onboarding_1_middle",
             bottomImage: "onboarding_3_bottom",
             text: "Leggi le recensioni, confronta il servizio e scegli il rider piu adatto alle tue esigenze"),
        Page(topImage: nil,
             middleImage: "onboarding_1_middle",
             bottomImage: "onboarding_4_bottom",
             text: "Chatta col tuo rider in tempo reale per una gestione puntuale del servizio"),
        Page(topImage: nil,
             middleImage: "onboarding_1_middle",
             bottomImage: "onboarding_5_bottom",
             text: "Una guest Programmazione e la chiave per ogni business di successo"),
    ]

    @State private var currentPage = 0
    var onSkip: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background(SwiftUI.Color.white)

            HStack {
                Spacer()
                Button("SKIP") { onSkip() }
                    .font(.custom("Roboto-Medium", size: 16))
                    .foregroundColor(AppTheme.Colors.placeholder)
                    .padding(.trailing, 20)
            }
            .padding(.top, 20)

            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Self.themeOrange : Self.themeOrange.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 50)
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingView.Page

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            if let topImage = page.topImage {
                VStack(spacing: 38) {
                    Image(topImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 220)
                    Image(page.middleImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 60)
                }
                .padding(.horizontal, 35)
            } else {
                Image(page.middleImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 60)
                    .padding(.horizontal, 35)
            }

            Spacer().frame(height: 25)

            Text(page.text)
                .font(.system(size: 24))
                .foregroundColor(SwiftUI.Color.black)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 50)

            if let bottomImage = page.bottomImage {
                Spacer().frame(height: 20)
                Image(bottomImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 280)
                    .padding(.horizontal, 20)
            }

            Spacer().frame(height: 80)
        }
    }
}
