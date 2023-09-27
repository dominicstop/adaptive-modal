//
//  RNIDraggableTestViewController.swift
//  swift-programmatic-modal
//
//  Created by Dominic Go on 5/22/23.
//


import UIKit
import AdaptiveModal

class AdaptiveModalConfigTestViewController : UIViewController {
  
  lazy var modalManager: AdaptiveModalManager = {
    let manager = AdaptiveModalManager(
      presentingViewController: self,
      staticConfig: AdaptiveModalConfigTestPresets.default.config
    );
    
    manager.stateEventsDelegate.add(self);
    manager.presentationEventsDelegate.add(self);
    manager.gestureEventsDelegate.add(self);
    
    return manager;
  }();
  
  private var initialGesturePoint: CGPoint = .zero;
  private var floatingViewInitialCenter: CGPoint = .zero
  
  lazy var floatingViewLabel: UILabel = {
    let label = UILabel();
    
    label.text = "\(self.modalManager.currentSnapPointIndex)";
    label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5);
    label.font = .boldSystemFont(ofSize: 22);

    return label;
  }();
  
  lazy var floatingView: UIView = {
    let view = UIView();
    
    // view.backgroundColor = UIColor(
    //   hue: 0/360,
    //   saturation: 0/100,
    //   brightness: 100/100,
    //   alpha: 0
    // );
    
    // view.addGestureRecognizer(
    //   UIPanGestureRecognizer(
    //     target: self,
    //     action: #selector(self.onDragPanGestureView(_:))
    //   )
    // );
    
    let floatingViewLabel = self.floatingViewLabel;
    view.addSubview(floatingViewLabel);
    
    floatingViewLabel.translatesAutoresizingMaskIntoConstraints = false;
    
    NSLayoutConstraint.activate([
      floatingViewLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      floatingViewLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ]);
    
    return view;
  }();

  override func viewDidLoad() {
    self.view.backgroundColor = .white;
    
    let dummyBackgroundView: UIView = {
      let imageView = UIImageView(
        image: UIImage(named: "DummyBackgroundImage3")
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
      
      button.setTitle("Show Modal", for: .normal);
      button.configuration = .filled();
      
      button.addTarget(
        self,
        action: #selector(self.onPressButtonPresentViewController(_:)),
        for: .touchUpInside
      );
      
      return button;
    }();
    
    self.view.addSubview(presentButton);
    presentButton.translatesAutoresizingMaskIntoConstraints = false;
    
    NSLayoutConstraint.activate([
      presentButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      presentButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
    ]);
  };
  
  override func viewDidLayoutSubviews() {
    self.modalManager.notifyDidLayoutSubviews();
  };
  
  @objc func onPressButtonPresentViewController(_ sender: UIButton){
    // self.modalManager.prepareForPresentation(
    //   modalView: self.floatingView,
    //   targetView: self.view
    // );
  
    //self.modalManager.showModal();
  };
};

extension AdaptiveModalConfigTestViewController:
  AdaptiveModalStateEventsNotifiable,
  AdaptiveModalPresentationEventsNotifiable,
  AdaptiveModalGestureEventsNotifiable {
  
  func notifyOnModalWillSnap(
    sender: AdaptiveModalManager,
    prevSnapPointIndex: Int?,
    nextSnapPointIndex: Int,
    prevSnapPointConfig: AdaptiveModalSnapPointConfig?,
    nextSnapPointConfig: AdaptiveModalSnapPointConfig,
    prevInterpolationPoint: AdaptiveModalInterpolationPoint?,
    nextInterpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    self.floatingViewLabel.text = "\(nextSnapPointIndex)";
  }
  
  func notifyOnModalDidSnap(
    sender: AdaptiveModalManager,
    prevSnapPointIndex: Int?,
    currentSnapPointIndex: Int,
    prevSnapPointConfig: AdaptiveModalSnapPointConfig?,
    currentSnapPointConfig: AdaptiveModalSnapPointConfig,
    prevInterpolationPoint: AdaptiveModalInterpolationPoint?,
    currentInterpolationPoint: AdaptiveModalInterpolationPoint
  ) {
    self.floatingViewLabel.text = "\(currentSnapPointIndex)";
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
  
  func notifyOnModalPresentCancelled(sender: AdaptiveModal.AdaptiveModalManager) {
    // no-op
  }
  
  func notifyOnModalDismissCancelled(sender: AdaptiveModal.AdaptiveModalManager) {
    // no-op
  }
  
  func notifyOnAdaptiveModalDragGesture(
    sender: AdaptiveModalManager,
    gestureRecognizer: UIGestureRecognizer
  ) {
    // no-op
  };
  
  func notifyOnCurrentModalConfigDidChange(
    sender: AdaptiveModalManager,
    currentModalConfig: AdaptiveModalConfig?,
    prevModalConfig: AdaptiveModalConfig?
  ) {
    // no-p[
  };
  
  func notifyOnModalStateWillChange(
    sender: AdaptiveModalManager,
    prevState: AdaptiveModalState,
    currentState: AdaptiveModalState,
    nextState: AdaptiveModalState
  ) {
    // no-op
  };
};
