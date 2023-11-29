//
//  AdaptiveModalConfigDemoPresets.swift
//  adaptive-modal-example
//
//  Created by Dominic Go on 6/22/23.
//

import UIKit
import AdaptiveModal
import ComputableLayout
import DGSwiftUtilities

enum AdaptiveModalConfigDemoPresets: CaseIterable {

  case demo01;
  case demo02;
  case demo03;
  case demo04;
  case demo05;
  case demo06;
  case demo07;
  case demo08;
  case demo09;
  case demo10;
  case demo11;
  case demo12;
  case demo13;
  case demo14;
  case demo15;
  
  var config: AdaptiveModalConfig {
    switch self {
    
      // Index: 0
      case .demo01: return AdaptiveModalConfig(
        snapPoints: [
          // Snap Point 1
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .percent(percentValue: 0.3)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalShadowOffset: .init(width: 0, height: -2),
              modalShadowOpacity: 0.2,
              modalShadowRadius: 7,
              modalCornerRadius: 25,
              modalMaskedCorners: .topCorners,
              modalBackgroundOpacity: 0.9,
              modalBackgroundVisualEffect: UIBlurEffect(style: .systemUltraThinMaterial),
              modalBackgroundVisualEffectIntensity: 1,
              backgroundOpacity: 0,
              backgroundVisualEffect: UIBlurEffect(style: .systemUltraThinMaterialDark),
              backgroundVisualEffectIntensity: 0
            )
          ),
          
          // Snap Point 2
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .percent(percentValue: 0.5),
              marginLeft: .constant(15),
              marginRight: .constant(15),
              marginBottom: .safeAreaInsets(
                insetKey: \.bottom,
                minValue: .constant(15)
              )
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              secondaryGestureAxisDampingPercent: 1,
              modalShadowOffset: .init(width: 2, height: 2),
              modalShadowOpacity: 0.2,
              modalShadowRadius: 15,
              modalCornerRadius: 10,
              modalMaskedCorners: .allCorners,
              modalBackgroundOpacity: 0.85,
              modalBackgroundVisualEffectIntensity: 0.6,
              backgroundOpacity: 0.1,
              backgroundVisualEffectIntensity: 0.075
            )
          ),
          
