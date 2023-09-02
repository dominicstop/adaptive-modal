//
//  AdaptiveModalPaginatedTestViewController.swift
//  adaptive-modal-example
//
//  Created by Dominic Go on 9/1/23.
//

import UIKit
import AdaptiveModal
import ComputableLayout

fileprivate class ModalViewController: UIViewController {

  weak var modalManager: AdaptiveModalManager?;
  
  var instanceID = -1;
  var snapPointIndex = -1 {
    willSet {
      self.labelSnapPointIndex.text = "Snap Point Index: \(newValue)";
    }
  };
  
  private var shouldIncreaseModalIndexOnTap = true;
  
  lazy var labelEmoji: UILabel = {
    let label = UILabel();
    
    let emojiList = ["⭐️", "💖", "⚛️", "🛁", "🐞"];
    let emoji = emojiList[self.instanceID % emojiList.count];

    label.text = emoji;
    label.font = .systemFont(ofSize: 32);
    
    return label;
  }();
  
  lazy var labelInstanceID: UILabel = {
    let label = UILabel();

    label.text = "VC Instance: \(self.instanceID)";
    label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5);
    label.font = .systemFont(ofSize: 20, weight: .bold);
    
    return label;
  }();
  
  lazy var labelSnapPointIndex: UILabel = {
    let label = UILabel();
    
    label.text = "Snap Point Index: \(self.snapPointIndex)";
    label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5);
    label.font = .systemFont(ofSize: 18);
    
    let tapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(Self.onPressLabelSnapPointIndex(_:))
    );
    
    label.addGestureRecognizer(tapGesture);
    label.isUserInteractionEnabled = true;

    return label;
  }();
  
  override func viewDidLoad() {
    self.view.backgroundColor = .clear;
    
    let dismissButton: UIButton = {
      let button = UIButton();
      
      let colors: [UIColor] = [
        .systemRed,
        .systemOrange,
        .systemYellow,
        .systemGreen,
        .systemBlue,
        .systemPurple
      ];
      
      button.setTitle("Dismiss Modal", for: .normal);
      button.configuration = {
        var config: UIButton.Configuration = .filled();
        config.baseBackgroundColor = colors[self.instanceID % colors.count];
        
        return config;
      }();
      
      button.addTarget(
        self,
        action: #selector(self.onPressButtonDismiss(_:)),
        for: .touchUpInside
      );
      
      return button;
    }();
   
    let controlsView: UIStackView = {
      let stack = UIStackView();
      
      stack.axis = .vertical;
      stack.distribution = .fill;
      stack.alignment = .center;
      stack.spacing = 1;
      
      stack.addArrangedSubview(self.labelEmoji);
      stack.addArrangedSubview(self.labelInstanceID);
      stack.addArrangedSubview(self.labelSnapPointIndex);
      
      stack.setCustomSpacing(17, after: self.labelSnapPointIndex);
      stack.addArrangedSubview(dismissButton);
      
      return stack;
    }();
    
    controlsView.translatesAutoresizingMaskIntoConstraints = false;
    self.view.addSubview(controlsView);
    
    NSLayoutConstraint.activate([
      controlsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      controlsView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
    ]);
  };
  
  @objc func onPressLabelSnapPointIndex(_ sender: UITapGestureRecognizer){
    guard let modalManager = self.modalManager else { return };
    let modalConfig = modalManager.currentModalConfig;

    let currentIndex = modalManager.currentInterpolationIndex;
    let lastIndex = {
      guard let overshootIndex = modalConfig.overshootSnapPointIndex else {
        return modalConfig.snapPointLastIndex;
      };
      
      return overshootIndex - 1;
    }();
    
    if currentIndex == lastIndex {
      self.shouldIncreaseModalIndexOnTap = false;
    
    } else if currentIndex == 0 {
      self.shouldIncreaseModalIndexOnTap = true;
    };
    
    if self.shouldIncreaseModalIndexOnTap {
      modalManager.snapToNextSnapPointIndex();
    
    } else {
      modalManager.snapToPrevSnapPointIndex();
    };
  };
  
  @objc func onPressButtonDismiss(_ sender: UIButton){
    self.modalManager?.dismissModal(
      animated: true,
      animationConfig: .presetCurve(
        duration: 0.275,
        curve: .easeInOut
      )
    );
  };
};

extension ModalViewController: AdaptiveModalPresentationEventsNotifiable {

  func notifyOnModalWillSnap(
    sender: AdaptiveModalManager,
    prevSnapPointIndex: Int?,
    nextSnapPointIndex: Int,
    snapPointConfig: AdaptiveModalSnapPointConfig,
    interpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    self.snapPointIndex = nextSnapPointIndex;
  };
  
  func notifyOnModalDidSnap(
    sender: AdaptiveModalManager,
    prevSnapPointIndex: Int?,
    currentSnapPointIndex: Int,
    snapPointConfig: AdaptiveModalSnapPointConfig,
    interpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    self.snapPointIndex = currentSnapPointIndex;
  };
  
