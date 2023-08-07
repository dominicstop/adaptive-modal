//
//  AdaptiveModalKeyframeConfig.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/23/23.
//

import UIKit

public struct AdaptiveModalKeyframeConfig: Equatable {
  
  // MARK: - Embedded Types
  // ----------------------

  public enum BackgroundInteractionMode: String, Equatable {
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
  
  public enum LayoutValueEdgeInsets: Equatable {
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
  
  // MARK: - Static Properties
  // -------------------------
  
  public static let defaultFirstKeyframe: Self = .init(
    modalContentOpacity: 1
  );

  public static let defaultUndershootKeyframe: Self = .init(
    backgroundTapInteraction: .default,
    modalTransform: .default,
    modalContentOpacity: 0.5,
    backgroundOpacity: 0,
    backgroundVisualEffectIntensity: 0
  );
  
  static let nilKeys: [PartialKeyPath<Self>] = [
    \.backgroundTapInteraction,
    \.secondaryGestureAxisDampingPercent,
    
    \.modalScrollViewContentInsets,
    \.modalScrollViewContentInsets,
    \.modalScrollViewVerticalScrollIndicatorInsets,
    \.modalScrollViewHorizontalScrollIndicatorInsets,
    
    // \.modalTransform,
    \.modalBorderWidth,
    \.modalBorderColor,
    \.modalShadowColor,
    \.modalShadowOffset,
    \.modalShadowOpacity,
    \.modalShadowRadius,
    \.modalCornerRadius,
    \.modalMaskedCorners,
    \.modalOpacity,
    \.modalContentOpacity,
    \.modalBackgroundColor,
    \.modalBackgroundOpacity,
    \.modalBackgroundVisualEffect,
    \.modalBackgroundVisualEffectOpacity,
    \.modalBackgroundVisualEffectIntensity,
    \.modalDragHandleSize,
    \.modalDragHandleOffset,
    \.modalDragHandleColor,
    \.modalDragHandleOpacity,
    \.modalDragHandleCornerRadius,
    \.backgroundColor,
    \.backgroundOpacity,
    \.backgroundVisualEffect,
    \.backgroundVisualEffectOpacity,
    \.backgroundVisualEffectIntensity,
  ];

  // MARK: - Properties
  // ------------------

  public var backgroundTapInteraction: BackgroundInteractionMode?;
  public var secondaryGestureAxisDampingPercent: CGFloat?;
  
  public var modalScrollViewContentInsets: LayoutValueEdgeInsets?;
  public var modalScrollViewVerticalScrollIndicatorInsets: LayoutValueEdgeInsets?;
  public var modalScrollViewHorizontalScrollIndicatorInsets: LayoutValueEdgeInsets?;
  
  // MARK: - Properties - Keyframes
  // ------------------------------

  public var modalTransform: Transform3D?;
  
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
    
    modalTransform: Transform3D? = nil,
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
    
    self.modalTransform = modalTransform;
    
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
    Self.nilKeys.forEach {
      let value =  self[keyPath: $0];
      
      guard value is ExpressibleByNilLiteral,
            let optionalValue = value as? OptionalUnwrappable,
            !optionalValue.isSome()
      else { return };
      
      switch $0 {
        case let key as WritableKeyPath<Self, BackgroundInteractionMode?>:
          self[keyPath: key] = otherKeyframe[keyPath: key];
          
        case let key as WritableKeyPath<Self, LayoutValueEdgeInsets?>:
          self[keyPath: key] = otherKeyframe[keyPath: key];
          
        case let key as WritableKeyPath<Self, CGFloat?>:
          self[keyPath: key] = otherKeyframe[keyPath: key];
        
        case let key as WritableKeyPath<Self, UIColor?>:
          self[keyPath: key] = otherKeyframe[keyPath: key];
          
        case let key as WritableKeyPath<Self, CGSize?>:
          self[keyPath: key] = otherKeyframe[keyPath: key];
          
        case let key as WritableKeyPath<Self, CACornerMask?>:
          self[keyPath: key] = otherKeyframe[keyPath: key];
          
        default:
          break;
      };
    };
  };
};

