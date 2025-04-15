//
//  BaseLayerSystemCornerRadiusConcreteKeyframe.swift
//  AdaptiveModal
//
//  Created by Dominic Go on 4/15/25.
//

import UIKit
import DGSwiftUtilities

public protocol BaseLayerSystemCornerRadiusConcreteKeyframe<KeyframeTarget>:
  BaseConcreteKeyframe,
  KeyframeAppliable where
    PartialKeyframe: BaseLayerSystemCornerRadiusPartialKeyframe
{
  associatedtype KeyframeTarget;
  
  var cornerRadius: CGFloat { get set };
  var cornerMask: CACornerMask { get set };
};


// MARK: - BaseLayerSystemCornerRadiusConcreteKeyframe+Helpers
// -----------------------------------------------------------

public extension BaseLayerSystemCornerRadiusConcreteKeyframe {
  
  static func extractBaseLayerSystemCornerRadiusPartialToConcreteKeyframePropertyMap<T: BaseConcreteKeyframe>(
    forType concreteKeyframeType: T.Type = T.self
  ) -> T.KeyframePropertyMap {
    
    var map: T.KeyframePropertyMap = [:];

    for (key, value) in Self.baseLayerSystemCornerRadiusPartialToConcreteKeyframePropertyMap {
      let partialKeyframeKeyPath = key as? T.KeyframePropertyMap.Key;
      let concreteKeyframeKeyPath = value as? T.KeyframePropertyMap.Value;
      
      map[partialKeyframeKeyPath!] = concreteKeyframeKeyPath!;
    };
    
    return map;
  };
  
  static var baseLayerSystemCornerRadiusPartialToConcreteKeyframePropertyMap: KeyframePropertyMap {
    return [
      .init(keyPath: \.cornerRadius): .init(keyPath: \.cornerRadius),
      .init(keyPath: \.cornerMask): .init(keyPath: \.cornerMask),
    ];
  };
  
  func applyBaseLayerSystemCornerRadiusKeyframe(toLayer layer: CALayer) {
    layer.cornerRadius = self.cornerRadius;
    layer.maskedCorners = self.cornerMask;
  };

  func applyBaseLayerSystemCornerRadiusKeyframe(toView view: UIView) {
    self.applyBaseLayerSystemCornerRadiusKeyframe(toLayer: view.layer);
  };
  
  // MARK: - Chain Setter Methods
  // ----------------------------
  
  func withCornerRadius(_ newValue: CGFloat) -> Self {
    var copy = self;
    copy.cornerRadius = newValue;
    return copy;
  };
  
  func withCornerMask(_ newValue: CACornerMask) -> Self {
    var copy = self;
    copy.cornerMask = newValue;
    return copy;
  };
};
