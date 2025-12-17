//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI

struct StackedImagesView: View {
    let images: [UIImage]
    let size: CGFloat

    var body: some View {
        ZStack {
            ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                Image(uiImage: rotatedImage(image))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: (size - CGFloat(images.count * 4)), height: size - CGFloat(images.count * 4))
                    .clipped()
                    .offset(x: CGFloat(-index * 4), y: CGFloat(-index * 4))
            }
        }
        .frame(
            width: size,
            height: size
        )
    }

    private func rotatedImage(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        return UIImage(
            cgImage: cgImage,
            scale: image.scale,
            orientation: .right
        )
    }
}

struct ItemRowView: View {
    let item: Item

    var body: some View {
        HStack(spacing: 16) {
            // Barcode thumbnail with stacked images
            if let images = item.images, !images.isEmpty {
                let imagesToShow = Array(images.suffix(3))
                StackedImagesView(images: imagesToShow, size: 56)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray4))
                    .frame(width: 56, height: 56)
            }

            // Item details
            VStack(alignment: .leading, spacing: 2) {
                Text(item.data)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)

                Text(item.symbologyReadableName)
                    .font(.system(size: 14))
                    .foregroundColor(Color(.systemGray))
            }

            Spacer()

            if item.quantity > 1 {
                Text("Qty: \(item.quantity)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 16)
    }
}
