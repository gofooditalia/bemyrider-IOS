import SwiftUI

struct ProviderEditServiceCardView: View {
    let categoryName: String
    let price: String
    let currency: String
    let totalService: String
    let serviceDescription: String
    let serviceMasterType: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Modifica Servizio")
                .font(AppTheme.Fonts.bold(16))
                .foregroundColor(AppTheme.Colors.charcoalGrey)
            
            VStack(spacing: 12) {
                infoRow(title: "Categoria".localized, value: categoryName.isEmpty ? "N/A" : categoryName)
                
                Divider()
                    .background(AppTheme.Colors.charcoalGrey.opacity(0.1))
                
                HStack {
                    Text("Tariffa".localized)
                        .font(AppTheme.Fonts.medium(14))
                        .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(currency)\(price)\(serviceMasterType == "hourly" ? " / Ora" : "")")
                        .font(AppTheme.Fonts.bold(15))
                        .foregroundColor(AppTheme.Colors.orange)
                }
                
                Divider()
                    .background(AppTheme.Colors.charcoalGrey.opacity(0.1))
                
                infoRow(title: "Totale Servizi".localized, value: totalService.isEmpty ? "N/A" : totalService)
                
                if !serviceDescription.isEmpty {
                    Divider()
                        .background(AppTheme.Colors.charcoalGrey.opacity(0.1))
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Descrizione Servizio".localized)
                            .font(AppTheme.Fonts.medium(14))
                            .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.7))
                        
                        Text(serviceDescription)
                            .font(AppTheme.Fonts.regular(13))
                            .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(16)
        .background(SwiftUI.Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(AppTheme.Fonts.medium(14))
                .foregroundColor(AppTheme.Colors.charcoalGrey.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(AppTheme.Fonts.regular(14))
                .foregroundColor(AppTheme.Colors.charcoalGrey)
        }
    }
}
