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
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SparkScanViewModel()

    init() {
        // Configure navigation bar appearance to match original (black background, white text)
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor.black
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with item count and clear button
                HStack {
                    Text("\(viewModel.totalItemsCount) item(s) scanned")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)

                    Spacer()

                    Button(
                        action: {
                            viewModel.clearItems()
                        },
                        label: {
                            Text("CLEAR LIST")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(viewModel.items.isEmpty ? .gray : .red)
                        }
                    )
                    .disabled(viewModel.items.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white)

                // Items list
                if viewModel.items.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("Start scanning to build your list")
                            .foregroundColor(.gray)
                            .font(.body)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.items) { item in
                            ItemRowView(item: item)
                                .frame(height: 80.0)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
                        }
                    }
                    .listStyle(.plain)
                    .background(Color(red: 0.97, green: 0.98, blue: 0.99))
                }
            }
            .background(Color.white)
            .navigationTitle("List Building")
            .navigationBarTitleDisplayMode(.inline)
            .withSparkScan(viewModel.sparkScanViewController)
        }
    }
}
