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

struct ItemRowView: View {
    let item: Item

    var body: some View {
        HStack(spacing: 16) {
            // Barcode thumbnail
            if let images = item.images, !images.isEmpty, let lastImage = images.last {
                Image(uiImage: rotatedImage(lastImage))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
                    .background(Color(.systemGray6))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray4))
                    .frame(width: 60, height: 60)
            }

            // Item details
            VStack(alignment: .leading, spacing: 2) {
                Text(item.data)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                    .lineLimit(1)

                Text(item.symbologyReadableName)
                    .font(.system(size: 14))
                    .foregroundColor(Color(.systemGray))

                if item.quantity > 1 {
                    Text("Qty: \(item.quantity)")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemBlue))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
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
