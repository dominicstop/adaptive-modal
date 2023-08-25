# adaptive-modal

Config-based `UIViewController` modal presentation w/ built in support for: 

* ❤️ Gesture-driven modal presentation and animation.
* 🧡 Snapping points, and keyframe-based animations (blurs, 3d transforms, color, alpha, shadows, drag handle, etc).
* 💛 Adaptive modal config (adapt based on the device/size class/rotation/accessibility/etc),
* 💚 Consolidated modal events, and unified/simplified modal state.
* 💙 Custom/override snapping points, keyboard avoidance, adaptive layout config, custom present/dismiss animations, custom drag handle...
* 💜 Etc.

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
  .upToNextMajor(from: "0.1.0"))
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

TBA

<br><br>

## Examples

TBA

<br><br>

## Misc and Contact

* 🐤 **Twitter/X**: `@GoDominic`
* 💌 **Email**: `dominicgo@dominicgo.dev`
* 🌐 **Website**: [dominicgo.dev](https://dominicgo.dev)

