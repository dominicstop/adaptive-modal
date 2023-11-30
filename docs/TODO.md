# TODO - `AdaptiveModal`

💖✨

<br><br>

## Current

- [ ] `TODO:2023-11-30-15-09-42` - Refactor: `AdaptiveModalManager` - Streamline modal presentation, and remove other ways of presenting the modal.
- [ ] `TODO:2023-11-30-15-05-46` - Refactor: `AdaptiveModalManager` - Rename `modalRootView` to `modalWrapperView`.
- [ ] `TODO:2023-11-30-15-10-26` - Refactor: `AdaptiveModalManager` - Rename `targetView` to `modalRootView`.

<br>

- [ ] `TODO:2023-11-30-15-17-43` - Refactor: `AdaptiveModalManager` - Move public functions to their own file, e.g. `AdaptiveModalManager+PublicFunctions`. 
- [ ] `TODO:2023-11-30-15-19-38` - Refactor: `AdaptiveModalManager` - Extract/group gesture related properties to `AdaptiveModalGestureContext`.
- [ ] `TODO:2023-11-30-17-50-08` - Refactor: `AdaptiveModalManager` - Extract/group display link related properties to `AdaptiveModalDisplayLinkContext`
- [ ] `TODO:2023-11-30-17-51-09` - Refactor: `AdaptiveModalManager` - Extract/group interpolation point related values to `AdaptiveModalInterpolationPointContext` 
- [ ] `TODO:2023-11-30-17-51-41` - Refactor: `AdaptiveModalManager` - Extract/group modal-related values to `AdaptiveModalMetadata`.
- [ ] `TODO:2023-11-30-17-52-05` - Refactor: `AdaptiveModalManager` - Extract/group modal animation related properties and logic to `AdaptiveModalAnimationContext`.

<br><br>

## WIP

- [ ] `TODO:2023-08-13-12-43-11` - Fix crash due to  `NaN` value during interpolation.
- [ ] `TODO:2023-07-11-22-45-46` - Impl: Keyframe - Update `modalCornerRadius` to accept a constant or percentage, then compute based on the modal size.
- [ ] `TODO:2023-06-28-04-16-09` - Impl: Update presentation-related delegates/subclass to integrate more with the modal transition + presentation/dismissal.
- [ ] `TODO:2023-06-24-23-15-29`  - Impl:  `AdaptiveModalConfig.keyboardOverrideSnapPoint`.
- [ ] `TODO:2023-06-28-04-17-34` Impl: Optimization - Conditionally initialize views only when needed.
- [ ] `TODO:2023-06-23-18-15-46` -  Impl: `AdaptiveModal` - Add support for animating the home gesture bar + status bar.
- [ ] `TODO:2023-06-23-18-17-01` - Impl: `AdaptiveModal` - Expose root view as computed property.
- [ ] `TODO:2023-10-24-20-58-01` - Impl: Shared element transition for entrance transition - Accept a view that will be snapshotted, and will be used during the entrance transition of the view.
- [ ] `TODO:2023-08-29-10-07-08` - Impl: Present a modal in place (e.g. fade in, scale in, etc) via a animation keyframe config + snap point index/key.

- [ ] `TODO:2023-09-19-14-25-06` - Refactor: Replace `UIVisualEffectView` usage w/ `VisualEffectBlurView`.

<br>

- [ ] `TODO:2023-06-23-18-17-27` - Chore: Publish initial version of the swift package.

<br><br>

## Docs-Related

