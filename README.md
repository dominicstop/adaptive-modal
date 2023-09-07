# adaptive-modal

An all-in-one, "config-based" `UIViewController` modal presentation `UIKit` component for making: interactive modals, sheets, drawers, dialogs, and overlays, with built in support for: 

* 💖 Gesture-driven modal presentation and animation.
* ❤️ Snapping points, and keyframe-based animations (blurs, 3d transforms, color, alpha, shadows, drag handle, etc).
* 🧡 "Adaptive" modal config (i.e. modal config that changes based on the current: device attributes/capabilities, size class, rotation, accessibility, etc).
* 💛 ["Adaptive" layout](https://github.com/dominicstop/ComputableLayout) (i.e. composable layout values, e.g. percentages, constants, safe area insets, keyboard rects, conditional layout values, etc).
* 💚 Consolidated modal events, and unified/simplified modal state.
* 💙 Paginated modal content (i.e. each snap point can have an associated "page" view, and the modal content changes based on the current snap point).
* 💜 Custom/override snapping points, keyboard avoidance, adaptive layout config, custom present/dismiss animations, custom drag handle, etc..

<br><br>

## Demo Gifs

See [`AdaptiveModalConfigDemoPresets`](example/src/AdaptiveModalConfigDemoPresets.swift) file for the config used for the modal.

![Demo 01 to 04](assets/demo-01-02-03-04.gif)

![Demo 01 to 04](assets/demo-05-06-07-08.gif)

![Demo 01 to 04](assets/demo-09-10-11-12.gif)

<br><br>

## Demo Videos

Video version of the [demo gifs](#demo-gifs).

https://github.com/dominicstop/adaptive-modal/assets/18517029/3616ae69-798e-4306-be93-40b53c261d78

https://github.com/dominicstop/adaptive-modal/assets/18517029/d2452a56-ad9e-49b4-b596-d1a67b4a0d2d

https://github.com/dominicstop/adaptive-modal/assets/18517029/f5a6387d-8e3e-4f97-b73c-836f17780309

<br><br>

## Installation

### Cocoapods

`AdaptiveModal` is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your `Podfile`:

```ruby
pod 'AdaptiveModal'
```

<br>

### Swift Package Manager (SPM)

Method: #1: Via Xcode GUI:

1. File > Swift Packages > Add Package Dependency
2. Add `https://github.com/dominicstop/AdaptiveModal.git`

<br>

Method: #2: Via `Package.swift`:

* Open your project's `Package.swift` file.
* Update `dependencies` in `Package.swift`, and add the following:

```swift
dependencies: [
  .package(url: "https://github.com/dominicstop/AdaptiveModal.git",
  .upToNextMajor(from: "1.0.0"))
]
```

<br><br>

## Basic Usage

[🔗 Full Example](./example/examples/AdaptiveModalBasicUsage01.swift)

```swift
// ✨ Code omitted for brevity

import AdaptiveModal
import ComputableLayout

class AdaptiveModalBasicUsage01 : UIViewController {
  
  @objc func onPressButtonPresentViewController(_ sender: UIButton) {
    let modalConfig = AdaptiveModalConfig(
      snapPoints: [
        AdaptiveModalSnapPointConfig(
          layoutConfig: ComputableLayout(
            horizontalAlignment: .center,
            verticalAlignment: .bottom,
            width: .stretch,
            height: .percent(percentValue: 0.7)
          ),
          keyframeConfig: AdaptiveModalKeyframeConfig(
            modalShadowColor: .black,
            modalShadowOpacity: 0.1,
            modalShadowRadius: 10,
            modalCornerRadius: 15,
            modalMaskedCorners: .topCorners,
            backgroundColor: .black,
            backgroundOpacity: 0.2
          )
        ),
      ],
      snapDirection: .bottomToTop,
      undershootSnapPoint: .automatic,
      overshootSnapPoint: AdaptiveModalSnapPointPreset(
        layoutPreset: .fitScreenVertically
      )
    );
  
    let modalManager = AdaptiveModalManager(staticConfig: modalConfig);
    
    // this can be any `UIViewController` instance...
    let modalVC = ModalViewController();
    modalVC.modalManager = modalManager;
    
    modalManager.presentModal(
      viewControllerToPresent: modalVC,
      presentingViewController: self
    );
  };
};

```

<br><br>

## Documentation

### Struct - `AdaptiveModalConfig`

This struct is uses to configure the modal. 

<br>

**`AdaptiveModalConfig` Properties - Raw Config**

| Property                                                     | Description                                                  |
| ------------------------------------------------------------ | :----------------------------------------------------------- |
| 🔤 `baseSnapPoints`<br/>⚛️ `[AdaptiveModalSnapPointConfig]`    | **Required**. Accepts an array of  `AdaptiveModalSnapPointConfig` enum values. <br><br>This property defines the various snapping points for the modal. There must be at least one snap point config in this array (i.e. it cannot be empty).<br><br>A snap point defines the position of the modal (i.e. layout, e.g. size, position, padding, etc)., as well as the modal's appearance (i.e. keyframe, e.g. shadows, transforms. background blur/opacity/color, etc)., and behavior (e.g. background tap interaction, gesture damping, etc).<br><br>As the user swipes the modal (or when you programmatically tell the modal manager instance to snap to a new snap point), it'll interpolate/animate between each snap point.<br><br>This means that if "Snap Point A" has a corner radius value of 10, and "Snap Point B" has a corner radius value of 20, then it'll interpolate the corner radius of the modal between the values of 10 and 20 as it gets dragged around (or as the current snap point is changed programmatically).<br><br>For more details, see: `AdaptiveModalSnapPointConfig`.<br><br>📝 **Note**: In the docs, the first item is in the `baseSnapPoint` array is referred to  as the "first snap point", and conversely, the last item is referred to as the "last snap point". This distinction exists due to "undershoot" snap points (i.e. `baseUndershootSnapPoint`) and "overshoot" snap points (i.e. `baseOvershootSnapPoint`) .<br><br>Eventually, all these snap points will combined into a single array in `AdaptiveModalConfig.snapPoints`. As such, the distinction is useful to clarify which snap point we are referring to.<br> |
| 🔤 `baseUndershootSnapPoint`<br/>⚛️ `AdaptiveModalSnapPointPreset`<br/>✳️  **Default**: `.automatic` | Accepts a `AdaptiveModalSnapPointPreset` struct value.<br><br>This property defines the initial/starting point of the modal; i.e. when the modal is about to be presented, this property defines where the modal will first appear from.<br><br>By default, this is set to `.automatic` (i.e. `AdaptiveModalSnapPointPreset.automatic`; it's an alias for `.init(layoutPreset: .automatic`).<br><br>A value of `.automatic` means that the initial starting of the modal will be inferred based on the current modal config's  `snapDirection`.<br><br> E.g. if the `snapDirection` is `.bottomToTop`, then the undershoot snap point will be: `AdaptiveModalSnapPointPreset(`<br>`layoutPreset: .offscreenBottom)`, meaning that the initial position of the modal will be just below the visible area at the bottom of the presenting view.<br><br>Because of this, as the the user swipes the modal down to the bottom edge of the "presenting view" in a  `.bottomToTop` modal, the modal will enter a "dismissing" state as it animates to the undershoot snap point (eventually entering the "dismissed" state once it fully snaps to the undershoot snap point).<br><br>A `AdaptiveModalSnapPointPreset` value is similar to a `AdaptiveModalSnapPointConfig` value, in the sense that they both define a "snapping point". The difference is that `AdaptiveModalSnapPointPreset` uses a pre-defined layout position via `ComputableLayoutPreset` value (e.g. `.offscreenLeft`, `.edgeRight`, etc). <br><br>💡 **Note A**: In most cases, the "presenting view" is the entire screen.<br><br>💡 **Note B**: An "undershoot snap point" is a "derived snap point", meaning that (unless explicitly specified), the existing configuration/properties from it's base/parent snap point will be carried over.<br><br>As such, if the base/parent snap point has a corner radius of 10, then the derived/child snap point will also have a corner radius of 10, and so on. This is true for all other attributes of the modal (e.g. layout position/size, keyframe values like opacity, etc).<br><br>In other words, a derived snap point is based on a pre-existing snap point (e.g. inheriting/copying over values, and only selectively changing/overwriting some of those values).<br><br>💡 **Note C**: In the case of an "undershoot snap point", it is based on, or derived from the first snapping point in `baseSnapPoints`. This is to say, values from the first snap point will be implicitly carried/copied over to the undershoot snap point.<br><br>As such, if the first snapping point has background color of red, then the undershoot snap point will also have a background color of red, and so on unless you explicitly overwrite those values.<br><br>💡 **Note D**: The undershoot snap point, in conjunction with the first snap point in `baseSnapPoints`, defines how the modal will be presented.<br><br>When the modal is about to be presented, the undershoot snap point defines the starting position of the modal (e.g. that's why it always configured to be offscreen or invisible), and the first snap point in `baseSnapPoints` defines the final position of the modal.<br><br>In other words, these two snap points define the starting and ending keyframes of the modal during presentation.<br> |
| 🔤 `baseOvershootSnapPoint`<br/>⚛️ `AdaptiveModalSnapPointPreset?`<br/>✳️  **Default**: `nil` | **Optional**. Accepts a `AdaptiveModalSnapPointPreset` struct value.<br><br>Similar to "over-scrolling" in a scroll view, this property defines what happens when the user swipes too far, i.e. when the user swipes past the last snapping point in `AdaptiveModalConfig.baseSnapPoints`.<br><br>In other words, this property defines the "max" snap point (i.e. final position). As such, you would usually configure this such that the modal will be "full screen" (i.e. `AdaptiveModalSnapPointPreset(`<br>`layoutPreset: .fitScreen)`).<br><br>This way, when the user "over-scrolls" ("over-swipes"?), the modal will grow bigger, and bigger; such that, when the user's finger reaches the very edge of the presenting view, the modal will be fill the entire area.<br><br>On the other hand, if you set this to `AdaptiveModalSnapPointPreset(`<br>`layoutPreset: .edgeTop)` on a `.bottomToTop` modal, this would define that  the final position of the modal will be at the very top edge of the screen.<br><br>In other words, when the user  "over-scrolls", it would appear as if the user is dragging the modal to the very top of the screen.<br><br>💡 **Note A**: If the value of this property is set to `nil`, then the "last snap point" in `AdaptiveModalConfig.baseSnapPoints` will be extrapolated (i.e. extended linearly) as the user continues to drag the modal past the last snap point (this behavior can be disabled via: `AdaptiveModalManager.shouldEnableOverShooting`, or selectively toggled via: `AdaptiveModalConfig.interpolationClampingConfig`).<br><br/>💡 **Note: B**: While it is possible to leave this property set to `nil`, in most cases, explicitly defining a "overshoot" snap point is better due to the fact that, extrapolating the final snap point indefinitely as the user swipes continuously past the last snap point, will often lead to undesirable results (or worse: layout bugs).<br><br>For example, let's say we have a `.leftToRight` modal, and when the user continues swiping to the right, such that the we have to extrapolate the final snap point, then the width of the modal will increase way past the bounds of the presenting view.<br><br>If we explicitly set `AdaptiveModalSnapPointPreset.layoutPreset` to either:  `.fitScreen`,  `.fitScreenHorizontally`, or `.fitScreenVertically`, then we can ensure that the modal will stay inside the presenting view's bounds, no matter how much the user swipes the modal.<br><br>Conversely, if we instead set `layoutPreset` to explicitly be 80% of the presenting view's width, then the modal's height will never exceed that value.<br><br>💡 **Note C**: Similar to an undershoot snap point, an overshoot snap point is also a "derived snap point" (see: `baseUndershootSnapPoint` + "Note B").<br><br>In the case of an overshoot snap point, the base/parent snap point of the modal is the last element in `AdaptiveModalConfig.baseSnapPoints`. This is to say that the values from the "last snap point" will be implicitly carried/copied over to the overshoot snap point, unless you explicitly provide a value.<br><br>This means that if the last snap point has a keyframe opacity of `0.5`, then the overshoot snap point will also have a keyframe opacity of `0.5`, and so on.<br> |
| 🔤 `baseDragHandlePosition`<br/>⚛️ `DragHandlePosition`<br/>✳️  **Default**: `.automatic` | Accepts an `DragHandlePosition` enum value.<br><br>This property controls the placement of the drag handle relative to the modal content.<br><br>By default, this property is set to `.automatic`. A value of `.automatic` means that the placement of the drag handle will be automatically inferred based on the `AdaptiveModalConfig.snapDirection` of the modal.<br><br>If you don't want to show a drag handle, set this property to `.none`. Alternatively, you can also use `AdaptiveModalKeyframeConfig.modalDragHandleOpacity` property to temporarily hide the drag handle (this is useful if you don't want to selectively show/hide the drag handle for a particular snap point).<br> |

<br>

**`AdaptiveModalConfig` Properties**

| Property                                                     | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| 🔤 `snapDirection`<br/>⚛️ `SnapDirection`                      | **Required**. Accepts a `SnapDirection` enum value.<br><br>This property defines the presentation, transition and swipe direction of the modal, as well as its orientation. E.g. a enum value of `.bottomToTop` means that modal will be shown starting from the bottom, then upwards, and its orientation is vertical; as such, the primary swipe axis of the modal will be Y).<br><br>To re-iterate, the undershoot snap point, in conjunction with the first snap point in `baseSnapPoints`, defines how the modal will be presented (see `baseUndershootSnapPoint` + "Note D").<br><br>As such these two snap points must match the `snapDirection`. E.g. a enum value of `.bottomToTop` means that the undershoot snap point must be below the final position of the first snap point in `baseSnapPoints`.<br> |
| 🔤 `snapPercentStrategy`<br/>⚛️ `SnapPercentStrategy`<br/>✳️  **Default**: `.position` | **Experimental**. Accepts a `SnapPercentStrategy` enum value.<br><br>Each snap point has computed percent value. By default, the percent value is determined based on the snapping point's position. <br> |
| 🔤 `snapAnimationConfig`<br/>⚛️ `AdaptiveModalSnapAnimationConfig`<br/>✳️  **Default**: `.default` | Accepts a `AdaptiveModalSnapAnimationConfig` struct value.<br><br>This property configures how the modal will be animated (e.g. duration, easing) when it snaps to a new snap point (i.e. when the user drags the modal, and lets go).<br><br>A value of `.default` (i.e. `AdaptiveModalSnapAnimationConfig`<br>`.default`) means that it'll be configured to use a `.springGesture`.<br> |
| 🔤 `entranceAnimationConfig`<br/>⚛️ `AdaptiveModalSnapAnimationConfig`<br/>✳️  **Default**: `.default` | Accepts a `AdaptiveModalSnapAnimationConfig` struct value.<br><br>When the modal is presented programmatically, this property will be used to configure the presentation transition (e.g. duration, easing). <br><br>A value of `.default` (i.e. `AdaptiveModalSnapAnimationConfig`<br/>`.default`) means that it'll be configured to use a `.springGesture`.<br/> |
| 🔤 `exitAnimationConfig`<br/>⚛️ `AdaptiveModalSnapAnimationConfig`<br/>✳️  **Default**: `default` | Accepts a `AdaptiveModalSnapAnimationConfig` struct value.<br/><br/>When the modal is dismissed programmatically, this property will be used to configure the dismissal transition (e.g. duration, easing). <br/><br/>A value of `.default` (i.e. `AdaptiveModalSnapAnimationConfig`<br/>`.default`) means that it'll be configured to use a `.springGesture`.<br/> |
| 🔤 `interpolationClampingConfig`<br/>⚛️ `AdaptiveModalClampingConfig`<br/>✳️  **Default**: `.init()` | Accepts a `AdaptiveModalClampingConfig` struct value.<br><br>When no undershoot and/or overshoot config is specified, this property controls how the modal keyframe values (e.g. modal size, position, keyframes) will extrapolated during interpolation (i.e. when the modal is be dragged around).<br> |
| 🔤 `initialSnapPointIndex`<br/>⚛️ `Int`<br/>✳️  **Default**: `1` | Accepts an `Int` value.<br><br>This property controls which snap point the modal will first snap to when it's presented.<br><br>The index value provided must be within the range of the the combined elements of `baseSnapPoints`, undershoot + overshoot snap points (i.e. `AdaptiveModalConfig.snapPoints`), where in the element in index 0 is the undershoot snap point, and element in index 1 is the first snap point in `baseSnapPoints`, etc.<br> |
| 🔤 `dragHandleHitSlop`<br/>⚛️ `CGPoint`<br/>✳️  **Default**: `CGPoint(x: 15, y: 15)` | Accepts a `CGPoint` value.<br><br>"Hit Slop" increases the touch area of a view (w/o affecting layout). This property increases the touch area of the drag handle view.<br> |
| 🔤 `modalSwipeGestureEdgeHeight`<br/>⚛️ `CGFloat`<br/>✳️  **Default**: `20` | Accepts a `CGFloat` value.<br><br>When the modal's content is a scrollview, the gesture recognizer in the scrollview will prevent the modal's pan gesture recognizer from firing, because the scrollview eats up all the touch events (i.e. the scrollview's gesture recognizer takes precedence over the modal's gesture recognizer).<br><br>This property overrides that precedence, and lets the modal's gesture recognizer respond to the touch events that are located at the leading edge of the modal.<br><br>The value you provide to this property determines the height (or width) of the modal's leading edge touch area.<br><br>E.g. the leading edge of a `.bottomToTop` modal, is the topmost edge, and conversely the leading edge of a `.topToBottom` modal is the bottom edge, etc.<br> |
| 🔤 `shouldSetModalScrollView`<br>`ContentInsets`<br/>⚛️ `Bool`<br/>✳️  **Default**: `false` | This property controls whether the `AdaptiveModalKeyframeConfig`<br>`.modalScrollViewContentInsets` modal keyframe is enabled.<br> |
| 🔤 `shouldSetModalScrollView`<br>`VerticalScrollIndicatorInsets`<br/>⚛️ `Bool`<br/>✳️  **Default**: `true` | This property controls whether the `AdaptiveModalKeyframeConfig`<br/>`.modalScrollViewVerticalScrollIndicatorInsets` modal keyframe is enabled.<br/> |
| 🔤 `shouldSetModalScrollView`<br>`HorizontalScrollIndicatorInsets`<br/>⚛️ `Bool`<br/>✳️  **Default**: `true` | This property controls whether the `AdaptiveModalKeyframeConfig`<br/>`.modalScrollViewHorizontalScrollIndicatorInsets` modal keyframe is enabled.<br/> |

