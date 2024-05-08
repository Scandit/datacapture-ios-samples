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

import ScanditCaptureCore

class ViewfinderDataSource: DataSource {

    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    private var isRectangular: Bool { (rectangular.getValue?() as? Bool) == true }
    private var isLaserline: Bool { (laserline.getValue?() as? Bool) == true }
    private var isAimer: Bool { (aimer.getValue?() as? Bool) == true }

    // MARK: - Sections
    var sections: [Section] {
        var sections = [viewfinderType]

        if isRectangular {
            sections.append(contentsOf: [rectangularSettings, animation, rectangularSizeType])
            switch SettingsManager.current.viewfinderSizeSpecification {
            case .widthAndHeight: sections.append(widthAndHeight)
            case .widthAndHeightAspect: sections.append(widthAndHeightAspect)
            case .heightAndWidthAspect: sections.append(heightAndAspectRatio)
            case .shorterDimensionAndAspect: sections.append(shorterDimensionAndAspectRatio)
            }
        } else if isLaserline {
            sections.append(laserlineSettings)
        } else if isAimer {
            sections.append(aimerSettings)
        }

        return sections
    }

    // MARK: Section: Type

    lazy var viewfinderType: Section = {
        return Section(title: "Type", rows: [none, rectangular, laserline, aimer])
    }()

    lazy var none: Row = {
        return Row.option(title: "None",
                          getValue: { SettingsManager.current.viewfinder == nil },
                          didSelect: { _, _ in SettingsManager.current.viewfinder = nil },
                          dataSourceDelegate: self.delegate)
    }()

    lazy var rectangular: Row = {
        return Row.option(title: "Rectangular",
                          getValue: { SettingsManager.current.viewfinder is RectangularViewfinder },
                          didSelect: { _, _ in SettingsManager.current.viewfinder = RectangularViewfinder() },
                          dataSourceDelegate: self.delegate)
    }()

    lazy var laserline: Row = {
        return Row.option(title: "Laserline",
                          getValue: { SettingsManager.current.viewfinder is LaserlineViewfinder },
                          didSelect: { _, _ in SettingsManager.current.viewfinder = LaserlineViewfinder() },
                          dataSourceDelegate: self.delegate)
    }()

    lazy var aimer: Row = {
        return Row.option(title: "Aimer",
                          getValue: { SettingsManager.current.viewfinder is AimerViewfinder },
                          didSelect: { _, _ in SettingsManager.current.viewfinder = AimerViewfinder() },
                          dataSourceDelegate: self.delegate)
    }()

    // MARK: Section: Rectangular Viewfinder Settings

    lazy var rectangularSettings: Section = {
        return Section(title: "Rectangular", rows: [
                        Row.choice(title: "Style",
                                   options: RectangularViewfinderStyle.allCases,
                                   getValue: { SettingsManager.current.rectangularStyle },
                                   didChangeValue: { value in
                                    SettingsManager.current.rectangularStyle = value
                                    switch value {
                                    case .square, .rounded:
                                        SettingsManager.current.viewfinderSizeSpecification = .shorterDimensionAndAspect
                                    default:
                                        break
                                    }},
                                   dataSourceDelegate: self.delegate),
                        Row.choice(title: "Line Style",
                                   options: RectangularViewfinderLineStyle.allCases,
                                   getValue: { SettingsManager.current.rectangularLineStyle },
                                   didChangeValue: { SettingsManager.current.rectangularLineStyle = $0 },
                                   dataSourceDelegate: self.delegate),
                        Row.init(title: "Dimming (0.0 - 1.0)",
                                        kind: .float,
                                        getValue: { SettingsManager.current.rectangularDimming },
                                        didChangeValue: { SettingsManager.current.rectangularDimming = $0 }),
                        Row.init(title: "Disabled Dimming (0.0 - 1.0)",
                                        kind: .float,
                                        getValue: { SettingsManager.current.rectangularDisabledDimming },
                                        didChangeValue: { SettingsManager.current.rectangularDisabledDimming = $0 }),
                        Row.choice(title: "Color",
                                   options: RectangularViewfinderColor.allCases,
                                   getValue: { SettingsManager.current.rectangularViewfinderColor },
                                   didChangeValue: { SettingsManager.current.rectangularViewfinderColor = $0 },
                                   dataSourceDelegate: self.delegate),
                        Row.choice(title: "Disabled Color",
                                   options: RectangularViewfinderDisabledColor.allCases,
                                   getValue: { SettingsManager.current.rectangularViewfinderDisabledColor },
                                   didChangeValue: { SettingsManager.current.rectangularViewfinderDisabledColor = $0 },
                                   dataSourceDelegate: self.delegate)])
    }()

