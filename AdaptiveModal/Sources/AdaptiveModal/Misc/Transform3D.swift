//
//  Transform3D.swift
//  
//
//  Created by Dominic Go on 8/7/23.
//

import QuartzCore



/// [m11, m12, m13, m14]
/// [m21, m22, m23, m24]
/// [m31, m32, m33, m34]
/// [m41, m42, m43, m44]
///
/// m11 - scale x
/// m12 - shear y
/// m13 - ?
/// m14 - a,c
///
/// m21 - shear x
/// m22 - scale y
/// m23 - ?
/// m24 - a,b
///
/// m31 - ?
/// m32 - ?
/// m33 - ?
/// m34 - perspective
///
/// m41 - translate x
/// m42 - translate y
/// m43 - ?
/// m44 - ?


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
  
  // MARK: - Properties
  // ------------------
  
  private var _translateX: CGFloat?;
  private var _translateY: CGFloat?;
  private var _translateZ: CGFloat?;
  
  private var _scaleX: CGFloat?;
  private var _scaleY: CGFloat?;
  
  private var _rotateX: Angle<CGFloat>?;
  private var _rotateY: Angle<CGFloat>?;
  private var _rotateZ: Angle<CGFloat>?;
  
  // MARK: - Computed Properties - Setters/Getters
  // ---------------------------------------------

  public var translateX: CGFloat {
    get {
      self._translateX
        ?? Self.default.translateX;
    }
    set {
      self._translateX = newValue;
    }
  };
  
  public var translateY: CGFloat {
    get {
      self._translateY
        ?? Self.default.translateY;
    }
    set {
      self._translateY = newValue;
    }
  };
  
  public var translateZ: CGFloat {
    get {
      self._translateZ
        ?? Self.default.translateZ;
    }
    set {
      self._translateZ = newValue;
    }
  };
  
  public var scaleX: CGFloat {
    get {
      self._scaleX
        ?? Self.default.scaleX;
    }
    set {
      self._scaleX = newValue;
    }
  };
  
  public var scaleY: CGFloat {
    get {
      self._scaleY
        ?? Self.default.scaleY;
    }
    set {
      self._scaleY = newValue;
    }
  };
  
  public var rotateX: Angle<CGFloat> {
    get {
      self._rotateX ??
        Self.default.rotateX;
    }
    set {
      self._rotateX = newValue;
    }
  };
  
  public var rotateY: Angle<CGFloat> {
    get {
      self._rotateY ??
        Self.default.rotateY;
    }
    set {
      self._rotateY = newValue;
    }
  };
  
  public var rotateZ: Angle<CGFloat> {
    get {
      self._rotateZ ??
        Self.default.rotateZ;
    }
    set {
      self._rotateZ = newValue;
    }
  };
  
  // MARK: - Computed Properties
  // ---------------------------
  
  public var transform: CATransform3D {
    var transform = CATransform3DIdentity;
    
    //transform.m34 =  1 / 500;
    //transform.m12 = 0;
    //transform.m21 = 0.1;
    
    transform = CATransform3DTranslate(
      transform,
      self.translateX,
      self.translateY,
      self.translateZ
    );
    
    transform = CATransform3DScale(
      transform,
      self.scaleX,
      self.scaleY,
      1
    );
    
    transform = CATransform3DRotate(
      transform,
      self.rotateX.radians,
      1,
      0,
      0
    );
    
    transform = CATransform3DRotate(
      transform,
      self.rotateY.radians,
      0,
      1,
      0
    );
    
    transform = CATransform3DRotate(
      transform,
      self.rotateZ.radians,
      0,
      0,
      1
    );
    
    return transform;
  };
  
  var isAllValueSet: Bool {
       self._translateX != nil
    || self._translateY != nil
    || self._translateZ != nil
    || self._scaleX     != nil
    || self._scaleY     != nil
    || self._rotateX    != nil
    || self._rotateY    != nil
    || self._rotateZ    != nil
  };
  
  // MARK: - Init
  // ------------
  
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
    
    self._translateX = translateX;
    self._translateY = translateY;
    self._translateZ = translateZ;
    
    self._scaleX = scaleX;
    self._scaleY = scaleY;
    
    self._rotateX = rotateX;
    self._rotateY = rotateY;
    self._rotateZ = rotateZ;
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
    
    self._translateX = translateX;
    self._translateY = translateY;
    self._translateZ = translateZ;
    
    self._scaleX = scaleX;
    self._scaleY = scaleY;
    
    self._rotateX = rotateX;
    self._rotateY = rotateY;
    self._rotateZ = rotateZ;
  };
  
  // MARK: - Functions
  // -----------------
  
  mutating func setNonNilValues(with value: Self) {
    if self._translateX == nil {
      self._translateX = value.translateX;
    };
    
    if self._translateY == nil {
      self._translateY = value.translateY;
    };
    
    if self._translateZ == nil {
      self._translateZ = value.translateZ;
    };
    
    if self._scaleX == nil {
      self._scaleX = value.scaleX;
    };
    
    if self._scaleY == nil {
      self._scaleY = value.scaleY;
    };
    
    if self._rotateX == nil {
      self._rotateX = value.rotateX;
    };
    
    if self._rotateY == nil {
      self._rotateY = value.rotateY;
    };
    
    if self._rotateZ == nil {
      self._rotateZ = value.rotateZ;
    };
  };
};