<br>

**`AdaptiveModalConfig` Computed Properties - Derived Config**

| Property                                                     | Description |
| ------------------------------------------------------------ | ----------- |
| 🔤 `undershootSnapPoint`<br/>⚛️ `AdaptiveModalSnapPointPreset` | TBA         |
| 🔤 `overshootSnapPoint`<br/>⚛️ `AdaptiveModalSnapPointPreset?` | TBA         |
| 🔤 `snapPoints`<br/>⚛️ `[AdaptiveModalSnapPointConfig]`        | TBA         |
| 🔤 `dragHandlePosition`<br/>⚛️ `DragHandlePosition`            | TBA         |

<br>

**`AdaptiveModalConfig` Functions**

| Function                                                     | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| 🔤  `init`<br><br>**Parameters**:<br>🔤  `snapPoints`<br>⚛️ `[AdaptiveModalSnapPointConfig]`<br><br>🔤  `snapDirection`<br/>⚛️  `SnapDirection`<br/><br/>🔤  `snapPercentStrategy`<br/>⚛️  `SnapPercentStrategy?`<br/>✳️  **Default**: `nil`<br><br/>🔤  `snapAnimationConfig`<br/>⚛️  `AdaptiveModalSnapAnimationConfig?`<br/>✳️  **Default**: `nil`<br/><br/>🔤  `entranceAnimationConfig`<br/>⚛️  `AdaptiveModalSnapAnimationConfig?`<br/>✳️  **Default**: `nil`<br/><br/>🔤  `exitAnimationConfig`<br/>⚛️  `AdaptiveModalSnapAnimationConfig?`<br/>✳️  **Default**: `nil`<br/><br/>🔤  `interpolationClampingConfig`<br/>⚛️  `AdaptiveModalClampingConfig?`<br/>✳️  **Default**: `nil`<br/><br/>🔤  `initialSnapPointIndex`<br/>⚛️  `Int?`<br/>✳️  **Default**: `nil`<br/><br/>🔤  `undershootSnapPoint`<br/>⚛️  `AdaptiveModalSnapPointPreset?`<br/>✳️  **Default**: `nil`<br/><br/>🔤  `overshootSnapPoint`<br/>⚛️  `AdaptiveModalSnapPointPreset?`<br/>✳️  **Default**: `nil`<br/><br/>🔤  `dragHandlePosition`<br/>⚛️  `DragHandlePosition?`<br/>✳️  **Default**: `nil`<br/><br/>🔤  `dragHandleHitSlop`<br/>⚛️  `CGPoint?`<br/>✳️  **Default**: `nil`<br/><br/>🔤  `modalSwipeGestureEdgeHeight`<br/>⚛️  `CGFloat?`<br/>✳️  **Default**: `nil`<br/><br/>🔤  `shouldSetModalScrollViewContentInsets`<br/>⚛️  `Bool?`<br/>✳️  **Default**: `nil`<br/><br/>🔤  `shouldSetModalScrollView`<br>`VerticalScrollIndicatorInsets`<br/>⚛️  `Bool?`<br/>✳️  **Default**: `nil`<br/><br/>🔤  `shouldSetModalScrollView`<br>`HorizontalScrollIndicatorInsets`<br/>⚛️  `Bool?`<br/>✳️  **Default**: `nil`<br/> | Each parameter directly initializes a property with the same name in `AdaptiveModalConfig`. As such, please refer to the `AdaptiveModalConfig` property docs for more info.<br><br>The `snapPoints` parameter initializes the `baseSnapPoints` property. |

