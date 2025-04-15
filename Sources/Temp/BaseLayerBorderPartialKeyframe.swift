//
//  BaseLayerBorderPartialKeyframe.swift
//  AdaptiveModal
//
//  Created by Dominic Go on 4/15/25.
//

import UIKit
import DGSwiftUtilities


public protocol BaseLayerBorderPartialKeyframe:
  BasePartialKeyframe where ConcreteKeyframe: BaseLayerBorderConcreteKeyframe
{  
  var borderWidth: CGFloat? { get set };
  var borderColor: UIColor? { get set };
};
