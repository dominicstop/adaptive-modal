//
//  BaseLayerSystemCornerRadiusPartialKeyframe.swift
//  AdaptiveModal
//
//  Created by Dominic Go on 4/15/25.
//

import UIKit
import DGSwiftUtilities


public protocol BaseLayerSystemCornerRadiusPartialKeyframe:
  BasePartialKeyframe where ConcreteKeyframe: BaseLayerSystemCornerRadiusConcreteKeyframe
{
  var cornerRadius: CGFloat? { get set };
  var cornerMask: CACornerMask? { get set };
};
