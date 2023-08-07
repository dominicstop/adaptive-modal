//
//  AdaptiveModalPresentationTest.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 6/7/23.
//

import UIKit
import AdaptiveModal

fileprivate class TestModalViewController:
  UIViewController, AdaptiveModalEventNotifiable, AdaptiveModalBackgroundTapDelegate,
  AdaptiveModalAnimationEventsNotifiable {
  
  enum ContentMode {
    case buttons, scrollview;
  };

  weak var modalManager: AdaptiveModalManager?;
  
  var contentMode: ContentMode = .buttons;
  
  var showDismissButton = true;
  var showCustomSnapPointButton = false;
  var showTextInputField = false;
  
  var shouldSetOverrideOverShootSnapPoint = false;

  lazy var floatingViewLabel: UILabel = {
    let label = UILabel();
    
    label.text = "\(self.modalManager?.currentInterpolationIndex ?? -1)";
    label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5);
    label.font = .boldSystemFont(ofSize: 22);

    return label;
  }();
  
  override func viewDidLoad() {
    self.view.backgroundColor = .clear;
    
    let dismissButton: UIButton = {
      let button = UIButton();
      
      button.setTitle("Dismiss Modal", for: .normal);
      button.configuration = .filled();
      
      button.addTarget(
        self,
        action: #selector(self.onPressButtonDismiss(_:)),
        for: .touchUpInside
      );
      
      return button;
    }();
    
    let customSnapPointButton: UIButton = {
      let button = UIButton();
      
      button.setTitle("Custom Snap Point", for: .normal);
      button.configuration = .filled();
      
      button.addTarget(
        self,
        action: #selector(self.onPressButtonCustomSnapPoint(_:)),
        for: .touchUpInside
      );
      
      return button;
    }();
    
    let textInputField: UITextField = {
      let textField = UITextField();
    
      textField.placeholder = "Enter text here";
      textField.font = UIFont.systemFont(ofSize: 15);
      textField.borderStyle = UITextField.BorderStyle.roundedRect;
      textField.autocorrectionType = UITextAutocorrectionType.no;
      textField.keyboardType = UIKeyboardType.default;
      textField.returnKeyType = UIReturnKeyType.done;
      textField.clearButtonMode = UITextField.ViewMode.whileEditing;
      textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center;
      
      return textField;
    }();
    
    let controlsView: UIStackView = {
      let stack = UIStackView();
      
      stack.axis = .vertical;
      stack.distribution = .equalSpacing;
      stack.alignment = .center;
      stack.spacing = 10;
      
      stack.addArrangedSubview(self.floatingViewLabel);
      
      if self.showTextInputField {
        stack.addArrangedSubview(textInputField);
      };
      
      if self.showDismissButton {
        stack.addArrangedSubview(dismissButton);
      };
      
      if self.showCustomSnapPointButton {
        stack.addArrangedSubview(customSnapPointButton);
      };
      
      return stack;
    }();
    
    switch self.contentMode {
      case .buttons:
        controlsView.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(controlsView);
        
        NSLayoutConstraint.activate([
          controlsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
          controlsView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ]);
            
      case .scrollview:
        let stackView: UIStackView = {
          let stack = UIStackView();
          
          stack.axis = .vertical;
          stack.distribution = .fillProportionally;
          stack.alignment = .center;
          stack.spacing = 15;
                    
          return stack;
        }();
        
        stackView.addArrangedSubview(controlsView);
        stackView.setCustomSpacing(40, after: controlsView);
        
        for index in 0...30 {
          let label = UILabel();
          
          label.text = "\(index)";
          label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5);
          label.font = .boldSystemFont(ofSize: 22);

          stackView.addArrangedSubview(label);
          stackView.setCustomSpacing(15, after: label);
        };
        
        let scrollView: UIScrollView = {
          let scrollView = UIScrollView();
          
          scrollView.showsHorizontalScrollIndicator = false;
          scrollView.showsVerticalScrollIndicator = true;
          return scrollView
        }();
        
        stackView.translatesAutoresizingMaskIntoConstraints = false;
        scrollView.addSubview(stackView);
        
        NSLayoutConstraint.activate([
          stackView.topAnchor.constraint(
            equalTo: scrollView.topAnchor,
            constant: 40
          ),
          
          stackView.bottomAnchor.constraint(
            equalTo: scrollView.bottomAnchor,
            constant: -100
          ),
          
          stackView.centerXAnchor.constraint(
            equalTo: scrollView.centerXAnchor
          ),
        ]);
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(scrollView);
        
        NSLayoutConstraint.activate([
          scrollView.topAnchor     .constraint(equalTo: self.view.topAnchor     ),
          scrollView.bottomAnchor  .constraint(equalTo: self.view.bottomAnchor  ),
          scrollView.leadingAnchor .constraint(equalTo: self.view.leadingAnchor ),
          scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ]);
    };
  };
  
  @objc func onPressButtonDismiss(_ sender: UIButton){
    self.dismiss(animated: true);
  };
  
  @objc func onPressButtonCustomSnapPoint(_ sender: UIButton){
    let snapPoint = AdaptiveModalSnapPointConfig(
      key: .string("custom"),
      layoutConfig: .init(
        horizontalAlignment: .center,
        verticalAlignment: .center,
        width: .stretch(
          offsetValue: .constant(15 * 2),
          offsetOperation: .subtract
        ),
        height: .stretch,
        marginTop: .multipleValues([
          .safeAreaInsets(insetKey: \.top),
          .constant(15),
        ]),
        marginBottom: .multipleValues([
          .safeAreaInsets(insetKey: \.bottom),
          .keyboardRelativeSize(sizeKey: \.height),
          .constant(15),
        ])
      ),
      keyframeConfig: .init(
        modalCornerRadius: 15,
        modalMaskedCorners: .allCorners,
        modalBackgroundOpacity: 0.85,
        modalBackgroundVisualEffect: UIBlurEffect(style: .regular),
        modalBackgroundVisualEffectIntensity: 1
      )
    );
    
    let overShootSnapPoint = AdaptiveModalSnapPointPreset(
      layoutPreset: .offscreenLeft
    );
  
    try? self.modalManager?.snapTo(
      overrideSnapPointConfig: snapPoint,
      overshootSnapPointPreset: self.shouldSetOverrideOverShootSnapPoint
        ? overShootSnapPoint
        : nil
    );
  };
  
  func notifyOnModalWillSnap(
    sender: AdaptiveModalManager,
    prevSnapPointIndex: Int?,
    nextSnapPointIndex: Int,
    snapPointConfig: AdaptiveModalSnapPointConfig,
    interpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    self.floatingViewLabel.text = "\(nextSnapPointIndex)";
    
    print(
      "notifyOnModalWillSnap",
      "\n - prevSnapPointIndex:", prevSnapPointIndex ?? -1,
      "\n - nextSnapPointIndex:", nextSnapPointIndex,
      "\n"
    );
  };
  
  func notifyOnModalDidSnap(
    sender: AdaptiveModalManager,
    prevSnapPointIndex: Int?,
    currentSnapPointIndex: Int,
    snapPointConfig: AdaptiveModalSnapPointConfig,
    interpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    self.floatingViewLabel.text = "\(currentSnapPointIndex)";
    
    print(
      "notifyOnModalDidSnap",
      "\n - prevSnapPointIndex:", prevSnapPointIndex ?? -1,
      "\n - currentSnapPointIndex:", currentSnapPointIndex,
      "\n"
    );
  };
  
  func notifyOnAdaptiveModalWillShow(sender: AdaptiveModalManager) {
    print("onAdaptiveModalWillShow");
  };
  
  func notifyOnAdaptiveModalDidShow(sender: AdaptiveModalManager) {
    print("onAdaptiveModalDidShow");
  };
  
  func notifyOnAdaptiveModalWillHide(sender: AdaptiveModalManager) {
    print("onAdaptiveModalWillHide");
  };
  
  func notifyOnAdaptiveModalDidHide(sender: AdaptiveModalManager) {
    print("onAdaptiveModalDidHide");
  };
  
  func notifyOnAdaptiveModalDragGesture(
    sender: AdaptiveModalManager,
    gestureRecognizer: UIGestureRecognizer
  ) {
    print(
      "notifyOnAdaptiveModalDragGesture",
      "\n - sender.gesturePoint:", sender.gesturePoint?.debugDescription ?? "N/A",
      "\n - sender.gestureInitialPoint:", sender.gestureInitialPoint?.debugDescription ?? "N/A",
      "\n - sender.gestureOffset:", sender.gestureOffset?.debugDescription ?? "N/A",
      "\n - sender.gesturePointWithOffsets", sender.gesturePointWithOffsets?.debugDescription ?? "N/A",
      "\n"
    );
  };
  
  func notifyOnBackgroundTapGesture(sender: UIGestureRecognizer) {
    print("notifyOnBackgroundTapGesture");
  };
  
  func notifyOnModalAnimatorStart(
    sender: AdaptiveModalManager,
    animator: UIViewPropertyAnimator?,
    interpolationPoint: AdaptiveModalInterpolationPoint,
    isAnimated: Bool
  ) {
    print(
      "notifyOnModalAnimatorStart",
      "\n - interpolationPoint.percent:", interpolationPoint.percent,
      "\n - isAnimated:", isAnimated,
      "\n"
    );
  };
  
  func notifyOnModalAnimatorStop(sender: AdaptiveModalManager) {
    print("notifyOnModalAnimatorStop");
  };
  
  func notifyOnModalAnimatorPercentChanged(
    sender: AdaptiveModalManager,
    percent: CGFloat
  ) {
    print(
      "notifyOnModalAnimatorPercentChanged",
      "\n - percent:", percent,
      "\n"
    );
  };
  
  func notifyOnModalAnimatorCompletion(
    sender: AdaptiveModalManager,
    position: UIViewAnimatingPosition
  ) {
    print(
      "notifyOnModalAnimatorCompletion",
      "\n - position:", position,
      "\n"
    );
  }
};

