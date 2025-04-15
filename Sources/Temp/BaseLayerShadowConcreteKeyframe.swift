//
//  BaseLayerShadowConcreteKeyframe.swift
//  AdaptiveModal
//
//  Created by Dominic Go on 4/15/25.
//

import UIKit
import DGSwiftUtilities

public protocol BaseLayerShadowConcreteKeyframe<KeyframeTarget>:
  BaseConcreteKeyframe,
  KeyframeAppliable where
    PartialKeyframe: BaseLayerShadowPartialKeyframe
{
  associatedtype KeyframeTarget;
  
  var shadowColor: UIColor { get set };
  var shadowOffset: CGSize { get set };
  var shadowOpacity: CGFloat { get set };
  var shadowRadius: CGFloat { get set };
};

// MARK: - BaseLayerShadowConcreteKeyframe+Helpers
// ---------------------------------------

public extension BaseLayerShadowConcreteKeyframe {
  
  static var baseLayerShadowPartialToConcreteKeyframePropertyMap: KeyframePropertyMap {
    return [
      .init(keyPath: \.shadowColor): .init(keyPath: \.shadowColor),
      .init(keyPath: \.shadowOffset): .init(keyPath: \.shadowOffset),
      .init(keyPath: \.shadowOpacity): .init(keyPath: \.shadowOpacity),
      .init(keyPath: \.shadowRadius): .init(keyPath: \.shadowRadius),
    ];
  };
  
  static func extractBaseLayerShadowPartialToConcreteKeyframePropertyMap<T: BaseConcreteKeyframe>(
    forType concreteKeyframeType: T.Type = T.self
  ) -> T.KeyframePropertyMap {
    
    var map: T.KeyframePropertyMap = [:];

    for (key, value) in Self.baseLayerShadowPartialToConcreteKeyframePropertyMap {
      let partialKeyframeKeyPath = key as? T.KeyframePropertyMap.Key;
      let concreteKeyframeKeyPath = value as? T.KeyframePropertyMap.Value;
      
      map[partialKeyframeKeyPath!] = concreteKeyframeKeyPath!;
    };
    
    return map;
  };
  
  func applyBaseLayerShadowKeyframe(toLayer layer: CALayer) {
    layer.shadowColor = self.shadowColor.cgColor
    layer.shadowOffset = self.shadowOffset;
    layer.shadowOpacity = .init(self.shadowOpacity);
    layer.shadowRadius = self.shadowRadius;
  };

  func applyBaseLayerShadowKeyframe(toView view: UIView) {
    self.applyBaseLayerShadowKeyframe(toLayer: view.layer);
  };
  
  // MARK: - Chain Setter Methods
  // ----------------------------
  
  func withShadowColor(_ newValue: UIColor) -> Self {
    var copy = self;
    copy.shadowColor = newValue;
    return copy;
  };
  
  func withShadowOffset(_ newValue: CGSize) -> Self {
    var copy = self;
    copy.shadowOffset = newValue;
    return copy;
  };
  
  func withShadowOpacity(_ newValue: CGFloat) -> Self {
    var copy = self;
    copy.shadowOpacity = newValue;
    return copy;
  };
  
  func withShadowRadius(_ newValue: CGFloat) -> Self {
    var copy = self;
    copy.shadowRadius = newValue;
    return copy;
  };
};
