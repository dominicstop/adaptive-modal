//
//  Transform3D.swift
//  
//
//  Created by Dominic Go on 8/7/23.
//

import QuartzCore


public struct Transform3D: Equatable {

  public static let `default`: Self = .init(
    translateX: 0,
    translateY: 0,
    translateZ: 0,
    scaleX: 1,
    scaleY: 1,
    rotateX: .zero,
    rotateY: .zero,
    rotateZ: .zero
  );

  public var translateX: CGFloat?;
  public var translateY: CGFloat?;
  public var translateZ: CGFloat?;
  
  public var scaleX: CGFloat?;
  public var scaleY: CGFloat?;
  
  public var rotateX: Angle<CGFloat>?;
  public var rotateY: Angle<CGFloat>?;
  public var rotateZ: Angle<CGFloat>?;
  
  public var transform: CATransform3D {
    var transform = CATransform3DIdentity;
    
    transform = CATransform3DTranslate(
      transform,
      self.translateX ?? 0,
      self.translateY ?? 0,
      self.translateZ ?? 0
    );
    
    transform = CATransform3DScale(
      transform,
      self.scaleX ?? 1,
      self.scaleY ?? 1,
      1
    );
    
    transform = CATransform3DRotate(
      transform,
      self.rotateX?.radians ?? 0,
      1,
      0,
      0
    );
    
    transform = CATransform3DRotate(
      transform,
      self.rotateY?.radians ?? 0,
      0,
      1,
      0
    );
    
    transform = CATransform3DRotate(
      transform,
      self.rotateZ?.radians ?? 0,
      0,
      0,
      1
    );
    
    return transform;
  };
  
  var isAllValueSet: Bool {
      translateX  != nil
    || translateY != nil
    || translateZ != nil
    || scaleX     != nil
    || scaleY     != nil
    || rotateX    != nil
    || rotateY    != nil
    || rotateZ    != nil
  };
  
  public init(
    translateX: CGFloat? = nil,
    translateY: CGFloat? = nil,
    translateZ: CGFloat? = nil,
    scaleX: CGFloat? = nil,
    scaleY: CGFloat? = nil,
    rotateX: Angle<CGFloat>? = nil,
    rotateY: Angle<CGFloat>? = nil,
    rotateZ: Angle<CGFloat>? = nil
  ) {
    
    self.translateX = translateX;
    self.translateY = translateY;
    self.translateZ = translateZ;
    
    self.scaleX = scaleX;
    self.scaleY = scaleY;
    
    self.rotateX = rotateX;
    self.rotateY = rotateY;
    self.rotateZ = rotateZ;
  };
  
  public init(
    translateX: CGFloat,
    translateY: CGFloat,
    translateZ: CGFloat,
    scaleX: CGFloat,
    scaleY: CGFloat,
    rotateX: Angle<CGFloat>,
    rotateY: Angle<CGFloat>,
    rotateZ: Angle<CGFloat>
  ) {
    
    self.translateX = translateX;
    self.translateY = translateY;
    self.translateZ = translateZ;
    
    self.scaleX = scaleX;
    self.scaleY = scaleY;
    
    self.rotateX = rotateX;
    self.rotateY = rotateY;
    self.rotateZ = rotateZ;
  };
  
  mutating func setNonNilValues(with value: Self) {
    if self.translateX == nil {
      self.translateX = value.translateX;
    };
    
    if self.translateY == nil {
      self.translateY = value.translateY;
    };
    
    if self.translateZ == nil {
      self.translateZ = value.translateZ;
    };
    
    if self.scaleX == nil {
      self.scaleX = value.scaleX;
    };
    
    if self.scaleY == nil {
      self.scaleY = value.scaleY;
    };
    
    if self.rotateX == nil {
      self.rotateX = value.rotateX;
    };
    
    if self.rotateY == nil {
      self.rotateY = value.rotateY;
    };
    
    if self.rotateZ == nil {
      self.rotateZ = value.rotateZ;
    };
  };
};
