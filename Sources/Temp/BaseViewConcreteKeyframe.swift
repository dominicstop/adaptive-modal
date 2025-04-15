//
//  BaseViewConcreteKeyframe.swift
//  AdaptiveModal
//
//  Created by Dominic Go on 4/14/25.
//

import UIKit
import DGSwiftUtilities


public protocol BaseViewConcreteKeyframe<KeyframeTarget>:
  BaseConcreteKeyframe,
  KeyframeAppliable where
    KeyframeTarget: UIView,
    PartialKeyframe: BaseViewPartialKeyframe
{
  associatedtype KeyframeTarget;

  var opacity: CGFloat { get set };
  var transform: Transform3D { get set };
  var backgroundColor: UIColor { get set };
  
  func applyBaseViewKeyframe(toTarget targetView: KeyframeTarget);
};

// MARK: - BaseViewConcreteKeyframe+Default
// --------------------------------------

public extension BaseViewConcreteKeyframe {
    
  static func extractBaseViewPartialToConcreteKeyframePropertyMap<T: BaseConcreteKeyframe>(
    forType concreteKeyframeType: T.Type = T.self
  ) -> T.KeyframePropertyMap {
    
    var map: T.KeyframePropertyMap = [:];

    for (key, value) in Self.baseViewPartialToConcreteKeyframePropertyMap {
      let partialKeyframeKeyPath = key as? T.KeyframePropertyMap.Key;
      let concreteKeyframeKeyPath = value as? T.KeyframePropertyMap.Value;
      
      map[partialKeyframeKeyPath!] = concreteKeyframeKeyPath!;
    };
    
    return map;
  };
  
  static var baseViewPartialToConcreteKeyframePropertyMap: KeyframePropertyMap {
    return [
      .init(keyPath: \.opacity): .init(keyPath: \.opacity),
      .init(keyPath: \.transform): .init(keyPath: \.transform),
      .init(keyPath: \.backgroundColor): .init(keyPath: \.backgroundColor),
    ];
  };
  
  func applyBaseViewKeyframe(toTarget targetView: KeyframeTarget) {
    self.applyBaseViewKeyframe(toView: targetView);
  };
};

// MARK: - BaseViewKeyframeConfig+Helpers
// --------------------------------------

public extension BaseViewConcreteKeyframe {
  
  func applyBaseViewKeyframe(toView view: UIView) {
    view.alpha = self.opacity
    view.layer.transform = self.transform.transform3D
    view.backgroundColor = self.backgroundColor;
  };
  
  // MARK: - Chain Setter Methods
  // ----------------------------
  
  func withOpacity(_ opacity: CGFloat) -> Self {
    var copy = self;
    copy.opacity = opacity;
    return copy;
  };
  
  func withTransform(_ transform: Transform3D) -> Self {
    var copy = self;
    copy.transform = transform;
    return copy;
  };
  
  func withBackgroundColor(_ backgroundColor: UIColor) -> Self {
    var copy = self;
    copy.backgroundColor = backgroundColor;
    return copy;
  };
};
