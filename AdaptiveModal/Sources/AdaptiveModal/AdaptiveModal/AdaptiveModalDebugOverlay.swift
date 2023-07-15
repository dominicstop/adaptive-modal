//
//  AdaptiveModalDebugOverlay.swift
//  adaptive-modal-example
//
//  Created by Dominic Go on 7/13/23.
//

import UIKit

extension UIGestureRecognizer.State {
  var string: String {
    switch self {
      case .possible : return "possible";
      case .began    : return "began";
      case .changed  : return "changed";
      case .ended    : return "ended";
      case .cancelled: return "cancelled";
      case .failed   : return "failed";
      
      @unknown default: return "unknown";
    };
  };
  
  var isActive: Bool {
    switch self {
      case .began, .changed:
        return true;
      
      case .possible, .ended, .cancelled, .failed:
        return false;
      
      @unknown default:
        return false;
    };
  };
};

class AdaptiveModalDebugOverlay: UIView {

  weak var modalManager: AdaptiveModalManager?;
  
  // MARK: - Properties
  // ------------------
  
  var invokeHistory: [String] = [];
  
    // MARK: - Properties - UI Refs
  // ------------------------------
  
  private var labelInvoke: UILabel!;
  private var labelInvokePrev: UILabel!;
  private var labelInvokePrev2: UILabel!;
  
  private var labelGestureState: UILabel!;
  private var labelIsAnimating: UILabel!;
  private var labelIsSwiping: UILabel!;
  
  private var labelGestureOffset: UILabel!;
  private var labelGestureVelocity: UILabel!;
  private var labelGestureInitialPoint: UILabel!;
  private var labelGesturePointPrev: UILabel!;
  private var labelGesturePoint: UILabel!;
  
  private var labelNextRectOrigin: UILabel!;
  private var labelNextRectSize: UILabel!;
  private var labelNextRectMaxOrigin: UILabel!;
  
  private var labelPrevRectOrigin: UILabel!;
  private var labelPrevRectSize: UILabel!;
  private var labelPrevRectMaxOrigin: UILabel!;
  
  private var labelModalFrameOrigin: UILabel!;
  private var labelModalFrameSize: UILabel!;
  private var labelPrevModalFrameOrigin: UILabel!;
  private var labelPrevModalFrameSize: UILabel!;
  
  private var labelModalFrameMaxOrigin: UILabel!;
  private var labelModalFrameCenter: UILabel!;
  
  // MARK: - Init
  // ------------

