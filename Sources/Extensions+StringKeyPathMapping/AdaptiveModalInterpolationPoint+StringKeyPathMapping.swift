//
//  AdaptiveModalInterpolationPoint+StringKeyPathMapping.swift
//
//
//  Created by Dominic Go on 12/28/23.
//

import Foundation
import DGSwiftUtilities

extension AdaptiveModalInterpolationPoint: StringKeyPathMapping {

  public static var partialKeyPathMap: Dictionary<String, PartialKeyPath<Self>> = [
    "percent": \.percent,
    "snapPoint": \.snapPoint,
    "computedRect": \.computedRect,
    "modalPadding": \.modalPadding,
    "allowSnapping": \.allowSnapping,
    "backgroundTapInteraction": \.backgroundTapInteraction,
    "secondaryGestureAxisDampingPercent": \.secondaryGestureAxisDampingPercent,
    "computedModalScrollViewContentInsets": \.computedModalScrollViewContentInsets,
    "computedModalScrollViewVerticalScrollIndicatorInsets": \.computedModalScrollViewVerticalScrollIndicatorInsets,
    "computedModalScrollViewHorizontalScrollIndicatorInsets": \.computedModalScrollViewHorizontalScrollIndicatorInsets,
    "modalTransform": \.modalTransform,
    "modalBorderWidth": \.modalBorderWidth,
    "modalBorderColor": \.modalBorderColor,
    "modalShadowColor": \.modalShadowColor,
    "modalShadowOffset": \.modalShadowOffset,
    "modalShadowOpacity": \.modalShadowOpacity,
    "modalShadowRadius": \.modalShadowRadius,
    "modalCornerRadius": \.modalCornerRadius,
    "modalMaskedCorners": \.modalMaskedCorners,
    "modalOpacity": \.modalOpacity,
    "modalContentOpacity": \.modalContentOpacity,
    "modalBackgroundColor": \.modalBackgroundColor,
    "modalBackgroundOpacity": \.modalBackgroundOpacity,
    "modalBackgroundVisualEffect": \.modalBackgroundVisualEffect,
    "modalBackgroundVisualEffectOpacity": \.modalBackgroundVisualEffectOpacity,
    "modalBackgroundVisualEffectIntensity": \.modalBackgroundVisualEffectIntensity,
    "modalDragHandleCornerRadius": \.modalDragHandleCornerRadius,
    "modalDragHandleSize": \.modalDragHandleSize,
    "modalDragHandleOffset": \.modalDragHandleOffset,
    "modalDragHandleColor": \.modalDragHandleColor,
    "modalDragHandleOpacity": \.modalDragHandleOpacity,
    "backgroundColor": \.backgroundColor,
    "backgroundOpacity": \.backgroundOpacity,
    "backgroundVisualEffect": \.backgroundVisualEffect,
    "backgroundVisualEffectOpacity": \.backgroundVisualEffectOpacity,
    "backgroundVisualEffectIntensity": \.backgroundVisualEffectIntensity,
    "modalPaddingAdjusted": \.modalPaddingAdjusted,
    "isBgVisualEffectSeeThrough": \.isBgVisualEffectSeeThrough,
    "isBgDimmingViewSeeThrough": \.isBgDimmingViewSeeThrough,
    "isBgSeeThrough": \.isBgSeeThrough,
    "derivedBackgroundTapInteraction": \.derivedBackgroundTapInteraction,
  ];
};
