//
//  AdaptiveModalKeyframeConfig.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/23/23.
//

import UIKit

public struct AdaptiveModalKeyframeConfig {

  public static let defaultFirstKeyframe: Self = .init(
    modalContentOpacity: 1
  );

  public static let defaultUndershootKeyframe: Self = .init(
    backgroundTapInteraction: .default,
    modalRotation: 0,
    modalScaleX: 1,
    modalScaleY: 1,
    modalTranslateX: 0,
    modalTranslateY: 0,
    modalContentOpacity: 0.5,
    backgroundOpacity: 0,
    backgroundVisualEffectIntensity: 0
  );
  
  // MARK: - Embedded Types
  // ----------------------

  public enum BackgroundInteractionMode: String {
    static let `default`: Self = .automatic;
  
    case automatic;
    case dismiss, passthrough, ignore;
    
    var isPassThrough: Bool {
      switch self {
        case .passthrough: return true;
        default: return false;
      };
    };
  };
  
  public enum LayoutValueEdgeInsets {
    case edgeInsets(UIEdgeInsets);
    
    case layoutValue(
      top   : RNILayoutValue,
      left  : RNILayoutValue,
      bottom: RNILayoutValue,
      right : RNILayoutValue
    );
    
    func compute(
      usingLayoutValueContext context: RNILayoutValueContext
    ) -> UIEdgeInsets {
      
      switch self {
        case let .edgeInsets(edgeInsets):
          return edgeInsets;
          
        case let .layoutValue(top, left, bottom, right):
        
          let computedValueTop = top.computeValue(
            usingLayoutValueContext: context,
            preferredSizeKey: nil
          );
          
          let computedValueLeft = left.computeValue(
            usingLayoutValueContext: context,
            preferredSizeKey: nil
          );
          
          let computedValueBottom = bottom.computeValue(
            usingLayoutValueContext: context,
            preferredSizeKey: nil
          );
          
          let computedValueRight = right.computeValue(
            usingLayoutValueContext: context,
            preferredSizeKey: nil
          );
          
          return .init(
            top   : computedValueTop    ?? 0,
            left  : computedValueLeft   ?? 0,
            bottom: computedValueBottom ?? 0,
            right : computedValueRight  ?? 0
          );
      };
    };
  };
  
  // MARK: - Properties
  // ------------------

  public var backgroundTapInteraction: BackgroundInteractionMode?;
  public var secondaryGestureAxisDampingPercent: CGFloat?;
  
  public var modalScrollViewContentInsets: LayoutValueEdgeInsets?;
  public var modalScrollViewVerticalScrollIndicatorInsets: LayoutValueEdgeInsets?;
  public var modalScrollViewHorizontalScrollIndicatorInsets: LayoutValueEdgeInsets?;
  
  // MARK: - Properties - Keyframes
  // ------------------------------

  public var modalRotation: CGFloat?;
  
  public var modalScaleX: CGFloat?;
  public var modalScaleY: CGFloat?;

  public var modalTranslateX: CGFloat?;
  public var modalTranslateY: CGFloat?;
  
  public var modalBorderWidth: CGFloat?;
  public var modalBorderColor: UIColor?;
  
  public var modalShadowColor: UIColor?;
  public var modalShadowOffset: CGSize?;
  public var modalShadowOpacity: CGFloat?;
  public var modalShadowRadius: CGFloat?;
  
  public var modalCornerRadius: CGFloat?;
  public var modalMaskedCorners: CACornerMask?;
  
  public var modalOpacity: CGFloat?;
  public var modalContentOpacity: CGFloat?;
  public var modalBackgroundColor: UIColor?;
  public var modalBackgroundOpacity: CGFloat?;
  
  public var modalBackgroundVisualEffect: UIVisualEffect?;
  public var modalBackgroundVisualEffectOpacity: CGFloat?;
  public var modalBackgroundVisualEffectIntensity: CGFloat?;
  
  public var modalDragHandleSize: CGSize?;
  public var modalDragHandleOffset: CGFloat?;
  public var modalDragHandleColor: UIColor?;
  public var modalDragHandleOpacity: CGFloat?;
  public var modalDragHandleCornerRadius: CGFloat?;
  
  public var backgroundColor: UIColor?;
  public var backgroundOpacity: CGFloat?;
  
  public var backgroundVisualEffect: UIVisualEffect?;
  public var backgroundVisualEffectOpacity: CGFloat?;
  public var backgroundVisualEffectIntensity: CGFloat?;
  
