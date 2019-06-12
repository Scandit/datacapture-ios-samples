/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

import ScanditCaptureCore

class LocationSelectionDataSource: DataSource {

    weak var delegate: DataSourceDelegate?

    init(delegate: DataSourceDelegate) {
        self.delegate = delegate
    }

    // MARK: - Sections
    var sections: [Section] {

        var sections = [locationStrategy]

        switch SettingsManager.current.locationSelection {
        case is RadiusLocationSelection:
            sections.append(radiusSettings)
        case let rectangularSelection as RectangularLocationSelection:
            sections.append(rectangularSettings)
            switch rectangularSelection.sizeWithUnitAndAspect.sizingMode {
            case .widthAndHeight: sections.append(Section(rows: [rectangularWidth, rectangularHeight]))
            case .widthAndAspectRatio: sections.append(Section(rows: [rectangularWidth, rectangularHeightAspect]))
            case .heightAndAspectRatio: sections.append(Section(rows: [rectangularHeight, rectangularWidthAspect]))
            }
        default:
            break
        }

        return sections
    }

    // MARK: Section: Strategy

    lazy var locationStrategy: Section = {
        return Section(title: "Type", rows: [none, radius, rectangular])
    }()

    lazy var none: Row = {
        return Row.option(title: "None",
                          getValue: { SettingsManager.current.locationSelection == nil },
                          didSelect: { _, _ in SettingsManager.current.locationSelection = nil },
                          dataSourceDelegate: self.delegate)
    }()

    lazy var radius: Row = {
        return Row.option(title: "Radius",
                          getValue: { SettingsManager.current.locationSelection is RadiusLocationSelection },
                          didSelect: { _, _ in
                            SettingsManager.current.locationSelection = RadiusLocationSelection(radius: .zero) },
                          dataSourceDelegate: self.delegate)
    }()

    lazy var rectangular: Row = {
        return Row.option(title: "Rectangular",
                          getValue: { SettingsManager.current.locationSelection is RectangularLocationSelection },
                          didSelect: { _, _ in
                            SettingsManager.current.locationSelection = RectangularLocationSelection(size: .zero)},
                          dataSourceDelegate: delegate)
    }()

    // MARK: Section: Radius Settings

    lazy var radiusSettings: Section = {
        return Section(title: "Radius", rows: [
            Row.valueWithUnit(title: "Size",
                              getValue: {
                                (SettingsManager.current.locationSelection as! RadiusLocationSelection).radius },
                              didChangeValue: {
                                SettingsManager.current.locationSelection = RadiusLocationSelection(radius: $0) },
                              dataSourceDelegate: self.delegate)
            ])
    }()

    lazy var rectangularSettings: Section = {
        return Section(title: "Rectangular", rows: [
            Row.choice(title: "Size Specification",
                       options: RectangularSizeSpecification.allCases,
                       getValue: getCurrentSizeSpecification,
                       didChangeValue: setCurrentSizeSpecification,
                       dataSourceDelegate: self.delegate)])
    }()

    lazy var rectangularWidth: Row = {
        return Row.valueWithUnit(title: "Width",
                                 getValue: getRectangularWidth,
                                 didChangeValue: setRectangularWidth,
                                 dataSourceDelegate: self.delegate)
    }()

    lazy var rectangularHeight: Row = {
        return Row.valueWithUnit(title: "Height",
                                 getValue: getRectangularHeight,
                                 didChangeValue: setRectangularHeight,
                                 dataSourceDelegate: self.delegate)
    }()

    lazy var rectangularWidthAspect: Row = {
        return Row.init(title: "Width Aspect",
                        kind: .float,
                        getValue: getRectangularAspect,
                        didChangeValue: setRectangularAspect)
    }()

    lazy var rectangularHeightAspect: Row = {
        return Row.init(title: "Height Aspect",
                        kind: .float,
                        getValue: getRectangularAspect,
                        didChangeValue: setRectangularAspect)
    }()

    // MARK: RectangularSizeSpecification
    func getCurrentSizeSpecification() -> RectangularSizeSpecification {
        guard let rectangularSelection =
            SettingsManager.current.locationSelection as? RectangularLocationSelection else {
            fatalError("Current LocationSelection is not RectangularLocationSelection")
        }

        switch rectangularSelection.sizeWithUnitAndAspect.sizingMode {
        case .widthAndHeight:
            return .widthAndHeight
        case .widthAndAspectRatio:
            return .widthAndHeightAspect
        case .heightAndAspectRatio:
            return .heightAndWidthAspect
        }
    }

