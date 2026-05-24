//
//  BulkInvoicePeriodSelector.swift
//  TaskGator
//
//  Dialog per selezionare il periodo di download bulk invoices
//

import SwiftUI

/// Tipo di periodo selezionabile
enum InvoicePeriod {
    case lastWeek
    case lastMonth
    case custom(from: Date, to: Date)

    var apiValue: String {
        switch self {
        case .lastWeek: return "last_week"
        case .lastMonth: return "last_month"
        case .custom: return "custom"
        }
    }

    var displayName: String {
        switch self {
        case .lastWeek: return "Ultima settimana"
        case .lastMonth: return "Ultimo mese"
        case .custom: return "Periodo personalizzato"
        }
    }

    func dateRange() -> (from: String?, to: String?) {
        switch self {
        case .custom(let from, let to):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return (formatter.string(from: from), formatter.string(from: to))
        default:
            return (nil, nil)
        }
    }
}

/// Sheet per selezionare il periodo di download bulk invoices
struct BulkInvoicePeriodSelector: View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var isPresented: Bool
    let onPeriodSelected: (InvoicePeriod) -> Void

    @State private var showCustomDatePicker = false
    @State private var customDateFrom = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    @State private var customDateTo = Date()

    var body: some View {
        NavigationView {
            List {
                Section {
                    // Ultima settimana
                    Button {
                        onPeriodSelected(.lastWeek)
                        isPresented = false
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(SwiftUI.Color(red: 0.0, green: 0.75, blue: 0.44, opacity: 1.0))
                                .frame(width: 30)
                            Text("Ultima settimana")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                    }

                    // Ultimo mese
                    Button {
                        onPeriodSelected(.lastMonth)
                        isPresented = false
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(SwiftUI.Color(red: 0.0, green: 0.75, blue: 0.44, opacity: 1.0))
                                .frame(width: 30)
                            Text("Ultimo mese")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                    }

                    // Periodo personalizzato
                    Button {
                        showCustomDatePicker.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(SwiftUI.Color(red: 0.0, green: 0.75, blue: 0.44, opacity: 1.0))
                                .frame(width: 30)
                            Text("Periodo personalizzato")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: showCustomDatePicker ? "chevron.up" : "chevron.down")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                    }

                    // Date pickers per periodo personalizzato
                    if showCustomDatePicker {
                        VStack(alignment: .leading, spacing: 16) {
                            // Data inizio
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Data inizio")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                DatePicker(
                                    "",
                                    selection: $customDateFrom,
                                    in: ...customDateTo,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                            }

                            // Data fine
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Data fine")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                DatePicker(
                                    "",
                                    selection: $customDateTo,
                                    in: customDateFrom...Date(),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                            }

                            // Pulsante conferma
                            Button {
                                onPeriodSelected(.custom(from: customDateFrom, to: customDateTo))
                                isPresented = false
                            } label: {
                                Text("Conferma")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(SwiftUI.Color(red: 0.0, green: 0.75, blue: 0.44, opacity: 1.0))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Seleziona periodo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Annulla") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct BulkInvoicePeriodSelector_Previews: PreviewProvider {
    static var previews: some View {
        BulkInvoicePeriodSelector(isPresented: .constant(true)) { period in
            print("Selected period: \(period.displayName)")
        }
    }
}
