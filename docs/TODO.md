# TODO

💖✨

<br><br>

## Current

- [ ] `TODO:2023-06-26-12-17-15` - Impl: Modal drag handle interpolation opacity.
- [ ]  `TODO:2023-06-27-21-11-15` - Refactor: Precompute all "modal handle"-related values.
- [ ] `TODO:2023-06-27-21-01-08` - Impl: Modal content opacity keyframe.
- [ ] `TODO:2023-06-23-03-17-21` - Impl: Respect `isAnimated` arg. when showing/hiding the modal.
- [ ] `TODO:2023-06-23-18-15-59` - Impl: `AdaptiveModal` - Update present/dismiss functions to support accepting "extra animations" block.
- [ ] `TODO:2023-06-28-04-16-09` - Impl: Update presentation-related delegates/subclass to integrate more with the modal transition + presentation/dismissal.
- [ ] `TODO:2023-06-28-04-17-14` - s Impl. auto recalculating of views when device is rotated.
- [ ] `TODO:2023-06-23-18-13-25` - Impl: `AdaptiveModal` - Config - Background interaction - `dismiss`, `passthrough`, `none`.
- [ ] `TODO:2023-06-23-18-14-24` -  Impl: `AdaptiveModal` - Add support for modal's w/ scrollviews.

<br><br>

## WIP

- [ ] `TODO:2023-06-24-23-15-29`  - Impl:  `AdaptiveModalConfig.keyboardOverrideSnapPoint`.
- [ ] `TODO:2023-06-28-04-17-34` Impl: Optimization - Conditionally initialize views only when needed.s

- [ ] `TODO:2023-06-23-18-13-58` -  Impl: `AdaptiveModal` - Add support for passing a user-created gesture handler.
- [ ] `TODO:2023-06-23-18-15-46` -  Impl: `AdaptiveModal` - Add support for animating the home gesture bar + status bar.
- [ ] `TODO:2023-06-23-18-15-46` -  Impl: `AdaptiveModal` - Adaptive config based on rules (i.e. the current size class, device type, device orientation, window size, etc).
- [ ] ` TODO:2023-06-23-18-16-28` - Impl: `AdaptiveModal` -Add support for "in-between" snap points.
- [ ] `TODO:2023-06-23-18-17-01` - Impl: `AdaptiveModal` - Expose root view as computed property.
- [ ] `TODO:2023-06-23-18-17-09` - Impl: `RNILayout` - `x` and `y` offsets.
- [ ] `TODO:2023-06-23-18-17-09` - Impl: `RNILayout` - raw rect layout value.
- [ ] `TODO:2023-06-23-18-17-19` - Impl: Modal Events Delegate - Will/Did show/hide modal events.
- [ ] `TODO:2023-06-23-18-17-27` - Impl: Modal Events Delegate - Drag begin/end event.
  * Send a ref of the animator so the user can attach custom animators.

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
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Animation Keyframes - Modal shadows.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Animation Keyframes - Modal corner radius and corner radius masks.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Animation Keyframes - modal opacity + undershoot snap point.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Animation Keyframes - Modal bg blur + opactiy.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Animation Keyframes - Bg blur and Bg opacity.
- [ ] `TODO:` - Docs: Create `AdaptiveModalExample00` - Animation Keyframes - Ex for animating the colors.
- [ ] `TODO:` - Docs: Create install instructions.

<br><br>

## Completed

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
