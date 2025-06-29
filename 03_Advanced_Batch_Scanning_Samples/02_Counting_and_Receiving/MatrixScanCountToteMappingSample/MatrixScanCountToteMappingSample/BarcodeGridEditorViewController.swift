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

import ScanditBarcodeCapture

class BarcodeGridEditorViewController: UIViewController {
    private let gridEditorView: BarcodeSpatialGridEditorView

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(view: BarcodeSpatialGridEditorView) {
        self.gridEditorView = view
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Tote Mapping"
        view.backgroundColor = .white

        gridEditorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridEditorView)
        NSLayoutConstraint.activate([
            gridEditorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            gridEditorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            gridEditorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            gridEditorView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}