    func setCurrentSizeSpecification(newSizeSpecification: RectangularSizeSpecification) {
        switch newSizeSpecification {
        case .widthAndHeight:
            let full = FloatWithUnit(value: 1, unit: .fraction)
            SettingsManager.current.locationSelection =
                RectangularLocationSelection(size: SizeWithUnit(width: full,
                                                                height: full))
        case .widthAndHeightAspect:
            SettingsManager.current.locationSelection = RectangularLocationSelection(width: .zero,
                                                                                     aspectRatio: 1)
        case .heightAndWidthAspect:
            SettingsManager.current.locationSelection = RectangularLocationSelection(height: .zero,
                                                                                     aspectRatio: 1)
        }
    }

    func setRectangularWidth(width: FloatWithUnit) {
        guard let rectangularSelection =
            SettingsManager.current.locationSelection as? RectangularLocationSelection else {
                return
        }

        switch rectangularSelection.sizeWithUnitAndAspect.sizingMode {
        case .widthAndHeight:
            let currentSize = rectangularSelection.sizeWithUnitAndAspect.widthAndHeight
            SettingsManager.current.locationSelection =
                RectangularLocationSelection(size: SizeWithUnit(width: width,
                                                                height: currentSize.height))
        case .heightAndAspectRatio:
            break
        case .widthAndAspectRatio:
            let currentSize = rectangularSelection.sizeWithUnitAndAspect.widthAndAspectRatio
            SettingsManager.current.locationSelection =
                RectangularLocationSelection(width: width,
                                             aspectRatio: currentSize.aspect)
        }
    }

    func setRectangularHeight(height: FloatWithUnit) {
        guard let rectangularSelection =
            SettingsManager.current.locationSelection as? RectangularLocationSelection else {
                return
        }

        switch rectangularSelection.sizeWithUnitAndAspect.sizingMode {
        case .widthAndHeight:
            let currentSize = rectangularSelection.sizeWithUnitAndAspect.widthAndHeight
            SettingsManager.current.locationSelection =
                RectangularLocationSelection(size: SizeWithUnit(width: currentSize.width,
                                                                height: height))
        case .heightAndAspectRatio:
            let currentSize = rectangularSelection.sizeWithUnitAndAspect.widthAndAspectRatio
            SettingsManager.current.locationSelection =
                RectangularLocationSelection(height: height,
                                             aspectRatio: currentSize.aspect)
        case .widthAndAspectRatio:
            break
        }
    }

    func getRectangularHeight() -> FloatWithUnit {
        guard let rectangularSelection =
            SettingsManager.current.locationSelection as? RectangularLocationSelection else {
            return .zero
        }

        switch rectangularSelection.sizeWithUnitAndAspect.sizingMode {
        case .heightAndAspectRatio:
            return rectangularSelection.sizeWithUnitAndAspect.heightAndAspectRatio.size
        case .widthAndHeight:
            return rectangularSelection.sizeWithUnitAndAspect.widthAndHeight.height
        case .widthAndAspectRatio:
            return .zero
        }
    }

    func getRectangularWidth() -> FloatWithUnit {
        guard let rectangularSelection =
            SettingsManager.current.locationSelection as? RectangularLocationSelection else {
            return .zero
        }

        switch rectangularSelection.sizeWithUnitAndAspect.sizingMode {
        case .widthAndAspectRatio:
            return rectangularSelection.sizeWithUnitAndAspect.widthAndAspectRatio.size
        case .widthAndHeight:
            return rectangularSelection.sizeWithUnitAndAspect.widthAndHeight.width
        case .heightAndAspectRatio:
            return .zero
        }
    }

    func getRectangularAspect() -> CGFloat {
        guard let rectangularSelection =
            SettingsManager.current.locationSelection as? RectangularLocationSelection else {
            return .zero
        }

        switch rectangularSelection.sizeWithUnitAndAspect.sizingMode {
        case .widthAndAspectRatio:
            return rectangularSelection.sizeWithUnitAndAspect.widthAndAspectRatio.aspect
        case .heightAndAspectRatio:
            return rectangularSelection.sizeWithUnitAndAspect.heightAndAspectRatio.aspect
        case .widthAndHeight:
            return .zero
        }
    }

    func setRectangularAspect(aspect: CGFloat) {
        guard let rectangularSelection =
            SettingsManager.current.locationSelection as? RectangularLocationSelection else {
            return
        }

        switch rectangularSelection.sizeWithUnitAndAspect.sizingMode {
        case .widthAndAspectRatio:
            let currentSize = rectangularSelection.sizeWithUnitAndAspect.widthAndAspectRatio
            SettingsManager.current.locationSelection =
                RectangularLocationSelection(width: currentSize.size,
                                             aspectRatio: aspect)
        case .heightAndAspectRatio:
            let currentSize = rectangularSelection.sizeWithUnitAndAspect.widthAndAspectRatio
            SettingsManager.current.locationSelection =
                RectangularLocationSelection(width: currentSize.size,
                                             aspectRatio: aspect)
        case .widthAndHeight:
            break
        }
    }
}