  public init(
    backgroundTapInteraction: BackgroundInteractionMode? = nil,
    secondaryGestureAxisDampingPercent: CGFloat? = nil,
    modalScrollViewContentInsets: LayoutValueEdgeInsets? = nil,
    modalScrollViewVerticalScrollIndicatorInsets: LayoutValueEdgeInsets?  = nil,
    modalScrollViewHorizontalScrollIndicatorInsets: LayoutValueEdgeInsets?  = nil,
    
    modalRotation: CGFloat? = nil,
    modalScaleX: CGFloat? = nil,
    modalScaleY: CGFloat? = nil,
    modalTranslateX: CGFloat? = nil,
    modalTranslateY: CGFloat? = nil,
    modalBorderWidth: CGFloat? = nil,
    modalBorderColor: UIColor? = nil,
    modalShadowColor: UIColor? = nil,
    modalShadowOffset: CGSize? = nil,
    modalShadowOpacity: CGFloat? = nil,
    modalShadowRadius: CGFloat? = nil,
    modalCornerRadius: CGFloat? = nil,
    modalMaskedCorners: CACornerMask? = nil,
    modalOpacity: CGFloat? = nil,
    modalContentOpacity: CGFloat? = nil,
    modalBackgroundColor: UIColor? = nil,
    modalBackgroundOpacity: CGFloat? = nil,
    modalBackgroundVisualEffect: UIVisualEffect? = nil,
    modalBackgroundVisualEffectOpacity: CGFloat? = nil,
    modalBackgroundVisualEffectIntensity: CGFloat? = nil,
    modalDragHandleSize: CGSize? = nil,
    modalDragHandleOffset: CGFloat? = nil,
    modalDragHandleColor: UIColor? = nil,
    modalDragHandleOpacity: CGFloat? = nil,
    modalDragHandleCornerRadius: CGFloat? = nil,
    backgroundColor: UIColor? = nil,
    backgroundOpacity: CGFloat? = nil,
    backgroundVisualEffect: UIVisualEffect? = nil,
    backgroundVisualEffectOpacity: CGFloat? = nil,
    backgroundVisualEffectIntensity: CGFloat? = nil
  ) {
    
    self.backgroundTapInteraction = backgroundTapInteraction;
    self.secondaryGestureAxisDampingPercent = secondaryGestureAxisDampingPercent;
    
    self.modalScrollViewContentInsets = modalScrollViewContentInsets;
    self.modalScrollViewVerticalScrollIndicatorInsets = modalScrollViewVerticalScrollIndicatorInsets;
    self.modalScrollViewHorizontalScrollIndicatorInsets = modalScrollViewHorizontalScrollIndicatorInsets;
    
    self.modalRotation = modalRotation;
    
    self.modalScaleX = modalScaleX;
    self.modalScaleY = modalScaleY;
    
    self.modalTranslateX = modalTranslateX;
    self.modalTranslateY = modalTranslateY;
    
    self.modalBorderWidth = modalBorderWidth;
    self.modalBorderColor = modalBorderColor;
    
    self.modalShadowColor = modalShadowColor;
    self.modalShadowOffset = modalShadowOffset;
    self.modalShadowOpacity = modalShadowOpacity;
    self.modalShadowRadius = modalShadowRadius;
    
    self.modalCornerRadius = modalCornerRadius;
    self.modalMaskedCorners = modalMaskedCorners;
    
    self.modalOpacity = modalOpacity;
    self.modalContentOpacity = modalContentOpacity;
    self.modalBackgroundColor = modalBackgroundColor;
    self.modalBackgroundOpacity = modalBackgroundOpacity;
    
    self.modalBackgroundVisualEffect = modalBackgroundVisualEffect;
    self.modalBackgroundVisualEffectOpacity = modalBackgroundVisualEffectOpacity;
    self.modalBackgroundVisualEffectIntensity = modalBackgroundVisualEffectIntensity;
    
    self.modalDragHandleSize = modalDragHandleSize;
    self.modalDragHandleOffset = modalDragHandleOffset
    self.modalDragHandleColor = modalDragHandleColor;
    self.modalDragHandleOpacity = modalDragHandleOpacity;
    self.modalDragHandleCornerRadius = modalDragHandleCornerRadius;
    
    self.backgroundColor = backgroundColor;
    self.backgroundOpacity = backgroundOpacity;
    
    self.backgroundVisualEffect = backgroundVisualEffect;
    self.backgroundVisualEffectOpacity = backgroundVisualEffectOpacity;
    self.backgroundVisualEffectIntensity = backgroundVisualEffectIntensity;
  };
  
