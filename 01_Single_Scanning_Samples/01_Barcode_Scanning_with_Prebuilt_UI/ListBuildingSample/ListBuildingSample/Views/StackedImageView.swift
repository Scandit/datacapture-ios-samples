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

import UIKit

class StackedImageView: UIView {
    var images: [UIImage]? {
        didSet {
            createImageViews()
        }
    }
    private var imageViews: [UIImageView]?

    private func createImageViews() {
        imageViews?.forEach { $0.removeFromSuperview() }
        imageViews = images?.map {
            let imageView = UIImageView(image: $0)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
            return imageView
        }

        if let imageView = imageViews?.first {
            NSLayoutConstraint.activate([
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
                imageView.rightAnchor.constraint(equalTo: rightAnchor),
            ])
        }

        if let imageView = imageViews?.last {
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: topAnchor),
                imageView.leftAnchor.constraint(equalTo: leftAnchor),
            ])
        }

        var prevImageView: UIImageView?
        imageViews?.forEach { imageView in
            if let prevImageView {
                NSLayoutConstraint.activate([
                    imageView.topAnchor.constraint(equalTo: prevImageView.topAnchor, constant: -4),
                    imageView.leftAnchor.constraint(equalTo: prevImageView.leftAnchor, constant: -4),
                    imageView.bottomAnchor.constraint(equalTo: prevImageView.bottomAnchor, constant: -4),
                    imageView.rightAnchor.constraint(equalTo: prevImageView.rightAnchor, constant: -4),
                ])
            }
            prevImageView = imageView
        }
    }
}