class AdaptiveModalPresentationTestViewController : UIViewController {

  lazy var adaptiveModalManager = AdaptiveModalManager(
    staticConfig: self.currentModalConfigPreset.config
  );
  
  let modalConfigs = AdaptiveModalConfigDemoPresets.allCases;
  
  var currentModalConfigPresetCounter = 0;
  
  var currentModalConfigPresetIndex: Int {
    self.currentModalConfigPresetCounter % self.modalConfigs.count
  };
  
  var currentModalConfigPreset: AdaptiveModalConfigDemoPresets {
    self.modalConfigs[self.currentModalConfigPresetIndex];
  };
  
  var currentModalManagerAdjustmentBlock: (AdaptiveModalManager) -> Void {
    let defaultBlock: (AdaptiveModalManager) -> Void = {
      $0.shouldEnableOverShooting = true;
    
      $0.overrideShouldSnapToUnderShootSnapPoint = true;
      $0.overrideShouldSnapToOvershootSnapPoint = false;
      
      $0.shouldDismissModalOnSnapToUnderShootSnapPoint = true;
      $0.shouldDismissModalOnSnapToOverShootSnapPoint = false;
      
      $0.shouldDismissKeyboardOnGestureSwipe = false;
    };
  
    switch self.currentModalConfigPreset {
      case .demo04: return {
        $0.overrideShouldSnapToOvershootSnapPoint = true;
        $0.shouldDismissModalOnSnapToOverShootSnapPoint = true;
      };
      
      case .demo09: return {
        $0.shouldDismissKeyboardOnGestureSwipe = true;
      };
      
      case .demo07: return {
        $0.shouldEnableOverShooting = false;
      };
      
      case .demo12: return {
        $0.overrideShouldSnapToOvershootSnapPoint = true;
        $0.shouldDismissModalOnSnapToOverShootSnapPoint = true;
      };
      
      default: return defaultBlock;
    };
  };
  
