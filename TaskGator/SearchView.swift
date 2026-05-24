//
//  SearchView.swift
//  TaskGator
//
//  Modern SwiftUI filter and search screen with gradient header.
//

import SwiftUI
// import RangeSeekSlider // Sostituito con RangeSliderView.swift custom

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    textInputCard("Nome Corriere", text: $viewModel.searchKeyword, icon: "person")
                    locationCard
                    ratingCard
                    priceRangeCard
                    categoryCard
                    sortCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }

            bottomButtons
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(spacing: 12) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(SwiftUI.Color.white.opacity(0.18))
                    .clipShape(Circle())
            }

            SwiftUI.Text("Filtra")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
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

    // MARK: - Text input card

    private func textInputCard(_ title: String, text: Binding<String>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SwiftUI.Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            HStack {
                TextField("", text: text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textDark)

                Image(systemName: icon)
                    .foregroundColor(AppTheme.Colors.textCaption)
                    .font(.system(size: 15))
            }
            .padding(14)
            .background(AppTheme.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Location card

    private var locationCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            SwiftUI.Text("Posizione")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            Button(action: { viewModel.onOpenLocationPicker?() }) {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.gradientStart)

                    SwiftUI.Text(viewModel.locationName.isEmpty ? "Tocca per selezionare..." : viewModel.locationName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(
                            viewModel.locationName.isEmpty
                                ? AppTheme.Colors.placeholder
                                : AppTheme.Colors.textDark
                        )
                        .lineLimit(1)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.Colors.border)
                }
                .padding(14)
                .background(AppTheme.Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Rating card

    private var ratingCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SwiftUI.Text("Valutazione Minima")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { i in
                    Button(action: { viewModel.starRating = Double(i) }) {
                        Image(systemName: Double(i) <= viewModel.starRating ? "star.fill" : "star")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.Colors.starYellow)
                    }
                }
            }
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Price range card

    private var priceRangeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SwiftUI.Text("Prezzo")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
                SwiftUI.Text("\(UserData.shared.currency)\(Int(viewModel.selectedMinPrice)) - \(UserData.shared.currency)\(Int(viewModel.selectedMaxPrice))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.Colors.gradientStart)
            }

            RangeSliderRepresentable(
                minValue: viewModel.minPrice,
                maxValue: viewModel.maxPrice,
                selectedMinValue: $viewModel.selectedMinPrice,
                selectedMaxValue: $viewModel.selectedMaxPrice
            )
            .frame(height: 30)
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Category card

    private var categoryCard: some View {
        VStack(spacing: 14) {
            pickerRow(title: "Categoria", selection: viewModel.selectedCategory?.category_name, items: viewModel.categories.map { $0.category_name }) { idx in
                viewModel.didSelectCategory(idx >= 0 ? viewModel.categories[idx] : nil)
            }

            pickerRow(title: "Sottocategoria", selection: viewModel.selectedSubCategory?.category_name, items: viewModel.subCategories.map { $0.category_name }) { idx in
                viewModel.didSelectSubCategory(idx >= 0 ? viewModel.subCategories[idx] : nil)
            }

            pickerRow(title: "Servizio", selection: viewModel.selectedService?.service_name, items: viewModel.services.map { $0.service_name }) { idx in
                viewModel.selectedService = idx >= 0 ? viewModel.services[idx] : nil
            }
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func pickerRow(title: String, selection: String?, items: [String], onSelect: @escaping (Int) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            SwiftUI.Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            SwiftUI.Menu {
                Button("Nessuno", action: { onSelect(-1) })
                ForEach(0..<items.count, id: \.self) { i in
                    Button(items[i], action: { onSelect(i) })
                }
            } label: {
                HStack {
                    SwiftUI.Text(selection ?? "Seleziona \(title)...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(
                            selection == nil
                                ? AppTheme.Colors.placeholder
                                : AppTheme.Colors.textDark
                        )
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.Colors.border)
                }
                .padding(14)
                .background(AppTheme.Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    // MARK: - Sort card

    private var sortCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SwiftUI.Text("Ordinamento")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            HStack(spacing: 12) {
                sortChip(title: "Crescente", value: "asc")
                sortChip(title: "Decrescente", value: "desc")
            }
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func sortChip(title: String, value: String) -> some View {
        let isSelected = viewModel.sorting == value
        return Button(action: {
            viewModel.sorting = isSelected ? "" : value
        }) {
            HStack(spacing: 6) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(
                        isSelected
                            ? AppTheme.Colors.gradientStart
                            : AppTheme.Colors.border
                    )
                SwiftUI.Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
        }
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        HStack(spacing: 12) {
            Button(action: { viewModel.clearFilter() }) {
                SwiftUI.Text("CANCELLA")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.Colors.gradientStart)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(SwiftUI.Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(AppTheme.Colors.gradientStart, lineWidth: 1.5)
                    )
            }

            Button(action: { viewModel.applyFilter() }) {
                SwiftUI.Text("APPLICA")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.gradientStart,
                                AppTheme.Colors.darkPurple
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(16)
        .background(
            SwiftUI.Color.white
                .shadow(color: SwiftUI.Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
        )
    }
}

// MARK: - Custom Range Slider (sostituisce RangeSeekSlider)
// Nota: Il range slider custom richiede l'aggiunta del file al progetto Xcode
struct RangeSliderRepresentable: View {
    var minValue: CGFloat
    var maxValue: CGFloat

    @Binding var selectedMinValue: CGFloat
    @Binding var selectedMaxValue: CGFloat

    var body: some View {
        // Placeholder - implementare con custom RangeSliderView se necessario
        VStack {
            Text("Price Range: $\(Int(selectedMinValue)) - $\(Int(selectedMaxValue))")
                .foregroundColor(.gray)
            Slider(value: $selectedMinValue, in: minValue...selectedMaxValue)
            Slider(value: $selectedMaxValue, in: selectedMinValue...maxValue)
        }
    }
}