<br><be>

### Struct - `AdaptiveModalClampingConfig`

TBA

<br><br>

### Struct - `AdaptiveModalConfigMode`

TBA

<br><br>

### Struct - `AdaptiveModalConstrainedConfig`

TBA

<br><br>

### Struct - `AdaptiveModalInterpolationPoint`

TBA

<br><br>

### Struct - `AdaptiveModalKeyframeConfig`

TBA

<br><br>

### Struct - `AdaptiveModalSnapPointPreset`

TBA

<br><br>

### Enum - `AdaptiveModalState`

TBA

<br><br>

### Enum - `AdaptiveModalSnapAnimationConfig`

TBA

<br><br>

### Enum - `AdaptiveModalSnapPointConfig`

TBA

<br><br>

#### `AdaptiveModalManager` Properties

**Config-Related**

TBA

<br>

**Gesture-Related**

TBA

<br>

**General**

TBA

#### `AdaptiveModalManager` Functions

TBA

<br><br>

### Class - `AdaptiveModalDragHandleView`

TBA

<br><br>

### Protocol - `AdaptiveModalAnimationEventsNotifiable`

TBA

<br><br>

### Protocol - `AdaptiveModalGestureEventsNotifiable`

TBA

<br><br>

### Protocol - `AdaptiveModalPresentationEventsNotifiable`

TBA

<br><br>

### Protocol - `AdaptiveModalStateEventsNotifiable`

TBA

<br><br>

### Protocol - `AdaptiveModalBackgroundTapDelegate`

TBA

<br><br>

### Struct - `Angle`

TBA

<br><br>

### Struct - `Transform3D`

TBA

<br><br>

## Topics + Discussion

TBA

<br><br>

## Examples

TBA

<br><br>

## Misc and Contact

* 🐤 **Twitter/X**: `@GoDominic`
* 💌 **Email**: `dominicgo@dominicgo.dev`
* 🌐 **Website**: [dominicgo.dev](https://dominicgo.dev)