  var counterLabel: UILabel?;
  
  override func viewDidLoad() {
    self.view.backgroundColor = .white;
    
    let dummyBackgroundView: UIView = {
      let imageView = UIImageView(
        image: UIImage(named: "DummyBackgroundImage2")
      );
      
      imageView.contentMode = .scaleAspectFill;
      return imageView;
    }();
    
    self.view.addSubview(dummyBackgroundView);
    dummyBackgroundView.translatesAutoresizingMaskIntoConstraints = false;
    
    NSLayoutConstraint.activate([
      dummyBackgroundView.topAnchor     .constraint(equalTo: self.view.topAnchor     ),
      dummyBackgroundView.bottomAnchor  .constraint(equalTo: self.view.bottomAnchor  ),
      dummyBackgroundView.leadingAnchor .constraint(equalTo: self.view.leadingAnchor ),
      dummyBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
    ]);
    
    let counterLabel: UILabel = {
      let label = UILabel();
      
      label.text = "\(self.currentModalConfigPresetIndex)";
      label.font = .systemFont(ofSize: 24, weight: .bold);
      label.textColor = .white;
      
      self.counterLabel = label;

      return label;
    }();
    
    let presentButton: UIButton = {
      let button = UIButton();
      button.setTitle("Present View Controller", for: .normal);
      
      button.addTarget(
        self,
        action: #selector(self.onPressButtonPresentViewController(_:)),
        for: .touchUpInside
      );
      
      return button;
    }();
    
    let nextConfigButton: UIButton = {
      let button = UIButton();
      button.setTitle("Next Modal Config", for: .normal);
      
      button.addTarget(
        self,
        action: #selector(self.onPressButtonNextConfig(_:)),
        for: .touchUpInside
      );
      
      return button;
    }();
    
    
    let stackView: UIStackView = {
      let stack = UIStackView();
      
      stack.axis = .vertical;
      stack.distribution = .equalSpacing;
      stack.alignment = .center;
      stack.spacing = 7;
      
      stack.addArrangedSubview(counterLabel);
      stack.addArrangedSubview(presentButton);
      stack.addArrangedSubview(nextConfigButton);
      
      return stack;
    }();
    
    stackView.translatesAutoresizingMaskIntoConstraints = false;
    self.view.addSubview(stackView);
    
    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
    ]);
  };
  
  override func viewDidLayoutSubviews() {

  };
  
  @objc func onPressButtonPresentViewController(_ sender: UIButton) {
    let testVC = TestModalViewController();
    
    switch self.currentModalConfigPreset {
      case .demo07, .demo08:
        testVC.showCustomSnapPointButton = true;
        
      case .demo09:
        testVC.showCustomSnapPointButton = true;
        testVC.showTextInputField = true;
        
      case .demo10:
        testVC.showCustomSnapPointButton = true;
        
      case .demo11:
        testVC.showTextInputField = true;
        testVC.showCustomSnapPointButton = true;
        
      case .demo12:
        testVC.showCustomSnapPointButton = true;
        testVC.shouldSetOverrideOverShootSnapPoint = true;
        
      case .demo13:
        testVC.contentMode = .scrollview;
        testVC.showCustomSnapPointButton = true;
        
      case .demo14:
        testVC.contentMode = .scrollview;
        
      case .demo15:
        testVC.contentMode = .scrollview;
        testVC.showCustomSnapPointButton = true;
      
      default: break;
    };
    
    if let presentedVC = self.presentedViewController {
      let modalManager = AdaptiveModalManager(
        adaptiveConfig: .adaptiveConfig(
          defaultConfig: self.currentModalConfigPreset.config,
          constrainedConfigs: self.currentModalConfigPreset.constrainedConfigs
        )
      );
      
      testVC.modalManager = modalManager;
      modalManager.eventDelegate = testVC;
      modalManager.backgroundTapDelegate = testVC;
      modalManager.animationEventDelegate = testVC;
      
      self.currentModalManagerAdjustmentBlock(modalManager);
      
      modalManager.presentModal(
        viewControllerToPresent: testVC,
        presentingViewController: presentedVC
      );
      
    } else {
      self.adaptiveModalManager.modalConfig = .adaptiveConfig(
        defaultConfig: self.currentModalConfigPreset.config,
        constrainedConfigs: self.currentModalConfigPreset.constrainedConfigs
      );
        
      testVC.modalManager = self.adaptiveModalManager;
      self.adaptiveModalManager.eventDelegate = testVC;
      self.adaptiveModalManager.backgroundTapDelegate = testVC;
      self.adaptiveModalManager.animationEventDelegate = testVC;
      
      self.currentModalManagerAdjustmentBlock(self.adaptiveModalManager);
      
      self.adaptiveModalManager.presentModal(
        viewControllerToPresent: testVC,
        presentingViewController: self
      );
    };
  };
  
  @objc func onPressButtonNextConfig(_ sender: UIButton) {
    self.currentModalConfigPresetCounter += 1;
    self.counterLabel!.text = "\(self.currentModalConfigPresetIndex)";
  };
};