- [ ] `TODO:2023-06-26-08-30-23` - Docs: Create `AdaptiveModalExample00` - Basic usage - Presenting a simple modal with one snap point.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Basic usage - Modal with one snap point + undershoot and overshoot preset.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Basic usage - Modal with one snap point + custom undershoot and overshoot config.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample01` - Basic Usage - Modal with 2 snapping points.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Layout - Constants and percentages for modal height and width.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Layout - Percentages + stretch, combined w/ min/max and offsets for the modal height and width.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Layout - Margins + constants and percent. 
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Layout - Margins + Safe Area and multiple values.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Layout - Margins + Keyboard values.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Animation Keyframes - Scale, transform, rotate and translate.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Animation Keyframes - Modal borders.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - 
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Animation Keyframes - 
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Animation Keyframes - modal opacity + undershoot snap point.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Animation Keyframes - Modal bg blur + opactiy.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Animation Keyframes - Bg blur and Bg opacity.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Animation Keyframes - Ex for animating the colors.
- [ ] `TODO:` - Docs: Create install instructions.

<br><br>

## Completed

- [x] `TODO:2023-09-16-06-33-40` - Fix: Modal corner radius layout bug - Modal corner radius mask cannot be animated, so applying next mask immediately during modal dragging/snapping.
- [x] `TODO:2023-09-15-21-58-53` - Fix: Drag handle layout bug - On a horizontal modal, the drag handle animates to the wrong position when dismissing via animator. 
  * Caused by a misconfigured override undershoot snap point during dismissal (i.e. when `hideModal` is invoked). 

<br>

- [x] `TODO:2023-09-15-22-06-28` - Fix: Modal blur layout bug - When a modal has a 3D transform, the modal's background blur disappears.
  * The layout bug is caused by the modal shadow view (`modalWrapperShadowView`.
  * For this bug to occur there must be: a 3d modal transform, a blur view, and modal shadows.
    * It does not matter whether the modal's BG blur is animated or not, the bug still occurs (i.e. disabling the modal blur animator does nothing).
    * The bug is not caused by autolayout (i.e. changing the layout constraints, or removing the layout constraints does nothing).
  * The bug happens when there is a shadow view in the modal's view hierarchy, e.g.:
    * The blur view is a child of a parent view that has shadows, (e.g. adding the shadows to `modalWrapperShadowView`). 
    * The blur view has a child that has shadows (e.g. adding the shadows to `modalContentWrapperView`).
    * The blur view itself has shadows (e.g. adding the shadows to `modalBackgroundBlurEffectStyleView`).
  * A possible fix could be to add the shadow view as sibling to the blur view. 

<br>

- [x] `TODO:2023-09-02-16-35-02` - Impl: Paginated Modal Content - Each snap point can have an associated "page" (i.e. a view controller), and the modal content changes based on the current snap point.

- [x] `TODO:2023-08-07-19-49-08` - Refactor `AdaptiveModalClampingConfig` - Accept list of keys that will be clamped left/initial value, right/last value.

- [x] `TODO:2023-08-27-13-54-16` - Impl: Default clamping config based on the snap direction. This is so that we can selectively extrapolate the width/height of the modal (e.g. only extrapolate the height).
- [x] `TODO:2023-08-18-01-24-19` - Refactor: Extract `RNILayout`, and publish as a separate library named `ComputableLayout`, and add it as a dependency to this package.

- [x] `TODO:2023-06-23-18-13-58` -  Impl: `AdaptiveModal` - Add support for passing a user-created `UIScreenEdgePanGestureRecognizer` gesture handler.

- [x] `TODO:2023-08-19-02-57-15` - Impl: Modal Manager Commands - Update `presentModal` to accept an arg that specifies where the modal snap's to when it gets presented.

- [x] `TODO:2023-08-18-04-51-59` - Impl: Modal Manager Commands - `dismissModal` with custom keyframe (i.e. animate in place, no layout changes; only keyframe animations, e.g. fade out, zoom out, etc).

- [x] `TODO:2023-08-14-06-28-18` - Impl: `dismiss` with custom snap point. 

- [x] `TODO:2023-08-17-23-52-21` - Impl: Event - On modal state change.

- [x] `TODO:2023-07-24-23-03-17` - Impl: Adaptive modal state.

- [x] `TODO:2023-08-13-19-26-53` - Events - `notifyOnCurrentModalConfigDidChange`.

- [x] `TODO:2023-08-13-12-26-59` - Impl: Keyframe - Update transform to support `perspective`, `shearX`, `shearY`.

- [x] ` TODO:2023-06-23-18-16-28` - Impl: `AdaptiveModal` - Add support for "in-between" snap points.

- [x] `TODO:2023-08-05-03-22-37` - Snap Point Config - allow snapping.

- [x] `TODO:2023-08-07-06-39-15` - Impl: Keyframe - Add support for 3D transforms. 

- [x] `TODO:2023-08-05-03-22-47` - Adaptive Modal Config - Custom animation config for entrance and exit. 

- [x] `TODO:2023-08-05-03-23-06` - `AdaptiveModalManager` - Custom animation config param. for modal present, dismiss and snapping.

- [x] `TODO:2023-08-05-03-24-07` - `AdaptiveModalSnapAnimationConfig` - Refactor to support more animation options.

- [x] `TODO:2023-06-23-18-15-46` -  Impl: `AdaptiveModal` - Adaptive config based on rules (i.e. the current size class, device type, device orientation, window size, etc).

- [x] `TODO:2023-07-24-14-59-51` - Impl: Modal Events Delegate - `AdaptiveModalAnimationEventsNotifiable` - Modal `onPercentChange`.

- [x] `TODO:2023-07-26-20-24-06` - Impl: Keyframe - Modal drag handle corner radius.

- [x] `TODO:2023-06-23-18-17-27` - Impl: Modal Events Delegate - Modal `onDragPanGesture` event + `gestureRecognizer` arg. 

- [x] `TODO:2023-06-23-18-17-19` - Impl: Modal Events Delegate - Will/did show/hide modal events.

- [x] `TODO:2023-07-11-22-37-10` - Impl: Keyframe - Update `modalScrollViewContentInsets`, `modalScrollViewVerticalScrollIndicatorInsets`, and `modalScrollViewHorizontalScrollIndicatorInsets` to accept `RNILayoutValue`.

- [x] `TODO:2023-06-23-18-17-09` - Impl: `RNILayout` - raw rect layout value.

- [x] `TODO:2023-06-23-18-17-09` - Impl: `RNILayout` - `x` and `y` offsets.

- [x] `TODO:2023-07-10-11-30-47` - Impl: Make Overshoot snap point config optional.

- [x] `TODO:2023-07-22-16-43-41` - Impl: `AdaptiveModalSnapPointPreset` + `RNILayoutPreset.automatic`. 

- [x] `TODO:2023-07-10-11-32-03` - Impl: Detect and warn against interpolation percent collision.

- [x] `TODO:2023-07-12-07-39-47` - Impl: Make separate default keyframe value for undershoot snap point.

- [x] `TODO:2023-07-12-07-37-27` - Impl: Keyframe - Modal drag handle size.

- [x] `TODO:2023-07-09-19-43-23` - Refactor: Update modal drag handle to work when outside the modal content bounds. 

- [x] `TODO:2023-07-11-02-45-28` - Impl: Limit modal gesture via `gestureRecognizerShouldBegin` + the current `secondaryGestureAxisDampingPercent` value. 

- [x] `TODO:2023-07-10-17-50-34` - Impl: Keyframe -  `modalScrollViewVerticalScrollIndicatorInsets`.

- [x] `TODO:2023-07-10-17-50-41` - Impl: Keyframe - `modalScrollViewHorizontalScrollIndicatorInsets`.
- [x] `TODO:2023-07-10-11-00-02` - Impl: Keyframe - `modalScrollViewContentInsets`.

- [x] `TODO:2023-07-10-17-53-41` - Impl: `allowModalToDragWhenAtMaxScrollViewOffset`.

- [x] `TODO:2023-07-10-17-53-59` - Impl: `allowModalToDragWhenAtMinScrollViewOffset`.
- [x] `TODO:2023-07-09-11-12-04` - Impl: `modalSwipeGestureEdgeHeight`.

- [x] `TODO:2023-07-09-11-04-39`  - Impl: "Drag Handle" `hitSlop` /`pointInsideInset`.

- [x] `TODO:2023-06-23-18-14-24` -  Impl: `AdaptiveModal` - Add support for modal's w/ scrollviews.

- [x] `TODO:2023-06-23-18-13-25` - Impl: `AdaptiveModal` - Config - Background interaction - `automatic`,  `dismiss`, `passthrough`, `none`.

- [x] `TODO:2023-06-28-10-33-55` - Impl: Optimize - `notifyDidLayoutSubviews`.

- [x] `TODO:2023-06-27-21-01-08` - Impl: Modal content opacity keyframe.

- [x] `TODO:2023-06-27-21-11-15` - Refactor: Precompute all "modal handle"-related values.

- [x] `TODO:2023-06-23-18-15-59` - Impl: `AdaptiveModal` - Update present/dismiss functions to support accepting "extra animations" block.

- [x] `TODO:2023-06-23-03-17-21` - Impl: Respect `isAnimated` arg. when showing/hiding the modal.

- [x] `TODO:2023-06-28-04-17-14` -  Impl. auto recalculating of views when device is rotated.

- [x] `TODO:2023-06-26-12-17-15` - Impl: Modal drag handle interpolation opacity keyframe.

- [x] `TODO:2023-06-27-21-11-07` - Fix: Keyboard-related bug - Drag becomes unresponsive.

  *  Persists even after dismissal + reset.

  * Can be reproduced by dismissing a modal while the keyboard is visible.

  * Fixes itself when the keyboard becomes visible again, and is dismissed via dragging.

  * Some state related to the keyboard might not be reset, triggering the gesture to cancel prematurely,

<br>

- [x] `TODO:2023-06-26-12-16-58` - Impl: Modal drag handle interpolation color keyframe.
- [x] `TODO:2023-06-26-12-16-49` - Impl: Modal drag handle interpolation offset keyframe.
- [x] `TODO:2023-06-25-02-31-12` -  Impl: Modal drag handle + modal drag handle config.
- [x] `TODO:2023-06-26-12-16-31` - Fix: `AdaptiveModalManagers.shouldDismissKeyboardOnGestureSwipe` abrupt animation.
- [x] `TODO:2023-06-23-18-13-48` -  Impl: `AdaptiveModalManager.secondaryAxisDampingPercent`.
- [x] `TODO:2023-06-23-18-13-34` -  Impl:  `AdaptiveModalManager.shouldLockAxisToModalDirection`.
- [x] `TODO:2023-06-24-23-55-57` - Impl: `AdaptiveModalManager.isSwipeGestureEnabled`.
- [x] `TODO:2023-06-24-23-46-58` - Impl:  `AdaptiveModalManagers.shouldDismissKeyboardOnGestureSwipe`.
- [x] `TODO:2023-06-25-05-24-18` - Impl: `isAnimated` arg. for `AdaptiveModalManager.animateTo` and related functions.
- [x] `TODO:2023-06-23-18-13-12` - Impl:  `AdaptiveModalManager.clearSnapPointOverride`.
- [x] `TODO:2023-06-23-03-12-52` - Impl:  `AdaptiveModalManager.snapTo(key:)`.
- [x] `TODO:2023-06-24-09-04-32` - Impl: `RNILayoutValueMode` - `conditionalValue` .

- [x] `TODO:2023-06-23-18-14-47` -  Impl: `AdaptiveModal` - Add support for modal content padding.