    lazy var rectangularSizeType: Section = {
        return Section(rows: [
                        Row.choice(title: "Size Specification",
                                   options: RectangularSizeSpecification.allCases,
                                   getValue: { SettingsManager.current.viewfinderSizeSpecification },
                                   didChangeValue: { SettingsManager.current.viewfinderSizeSpecification = $0 },
                                   dataSourceDelegate: self.delegate)])
    }()

    lazy var widthAndHeight: Section = {
        Section(rows: [
            Row.valueWithUnit(title: "Width",
                              getValue: { SettingsManager.current.rectangularWidthAndHeight.width },
                              didChangeValue: {
                                let height = SettingsManager.current.rectangularWidthAndHeight.height
                                let size = SizeWithUnit(width: $0, height: height)
                                SettingsManager.current.rectangularWidthAndHeight = size
                              },
                              dataSourceDelegate: self.delegate),
            Row.valueWithUnit(title: "Height",
                              getValue: { SettingsManager.current.rectangularWidthAndHeight.height },
                              didChangeValue: {
                                let width = SettingsManager.current.rectangularWidthAndHeight.width
                                let size = SizeWithUnit(width: width, height: $0)
                                SettingsManager.current.rectangularWidthAndHeight = size
                              },
                              dataSourceDelegate: self.delegate)
        ])
    }()

    lazy var widthAndHeightAspect: Section = {
        Section(rows: [
            Row.valueWithUnit(title: "Width",
                              getValue: { SettingsManager.current.rectangularWidthAndAspectRatio.size },
                              didChangeValue: {
                                let aspect = SettingsManager.current.rectangularWidthAndAspectRatio.aspect
                                let size = SizeWithAspect(size: $0, aspect: aspect)
                                SettingsManager.current.rectangularWidthAndAspectRatio = size
                              },
                              dataSourceDelegate: self.delegate),
            Row.init(title: "Height Aspect",
                     kind: .float,
                     getValue: { SettingsManager.current.rectangularWidthAndAspectRatio.aspect },
                     didChangeValue: {
                        let width = SettingsManager.current.rectangularWidthAndAspectRatio.size
                        let size = SizeWithAspect(size: width, aspect: $0)
                        SettingsManager.current.rectangularWidthAndAspectRatio = size
                     })
        ])
    }()

    lazy var heightAndAspectRatio: Section = {
        Section(rows: [
            Row.valueWithUnit(title: "Height",
                              getValue: { SettingsManager.current.rectangularHeightAndAspectRatio.size },
                              didChangeValue: {
                                let aspect = SettingsManager.current.rectangularHeightAndAspectRatio.aspect
                                let size = SizeWithAspect(size: $0, aspect: aspect)
                                SettingsManager.current.rectangularHeightAndAspectRatio = size
                              },
                              dataSourceDelegate: self.delegate),
            Row.init(title: "Width Aspect",
                     kind: .float,
                     getValue: { SettingsManager.current.rectangularHeightAndAspectRatio.aspect },
                     didChangeValue: {
                        let height = SettingsManager.current.rectangularHeightAndAspectRatio.size
                        let size = SizeWithAspect(size: height, aspect: $0)
                        SettingsManager.current.rectangularHeightAndAspectRatio = size
                     })
        ])
    }()