  init(modalManager: AdaptiveModalManager) {
    super.init(frame: .zero);
    
    self.modalManager = modalManager;
    self.setupView();
  };
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented");
  };
  
  func setupView(){
    self.isUserInteractionEnabled = false;
    
    let stackView: UIStackView = {
      let stack = UIStackView();
      
      stack.axis = .vertical;
      stack.distribution = .fillProportionally;
      stack.alignment = .center;
      stack.spacing = 3;
      
      stack.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5);
      
      return stack;
    }();
    
    func makeLabelRowStack() -> UIStackView {
      let stack = UIStackView();
      
      stack.axis = .horizontal;
      stack.distribution = .fillProportionally;
      stack.alignment = .center;
      stack.spacing = 10;
      
      return stack;
    };
    
    func makeLabelDetail(text: String) -> UILabel {
      let labelDetail = UILabel();

      labelDetail.text = text;
      labelDetail.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5);
      labelDetail.font = .boldSystemFont(ofSize: 14);
      
      return labelDetail;
    };
    
    func makeLabelValue(text: String) -> UILabel {
      let labelValue = UILabel();

      labelValue.text = text;
      labelValue.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1);
      labelValue.font = .systemFont(ofSize: 14);
      
      return labelValue;
    };
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "invoke:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelInvoke = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "invokePrev:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelInvokePrev = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "invokePrev2:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelInvokePrev2 = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "gesture state:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelGestureState = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "isAnimating:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelIsAnimating = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "isSwiping:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelIsSwiping = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "gestureOffset:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelGestureOffset = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "gestureVelocity:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelGestureVelocity = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "gestureInitialPoint:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelGestureInitialPoint = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "gesturePointPrev:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelGesturePointPrev = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "gesturePoint:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelGesturePoint = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "nextRectOrigin:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelNextRectOrigin = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "nextRectSize:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelNextRectSize = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "nextRectMaxOrigin:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelNextRectMaxOrigin = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "prevRectOrigin:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelPrevRectOrigin = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "prevRectSize:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelPrevRectSize = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "prevRectMaxOrigin:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelPrevRectMaxOrigin = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "modalFrame.origin:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelModalFrameOrigin = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "modalFrame.size:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelModalFrameSize = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "prevModalFrame.origin:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelPrevModalFrameOrigin = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "prevModalFrame.size:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelPrevModalFrameSize = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "modalFrameMaxOrigin:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelModalFrameMaxOrigin = labelValue;
      return stack;
    }());
    
    stackView.addArrangedSubview({
      let stack = makeLabelRowStack();
      
      let labelDetail = makeLabelDetail(text: "modalFrameCenter:");
      stack.addArrangedSubview(labelDetail);
      
      let labelValue = makeLabelValue(text: "N/A");
      stack.addArrangedSubview(labelValue);
      
      self.labelModalFrameCenter = labelValue;
      return stack;
    }());
    
    self.addSubview(stackView);
    stackView.translatesAutoresizingMaskIntoConstraints = false;
    
    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
    ]);
  };
  
  // MARK: - Functions
  // -----------------
  
  private func setInvoke(_ string: String){
    let lastIndex = self.invokeHistory.count - 1;
  
    let prev  = self.invokeHistory[safeIndex: lastIndex];
    let prev2 = self.invokeHistory[safeIndex: lastIndex - 1];
    
    self.invokeHistory.append(string);
    
    self.labelInvoke.text = string;
    self.labelInvokePrev.text = prev ?? "N/A";
    self.labelInvokePrev2.text = prev2 ?? "N/A";
  };
  
  private func sharedUpdate(){
    guard let modalManager = self.modalManager else { return };
    
    self.labelIsAnimating.text = modalManager.isAnimating.description;
    self.labelIsSwiping.text = modalManager.isSwiping.description;
    
    self.labelGestureOffset.text = modalManager.gestureOffset?.debugDescription ?? "N/A";
    self.labelGestureVelocity.text = modalManager.gestureVelocity?.debugDescription ?? "N/A";
    self.labelGestureInitialPoint.text = modalManager.gestureInitialPoint?.debugDescription ?? "N/A";
    self.labelGesturePointPrev.text = modalManager.gesturePointPrev?.debugDescription ?? "N/A";
    self.labelGesturePoint.text = modalManager.gesturePoint?.debugDescription ?? "N/A";
  };
  
  private func updateModalFrame(_ modalFrame: CGRect?){
  
    self.labelModalFrameOrigin.text = modalFrame?.origin.debugDescription ?? "N/A";
    self.labelModalFrameSize.text = modalFrame?.size.debugDescription ?? "N/A";
    
    self.labelPrevModalFrameOrigin.text = self.modalManager?.prevModalFrame.origin.debugDescription ?? "N/A";
    self.labelPrevModalFrameSize.text = self.modalManager?.prevModalFrame.size.debugDescription ?? "N/A";
    
    let modalFrameMaxOrigin: CGPoint? = {
      guard let modalFrame = modalFrame else { return nil };
      
      return CGPoint(
        x: modalFrame.maxX,
        y: modalFrame.maxY
      );
    }();
    
    self.labelModalFrameMaxOrigin.text = modalFrameMaxOrigin?.debugDescription ?? "N/A";
    
    let modalFrameCenter: CGPoint? = {
      guard let modalFrame = modalFrame else { return nil };
      
      return CGPoint(
        x: modalFrame.midX,
        y: modalFrame.midY
      );
    }();
    
    
    self.labelModalFrameCenter.text = modalFrameCenter?.debugDescription ?? "N/A";
  };
  
  // MARK: - Functions - Notify
  // --------------------------
  
  func notifyOnDragPanGesture(_ gesture: UIPanGestureRecognizer){
    self.setInvoke("notifyOnDragPanGesture");
    self.labelGestureState.text = gesture.state.string;
    
    self.labelNextRectOrigin.text = "N/A";
    self.labelNextRectSize.text = "N/A";
    self.labelNextRectMaxOrigin.text = "N/A";
    self.labelPrevRectOrigin.text = "N/A";
    self.labelPrevRectSize.text = "N/A";
    self.labelPrevRectMaxOrigin.text = "N/A";
    
    self.sharedUpdate();
  };
  
  func notifyOnApplyInterpolationToModal(){
    self.setInvoke("applyInterpolationToModal");
    self.sharedUpdate();
    
    if !(self.modalManager?.isAnimating ?? false) {
      self.updateModalFrame(self.modalManager?.modalFrame);
    };
  };
  
  func notifyOnAnimateModal(
    interpolationPoint: AdaptiveModalInterpolationPoint
  ){
    self.setInvoke("animateModal");
    
    self.labelNextRectOrigin.text = interpolationPoint.computedRect.origin.debugDescription;
    self.labelNextRectSize.text = interpolationPoint.computedRect.size.debugDescription;
    
    self.labelNextRectMaxOrigin.text = {
      let maxPoint = CGPoint(
        x: interpolationPoint.computedRect.maxX,
        y: interpolationPoint.computedRect.maxY
      );
      
      return maxPoint.debugDescription;
    }();
    
    if let modalFrame = self.modalManager?.modalFrame {
      self.labelPrevRectOrigin.text = modalFrame.origin.debugDescription;
      self.labelPrevRectSize.text = modalFrame.size.debugDescription;
      
      let maxPoint = CGPoint(
        x: modalFrame.maxX,
        y: modalFrame.maxY
      );
      
      self.labelPrevRectMaxOrigin.text = maxPoint.debugDescription;
    };
    
    self.sharedUpdate();
  };
  
  func notifyOnAnimateModalCompletion(){
    self.setInvoke("animateModalCompletion");
    
    self.labelNextRectOrigin.text = "N/A";
    self.labelNextRectSize.text = "N/A";
    self.labelNextRectMaxOrigin.text = "N/A";
    self.labelPrevRectOrigin.text = "N/A";
    self.labelPrevRectSize.text = "N/A";
    self.labelPrevRectMaxOrigin.text = "N/A";
    
    self.sharedUpdate();
  };
  
  func notifyOnDisplayLinkTick(){
    self.setInvoke("notifyOnDisplayLinkTick");
    self.sharedUpdate();
    
    let dummyModalView = self.modalManager?.dummyModalView;
    let dummyModalViewLayer = dummyModalView?.layer.presentation();
    
    self.updateModalFrame(dummyModalViewLayer?.frame);
  };
  
  func notifyOnModalDidSnap(){
    self.setInvoke("notifyOnModalDidSnap");
    
    self.labelNextRectOrigin.text = "N/A";
    self.labelNextRectSize.text = "N/A";
    self.labelNextRectMaxOrigin.text = "N/A";
    self.labelPrevRectOrigin.text = "N/A";
    self.labelPrevRectSize.text = "N/A";
    self.labelPrevRectMaxOrigin.text = "N/A";
    
    self.sharedUpdate();
  };
  
  func notifyDidCleanup(){
    self.setInvoke("notifyDidCleanup");
    
    self.labelNextRectOrigin.text = "N/A";
    self.labelNextRectSize.text = "N/A";
    self.labelNextRectMaxOrigin.text = "N/A";
    self.labelPrevRectOrigin.text = "N/A";
    self.labelPrevRectSize.text = "N/A";
    self.labelPrevRectMaxOrigin.text = "N/A";
    
    self.sharedUpdate();
  };
};

