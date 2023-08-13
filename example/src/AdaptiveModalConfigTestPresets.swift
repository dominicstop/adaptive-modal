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
          .snapPoint(
            layoutConfig: RNILayout(
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
              modalTransform: .init(
                translateX: -100,
                translateY: 20,
                scaleX: 0.5,
                scaleY: 0.5,
                rotateZ: .radians(0.2)
              )
            )
          ),
          
          // snap point - 1
          .snapPoint(
            layoutConfig: RNILayout(
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
              modalTransform: .init(
                translateX: 0,
                translateY: 0,
                scaleX: 0.5,
                scaleY: 1,
                rotateZ: .radians(-0.2)
              )
            )
          ),
          // snap point - 2
          .snapPoint(
            layoutConfig: RNILayout(
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
              modalTransform: .init(
                scaleX: 1,
                scaleY: 1
              )
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
          .snapPoint(
            layoutConfig: RNILayout(
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
              modalTransform: .init(
                scaleX: 1,
                scaleY: 1
              )
            )
          ),
          
          // snap point - 1
          .snapPoint(
            layoutConfig: RNILayout(
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
              modalTransform: .init(
                scaleX: 0.5,
                scaleY: 1
              )
            )
          ),
          // snap point - 2
          .snapPoint(
            layoutConfig: RNILayout(
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
              modalTransform: .init(
                scaleX: 1.5,
                scaleY: 1.5
              )
            )
          ),
        ],
        snapDirection: .bottomToTop,
        undershootSnapPoint: .init(
          layoutPreset: .offscreenBottom,
          keyframeConfig: .init(
            modalTransform: .init(
              scaleX: 0.25,
              scaleY: 0.25
            )
          )
        ),
        overshootSnapPoint: AdaptiveModalSnapPointPreset(
          layoutPreset: .fitScreenVertically
        )
      );
      
      case .testModalBorderAndShadow01: return AdaptiveModalConfig(
        snapPoints: [
          // snap point - 0
          .snapPoint(
            layoutConfig: RNILayout(
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
          .snapPoint(
            layoutConfig: RNILayout(
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
          .snapPoint(
            layoutConfig: RNILayout(
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
          .snapPoint(
            layoutConfig: RNILayout(
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
          .snapPoint(
            layoutConfig: RNILayout(
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
          .snapPoint(
            layoutConfig: .init(
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
          .snapPoint(
            layoutConfig: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .percent(percentValue: 0.1)
            )
          ),
          .snapPoint(
            layoutConfig: RNILayout(
              horizontalAlignment: .center,
              verticalAlignment: .bottom,
              width: .stretch,
              height: .percent(percentValue: 0.3)
            )
          ),
          .snapPoint(
            layoutConfig: RNILayout(
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
          .snapPoint(
            layoutConfig: RNILayout(
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
          .snapPoint(
            layoutConfig: RNILayout(
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

