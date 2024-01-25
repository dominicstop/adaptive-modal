//
//  AdaptiveModalSnapPointConfig.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/23/23.
//

import UIKit
import ComputableLayout

public enum AdaptiveModalSnapPointConfig: Equatable {

  // MARK: Types
  // -----------

  public enum SnapPointKey: Equatable {
    case undershootPoint, overshootPoint, unspecified;
    
    case string(_ stringKey: String);
    case index(_ indexKey: Int);
  };
  
  enum SnapPointMode: String {
    case standard;
    case inBetween;
  };
  
  // MARK: - Enum Cases
  // ------------------
  
  case snapPoint(
    key: SnapPointKey = .unspecified,
    layoutConfig: ComputableLayout,
    keyframeConfig: AdaptiveModalKeyframeConfig? = nil
  );
  
  case inBetweenSnapPoint(
    key: SnapPointKey = .unspecified,
    layoutConfig: ComputableLayout?,
    keyframeConfig: AdaptiveModalKeyframeConfig? = nil
  );
  
  // MARK: Computed Properties
  // -------------------------
  
  var mode: SnapPointMode {
    switch self {
      case .snapPoint:
        return .standard;
        
      case .inBetweenSnapPoint:
        return .inBetween;
    };
  };

  public var key: SnapPointKey {
    switch self {
      case let .snapPoint(key, _, _):
        return key;
        
      case let .inBetweenSnapPoint(key, _, _):
        return key;
    };
  };
  
  public var layoutConfig: ComputableLayout {
    switch self {
      case let .snapPoint(_, layoutConfig, _):
        return layoutConfig;
        
      case let .inBetweenSnapPoint(_, layoutConfig, _):
        return layoutConfig ?? .zero;
    };
  };
  
  public var keyframeConfig: AdaptiveModalKeyframeConfig? {
    switch self {
      case let .snapPoint(_, _, keyframeConfig):
        return keyframeConfig;
        
      case let .inBetweenSnapPoint(_, _, keyframeConfig):
        return keyframeConfig;
    };
  };
  
  // MARK: Init
  // ----------
  
  public init(
    key: SnapPointKey = .unspecified,
    layoutConfig: ComputableLayout,
    keyframeConfig: AdaptiveModalKeyframeConfig? = nil
  ) {
  
    self = .snapPoint(
      key: key,
      layoutConfig: layoutConfig,
      keyframeConfig: keyframeConfig
    );
  };
  
  public init(
    key: SnapPointKey = .unspecified,
    fromSnapPointPreset snapPointPreset: AdaptiveModalSnapPointPreset,
    fromBaseLayoutConfig baseLayoutConfig: ComputableLayout
  ) {
    let snapPointLayoutPreset = snapPointPreset.layoutPreset;
    
    let snapPointLayout = snapPointLayoutPreset.getLayoutConfig(
      fromBaseLayoutConfig: baseLayoutConfig
    );
    
    self = .snapPoint(
      key: key,
      layoutConfig: snapPointLayout,
      keyframeConfig: snapPointPreset.keyframeConfig
    );
  };
  
  public init(
    fromBase base: Self,
    fallbackKey: SnapPointKey? = nil,
    newSnapPoint: ComputableLayout? = nil,
    newAnimationKeyframe: AdaptiveModalKeyframeConfig? = nil
  ) {
  
    let key = base.key == .unspecified
      ? fallbackKey ?? base.key
      : base.key;
      
    let layoutConfig = newSnapPoint ?? base.layoutConfig;
    let keyframeConfig = newAnimationKeyframe ?? base.keyframeConfig;
  
    switch base.mode {
      case .standard:
        self = .snapPoint(
          key: key,
          layoutConfig: layoutConfig,
          keyframeConfig: keyframeConfig
        );
        
      case .inBetween:
        self = .inBetweenSnapPoint(
          key: key,
          layoutConfig: layoutConfig,
          keyframeConfig: keyframeConfig
        );
    };
  };
};

};
