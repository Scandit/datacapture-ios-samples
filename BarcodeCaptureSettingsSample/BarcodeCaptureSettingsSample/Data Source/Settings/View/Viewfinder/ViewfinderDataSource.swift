/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import ScanditCaptureCore

class ViewfinderDataSource: DataSource {

    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    private var isRectangular: Bool {
        return (rectangular.getValue?() as? Bool) == true
    }

    private var isLaserline: Bool {
        return (laserline.getValue?() as? Bool) == true
    }

    private var isAimer: Bool {
        return (aimer.getValue?() as? Bool) == true
    }

    // MARK: - Sections

    var sections: [Section] {
        var sections = [viewfinderType]

        if isRectangular {
            sections.append(contentsOf: [rectangularSettings, rectangularSizeType])
            switch SettingsManager.current.viewfinderSizeSpecification {
            case .widthAndHeight: sections.append(Section(rows: [rectangularWidth, rectangularHeight]))
            case .widthAndHeightAspect: sections.append(Section(rows: [rectangularWidth, rectangularHeightAspect]))
            case .heightAndWidthAspect: sections.append(Section(rows: [rectangularWidthAspect, rectangularHeight]))
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
            Row.choice(title: "Color",
                       options: RectangularViewfinderColor.allCases,
                       getValue: { SettingsManager.current.rectangularViewfinderColor },
                       didChangeValue: { SettingsManager.current.rectangularViewfinderColor = $0 },
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

    lazy var rectangularWidth: Row = {
        return Row.valueWithUnit(title: "Width",
                                 getValue: { SettingsManager.current.rectangularWidth },
                                 didChangeValue: { SettingsManager.current.rectangularWidth = $0 },
                                 dataSourceDelegate: self.delegate)
    }()

    lazy var rectangularHeight: Row = {
        return Row.valueWithUnit(title: "Height",
                                 getValue: { SettingsManager.current.rectangularHeight },
                                 didChangeValue: { SettingsManager.current.rectangularHeight = $0 },
                                 dataSourceDelegate: self.delegate)
    }()

    lazy var rectangularWidthAspect: Row = {
        return Row.init(title: "Width Aspect",
                        kind: .float,
                        getValue: { SettingsManager.current.rectangularWidthAspect },
                        didChangeValue: { SettingsManager.current.rectangularWidthAspect = $0 })
    }()

    lazy var rectangularHeightAspect: Row = {
        return Row.init(title: "Height Aspect",
                        kind: .float,
                        getValue: { SettingsManager.current.rectangularHeightAspect },
                        didChangeValue: { SettingsManager.current.rectangularHeightAspect = $0 })
    }()

    // MARK: Section: Laserline Viewfinder Settings

    lazy var laserlineSettings: Section = {
        return Section(title: "Laserline", rows: [laserlineWidth, laserlineEnabledColor, laserlineDisabledColor])
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
