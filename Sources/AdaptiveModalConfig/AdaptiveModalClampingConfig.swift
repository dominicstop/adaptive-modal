//
//  AdaptiveModalClampingConfig.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/28/23.
//

import Foundation

public struct AdaptiveModalClampingConfig: Equatable {

  public enum ClampingKeys: Equatable, CaseIterable {
    case modalSizeHeight;
    case modalSizeWidth;
    case modalOriginX;
    case modalOriginY;
    
    case modalPaddingTop;
    case modalPaddingLeft;
    case modalPaddingBottom;
    case modalPaddingRight;
    
    case modalTransformTranslateX;
    case modalTransformTranslateY;
    case modalTransformTranslateZ;
    case modalTransformScaleX;
    case modalTransformScaleY;
    case modalTransformRotateX;
    case modalTransformRotateY;
    case modalTransformRotateZ;
    case modalTransformPerspective;
    case modalTransformSkewX;
    case modalTransformSkewY;
    
    case modalBorderWidth;
    case modalShadowOffset;
    case modalShadowRadius;
    case modalCornerRadius;
    case modalDragHandleSizeHeight;
    case modalDragHandleSizeWidth;
    case modalDragHandleOffset;
    case modalDragHandleCornerRadius;
  };
  
  static let defaultClampingKeys: Set<ClampingKeys> = [
    .modalBorderWidth,
    .modalShadowOffset,
    .modalShadowRadius,
    .modalCornerRadius,
    .modalDragHandleSizeHeight,
    .modalDragHandleSizeWidth,
    .modalDragHandleOffset,
    .modalDragHandleCornerRadius,
  ];
  
  public static let defaultHorizontal: Self = .init(
    clampingKeys: Self.defaultClampingKeys.union([
      .modalSizeHeight,
      .modalOriginY,
      .modalPaddingBottom,
      .modalPaddingTop,
    ])
  );
  
  public static let defaultVertical: Self = .init(
    clampingKeys: Self.defaultClampingKeys.union([
      .modalSizeWidth,
      .modalOriginX,
      .modalPaddingLeft,
      .modalPaddingRight,
    ])
  );
  
  public var clampingKeysLeft: Set<ClampingKeys>;
  public var clampingKeysRight: Set<ClampingKeys>;
  
  public init(
    clampingKeysLeft: Set<ClampingKeys>,
    clampingKeysRight: Set<ClampingKeys>
  ) {
    self.clampingKeysLeft = clampingKeysLeft
    self.clampingKeysRight = clampingKeysRight
  };
  
  public init(clampingKeys: Set<ClampingKeys>) {
    self.clampingKeysLeft = clampingKeys;
    self.clampingKeysRight = clampingKeys;
  };
};
