

* `AdaptiveModal`

  * Short Introduction + Gifs

  <br><br>

  * Table of Contents

  * Installation

  * Basic Usage

  * Documentation

    * Class - `AdaptiveModalManager`
      * `AdaptiveModalManager` Properties
        * Config-Related
        * Gesture-Related
        * General
      * `AdaptiveModalManager` Functions
    * Enum - `AdaptiveModalManager.PresentationState`
    * Struct - `AdaptiveModalConfig`
    * Struct - `AdaptiveModalKeyframeConsfig`
    * Struct - `AdaptiveModalInterpolationPoint`
      * Properties - From `AdaptiveModalKeyframeConfig`
    * Struct - `AdaptiveModalClampingConfig`
    * Sturct - `AdaptiveModalEventNotifiable`
    * Struct - `AdaptiveModalSnapAnimationConfig`
    * Struct - `AdaptiveModalSnapPointPreset`
    * Struct - `RNILayout`
    * Struct - `RNILayout.HorizontalAlignment`
    * Struct - `RNILayout.VerticalAlignment`
    * `RNILayoutComputableOffset`
    * `RNILayoutConditionalValueMode`
    * `RNILayoutPreset`
    * `RNILayoutValue`
    * Topics + Discussion

  * Examples

    * `AdaptiveModalExampleBasicUsage00`
      * Basic usage - Presenting a simple modal with one snap point.
      * Mentioned, but not part of the example: `dismissModal`.
    * `AdaptiveModalExampleBasicUsage01`
      * Basic usage - Modal with one snap point + undershoot and overshoot preset.
    * `AdaptiveModalExampleBasicUsage02`
      * Basic usage - Modal with one snap point + custom undershoot and overshoot config.
    * `AdaptiveModalExampleBasicUsageXX`
      * Modal with 2 snapping points.
    
    <br><br>
    
    * `AdaptiveModalExampleLayoutXX`
      * Constants and percentages for modal height and width.
      * Modal width + constant value.
      * Modal height + percent value.
    * `AdaptiveModalExampleLayoutXX`
      * `RNILayout` + Min/Max value.
      * Modal height + percent value + min height.
      * Modal width + stretch value + max width. 
    * `AdaptiveModalExampleLayoutXX`
      * Margins + constants and percent. 
    * `AdaptiveModalExampleLayoutXX`
      * Margins + Safe Area and multiple values.
    * `AdaptiveModalExampleLayoutXX`
      * Padding + Safe Area and multiple values
    
    * `AdaptiveModalExampleLayoutXX`
      * Margins + Keyboard values.
    * `AdaptiveModalExampleLayoutXX`
      * Padding + Keyboard values.
    
    <br><br>
    
    * `AdaptiveModalExampleSnapDirectionXX`
      * Snap direction + bottom to top.
    * `AdaptiveModalExampleSnapDirectionXX`
      * Snap direction + top to bottom.
    * `AdaptiveModalExampleSnapDirectionXX`
      * Snap direction + left to right.
    * `AdaptiveModalExampleSnapDirectionXX`
      * Snap direction + right to left.
    
    <br>
    
    * `AdaptiveModalExampleSnapPointKeyframesXX`
    
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalRotation`, `modalScaleX`, `modalScaleY`, `modalTranslateX`, `modalTranslateY`.
    
    
    
    * `AdaptiveModalExampleSnapPointKeyframesXX`
    
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalBorderWidth`, `modalBorderColor`.
    
    
    
    * `AdaptiveModalExampleSnapPointKeyframesXX`
    
      * `modalShadowColor`, `modalShadowOffset`, `modalShadowOpacity`, `modalShadowRadius`.
    
    
    
    * `AdaptiveModalExampleSnapPointKeyframesXX`
    
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalCornerRadius`, `modalMaskedCorners`.
    
    
    
    * `AdaptiveModalExampleSnapPointKeyframesXX`
    
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalOpacity`.
    
    
    
    * `AdaptiveModalExampleSnapPointKeyframesXX`
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalContentOpacity`,
    
    
    
    * `AdaptiveModalExampleSnapPointKeyframesXX`
    
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalBackgroundOpacity`, `modalBackgroundVisualEffect`, `modalBackgroundVisualEffectIntensity`.
      * Mentioned, but not part of example: `modalBackgroundVisualEffectOpacity`.
    
      
    
    * `AdaptiveModalExampleSnapPointKeyframesXX`
    
      * `AdaptiveModalConfig` properties used in this example: `dragHandlePosition`.
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalDragHandleSize`, `modalDragHandleOffset`, `modalDragHandleColor`, `modalDragHandleOpacity`.
      * Mentioned, but not part of example: `dragHandleHitSlop`, 
    
      
    
    * `AdaptiveModalExampleSnapPointKeyframesXX`
    
      * `AdaptiveModalKeyframeConfig` properties used in this example: `backgroundColor`, `backgroundOpacity`.
    
    
    
    * `AdaptiveModalExampleSnapPointKeyframesXX`
      * `AdaptiveModalKeyframeConfig` properties used in this example: `backgroundVisualEffect`, `backgroundVisualEffectIntensity`.
      * Mentioned, but not part of example: `backgroundVisualEffectOpacity`, 
    
    <br><br>
    
    * `AdaptiveModalExampleSnapPointOtherKeyframesXX`
      * `AdaptiveModalKeyframeConfig` properties used in this example: `backgroundTapInteraction`.
    
    
    
    * `AdaptiveModalExampleSnapPointOtherKeyframesXX`
      * `AdaptiveModalKeyframeConfig` properties used in this example: `secondaryGestureAxisDampingPercent`.
    
    
    
    * `AdaptiveModalExampleSnapPointOtherKeyframesXX`
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalScrollViewContentInsets`.
    
    
    
    * `AdaptiveModalExampleSnapPointOtherKeyframesXX`
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalScrollViewVerticalScrollIndicatorInsets`.
      * Mentioned, but not part of example: `modalScrollViewHorizontalScrollIndicatorInsets`, 
    
    <br><br>
    
    * `AdaptiveModalOverrideExampleXX`
      * Basic example for `overrideSnapPointConfig` param.
      * Mentioned, but not part of example: `clearSnapPointOverride`.
    
    
    
    * `AdaptiveModalOverrideExampleXX`
      * Example for `prevSnapPointConfigs` param.
    
    <br><br>
    
    * `AdaptiveModalCommandsExampleXX`
      * `dismiss`.
    * `AdaptiveModalCommandsExampleXX`
      * `snapTo`.