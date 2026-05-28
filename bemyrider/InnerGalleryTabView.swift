//
//  InnerGalleryTabView.swift
//  bemyrider
//
//  Gallery tab for ServiceDetailView — 2-column grid of service photos.
//

import SwiftUI

struct InnerGalleryTabView: View {
    @ObservedObject var viewModel: ServiceDetailViewModel

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            if let mediaData = viewModel.providerServiceDetail?.media_data, !mediaData.isEmpty {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<mediaData.count, id: \.self) { index in
                        let media = mediaData[index]
                        if !media.media_url.isEmpty {
                            RemoteImageView(media.media_url,
                                           contentMode: .scaleAspectFill,
                                           placeholder: UIImage(named: "Image-Place-Holder"))
                                .aspectRatio(1, contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(color: SwiftUI.Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                        } else {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AppTheme.Colors.mist)
                                .aspectRatio(1, contentMode: .fill)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 24, weight: .light))
                                        .foregroundColor(AppTheme.Colors.border)
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            } else {
                VStack(spacing: 14) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(AppTheme.Colors.border)

                    SwiftUI.Text("Nessuna immagine")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.placeholder)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            }
        }
    }
}
