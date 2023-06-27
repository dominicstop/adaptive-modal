//
//  AdaptiveModalConfigDemoPresets.swift
//  adaptive-modal-example
//
//  Created by Dominic Go on 6/22/23.
//

import UIKit
import AdaptiveModal

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
  
  var config: AdaptiveModalConfig {
    switch self {
      case .demo01: return AdaptiveModalConfig(
        snapPoints: [
          // Snap Point 1
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .percent(percentValue: 0.3)
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
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
            snapPoint: RNILayout(
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
            animationKeyframe: AdaptiveModalAnimationConfig(
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
            snapPoint: RNILayout(
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
            animationKeyframe: AdaptiveModalAnimationConfig(
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
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: RNILayoutValue(
                mode: .stretch
              ),
              height: RNILayoutValue(
                mode: .stretch
              ),
              marginTop: .safeAreaInsets(insetKey: \.top)
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
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
        interpolationClampingConfig: .init(
          shouldClampModalLastHeight: true,
          shouldClampModalLastWidth: true,
          shouldClampModalLastX: true
        ),
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .fitScreen
        )
      );
      
      case .demo02: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.8),
              height: .percent(percentValue: 0.2)
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
              modalShadowOffset: .init(width: 0, height: -2),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 7,
              modalCornerRadius: 10,
              modalMaskedCorners: .topCorners,
              backgroundOpacity: 0,
              backgroundVisualEffect: UIBlurEffect(style: .regular),
              backgroundVisualEffectIntensity: 0
            )
          ),
          
          // snap point - 2
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.8),
              height: .percent(percentValue: 0.4)
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
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
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.9),
              height: .percent(percentValue: 0.7)
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
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
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .fitScreenVertically
        )
      );
      
      case .demo03: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .left,
              verticalAlignment: .center,
              width: .percent(percentValue: 0.5),
              height: .percent(percentValue: 0.65),
              marginLeft: .constant(15)
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
              modalScaleX: 1,
              modalScaleY: 1,
              modalShadowOffset: .init(width: 1, height: 1),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 8,
              modalCornerRadius: 10,
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
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .center,
              width: .stretch,
              height: .percent(percentValue: 0.85),
              marginLeft: .constant(20),
              marginRight: .constant(20)
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
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
          animationKeyframe: .init(
            modalScaleX: 0.5,
            modalScaleY: 0.5,
            modalCornerRadius: 5,
            modalDragHandleOffset: -14,
            backgroundVisualEffectIntensity: 0
          )
        ),
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .offscreenRight
        )
      );
      
      case .demo04: return AdaptiveModalConfig(
        snapPoints: [
          // 1
          .init(
            snapPoint: .init(
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
            animationKeyframe: .init(
              modalScaleX: 1,
              modalScaleY: 1,
              modalShadowOpacity: 0.3,
              modalShadowRadius: 10,
              modalCornerRadius: 10
            )
          ),
          
          // 2
          .init(
            snapPoint: .init(
              horizontalAlignment: .center,
              verticalAlignment: .center,
              width: .stretch,
              height: .percent(percentValue: 0.5),
              marginLeft: .constant(15),
              marginRight: .constant(15)
            ),
            animationKeyframe: .init(
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
          animationKeyframe: .init(
            modalScaleX: 0.75,
            modalScaleY: 0.75
          )
        ),
        overshootSnapPoint: .init(
          layoutPreset: .offscreenBottom,
          animationKeyframe: .init(
            modalScaleX: 0.9,
            modalScaleY: 0.9,
            modalOpacity: 0.8,
            backgroundOpacity: 0
          )
        )
      );
      
      case .demo05: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .left,
              verticalAlignment: .center,
              width: .percent(percentValue: 0.7),
              height: .stretch
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
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
            snapPoint: RNILayout(
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
            animationKeyframe: AdaptiveModalAnimationConfig(
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
          animationKeyframe: .init(
            backgroundVisualEffectIntensity: 0
          )
        ),
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .edgeRight
        )
      );
      
      case .demo06: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.8),
              height: .percent(percentValue: 0.2),
              marginBottom: .init(
                mode: .safeAreaInsets(insetKey: \.bottom),
                minValue: .constant(15)
              )
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
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
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.85),
              height: .percent(percentValue: 0.5),
              marginBottom: .init(
                mode: .safeAreaInsets(insetKey: \.bottom),
                minValue: .constant(15)
              )
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
              modalShadowOffset: .init(width: 1, height: 1),
              modalShadowOpacity: 0.4,
              modalShadowRadius: 7,
              modalCornerRadius: 15,
              backgroundOpacity: 0.1
            )
          ),
          
          // snap point - 3
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.87),
              height: .percent(percentValue: 0.7),
              marginBottom: .init(
                mode: .safeAreaInsets(insetKey: \.bottom),
                minValue: .constant(15)
              )
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
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
          animationKeyframe: AdaptiveModalAnimationConfig(
            modalShadowOffset: .init(width: 3, height: 3),
            modalShadowOpacity: 0.35,
            modalShadowRadius: 15
          )
        )
      );
      
      case .demo07: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .left,
              verticalAlignment: .center,
              width: .percent(percentValue: 0.7),
              height: .percent(percentValue: 0.65),
              marginLeft: .constant(15)
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
              modalScaleX: 1,
              modalScaleY: 1,
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
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .center,
              width: .stretch,
              height: .stretch
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
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
          animationKeyframe: .init(
            modalScaleX: 0.5,
            modalScaleY: 0.5,
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
      
      case .demo08: return AdaptiveModalConfig(
        snapPoints: [
          // Snap Point 1
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .percent(percentValue: 0.3)
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
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
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .percent(percentValue: 0.75)
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
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
      
      case .demo09: return AdaptiveModalConfig(
        snapPoints: [
          // Snap Point 1
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
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
            animationKeyframe: AdaptiveModalAnimationConfig(
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
      
      case .demo10: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            snapPoint: .init(
              horizontalAlignment: .left,
              verticalAlignment: .center,
              width: .percent(percentValue: 0.5),
              height: .percent(percentValue: 0.5)
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
              modalScaleX: 1,
              modalScaleY: 1,
              modalShadowOffset: .init(width: 1, height: 1),
              modalShadowOpacity: 0.3,
              modalShadowRadius: 8,
              modalCornerRadius: 10,
              modalMaskedCorners: .rightCorners,
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
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .left,
              verticalAlignment: .center,
              width: .percent(percentValue: 0.7),
              height: .percent(percentValue: 0.85)
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
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
            snapPoint: RNILayout(
              horizontalAlignment: .left,
              verticalAlignment: .center,
              width: .percent(percentValue: 0.95),
              height: .stretch
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
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
          animationKeyframe: .init(
            modalScaleX: 0.5,
            modalScaleY: 0.5,
            modalCornerRadius: 5,
            modalDragHandleOffset: -14,
            backgroundVisualEffectIntensity: 0
          )
        ),
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .fitScreenHorizontally
        )
      );
      
      case .demo11: return AdaptiveModalConfig(
        snapPoints: [
          // Snap Point 1
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .multipleValues([
                .percent(percentValue: 0.3),
                .conditionalValue(
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
              paddingBottom: .conditionalValue(
                condition: .keyboardPresent,
                trueValue: .keyboardRelativeSize(sizeKey: \.height),
                falseValue: .safeAreaInsets(insetKey: \.bottom)
              )
            ),
            animationKeyframe: AdaptiveModalAnimationConfig(
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
    };
  };
};
