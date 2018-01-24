//
//  DeprecateColorRule.swift
//  IBLinterKit
//
//  Created by SaitoYuta on 2017/12/15.
//

import IBLinterCore

extension Rules {
    
    public struct DeprecateColorRule: Rule {
        
        public static var identifier: String = "deprecate_color"
        
        public init() {}
        
        public func validate(xib: XibFile) -> [Violation] {
            guard let views = xib.document.views else { return [] }
            return views.flatMap { validate(for: $0, file: xib) }
        }
        
        public func validate(storyboard: StoryboardFile) -> [Violation] {
            guard let scenes = storyboard.document.scenes else { return [] }
            let views = scenes.flatMap { $0.viewController?.rootView }
            return views.flatMap { validate(for: $0, file: storyboard) }
        }
        
        private func validate(for view: ViewProtocol, file: InterfaceBuilderFile) -> [Violation] {
            let violation: [Violation] = {
                var violations = [Violation]()
                // sRGB is in customColorSpace, so if it does not exist, it's a system color
                if view.elementClass == "UIButton" {
                    let button = view as? InterfaceBuilderNode.View.Button
                    let colors = [button?.textColor.normal,
                                  button?.textColor.selected,
                                  button?.textColor.highlighted,
                                  button?.textColor.disabled]
                    for color in colors {
                        if let color = color {
                            if color.sRGB == nil {
                                violations.append(Violation(interfaceBuilderFile: file, message: "A system color \(String(describing: color.calibratedWhite)) in here.", level: .error))
                            }
                        }
                    }
                }
                if let color = view.color {
                    if color.sRGB == nil {
                        violations.append(Violation(interfaceBuilderFile: file, message: "A system color \(String(describing: color.calibratedWhite)) in here.", level: .error))
                        return violations
                    } else {
                        return []
                    }
                } else {
                    return []
                }
            }()
            return violation + (view.subviews?.flatMap { validate(for: $0, file: file) } ?? [])
        }
    }
}
