//
//  AdaptiveModalKeyframeConfig+StringKeyPathMapping.swift
//
//
//  Created by Dominic Go on 12/28/23.
//

import Foundation
import DGSwiftUtilities

extension AdaptiveModalKeyframeConfig: StringKeyPathMapping {

  public static var partialKeyPathMap: Dictionary<String, PartialKeyPath<Self>> = [
    "allowSnapping": \.allowSnapping,
    "backgroundTapInteraction": \.backgroundTapInteraction,
    "secondaryGestureAxisDampingPercent": \.secondaryGestureAxisDampingPercent,
    "modalScrollViewContentInsets": \.modalScrollViewContentInsets,
    "modalScrollViewVerticalScrollIndicatorInsets": \.modalScrollViewVerticalScrollIndicatorInsets,
    "modalScrollViewHorizontalScrollIndicatorInsets": \.modalScrollViewHorizontalScrollIndicatorInsets,
    "computedRect": \.computedRect,
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
    "modalDragHandleSize": \.modalDragHandleSize,
    "modalDragHandleOffset": \.modalDragHandleOffset,
    "modalDragHandleColor": \.modalDragHandleColor,
    "modalDragHandleOpacity": \.modalDragHandleOpacity,
    "modalDragHandleCornerRadius": \.modalDragHandleCornerRadius,
    "backgroundColor": \.backgroundColor,
    "backgroundOpacity": \.backgroundOpacity,
    "backgroundVisualEffect": \.backgroundVisualEffect,
    "backgroundVisualEffectOpacity": \.backgroundVisualEffectOpacity,
    "backgroundVisualEffectIntensity": \.backgroundVisualEffectIntensity,
  ];
};