  public mutating func setNonNilValues(using otherKeyframe: Self) {
    if self.backgroundTapInteraction == nil {
      self.backgroundTapInteraction = otherKeyframe.backgroundTapInteraction;
    };
    
    if self.secondaryGestureAxisDampingPercent == nil {
      self.secondaryGestureAxisDampingPercent = otherKeyframe.secondaryGestureAxisDampingPercent;
    };
    
    if self.modalScrollViewContentInsets == nil {
      self.modalScrollViewContentInsets = otherKeyframe.modalScrollViewContentInsets;
    };
    
    if self.modalScrollViewVerticalScrollIndicatorInsets == nil {
      self.modalScrollViewVerticalScrollIndicatorInsets = otherKeyframe.modalScrollViewVerticalScrollIndicatorInsets;
    };
    
    if self.modalScrollViewHorizontalScrollIndicatorInsets == nil {
      self.modalScrollViewHorizontalScrollIndicatorInsets = otherKeyframe.modalScrollViewHorizontalScrollIndicatorInsets;
    };
    
    if self.modalRotation == nil {
      self.modalRotation = otherKeyframe.modalRotation;
    };
    
    if self.modalScaleX == nil {
      self.modalScaleX = otherKeyframe.modalScaleX;
    };
    
    if self.modalScaleY == nil {
      self.modalScaleY = otherKeyframe.modalScaleY;
    };
    
    if self.modalTranslateX == nil {
      self.modalTranslateX = otherKeyframe.modalTranslateX;
    };
    
    if self.modalTranslateY == nil {
      self.modalTranslateY = otherKeyframe.modalTranslateY;
    };
    
    if self.modalBorderWidth == nil {
      self.modalBorderWidth = otherKeyframe.modalBorderWidth;
    };
    
    if self.modalBorderColor == nil {
      self.modalBorderColor = otherKeyframe.modalBorderColor;
    };
    
    if self.modalShadowColor == nil {
      self.modalShadowColor = otherKeyframe.modalShadowColor;
    };
    
    if self.modalShadowOffset == nil {
      self.modalShadowOffset = otherKeyframe.modalShadowOffset;
    };
    
    if self.modalShadowOpacity == nil {
      self.modalShadowOpacity = otherKeyframe.modalShadowOpacity;
    };
    
    if self.modalShadowRadius == nil {
      self.modalShadowRadius = otherKeyframe.modalShadowRadius;
    };
    
    if self.modalCornerRadius == nil {
      self.modalCornerRadius = otherKeyframe.modalCornerRadius;
    };
    
    if self.modalMaskedCorners == nil {
      self.modalMaskedCorners = otherKeyframe.modalMaskedCorners;
    };
    
    if self.modalOpacity == nil {
      self.modalOpacity = otherKeyframe.modalOpacity;
    };
    
    if self.modalContentOpacity == nil {
      self.modalContentOpacity = otherKeyframe.modalContentOpacity;
    };
    
    if self.modalBackgroundColor == nil {
      self.modalBackgroundColor = otherKeyframe.modalBackgroundColor;
    };
    
    if self.modalBackgroundOpacity == nil {
      self.modalBackgroundOpacity = otherKeyframe.modalBackgroundOpacity;
    };
    
    if self.modalBackgroundVisualEffect == nil {
      self.modalBackgroundVisualEffect = otherKeyframe.modalBackgroundVisualEffect;
    };
    
    if self.modalBackgroundVisualEffectOpacity == nil {
      self.modalBackgroundVisualEffectOpacity = otherKeyframe.modalBackgroundVisualEffectOpacity;
    };
    
    if self.modalBackgroundVisualEffectIntensity == nil {
      self.modalBackgroundVisualEffectIntensity = otherKeyframe.modalBackgroundVisualEffectIntensity;
    };
    
    if self.modalDragHandleSize == nil {
      self.modalDragHandleSize = otherKeyframe.modalDragHandleSize;
    };
    
    if self.modalDragHandleOffset == nil {
      self.modalDragHandleOffset = otherKeyframe.modalDragHandleOffset;
    };
    
    if self.modalDragHandleColor == nil {
      self.modalDragHandleColor = otherKeyframe.modalDragHandleColor;
    };
    
    if self.modalDragHandleOpacity == nil {
      self.modalDragHandleOpacity = otherKeyframe.modalDragHandleOpacity;
    };
    
    if self.backgroundColor == nil {
      self.backgroundColor = otherKeyframe.backgroundColor;
    };
    
    if self.backgroundOpacity == nil {
      self.backgroundOpacity = otherKeyframe.backgroundOpacity;
    };
    
    if self.backgroundVisualEffect == nil {
      self.backgroundVisualEffect = otherKeyframe.backgroundVisualEffect;
    };
    
    if self.backgroundVisualEffectOpacity == nil {
      self.backgroundVisualEffectOpacity = otherKeyframe.backgroundVisualEffectOpacity;
    };
    
    if self.backgroundVisualEffectIntensity == nil {
      self.backgroundVisualEffectIntensity = otherKeyframe.backgroundVisualEffectIntensity;
    };
  };
};
