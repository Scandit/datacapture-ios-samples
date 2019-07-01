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

extension Brush {
    static var matching: Brush {
        let fillColor = UIColor(red: 57.0/255.0, green: 204.0/255.0, blue: 97.0/255.0, alpha: 0.6)
        return Brush(fill: fillColor, stroke: .clear, strokeWidth: 0)
    }

    static var nonMatching: Brush {
        return Brush(fill: .clear, stroke: .white, strokeWidth: 3)
    }
}
