//
//  AdaptiveModalSnapPointPreset.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/31/23.
//

import Foundation

public struct AdaptiveModalSnapPointPreset: Equatable {

  public static let automatic: Self = .init(layoutPreset: .automatic);

  public var layoutPreset: RNILayoutPreset;
  public var keyframeConfig: AdaptiveModalKeyframeConfig?;
  
  public init(
    layoutPreset: RNILayoutPreset,
    keyframeConfig: AdaptiveModalKeyframeConfig? = nil
  ) {
    self.layoutPreset = layoutPreset;
    self.keyframeConfig = keyframeConfig;
  };
};

extension AdaptiveModalSnapPointPreset {
  static func getDefaultOvershootSnapPoint(
    forDirection direction: AdaptiveModalConfig.SnapDirection,
    keyframeConfig: AdaptiveModalKeyframeConfig? = nil
  ) -> Self {
  
    let layoutPreset: RNILayoutPreset = {
      switch direction {
        case .bottomToTop: return .edgeTop;
        case .topToBottom: return .edgeBottom;
        case .leftToRight: return .edgeRight;
        case .rightToLeft: return .edgeLeft;
      };
    }();
  
    return self.init(
      layoutPreset: layoutPreset,
      keyframeConfig: keyframeConfig
    );
  };
  
  static func getDefaultUnderShootSnapPoint(
    forDirection direction: AdaptiveModalConfig.SnapDirection,
    keyframeConfig: AdaptiveModalKeyframeConfig? = nil
  ) -> Self {
  
    let layoutPreset: RNILayoutPreset = {
      switch direction {
        case .bottomToTop: return .offscreenBottom;
        case .topToBottom: return .offscreenTop;
        case .leftToRight: return .offscreenLeft;
        case .rightToLeft: return .offscreenRight;
      };
    }();
  
    return self.init(
      layoutPreset: layoutPreset,
      keyframeConfig: keyframeConfig ?? .defaultUndershootKeyframe
    );
  };
};