    lazy var shorterDimensionAndAspectRatio: Section = {
        Section(rows: [
            Row.init(title: "Fraction of Shorter Scan Area Dimension",
                     kind: .float,
                     getValue: { SettingsManager.current.rectangularShorterDimensionAndAspectRatio.0 },
                     didChangeValue: {
                        let aspect = SettingsManager.current.rectangularShorterDimensionAndAspectRatio.1
                        SettingsManager.current.rectangularShorterDimensionAndAspectRatio = ($0, aspect)
                     }),
            Row.init(title: "Aspect",
                     kind: .float,
                     getValue: { SettingsManager.current.rectangularShorterDimensionAndAspectRatio.1 },
                     didChangeValue: {
                        let dimension = SettingsManager.current.rectangularShorterDimensionAndAspectRatio.0
                        SettingsManager.current.rectangularShorterDimensionAndAspectRatio = (dimension, $0)
                     })
        ])
    }()

    // MARK: Section: Laserline Viewfinder Settings

    lazy var laserlineSettings: Section = {
        return Section(title: "Laserline",
                       rows: [laserlineStyle, laserlineWidth, laserlineEnabledColor, laserlineDisabledColor])
    }()

    lazy var laserlineStyle: Row = {
        return Row.choice(title: "Style",
                          options: LaserlineViewfinderStyle.allCases,
                          getValue: { SettingsManager.current.laserlineStyle },
                          didChangeValue: { SettingsManager.current.laserlineStyle = $0 },
                          dataSourceDelegate: self.delegate)
    }()

    lazy var laserlineWidth: Row = {
        return Row.valueWithUnit(title: "Width",
                                 getValue: { (SettingsManager.current.viewfinder as! LaserlineViewfinder).width },
                                 didChangeValue: {
                                    (SettingsManager.current.viewfinder as! LaserlineViewfinder).width = $0 },
                                 dataSourceDelegate: self.delegate)
    }()

    lazy var laserlineEnabledColor: Row = {
        return Row.choice(title: "Enabled Color",
                          options: LaserlineViewfinderEnabledColor.allCases,
                          getValue: { SettingsManager.current.laserlineViewfinderEnabledColor },
                          didChangeValue: { SettingsManager.current.laserlineViewfinderEnabledColor = $0 },
                          dataSourceDelegate: self.delegate)
    }()

    lazy var laserlineDisabledColor: Row = {
        return Row.choice(title: "Disabled Color",
                          options: LaserlineViewfinderDisabledColor.allCases,
                          getValue: { SettingsManager.current.laserlineViewfinderDisabledColor },
                          didChangeValue: { SettingsManager.current.laserlineViewfinderDisabledColor = $0 },
                          dataSourceDelegate: self.delegate)
    }()

    // MARK: Section: Aimer Viewfinder Settings

    lazy var aimerSettings: Section = {
        return Section(title: "Aimer", rows: [aimerFrameColor, aimerDotColor])
    }()

    lazy var aimerFrameColor: Row = {
        return Row.choice(title: "Aimer Frame Color",
                          options: AimerViewfinderFrameColor.allCases,
                          getValue: { SettingsManager.current.aimerViewfinderFrameColor },
                          didChangeValue: { SettingsManager.current.aimerViewfinderFrameColor = $0 },
                          dataSourceDelegate: self.delegate)
    }()

    lazy var aimerDotColor: Row = {
        return Row.choice(title: "Aimer Dot Color",
                          options: AimerViewfinderDotColor.allCases,
                          getValue: { SettingsManager.current.aimerViewfinderDotColor },
                          didChangeValue: { SettingsManager.current.aimerViewfinderDotColor = $0 },
                          dataSourceDelegate: self.delegate)
    }()
}

extension ViewfinderDataSource {
    var animation: Section {
        let animationRow = Row(title: "Animation",
                               kind: .switch,
                               getValue: { SettingsManager.current.rectangularAnimation != nil },
                               didChangeValue: { value in
                                    let animation = value ? RectangularViewfinderAnimation() : nil
                                   SettingsManager.current.rectangularAnimation = animation
                                self.delegate?.didChangeData()
                               })
        var rows = [animationRow]
        if SettingsManager.current.rectangularAnimation != nil {
            rows.append(Row(title: "Looping",
                            kind: .switch,
                            getValue: {
                                guard let animation = SettingsManager.current.rectangularAnimation else {
                                    return false
                                }
                                return animation.isLooping
                            },
                            didChangeValue: { value in
                                SettingsManager.current.rectangularAnimation =
                                    RectangularViewfinderAnimation(looping: value)
                            }))
        }
        return Section(rows: rows)
    }
}