          // Snap Point 3
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .center,
              width: .percent(
                percentValue: 0.85,
                maxValue: .constant(ScreenSize.iPhone8.size.width)
              ),
              height: .percent(
                percentValue: 0.75,
                maxValue: .constant(ScreenSize.iPhone8.size.height)
              )
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              secondaryGestureAxisDampingPercent: 0.8,
              modalShadowOffset: .init(width: 2, height: 2),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 10,
              modalCornerRadius: 20,
              modalMaskedCorners: .allCorners,
              modalBackgroundOpacity: 0.8,
              modalBackgroundVisualEffectIntensity: 1,
              backgroundOpacity: 0,
              backgroundVisualEffectIntensity: 0.5
            )
          ),
          
          // Snap Point 4
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: ComputableLayoutValue(
                mode: .stretch
              ),
              height: ComputableLayoutValue(
                mode: .stretch
              ),
              marginTop: .safeAreaInsets(insetKey: \.top)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              secondaryGestureAxisDampingPercent: 1,
              modalShadowOffset: .init(width: 0, height: -1),
              modalShadowOpacity: 0.4,
              modalShadowRadius: 10,
              modalCornerRadius: 25,
              modalMaskedCorners: .topCorners,
              modalBackgroundOpacity: 0.83,
              modalBackgroundVisualEffectIntensity: 1,
              backgroundVisualEffectIntensity: 1
            )
          ),
        ],
        snapDirection: .bottomToTop,
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .fitScreen
        )
      );
      
      // Index: 1
      case .demo02: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.8),
              height: .percent(percentValue: 0.2)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalTransform: Transform3D(
                rotateX: .degrees(0)
              ),
              modalShadowOffset: .init(width: 0, height: -2),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 7,
              modalCornerRadius: 10,
              modalMaskedCorners: .topCorners,
              modalContentOpacity: 1,
              backgroundOpacity: 0,
              backgroundVisualEffect: UIBlurEffect(style: .regular),
              backgroundVisualEffectIntensity: 0
            )
          ),
          
          // snap point - 2
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.8),
              height: .percent(percentValue: 0.4)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              backgroundTapInteraction: .dismiss,
              modalShadowOffset: .init(width: 1, height: 1),
              modalShadowOpacity: 0.4,
              modalShadowRadius: 7,
              modalCornerRadius: 15,
              modalMaskedCorners: .topCorners,
              backgroundOpacity: 0.1
            )
          ),
          // snap point - 3
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.9),
              height: .percent(percentValue: 0.7)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              backgroundTapInteraction: .ignore,
              modalShadowOffset: .init(width: 2, height: 2),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 8,
              backgroundOpacity: 0.3,
              backgroundVisualEffect: UIBlurEffect(style: .regular),
              backgroundVisualEffectIntensity: 0.3
            )
          ),
        ],
        snapDirection: .bottomToTop,
        undershootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .automatic,
          keyframeConfig: AdaptiveModalKeyframeConfig(
            modalTransform: Transform3D(
              rotateX: .degrees(-25),
              perspective: 1 / 500
            ),
            modalContentOpacity: 0.5
          )
        ),
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .fitScreenVertically
        )
      );
      
      // Index: 2
      case .demo03: return .init(
        snapPoints: [
          // snap point - 1
          .init(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .left,
              verticalAlignment: .center,
              width: .percent(percentValue: 0.5),
              height: .percent(percentValue: 0.65),
              marginLeft: .constant(15)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              secondaryGestureAxisDampingPercent: 0.5,
              modalTransform: .init(
                scaleX: 1,
                scaleY: 1
              ),
              modalShadowOffset: .init(width: 1, height: 1),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 8,
              modalCornerRadius: 10,
              modalContentOpacity: 1,
              modalBackgroundOpacity: 0.87,
              modalBackgroundVisualEffect: UIBlurEffect(style: .regular),
              modalBackgroundVisualEffectIntensity: 1,
              modalDragHandleOffset: -14,
              modalDragHandleColor: .systemBackground,
              backgroundVisualEffect: UIBlurEffect(style: .regular),
              backgroundVisualEffectIntensity: 0.04
            )
          ),
          
          // snap point - 2
          .init(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .center,
              width: .stretch,
              height: .percent(percentValue: 0.85),
              marginLeft: .constant(20),
              marginRight: .constant(20)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              secondaryGestureAxisDampingPercent: 1,
              modalShadowOffset: .init(width: 2, height: 2),
              modalShadowOpacity: 0.2,
              modalShadowRadius: 15,
              modalCornerRadius: 15,
              modalBackgroundOpacity: 0.9,
              modalBackgroundVisualEffectIntensity: 0.5,
              modalDragHandleOffset: 6,
              modalDragHandleColor: .systemGray,
              backgroundVisualEffectIntensity: 0.5
            )
          ),
        ],
        snapDirection: .leftToRight,
        undershootSnapPoint: .init(
          layoutPreset: .offscreenLeft,
          keyframeConfig: .init(
            modalTransform: .init(
              scaleX: 0.5,
              scaleY: 0.5
            ),
            modalCornerRadius: 5,
            modalContentOpacity: 0.3,
            modalDragHandleOffset: -14,
            backgroundVisualEffectIntensity: 0
          )
        ),
        overshootSnapPoint: .init(
          layoutPreset: .offscreenRight
        )
      );
      
      // Index: 3
      case .demo04: return AdaptiveModalConfig(
        snapPoints: [
          // 1
          .init(
            layoutConfig: .init(
              horizontalAlignment: .center,
              verticalAlignment: .top,
              width: .stretch,
              height: .percent(percentValue: 0.2),
              marginLeft: .constant(10),
              marginRight: .constant(10),
              marginTop: .multipleValues([
                .safeAreaInsets(insetKey: \.top),
                .constant(10)
              ])
            ),
            keyframeConfig: .init(
              modalTransform: .init(
                translateX: 1,
                translateY: 1,
                scaleX: 1,
                scaleY: 1
              ),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 10,
              modalCornerRadius: 10
            )
          ),
          
          // 2
          .init(
            layoutConfig: .init(
              horizontalAlignment: .center,
              verticalAlignment: .center,
              width: .stretch,
              height: .percent(percentValue: 0.5),
              marginLeft: .constant(15),
              marginRight: .constant(15)
            ),
            keyframeConfig: .init(
              modalShadowOffset: .init(width: 2, height: 2),
              modalShadowOpacity: 0.2,
              modalShadowRadius: 5,
              modalCornerRadius: 15,
              backgroundOpacity: 0.25
            )
          )
        ],
        snapDirection: .topToBottom,
        undershootSnapPoint: .init(
          layoutPreset: .offscreenTop,
          keyframeConfig: .init(
            modalTransform: .init(
              scaleX: 0.75,
              scaleY: 0.75
            )
          )
        ),
        overshootSnapPoint: .init(
          layoutPreset: .offscreenBottom,
          keyframeConfig: .init(
            modalTransform: .init(
              scaleX: 0.9,
              scaleY: 0.9
            ),
            modalOpacity: 0.8,
            backgroundOpacity: 0
          )
        )
      );
      
      // Index: 4
      case .demo05: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .left,
              verticalAlignment: .center,
              width: .percent(percentValue: 0.7),
              height: .stretch
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalShadowOffset: .init(width: 1, height: 0),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 8,
              modalBackgroundOpacity: 0.87,
              modalBackgroundVisualEffect: UIBlurEffect(style: .regular),
              modalBackgroundVisualEffectIntensity: 1,
              backgroundVisualEffect: UIBlurEffect(style: .regular),
              backgroundVisualEffectIntensity: 0.04
            )
          ),
          
          // snap point - 2
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .center,
              width: .stretch(
                offsetValue: .constant(40),
                offsetOperation: .subtract
              ),
              height: .stretch(
                offsetValue: .multipleValues([
                  .safeAreaInsets(insetKey: \.top),
                  .safeAreaInsets(insetKey: \.bottom),
                  .constant(40),
                ]),
                offsetOperation: .subtract
              )
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalShadowOffset: .init(width: 2, height: 2),
              modalShadowOpacity: 0.2,
              modalShadowRadius: 15,
              modalCornerRadius: 15,
              modalBackgroundOpacity: 0.9,
              modalBackgroundVisualEffectIntensity: 0.5,
              backgroundVisualEffectIntensity: 0.5
            )
          ),
        ],
        snapDirection: .leftToRight,
        undershootSnapPoint: .init(
          layoutPreset: .offscreenLeft,
          keyframeConfig: .init(
            backgroundVisualEffectIntensity: 0
          )
        ),
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .edgeRight
        )
      );
      
      // Index: 5
      case .demo06: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.8),
              height: .percent(percentValue: 0.2),
              marginBottom: .init(
                mode: .safeAreaInsets(insetKey: \.bottom),
                minValue: .constant(15)
              )
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalShadowOffset: .init(width: 0, height: -2),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 7,
              modalCornerRadius: 10,
              backgroundOpacity: 0,
              backgroundVisualEffect: UIBlurEffect(style: .regular),
              backgroundVisualEffectIntensity: 0
            )
          ),
          
          // snap point - 2
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.85),
              height: .percent(percentValue: 0.5),
              marginBottom: .init(
                mode: .safeAreaInsets(insetKey: \.bottom),
                minValue: .constant(15)
              )
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalShadowOffset: .init(width: 1, height: 1),
              modalShadowOpacity: 0.4,
              modalShadowRadius: 7,
              modalCornerRadius: 15,
              backgroundOpacity: 0.1
            )
          ),
          
          // snap point - 3
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.87),
              height: .percent(percentValue: 0.7),
              marginBottom: .init(
                mode: .safeAreaInsets(insetKey: \.bottom),
                minValue: .constant(15)
              )
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalShadowOffset: .init(width: 2, height: 2),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 8,
              backgroundOpacity: 0.3,
              backgroundVisualEffectIntensity: 0.3
            )
          ),
        ],
        snapDirection: .bottomToTop,
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .layoutConfig(
            .init(
              horizontalAlignment: .center,
              verticalAlignment: .center,
              width: .percent(percentValue: 0.87),
              height: .stretch,
              marginTop: .init(
                mode: .safeAreaInsets(insetKey: \.top),
                minValue: .constant(15)
              ),
              marginBottom: .init(
                mode: .safeAreaInsets(insetKey: \.bottom),
                minValue: .constant(15)
              )
            )
          ),
          keyframeConfig: AdaptiveModalKeyframeConfig(
            modalShadowOffset: .init(width: 3, height: 3),
            modalShadowOpacity: 0.35,
            modalShadowRadius: 15
          )
        )
      );
      
      // Index: 6
      case .demo07: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .left,
              verticalAlignment: .center,
              width: .percent(percentValue: 0.7),
              height: .percent(percentValue: 0.65),
              marginLeft: .constant(15)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              secondaryGestureAxisDampingPercent: 0.8,
              modalTransform: .init(
                scaleX: 1,
                scaleY: 1
              ),
              modalShadowOffset: .init(width: 1, height: 1),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 10,
              modalCornerRadius: 15,
              modalBackgroundOpacity: 0.85,
              modalBackgroundVisualEffectIntensity: 0.9,
              backgroundColor: .white,
              backgroundOpacity: 0.15,
              backgroundVisualEffectIntensity: 0.05
            )
          ),
          
          // snap point - 2
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .center,
              width: .stretch,
              height: .stretch
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              secondaryGestureAxisDampingPercent: 1,
              modalShadowOffset: .zero,
              modalShadowOpacity: 0,
              modalShadowRadius: 0,
              modalBackgroundOpacity: 0,
              modalBackgroundVisualEffectOpacity: 0,
              modalBackgroundVisualEffectIntensity: 0,
              modalDragHandleOpacity: 0,
              backgroundColor: .white,
              backgroundOpacity: 0.75,
              backgroundVisualEffectIntensity: 1
            )
          ),
        ],
        snapDirection: .leftToRight,
        undershootSnapPoint: .init(
          layoutPreset: .offscreenLeft,
          keyframeConfig: .init(
            modalTransform: .init(
              scaleX: 0.5,
              scaleY: 0.5
            ),
            modalCornerRadius: 10,
            modalBackgroundOpacity: 1,
            modalBackgroundVisualEffect: UIBlurEffect(style: .regular),
            modalBackgroundVisualEffectIntensity: 0,
            backgroundVisualEffect: UIBlurEffect(style: .regular),
            backgroundVisualEffectIntensity: 0
          )
        ),
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .offscreenRight
        )
      );
      
      // Index: 7
      case .demo08: return AdaptiveModalConfig(
        snapPoints: [
          // Snap Point 1
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .percent(percentValue: 0.3)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalShadowOffset: .init(width: 0, height: -2),
              modalShadowOpacity: 0.2,
              modalShadowRadius: 7,
              modalCornerRadius: 0,
              modalMaskedCorners: [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
              ],
              modalBackgroundOpacity: 0.9,
              modalBackgroundVisualEffect: UIBlurEffect(style: .systemUltraThinMaterial),
              modalBackgroundVisualEffectIntensity: 1,
              backgroundVisualEffect: UIBlurEffect(style: .regular),
              backgroundVisualEffectIntensity: 0
            )
          ),
          
          // Snap Point 2
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .percent(percentValue: 0.75)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalShadowOffset: .init(width: 0, height: -2),
              modalShadowOpacity: 0.2,
              modalShadowRadius: 7,
              modalCornerRadius: 15,
              modalMaskedCorners: [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
              ],
              modalBackgroundOpacity: 0.85,
              modalBackgroundVisualEffectIntensity: 0.25,
              backgroundVisualEffectIntensity: 0.75
            )
          )
        ],
        snapDirection: .bottomToTop,
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .fitScreen
        )
      );
      
      // Index: 8 - Keyboard
      case .demo09: return AdaptiveModalConfig(
        snapPoints: [
          // Snap Point 1
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .percent(percentValue: 0.3),
              marginLeft: .multipleValues([
                .safeAreaInsets(insetKey: \.left),
                .constant(15),
              ]),
              marginRight: .multipleValues([
                .safeAreaInsets(insetKey: \.right),
                .constant(15)
              ]),
              marginBottom: .multipleValues([
                .safeAreaInsets(insetKey: \.bottom),
                .keyboardRelativeSize(sizeKey: \.height),
                .constant(15)
              ])
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalShadowOffset: .init(width: 0, height: -2),
              modalShadowOpacity: 0.2,
              modalShadowRadius: 7,
              modalCornerRadius: 12,
              modalMaskedCorners: .allCorners,
              modalBackgroundOpacity: 0.9,
              modalBackgroundVisualEffect: UIBlurEffect(style: .systemUltraThinMaterial),
              modalBackgroundVisualEffectIntensity: 1,
              backgroundVisualEffect: UIBlurEffect(style: .regular),
              backgroundVisualEffectIntensity: 0
            )
          ),
        ],
        snapDirection: .bottomToTop,
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .fitScreenVertically
        )
      );
      
      // Index: 9
      case .demo10: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            layoutConfig: .init(
              horizontalAlignment: .left,
              verticalAlignment: .center,
              width: .percent(percentValue: 0.5),
              height: .percent(percentValue: 0.5)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalTransform: .init(
                scaleX: 1,
                scaleY: 1,
                rotateY: .degrees(0)
              ),
              modalShadowOffset: .init(width: 1, height: 1),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 8,
              modalCornerRadius: 10,
              modalMaskedCorners: .rightCorners,
              modalContentOpacity: 1,
              modalBackgroundOpacity: 0.8,
              modalBackgroundVisualEffect: UIBlurEffect(style: .regular),
              modalBackgroundVisualEffectIntensity: 1,
              modalDragHandleOffset: -14,
              modalDragHandleColor: .systemBackground,
              backgroundVisualEffect: UIBlurEffect(style: .regular),
              backgroundVisualEffectIntensity: 0.04
            )
          ),
          
          // snap point - 2
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .left,
              verticalAlignment: .center,
              width: .percent(percentValue: 0.7),
              height: .percent(percentValue: 0.85)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalShadowOffset: .init(width: 2, height: 2),
              modalShadowOpacity: 0.2,
              modalShadowRadius: 12,
              modalCornerRadius: 15,
              modalBackgroundOpacity: 0.9,
              modalBackgroundVisualEffectIntensity: 0.6,
              modalDragHandleOffset: 6,
              modalDragHandleColor: .systemGray,
              backgroundVisualEffectIntensity: 0.4
            )
          ),
          
          // snap point - 3
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .left,
              verticalAlignment: .center,
              width: .percent(percentValue: 0.95),
              height: .stretch
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalShadowOffset: .init(width: 2.5, height: 0),
              modalShadowOpacity: 0.35,
              modalShadowRadius: 10,
              modalCornerRadius: 20,
              modalBackgroundOpacity: 0.87,
              modalBackgroundVisualEffectIntensity: 0.4,
              modalDragHandleOffset: 6,
              modalDragHandleColor: .systemGray,
              backgroundVisualEffectIntensity: 0.9
            )
          ),
        ],
        snapDirection: .leftToRight,
        undershootSnapPoint: .init(
          layoutPreset: .offscreenLeft,
          keyframeConfig: .init(
            modalTransform: .init(
              scaleX: 0.5,
              scaleY: 0.5,
              rotateY: .degrees(-45),
              perspective: 1 / 750
            ),
            modalCornerRadius: 5,
            modalContentOpacity: 0.25,
            modalBackgroundVisualEffectIntensity: 1,
            modalDragHandleOffset: -14,
            backgroundVisualEffectIntensity: 0
          )
        ),
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .fitScreenHorizontally
        )
      );
      
      // Index: 10 - Keyboard
      case .demo11: return AdaptiveModalConfig(
        snapPoints: [
          // Snap Point 1
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .multipleValues([
                .percent(percentValue: 0.3),
                .conditionalLayoutValue(
                  condition: .keyboardPresent,
                  trueValue: .keyboardRelativeSize(sizeKey: \.height),
                  falseValue: .safeAreaInsets(insetKey: \.bottom)
                )
              ]),
              paddingLeft: .multipleValues([
                .safeAreaInsets(insetKey: \.left),
                .constant(15),
              ]),
              paddingRight: .multipleValues([
                .safeAreaInsets(insetKey: \.right),
                .constant(15)
              ]),
              paddingBottom: .conditionalLayoutValue(
                condition: .keyboardPresent,
                trueValue: .keyboardRelativeSize(sizeKey: \.height),
                falseValue: .safeAreaInsets(insetKey: \.bottom)
              )
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalShadowOffset: .init(width: 0, height: -2),
              modalShadowOpacity: 0.25,
              modalShadowRadius: 7,
              modalCornerRadius: 12,
              modalMaskedCorners: .topCorners,
              modalBackgroundOpacity: 0.9,
              modalBackgroundVisualEffect: UIBlurEffect(style: .systemUltraThinMaterial),
              modalBackgroundVisualEffectIntensity: 1,
              backgroundVisualEffect: UIBlurEffect(style: .regular),
              backgroundVisualEffectIntensity: 0
            )
          ),
        ],
        snapDirection: .bottomToTop,
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .fitScreenVertically
        )
      );
      
      // Index: 11
      case .demo12: return AdaptiveModalConfig(
        snapPoints: [
          .init(
            layoutConfig: .init(
              horizontalAlignment: .right,
              verticalAlignment: .center,
              width: .percent(percentValue: 0.5),
              height: .percent(percentValue: 0.5),
              marginRight: .multipleValues([
                .safeAreaInsets(insetKey: \.right),
                .constant(10),
              ])
            ),
            keyframeConfig: .init(
              secondaryGestureAxisDampingPercent: 0.25,
              modalCornerRadius: 10
            )
          ),
          .init(
            layoutConfig: .init(
              horizontalAlignment: .left,
              verticalAlignment: .center,
              width: .percent(percentValue: 0.5),
              height: .percent(percentValue: 0.5),
              marginLeft: .multipleValues([
                .safeAreaInsets(insetKey: \.left),
                .constant(10),
              ])
            )
          ),
        ],
        snapDirection: .rightToLeft,
        undershootSnapPoint: .init(
          layoutPreset: .offscreenRight
        ),
        overshootSnapPoint: .init(
          layoutPreset: .offscreenLeft
        ),
        dragHandlePosition: .none
      );
      
      // Index: 12
      case .demo13: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            layoutConfig: .init(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.9),
              height: .percent(percentValue: 0.3)
            ),
            keyframeConfig: .init(
              modalShadowOffset: .init(width: 0, height: -2),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 7,
              modalCornerRadius: 10,
              modalMaskedCorners: .topCorners,
              modalBackgroundOpacity: 0.9,
              modalBackgroundVisualEffect: UIBlurEffect(style: .regular),
              modalBackgroundVisualEffectIntensity: 1,
              backgroundOpacity: 0,
              backgroundVisualEffect: UIBlurEffect(style: .regular),
              backgroundVisualEffectIntensity: 0
            )
          ),
          
          // snap point - 2
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.9),
              height: .percent(percentValue: 0.7)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalShadowOffset: .init(width: 2, height: 2),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 8,
              modalBackgroundOpacity: 0.8,
              modalBackgroundVisualEffectIntensity: 0.8,
              backgroundOpacity: 0.2,
              backgroundVisualEffectIntensity: 0.1
            )
          ),
        ],
        snapDirection: .bottomToTop,
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .fitScreenVertically
        )
      );
      
      // Index: 13
      case .demo14: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            layoutConfig: .init(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .stretch
            ),
            keyframeConfig: .init(
              modalContentOpacity: 1,
              backgroundOpacity: 0.2,
              backgroundVisualEffectIntensity: 1
            )
          ),
        ],
        snapDirection: .bottomToTop,
        undershootSnapPoint: .init(
          layoutPreset: .offscreenBottom,
          keyframeConfig: .init(
            modalContentOpacity: 0,
            modalBackgroundOpacity: 0,
            backgroundColor: .white,
            backgroundOpacity: 0,
            backgroundVisualEffect: UIBlurEffect(style: .regular),
            backgroundVisualEffectIntensity: 0
          )
        ),
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .halfOffscreenTop
        ),
        dragHandlePosition: .none
      );
      
      // Index: 14
      case .demo15: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            layoutConfig: .init(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.9),
              height: .percent(
                percentValue: 0.3,
                minValue: .constant(300)
              ),
              marginBottom: .safeAreaInsets(
                insetKey: \.bottom,
                minValue: .constant(15)
              ),
              paddingTop: .constant(0)
            ),
            keyframeConfig: .init(
              secondaryGestureAxisDampingPercent: 0.5,
              modalTransform: .init(
                scaleX: 1,
                scaleY: 1
              ),
              modalShadowOffset: .init(width: 0, height: -2),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 7,
              modalCornerRadius: 15,
              modalMaskedCorners: .allCorners,
              modalContentOpacity: 1,
              modalBackgroundOpacity: 0.9,
              modalBackgroundVisualEffect: UIBlurEffect(style: .regular),
              modalBackgroundVisualEffectIntensity: 1,
              modalDragHandleSize: CGSize(width: 50, height: 6.5),
              modalDragHandleOffset: -16.5,
              modalDragHandleColor: .white,
              modalDragHandleOpacity: 0.8,
              backgroundOpacity: 0,
              backgroundVisualEffect: UIBlurEffect(style: .regular),
              backgroundVisualEffectIntensity: 0
            )
          ),
          
          // snap point - 2
          AdaptiveModalSnapPointConfig(
            layoutConfig: ComputableLayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .stretch,
              marginTop: .multipleValues([
                .safeAreaInsets(insetKey: \.top),
                .constant(10),
              ]),
              paddingTop: .constant(6 + 8 + 6)
              
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              secondaryGestureAxisDampingPercent: 1,
              modalShadowOffset: .init(width: 2, height: 2),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 7,
              modalCornerRadius: 10,
              modalMaskedCorners: .topCorners,
              modalBackgroundOpacity: 0.8,
              modalBackgroundVisualEffectIntensity: 0.8,
              modalDragHandleSize: CGSize(width: 40, height: 6),
              modalDragHandleOffset: 8,
              modalDragHandleColor: .gray,
              modalDragHandleOpacity: 0.9,
              backgroundOpacity: 0.2,
              backgroundVisualEffectIntensity: 0.1
            )
          ),
        ],
        snapDirection: .bottomToTop,
        undershootSnapPoint: .init(
          layoutPreset: .offscreenBottom,
          keyframeConfig: .init(
            modalTransform: .init(
              scaleX: 0.75,
              scaleY: 0.75
            ),
            modalCornerRadius: 15,
            modalMaskedCorners: .allCorners,
            modalContentOpacity: 0.25
          )
        ),
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .fitScreenVertically
        ),
        modalSwipeGestureEdgeHeight: 20
      );
    };
  };
  
  var constrainedConfigs: [AdaptiveModalConstrainedConfig] {
    switch self {
      default: return [
        .init(
          constraints: [
            .verticalSizeClass(is: .compact),
          ],
          config: .init(
            snapPoints: [
              AdaptiveModalSnapPointConfig(
                layoutConfig: ComputableLayout(
                  horizontalAlignment: .center,
                  verticalAlignment: .bottom,
                  width: .percent(percentValue: 0.8),
                  height: .multipleValues(
                    [
                      .conditionalLayoutValue(
                        condition: .keyboardPresent,
                        trueValue: .keyboardRelativeSize(sizeKey: \.height),
                        falseValue: .safeAreaInsets(insetKey: \.bottom)
                      ),
                      .percent(percentValue: 0.5)
                    ],
                    maxValue: .percent(
                      relativeTo: .screenHeight,
                      percentValue: 1
                    )
                  ),
                  marginTop: .constant(10),
                  paddingBottom: .conditionalLayoutValue(
                    condition: .keyboardPresent,
                    trueValue: .keyboardRelativeSize(sizeKey: \.height),
                    falseValue: .safeAreaInsets(insetKey: \.bottom)
                  )
                ),
                keyframeConfig: AdaptiveModalKeyframeConfig(
                  modalShadowOpacity: 0.2,
                  modalShadowRadius: 15,
                  modalCornerRadius: 10,
                  modalMaskedCorners: .topCorners,
                  modalBackgroundOpacity: 0.85,
                  modalBackgroundVisualEffect: UIBlurEffect(style: .regular),
                  modalBackgroundVisualEffectIntensity: 1
                )
              ),
            ],
            snapDirection: .bottomToTop,
            overshootSnapPoint: .init(
              layoutPreset: .fitScreenVertically
            )
          )
        ),
      ];
    };
  };
};
