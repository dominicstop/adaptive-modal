//
//  AdaptiveModalKeyframeConfig.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/23/23.
//

import UIKit
import ComputableLayout


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
      top   : ComputableLayoutValue,
      left  : ComputableLayoutValue,
      bottom: ComputableLayoutValue,
      right : ComputableLayoutValue
    );
    
    func compute(
      usingLayoutValueContext context: ComputableLayoutValueContext
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
    modalBackgroundBlurEffectIntensity: 0,
    backgroundOpacity: 0,
    backgroundBlurEffectIntensity: 0
  );
  
  static let keyMap: [(
    keyframeKey: PartialKeyPath<Self>,
    interpolationPointKey: PartialKeyPath<AdaptiveModalInterpolationPoint>
  )] = [(
      \.computedRect,
      \.computedRect
    ), (
      \.allowSnapping,
      \.allowSnapping
    ), (
      \.backgroundTapInteraction,
      \.backgroundTapInteraction
    ), (
      \.secondaryGestureAxisDampingPercent,
      \.secondaryGestureAxisDampingPercent
    ), (
      \.computedModalScrollViewContentInsets,
      \.computedModalScrollViewContentInsets
    ), (
      \.computedModalScrollViewContentInsets,
      \.computedModalScrollViewContentInsets
    ), (
      \.computedModalScrollViewVerticalScrollIndicatorInsets,
      \.computedModalScrollViewVerticalScrollIndicatorInsets
    ), (
      \.computedModalScrollViewHorizontalScrollIndicatorInsets,
      \.computedModalScrollViewHorizontalScrollIndicatorInsets
    ),(
      \.modalTransform,
      \.modalTransform
    ), (
      \.modalBorderWidth,
      \.modalBorderWidth
    ), (
      \.modalBorderColor,
      \.modalBorderColor
    ), (
      \.modalShadowColor,
      \.modalShadowColor
    ), (
      \.modalShadowOffset,
      \.modalShadowOffset
    ), (
      \.modalShadowOpacity,
      \.modalShadowOpacity
    ), (
      \.modalShadowRadius,
      \.modalShadowRadius
    ), (
      \.modalCornerRadius,
      \.modalCornerRadius
    ), (
      \.modalMaskedCorners,
      \.modalMaskedCorners
    ), (
      \.modalOpacity,
      \.modalOpacity
    ), (
      \.modalContentOpacity,
      \.modalContentOpacity
    ), (
      \.modalBackgroundColor,
      \.modalBackgroundColor
    ), (
      \.modalBackgroundOpacity,
      \.modalBackgroundOpacity
    ), (
      \.modalBackgroundBlurEffectStyle,
      \.modalBackgroundBlurEffectStyle
    ), (
      \.modalBackgroundBlurEffectOpacity,
      \.modalBackgroundBlurEffectOpacity
    ), (
      \.modalBackgroundBlurEffectIntensity,
      \.modalBackgroundBlurEffectIntensity
    ), (
      \.modalDragHandleSize,
      \.modalDragHandleSize
    ), (
      \.modalDragHandleOffset,
      \.modalDragHandleOffset
    ), (
      \.modalDragHandleColor,
      \.modalDragHandleColor
    ), (
      \.modalDragHandleOpacity,
      \.modalDragHandleOpacity
    ), (
      \.modalDragHandleCornerRadius,
      \.modalDragHandleCornerRadius
    ), (
      \.backgroundColor,
      \.backgroundColor
    ), (
      \.backgroundOpacity,
      \.backgroundOpacity
    ), (
      \.backgroundBlurEffectStyle,
      \.backgroundBlurEffectStyle
    ), (
      \.backgroundBlurEffectOpacity,
      \.backgroundBlurEffectOpacity
    ), (
      \.backgroundBlurEffectIntensity,
      \.backgroundBlurEffectIntensity
    ),
  ];

  // MARK: - Properties
  // ------------------
  
  public var allowSnapping: Bool?;

  public var backgroundTapInteraction: BackgroundInteractionMode?;
  public var secondaryGestureAxisDampingPercent: CGFloat?;
  
  public var modalScrollViewContentInsets: LayoutValueEdgeInsets?;
  public var modalScrollViewVerticalScrollIndicatorInsets: LayoutValueEdgeInsets?;
  public var modalScrollViewHorizontalScrollIndicatorInsets: LayoutValueEdgeInsets?;
  
  // MARK: - Properties - Internal Keyframes
  // ---------------------------------------
  
  var computedRect: CGRect?;
  
  var computedModalScrollViewContentInsets: UIEdgeInsets?;
  var computedModalScrollViewVerticalScrollIndicatorInsets: UIEdgeInsets?;
  var computedModalScrollViewHorizontalScrollIndicatorInsets: UIEdgeInsets?;
  
  // MARK: - Properties - Keyframes
  // --------------------------------

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
  
  public var modalBackgroundBlurEffectStyle: UIBlurEffect.Style?;
  public var modalBackgroundBlurEffectOpacity: CGFloat?;
  public var modalBackgroundBlurEffectIntensity: CGFloat?;
  
  public var modalDragHandleSize: CGSize?;
  public var modalDragHandleOffset: CGFloat?;
  public var modalDragHandleColor: UIColor?;
  public var modalDragHandleOpacity: CGFloat?;
  public var modalDragHandleCornerRadius: CGFloat?;
  
  public var backgroundColor: UIColor?;
  public var backgroundOpacity: CGFloat?;
  
  public var backgroundBlurEffectStyle: UIBlurEffect.Style?;
  public var backgroundBlurEffectOpacity: CGFloat?;
  public var backgroundBlurEffectIntensity: CGFloat?;
  
  public init(
    allowSnapping: Bool? = nil,
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
    modalBackgroundBlurEffectStyle: UIBlurEffect.Style? = nil,
    modalBackgroundBlurEffectOpacity: CGFloat? = nil,
    modalBackgroundBlurEffectIntensity: CGFloat? = nil,
    modalDragHandleSize: CGSize? = nil,
    modalDragHandleOffset: CGFloat? = nil,
    modalDragHandleColor: UIColor? = nil,
    modalDragHandleOpacity: CGFloat? = nil,
    modalDragHandleCornerRadius: CGFloat? = nil,
    backgroundColor: UIColor? = nil,
    backgroundOpacity: CGFloat? = nil,
    backgroundBlurEffectStyle: UIBlurEffect.Style? = nil,
    backgroundBlurEffectOpacity: CGFloat? = nil,
    backgroundBlurEffectIntensity: CGFloat? = nil
  ) {
  
    self.allowSnapping = allowSnapping;
    
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
    
    self.modalBackgroundBlurEffectStyle = modalBackgroundBlurEffectStyle;
    self.modalBackgroundBlurEffectOpacity = modalBackgroundBlurEffectOpacity;
    self.modalBackgroundBlurEffectIntensity = modalBackgroundBlurEffectIntensity;
    
    self.modalDragHandleSize = modalDragHandleSize;
    self.modalDragHandleOffset = modalDragHandleOffset
    self.modalDragHandleColor = modalDragHandleColor;
    self.modalDragHandleOpacity = modalDragHandleOpacity;
    self.modalDragHandleCornerRadius = modalDragHandleCornerRadius;
    
    self.backgroundColor = backgroundColor;
    self.backgroundOpacity = backgroundOpacity;
    
    self.backgroundBlurEffectStyle = backgroundBlurEffectStyle;
    self.backgroundBlurEffectOpacity = backgroundBlurEffectOpacity;
    self.backgroundBlurEffectIntensity = backgroundBlurEffectIntensity;
  };
  
  init(fromInterpolationPoint interpolationPoint: AdaptiveModalInterpolationPoint){
    
    typealias KeyframeKey<T> = WritableKeyPath<Self, T>;
  
    typealias InterpolationPointKey<T> =
      WritableKeyPath<AdaptiveModalInterpolationPoint, T>;
      
    Self.keyMap.forEach {
      switch ($0.keyframeKey, $0.interpolationPointKey) {
        case (
          let keyframeKey as KeyframeKey<CGRect?>,
          let interpolationPointKey as InterpolationPointKey<CGRect>
        ):
          self[keyPath: keyframeKey] =
            interpolationPoint[keyPath: interpolationPointKey];
            
        case (
          let keyframeKey as KeyframeKey<Bool?>,
          let interpolationPointKey as InterpolationPointKey<Bool>
        ):
          self[keyPath: keyframeKey] =
            interpolationPoint[keyPath: interpolationPointKey];
        
        case (
          let keyframeKey as KeyframeKey<BackgroundInteractionMode?>,
          let interpolationPointKey as InterpolationPointKey<BackgroundInteractionMode>
        ):
          self[keyPath: keyframeKey] =
            interpolationPoint[keyPath: interpolationPointKey];
        
        case (
          let keyframeKey as KeyframeKey<LayoutValueEdgeInsets?>,
          let interpolationPointKey as InterpolationPointKey<LayoutValueEdgeInsets>
        ):
          self[keyPath: keyframeKey] =
            interpolationPoint[keyPath: interpolationPointKey];
        
        case (
          let keyframeKey as KeyframeKey<CGFloat?>,
          let interpolationPointKey as InterpolationPointKey<CGFloat>
        ):
          self[keyPath: keyframeKey] =
            interpolationPoint[keyPath: interpolationPointKey];
        
        case (
          let keyframeKey as KeyframeKey<UIColor?>,
          let interpolationPointKey as InterpolationPointKey<UIColor>
        ):
          self[keyPath: keyframeKey] =
            interpolationPoint[keyPath: interpolationPointKey];
        
        case (
          let keyframeKey as KeyframeKey<CGSize?>,
          let interpolationPointKey as InterpolationPointKey<CGSize>
        ):
          self[keyPath: keyframeKey] =
            interpolationPoint[keyPath: interpolationPointKey];
        
        case (
          let keyframeKey as KeyframeKey<CACornerMask?>,
          let interpolationPointKey as InterpolationPointKey<CACornerMask>
        ):
          self[keyPath: keyframeKey] =
            interpolationPoint[keyPath: interpolationPointKey];
            
        case (
          let keyframeKey as KeyframeKey<UIVisualEffect?>,
          let interpolationPointKey as InterpolationPointKey<UIVisualEffect?>
        ):
          self[keyPath: keyframeKey] =
            interpolationPoint[keyPath: interpolationPointKey];
   
        case (
          let keyframeKey as KeyframeKey<Transform3D?>,
          let interpolationPointKey as InterpolationPointKey<Transform3D>
        ):
          self[keyPath: keyframeKey] =
            interpolationPoint[keyPath: interpolationPointKey];
        
        default:
          break;
      };
    };
  };
  
  public mutating func setNonNilValues(using otherKeyframe: Self) {
    Self.keyMap.forEach {
      let value =  self[keyPath: $0.0];
      
      guard value is ExpressibleByNilLiteral,
            let optionalValue = value as? OptionalUnwrappable,
            !optionalValue.isSome()
      else { return };
      
      switch $0.keyframeKey {
        case let key as WritableKeyPath<Self, Bool?>:
          self[keyPath: key] = otherKeyframe[keyPath: key];
      
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
          
        case let key as WritableKeyPath<Self, UIVisualEffect?>:
          self[keyPath: key] = otherKeyframe[keyPath: key];
          
        case let key as WritableKeyPath<Self, Transform3D?>:
          guard let otherValue = otherKeyframe[keyPath: key] else { break };
          self[keyPath: key]?.setNonNilValues(with: otherValue);

        default:
          break;
      };
    };
  };
  
  public mutating func setIfNilValue<T>(
    forKey key: WritableKeyPath<Self, T?>,
    value: T
  ) {
    guard self[keyPath: key] == nil else { return };
    self[keyPath: key] = value;
  };
};

