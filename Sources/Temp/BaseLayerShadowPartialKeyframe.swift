//
//  BaseLayerShadowPartialKeyframe.swift
//  AdaptiveModal
//
//  Created by Dominic Go on 4/15/25.
//

import UIKit
import DGSwiftUtilities


public protocol BaseLayerShadowPartialKeyframe:
  BasePartialKeyframe where ConcreteKeyframe: BaseLayerShadowConcreteKeyframe
{  
  var shadowColor: UIColor? { get set };
  var shadowOffset: CGSize? { get set };
  var shadowOpacity: CGFloat? { get set };
  var shadowRadius: CGFloat? { get set };
};
