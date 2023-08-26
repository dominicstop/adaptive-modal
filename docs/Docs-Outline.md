

* `AdaptiveModal`

  * Short Introduction + Gifs

  <br><br>

  * Table of Contents

  * Installation

  * Basic Usage

  * Documentation

    * Struct - `AdaptiveModalClampingConfig`
    * Struct - `AdaptiveModalConfigMode`
    * Struct - `AdaptiveModalConstrainedConfig`
    * Struct - `AdaptiveModalInterpolationPoint`
    * Struct - `AdaptiveModalKeyframeConfig`
    * Struct - `AdaptiveModalKeyframePropertyAnimator`
    * Struct - `AdaptiveModalRangePropertyAnimator`
    * Struct - `AdaptiveModalSnapPointPreset`
  
    <br>
  
    * Enum - `AdaptiveModalState`
    * Enum - `AdaptiveModalSnapAnimationConfig`
    * Enum - `AdaptiveModalSnapPointConfig`
  
    <br>
  
    * Class - `AdaptiveModalConfig`
      * `AdaptiveModalManager` Properties
        * Config-Related
        * Gesture-Related
        * General
      * `AdaptiveModalManager` Functions
    * Class - `AdaptiveModalDragHandleView`
    * Class - `AdaptiveModalRootViewController`
    * Class - `AdaptiveModalWrapperView`
  
    <br>
  
    * Protocol - `AdaptiveModalAnimationEventsNotifiable`
    * Protocol - `AdaptiveModalGestureEventsNotifiable`
    * Protocol - `AdaptiveModalPresentationEventsNotifiable`
    * Protocol - `AdaptiveModalStateEventsNotifiable`
    * Protocol - `AdaptiveModalBackgroundTapDelegate`
  
    <br>
  
    * Struct - `Angle`
    * Struct - `Transform3D`
  
    <br>
  
    * Topics + Discussion
  
  * Examples
  
    * `AdaptiveModalExampleBasicUsage00`
      * Basic usage - Presenting a simple modal with one snap point.
      * Mentioned, but not part of the example: `dismissModal`.
        * `1.` Here is a simple modal with one snap point.
        * `2.` We can configure the modal via a `AdaptiveModalConfig` value. 
        * `3.` The init function for `AdaptiveModalConfig` can accept an array of snap points via the `snapPoints` parameter (i.e. `init(snapPoints: [AdaptiveModalSnapPointConfig])`).
        * `4.` The `snapPoints` parameter accepts an array of `AdaptiveModalSnapPointConfig` enum values.
        * `5.` A snap point defines the various positions of the modal, and a modal can have multiple snap points.
          * The array of snap points will be used to define the position, layout, behavior, and animations for the modal. 
          * When the user drags the modal, the modal will interpolate from snap point to snap point, based on the location of the drag gesture.
          * When the user lets go of the modal, the modal will then snap to the closest snap point.
        * `6.`  To create a snap point, invoke: `AdaptiveModalSnapPointConfig.snapPoint(...)`. 
          * For brevity you can just use: `.snapPoint(...)`, E.g. `init(snapPoints: [.snapPoint(...)])`.
          * `AdaptiveModalSnapPointConfig` is an enum, and for this example we'll be using `.snapPoint` case to create our first snap point.
        * `7.` The `.snapPoint` case accepts the following list of associated values as parameters: `key`, `layoutConfig`, and `keyframeConfig`.
          * Only the `layoutConfig` parameter is required to make a snap point.
        * `8.` The `layoutConfig` parameter accepts a `RNILayout` struct value.
    * `AdaptiveModalExampleBasicUsage01`
      * Basic usage - Modal with one snap point + undershoot and overshoot preset.
        * An "undershoot snap point" is the initial position of the modal before it gets presented.
        * An "overshoot snap point" is the final position of the modal. 
        * Basically, the "overshoot snap point" is used to "extrapolate" the position of the modal when the user continues to swipe the modal.
    * `AdaptiveModalExampleBasicUsage02`
      * Basic usage - Modal with one snap point + custom undershoot and overshoot config.
        * The undershoot parameter (i.e. `init(undershootSnapPoint: AdaptiveModalSnapPointPreset)`), and overshoot parameter (i.e. `init(overshootSnapPoint: AdaptiveModalSnapPointPreset?)`) are set to `.automatic` by default.
        *  `AdaptiveModalConfig.undershootSnapPoint`
        * `AdaptiveModalSnapPointPreset`
        * Mention `.automatic`, e.g.: By default, `AdaptiveModalSnapPointPreset.layoutPreset` is set to `.automatic`.
    * `AdaptiveModalExampleBasicUsageXX`
      * Modal with 2 snapping points.
  
    <br><br>
  
    * `AdaptiveModalExampleLayoutXX`
      * Constants and percentages for modal height and width.
      * Modal width + constant value.
      * Modal height + percent value.
  
    <br>
  
    * `AdaptiveModalExampleLayoutXX`
      * `RNILayout` + Min/Max value.
      * Modal height + percent value + min height.
      * Modal width + stretch value + max width. 
  
    <br>
  
    * `AdaptiveModalExampleLayoutXX`
      * Margins + constants and percent. 
  
    <br>
  
    * `AdaptiveModalExampleLayoutXX`
      * Margins + Safe Area and multiple values.
  
    <br>
  
    * `AdaptiveModalExampleLayoutXX`
      * Padding + Safe Area and multiple values
  
    <br>
  
    * `AdaptiveModalExampleLayoutXX`
      * Margins + Keyboard values.
  
    <br>
  
    * `AdaptiveModalExampleLayoutXX`
      * Padding + Keyboard values.
  
    <br><br>
  
    * `AdaptiveModalExampleSnapDirectionXX`
      * Snap direction + bottom to top.
  
    <br>
  
    * `AdaptiveModalExampleSnapDirectionXX`
      * Snap direction + top to bottom.
  
    <br>
  
    * `AdaptiveModalExampleSnapDirectionXX`
      * Snap direction + left to right.
  
    <br>
  
    * `AdaptiveModalExampleSnapDirectionXX`
      * Snap direction + right to left.
  
    <br>
  
    * `AdaptiveModalExampleSnapPointKeyframesXX`
  
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalRotation`, `modalScaleX`, `modalScaleY`, `modalTranslateX`, `modalTranslateY`.
  
    <br>
  
    * `AdaptiveModalExampleSnapPointKeyframesXX`
    * `AdaptiveModalKeyframeConfig` properties used in this example: `modalBorderWidth`, `modalBorderColor`.
  
    <br>
  
    * `AdaptiveModalExampleSnapPointKeyframesXX`
  
      * `modalShadowColor`, `modalShadowOffset`, `modalShadowOpacity`, `modalShadowRadius`.
  
    <br>
  
    * `AdaptiveModalExampleSnapPointKeyframesXX`
  
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalCornerRadius`, `modalMaskedCorners`.
  
    <br>
  
    * `AdaptiveModalExampleSnapPointKeyframesXX`
  
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalOpacity`.
  
    <br>
  
    * `AdaptiveModalExampleSnapPointKeyframesXX`
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalContentOpacity`,
  
    <br>
  
    * `AdaptiveModalExampleSnapPointKeyframesXX`
  
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalBackgroundOpacity`, `modalBackgroundVisualEffect`, `modalBackgroundVisualEffectIntensity`.
      * Mentioned, but not part of example: `modalBackgroundVisualEffectOpacity`.
  
  
    <br>
  
    * `AdaptiveModalExampleSnapPointKeyframesXX`
      * `AdaptiveModalConfig` properties used in this example: `dragHandlePosition`.
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalDragHandleSize`, `modalDragHandleOffset`, `modalDragHandleColor`, `modalDragHandleOpacity`.
      * Mentioned, but not part of example: `dragHandleHitSlop`, 
  
  
    <br>
  
    * `AdaptiveModalExampleSnapPointKeyframesXX`
  
      * `AdaptiveModalKeyframeConfig` properties used in this example: `backgroundColor`, `backgroundOpacity`.
  
    <br>
  
    * `AdaptiveModalExampleSnapPointKeyframesXX`
      * `AdaptiveModalKeyframeConfig` properties used in this example: `backgroundVisualEffect`, `backgroundVisualEffectIntensity`.
      * Mentioned, but not part of example: `backgroundVisualEffectOpacity`, 
  
    <br><br>
  
    * `AdaptiveModalExampleSnapPointOtherKeyframesXX`
      * `AdaptiveModalKeyframeConfig` properties used in this example: `backgroundTapInteraction`.
  
    <br>
  
    * `AdaptiveModalExampleSnapPointOtherKeyframesXX`
      * `AdaptiveModalKeyframeConfig` properties used in this example: `secondaryGestureAxisDampingPercent`.
  
    <br>
  
    * `AdaptiveModalExampleSnapPointOtherKeyframesXX`
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalScrollViewContentInsets`.
  
    <br>
  
    * `AdaptiveModalExampleSnapPointOtherKeyframesXX`
      * `AdaptiveModalKeyframeConfig` properties used in this example: `modalScrollViewVerticalScrollIndicatorInsets`.
      * Mentioned, but not part of example: `modalScrollViewHorizontalScrollIndicatorInsets`, 
  
    <br><br>
  
    * `AdaptiveModalOverrideExampleXX`
      * Basic example for `overrideSnapPointConfig` param.
      * Mentioned, but not part of example: `clearSnapPointOverride`.
  
    <br>
  
    * `AdaptiveModalOverrideExampleXX`
      * Example for `prevSnapPointConfigs` param.
  
    <br><br>
  
    * `AdaptiveModalCommandsExampleXX`
      * `dismiss`.
  
    <br>
  
    * `AdaptiveModalCommandsExampleXX`
      * `snapTo`.
  
  <br>
  
    * `AdaptiveModalCommandsExampleXX`
      * Dynamically updating/changing the modal config.
  
  <br>
  
    * `AdaptiveModalCommandsExampleXX`
      * Dismissing the modal to a custom snap point.
  
  <br>
  
    * `AdaptiveModalCommandsExampleXX`
      * Dismissing the modal in-place with a custom animation keyframe.