  func notifyOnAdaptiveModalWillShow(sender: AdaptiveModalManager) {
    // no-op
  };
  
  func notifyOnAdaptiveModalDidShow(sender: AdaptiveModalManager) {
    // no-op
  };
  
  func notifyOnAdaptiveModalWillHide(sender: AdaptiveModalManager) {
    // no-op
  };
  
  func notifyOnAdaptiveModalDidHide(sender: AdaptiveModalManager) {
    // no-op
  };
  
  func notifyOnModalPresentCancelled(sender: AdaptiveModalManager) {
    // no-op
  };
  
  func notifyOnModalDismissCancelled(sender: AdaptiveModalManager) {
    // no-op
  };
  
  func notifyOnCurrentModalConfigDidChange(
    sender: AdaptiveModalManager,
    currentModalConfig: AdaptiveModalConfig?,
    prevModalConfig: AdaptiveModalConfig?
  ) {
    // no-op
  };
};

class AdaptiveModalPageTestViewController: UIViewController {
  
  override func viewDidLoad() {
    self.view.backgroundColor = .white;
    
    let dummyBackgroundView: UIView = {
      let imageView = UIImageView(
        image: UIImage(named: "DummyBackgroundImage")
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
    
    let presentButton: UIButton = {
      let button = UIButton();
      button.setTitle("Present View Controller", for: .normal);
      button.configuration = .filled();
      
      button.addTarget(
        self,
        action: #selector(self.onPressButtonPresentViewController(_:)),
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
      
      stack.addArrangedSubview(presentButton);
      return stack;
    }();
    
    stackView.translatesAutoresizingMaskIntoConstraints = false;
    self.view.addSubview(stackView);
    
    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
    ]);
  };
  
  @objc func onPressButtonPresentViewController(_ sender: UIButton) {
    let modalConfig = AdaptiveModalConfig(
      snapPoints: [
        // snap point - 1
        AdaptiveModalSnapPointConfig(
          layoutConfig: ComputableLayout(
            horizontalAlignment: .center,
            verticalAlignment: .bottom,
            width: .stretch,
            height: .percent(percentValue: 0.3)
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
        
        // snap point - 2
        AdaptiveModalSnapPointConfig(
          layoutConfig: ComputableLayout(
            horizontalAlignment: .center,
            verticalAlignment: .bottom,
            width: .stretch,
            height: .percent(percentValue: 0.5)
          )
        ),
        
        // snap point - 3
        AdaptiveModalSnapPointConfig(
          layoutConfig: ComputableLayout(
            horizontalAlignment: .center,
            verticalAlignment: .bottom,
            width: .stretch,
            height: .percent(percentValue: 0.7)
          )
        ),
        
        // snap point - 4
        AdaptiveModalSnapPointConfig(
          layoutConfig: ComputableLayout(
            horizontalAlignment: .center,
            verticalAlignment: .bottom,
            width: .stretch,
            height: .stretch,
            marginTop: .safeAreaInsets(insetKey: \.top)
          )
        )
      ],
      snapDirection: .bottomToTop,
      undershootSnapPoint: .automatic,
      overshootSnapPoint: AdaptiveModalSnapPointPreset(
        layoutPreset: .fitScreenVertically
      )
    );
  
    let modalManager = AdaptiveModalManager(staticConfig: modalConfig);
    
    let pageVC = AdaptiveModalPageViewController(pages: [
      AdaptiveModalPageItemConfig(
        associatedSnapPoints: [
          .index(1)
        ],
        viewController: {
          let modalVC = ModalViewController();
          modalVC.modalManager = modalManager;
          modalVC.instanceID = 0;
          
          modalManager.presentationEventsDelegate.add(modalVC);
          return modalVC;
        }()
      ),
      
      AdaptiveModalPageItemConfig(
        associatedSnapPoints: [
          .index(2)
        ],
        viewController: {
          let modalVC = ModalViewController();
          modalVC.modalManager = modalManager;
          modalVC.instanceID = 1;
          
          modalManager.presentationEventsDelegate.add(modalVC);
          return modalVC;
        }()
      ),
      
      AdaptiveModalPageItemConfig(
        associatedSnapPoints: [
          .index(3)
        ],
        viewController: {
          let modalVC = ModalViewController();
          modalVC.modalManager = modalManager;
          modalVC.instanceID = 2;
          
          modalManager.presentationEventsDelegate.add(modalVC);
          return modalVC;
        }()
      ),
      
      AdaptiveModalPageItemConfig(
        associatedSnapPoints: [
          .index(4)
        ],
        viewController: {
          let modalVC = ModalViewController();
          modalVC.modalManager = modalManager;
          modalVC.instanceID = 3;
          
          modalManager.presentationEventsDelegate.add(modalVC);
          return modalVC;
        }()
      ),
    ]);
    
    modalManager.presentModal(
      viewControllerToPresent: pageVC,
      presentingViewController: self
    );
  };
};
