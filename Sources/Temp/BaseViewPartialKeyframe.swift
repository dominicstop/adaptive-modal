//
//  BaseViewPartialKeyframe.swift
//  AdaptiveModal
//
//  Created by Dominic Go on 4/14/25.
//

import UIKit
import DGSwiftUtilities


public protocol BaseViewPartialKeyframe:
  BasePartialKeyframe where ConcreteKeyframe: BaseViewConcreteKeyframe
{
  var opacity: CGFloat? { get set };
  var transform: Transform3D? { get set };
  var backgroundColor: UIColor? { get set };
};
