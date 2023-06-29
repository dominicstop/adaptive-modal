//
//  AdaptiveModalConfigTestPresets.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 6/15/23.
//

import UIKit
import AdaptiveModal

enum AdaptiveModalConfigTestPresets: CaseIterable {
  
  static let `default`: Self = .testTopToBottom;
  
  case testModalTransform01;
  case testModalTransformScale;
  case testModalBorderAndShadow01;
  case testLeftToRight;
  case testTopToBottom;

  case test01;
  case test02;
  
  var config: AdaptiveModalConfig {
    switch self {
    
      // MARK: - Tests
      // -------------
    
      case .testModalTransform01: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 0
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: RNILayoutValue(
                mode: .percent(percentValue: 0.8)
              ),
              height: RNILayoutValue(
                mode: .percent(percentValue: 0.2)
              )
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalRotation: 0.2,
              modalScaleX: 0.5,
              modalScaleY: 0.5,
              modalTranslateX: -100,
              modalTranslateY: 20
            )
          ),
          
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: RNILayoutValue(
                mode: .percent(percentValue: 0.8)
              ),
              height: RNILayoutValue(
                mode: .percent(percentValue: 0.4)
              )
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalRotation: -0.2,
              modalScaleX: 0.5,
              modalScaleY: 1,
              modalTranslateX: 0,
              modalTranslateY: 0
            )
          ),
          // snap point - 2
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: RNILayoutValue(
                mode: .percent(percentValue: 0.8)
              ),
              height: RNILayoutValue(
                mode: .percent(percentValue: 0.6)
              )
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              //modalRotation: 1,
              modalScaleX: 1,
              modalScaleY: 1
              //modalTranslateX: 0,
              //modalTranslateY: 0
            )
          ),
        ],
        snapDirection: .bottomToTop,
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .fitScreenVertically
        )
      );
      
      case .testModalTransformScale: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 0
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: RNILayoutValue(
                mode: .percent(percentValue: 0.8)
              ),
              height: RNILayoutValue(
                mode: .percent(percentValue: 0.2)
              )
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalScaleX: 1,
              modalScaleY: 1
            )
          ),
          
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: RNILayoutValue(
                mode: .percent(percentValue: 0.8)
              ),
              height: RNILayoutValue(
                mode: .percent(percentValue: 0.4)
              )
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalScaleX: 0.5,
              modalScaleY: 1
            )
          ),
          // snap point - 2
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: RNILayoutValue(
                mode: .percent(percentValue: 0.8)
              ),
              height: RNILayoutValue(
                mode: .percent(percentValue: 0.6)
              )
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalScaleX: 1.5,
              modalScaleY: 1.5
            )
          ),
        ],
        snapDirection: .bottomToTop,
        undershootSnapPoint: .init(
          layoutPreset: .offscreenBottom,
          keyframeConfig: .init(
            modalScaleX: 0.25,
            modalScaleY: 0.25
          )
        ),
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .fitScreenVertically
        )
      );
      
      case .testModalBorderAndShadow01: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 0
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.8),
              height: .percent(percentValue: 0.2)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalBorderWidth: 2,
              modalBorderColor: .blue,
              modalShadowColor: .blue,
              modalShadowOffset: .init(width: 3, height: 3),
              modalShadowOpacity: 0.4,
              modalShadowRadius: 4.0
            )
          ),
          
          // snap point - 1
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.8),
              height: .percent(percentValue: 0.4)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalBorderWidth: 4,
              modalBorderColor: .cyan,
              modalShadowColor: .green,
              modalShadowOffset: .init(width: 6, height: 6),
              modalShadowOpacity: 0.5,
              modalShadowRadius: 5
            )
          ),
          // snap point - 2
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .percent(percentValue: 0.9),
              height: .percent(percentValue: 0.7)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalBorderWidth: 8,
              modalBorderColor: .green,
              modalShadowColor: .purple,
              modalShadowOffset: .init(width: 9, height: 9),
              modalShadowOpacity: 0.9,
              modalShadowRadius: 7
            )
          ),
        ],
        snapDirection: .bottomToTop,
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .fitScreenVertically
        )
      );
      
      case .testLeftToRight: return AdaptiveModalConfig(
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
            keyframeConfig: AdaptiveModalKeyframeConfig(
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
            keyframeConfig: AdaptiveModalKeyframeConfig(
            )
          ),
        ],
        snapDirection: .leftToRight,
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .edgeRight
        )
      );
      
      case .testTopToBottom: return AdaptiveModalConfig(
        snapPoints: [
          .init(
            snapPoint: .init(
              horizontalAlignment: .center,
              verticalAlignment: .top,
              width: .stretch,
              height: .percent(percentValue: 0.2)
            )
          )
        ],
        snapDirection: .topToBottom,
        overshootSnapPoint: .init(
          layoutPreset: .fitScreenVertically
        )
      );
    
      case .test01: return AdaptiveModalConfig(
        snapPoints:  [
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .percent(percentValue: 0.1)
            )
          ),
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .percent(percentValue: 0.3)
            )
          ),
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .percent(percentValue: 0.7)
            )
          ),
        ],
        snapDirection: .bottomToTop
      );
      
      case .test02: return AdaptiveModalConfig(
        snapPoints: [
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .percent(percentValue: 0.3)
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalCornerRadius: 15,
              modalMaskedCorners: [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
              ],
              backgroundVisualEffect: UIBlurEffect(style: .regular),
              backgroundVisualEffectIntensity: 0
            )
          ),
          AdaptiveModalSnapPointConfig(
            snapPoint: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .center,
              width: RNILayoutValue(
                mode: .percent(percentValue: 0.7),
                maxValue: .constant(ScreenSize.iPhone8.size.width)
              ),
              height: RNILayoutValue(
                mode: .percent(percentValue: 0.7),
                maxValue: .constant(ScreenSize.iPhone8.size.height)
              )
            ),
            keyframeConfig: AdaptiveModalKeyframeConfig(
              modalCornerRadius: 20,
              modalMaskedCorners: [
                .layerMinXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMinYCorner,
                .layerMaxXMaxYCorner
              ],
              backgroundVisualEffect: UIBlurEffect(style: .regular),
              backgroundVisualEffectIntensity: 0.5
            )
          ),
        ],
        snapDirection: .bottomToTop,
        interpolationClampingConfig: .init(
          shouldClampModalLastHeight: true,
          shouldClampModalLastWidth: true,
          shouldClampModalLastX: true
        )
      );
      
    };
  };
};

