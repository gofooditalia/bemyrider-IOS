//
//  RemoteImageView.swift
//  bemyrider
//
//  UIViewRepresentable bridge: loads remote images via AlamofireImage.
//  Use in any SwiftUI view that needs to display a URL-based image.
//

import SwiftUI
import UIKit
import AlamofireImage

struct RemoteImageView: UIViewRepresentable {

    let urlString: String
    var contentMode: UIView.ContentMode = .scaleAspectFill
    var placeholder: UIImage? = UIImage(named: "Image-Place-Holder")

    init(_ urlString: String,
         contentMode: UIView.ContentMode = .scaleAspectFill,
         placeholder: UIImage? = UIImage(named: "Image-Place-Holder")) {
        self.urlString   = urlString
        self.contentMode = contentMode
        self.placeholder = placeholder
    }

    func makeUIView(context: Context) -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = contentMode
        iv.clipsToBounds = true
        iv.setContentHuggingPriority(.defaultLow, for: .horizontal)
        iv.setContentHuggingPriority(.defaultLow, for: .vertical)
        iv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        iv.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return iv
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        if let url = URL(string: urlString), !urlString.isEmpty {
            uiView.af_setImage(withURL: url, placeholderImage: placeholder)
        } else {
            uiView.image = placeholder
        }
    }
}
