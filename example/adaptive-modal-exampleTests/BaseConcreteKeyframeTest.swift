//
//  adaptive_modal_exampleTests.swift
//  adaptive-modal-exampleTests
//
//  Created by Dominic Go on 4/10/25.
//

import Testing
import Foundation

@testable import DGSwiftUtilities
@testable import AdaptiveModal

struct BaseConcreteKeyframeTest {
  
  // MARK: - Embedded Types
  // ----------------------
  
  struct TestPartialKeyframe: BasePartialKeyframe {
    static var empty: Self = .init();
    
    var someFloat: CGFloat?;
    var someDouble: Double?;
  };

  struct TestConcreteKeyframe: BaseConcreteKeyframe {
    
    typealias PartialKeyframe = TestPartialKeyframe;

    static var `default`: Self = .init(
      someFloat: 3.14,
      someDouble: 123.456
    );
    
    static var partialToConcreteKeyframePropertyMap: KeyframePropertyMap = [
      \.someFloat: \.someFloat,
      \.someDouble: \.someDouble,
    ];
    
    var someFloat: CGFloat;
    var someDouble: Double;
    
    init(someFloat: CGFloat, someDouble: Double) {
      self.someFloat = someFloat
      self.someDouble = someDouble
    };
    
  };
  
  // MARK: - Test Cases
  // ------------------

  @Test func verifyInterpolatablePropertiesMap() async throws {
    let keyframePropertiesCount = TestConcreteKeyframe.partialToConcreteKeyframePropertyMap.count;
    let keyframeInteroplatablePropertiesCount = TestConcreteKeyframe.interpolatablePropertiesMap.count;
    
    #expect(
      keyframePropertiesCount == keyframeInteroplatablePropertiesCount,
      """
      ConcreteKeyframe has \(keyframePropertiesCount) properties,
      but the number of interpolatable properties is \(keyframeInteroplatablePropertiesCount)
      (the count must be the same)
      """
    );
  };
  
  @Test func verifyConcreteToPartialKeyframeConversion() async throws {
    let concreteKeyframe: TestConcreteKeyframe = .default;
    let partialKeyframe: TestPartialKeyframe = concreteKeyframe.asPartialKeyframe;
    let concreteKeyframe2: TestConcreteKeyframe = .init(sourcePartialKeyframe: partialKeyframe);
    
    print(
      #function,
      "\n - origina:", concreteKeyframe,
      "\n - pass #1:", partialKeyframe,
      "\n - pass #2:", concreteKeyframe2,
      "\n"
    );
    
    for (_, keyPathPair) in TestConcreteKeyframe.partialToConcreteKeyframePropertyMap.enumerated() {
      let partialKeyframePath = keyPathPair.key;
      let concreteKeyframePath = keyPathPair.value;
      
      let concreteKeyframeValue = concreteKeyframe[keyPath: concreteKeyframePath];
      let concreteKeyframeValue2 = concreteKeyframe2[keyPath: concreteKeyframePath];
      
      let partialKeyframeValue = try #require(
        partialKeyframe[keyPath: keyPathPair.key],
        """
        keyPath: `\(partialKeyframePath.valueTypeAsString)` is empty
        but is expected to have a value of \(concreteKeyframeValue)
        """
      );
      
      let concreteKeyframeValueRefined = try #require(
        concreteKeyframeValue as? (any Comparable),
        """
        ConcreteKeyframe value of: \(concreteKeyframeValue)
        for key path: \(concreteKeyframePath.valueTypeAsString)
        could not be converted to comparable
        """
      );
      
      let concreteKeyframeValue2Refined = try #require(
        concreteKeyframeValue2 as? (any Equatable),
        """
        ConcreteKeyframe (2nd pass) value of: \(concreteKeyframeValue2)
        for key path: \(concreteKeyframePath.valueTypeAsString)
        could not be converted to comparable
        """
      );
      
      let partialKeyframeValueRefined = try #require(
        partialKeyframeValue as? (any Equatable),
        """
        ConcreteKeyframe value of: \(partialKeyframeValue)
        for key path: \(partialKeyframePath.valueTypeAsString)
        could not be converted to comparable
        """
      );
      
      let isEqualForPass1 = concreteKeyframeValueRefined.isEqual(to: partialKeyframeValueRefined);
      
      #expect(
        isEqualForPass1,
        """
        ConcreteKeyframe value of: \(concreteKeyframeValueRefined)
        for ConcreteKeyframe key path: \(concreteKeyframePath.valueTypeAsString),
        did not match PartialKeyframe value of: \(partialKeyframeValueRefined)
        for PartialKeyframe key path: \(partialKeyframePath.valueTypeAsString)
        """
      );
      
      let isEqualForPass2 = concreteKeyframeValueRefined.isEqual(to: concreteKeyframeValue2Refined);
      
      #expect(
        isEqualForPass2,
        """
        Conversion of: `ConcreteKeyframe (\(concreteKeyframeValueRefined)) 
         -> PartialKeyframe (\(partialKeyframeValueRefined)) 
         -> ConcreteKeyframe (\(concreteKeyframeValue2Refined))`
        for PartialKeyframe key path: \(partialKeyframePath.valueTypeAsString)
        has failed to divergence of values.
        """
      );
    }
  };
  
  @Test func verifyLerping() async throws {
    let keyframeStart: TestConcreteKeyframe = .init(someFloat: 0, someDouble: 0);
    let keyframeEnd: TestConcreteKeyframe = .init(someFloat: 100, someDouble: 100);
    
    let resultLerpToNegativeHalf = TestConcreteKeyframe.lerp(valueStart: keyframeStart, valueEnd: keyframeEnd, percent: -0.5);
    #expect(
         resultLerpToNegativeHalf.someDouble == -50.0
      && resultLerpToNegativeHalf.someFloat == -50.0
    );
    
    let resultLerpToZero = TestConcreteKeyframe.lerp(valueStart: keyframeStart, valueEnd: keyframeEnd, percent: 0);
    #expect(
         resultLerpToZero.someDouble == 0
      && resultLerpToZero.someFloat == 0
    );
    
    let resultLerpToQuarter = TestConcreteKeyframe.lerp(valueStart: keyframeStart, valueEnd: keyframeEnd, percent: 0.25);
    #expect(
         resultLerpToQuarter.someDouble == 25.0
      && resultLerpToQuarter.someFloat == 25.0
    );
    
    let resultLerpToHalf = TestConcreteKeyframe.lerp(valueStart: keyframeStart, valueEnd: keyframeEnd, percent: 0.5);
    #expect(
         resultLerpToHalf.someDouble == 50.0
      && resultLerpToHalf.someFloat == 50.0
    );
    
    let resultLerpToFull = TestConcreteKeyframe.lerp(valueStart: keyframeStart, valueEnd: keyframeEnd, percent: 1.0);
    #expect(
         resultLerpToFull.someDouble == 100.0
      && resultLerpToFull.someFloat == 100.0
    );
    
    let resultLerpToDouble = TestConcreteKeyframe.lerp(valueStart: keyframeStart, valueEnd: keyframeEnd, percent: 2.0);
    #expect(
         resultLerpToDouble.someDouble == 200.0
      && resultLerpToDouble.someFloat == 200.0
    );
    
    print(
      #function,
      "\n - keyframeStart:", keyframeStart,
      "\n - keyframeEnd:", keyframeEnd,
      "\n - resultLerpToNegativeHalf:", resultLerpToNegativeHalf,
      "\n - resultLerpToZero:", resultLerpToZero,
      "\n - resultLerpToQuarter:", resultLerpToQuarter,
      "\n - resultLerpToHalf:", resultLerpToHalf,
      "\n - resultLerpToFull:", resultLerpToFull,
      "\n - resultLerpToDouble:", resultLerpToDouble,
      "\n"
    );
  };
  
  @Test func verifyRangedLerping() async throws {
    let keyframeStart: TestConcreteKeyframe = .init(someFloat: 0, someDouble: 0);
    let keyframeHalf: TestConcreteKeyframe = .init(someFloat: 1, someDouble: 1);
    let keyframeEnd: TestConcreteKeyframe = .init(someFloat: 100, someDouble: 100);
    
    let rangeInput: [CGFloat] = [0, 0.5, 1];
    
    let rangeOutput = [
      keyframeStart,
      keyframeHalf,
      keyframeEnd,
    ];
    
    var rangeInterpolator = try TestConcreteKeyframe.RangeInterpolator(
      rangeInput: rangeInput,
      rangeOutput: rangeOutput,
      easingProvider: nil
    );
    
    let resultLerpToZero = rangeInterpolator.interpolate(inputValue: 0);
    #expect(resultLerpToZero.someDouble == 0.0);
    #expect(resultLerpToZero.someFloat == 0.0);
    
    let resultLerpToQuarter = rangeInterpolator.interpolate(inputValue: 0.25);
    #expect(resultLerpToQuarter.someDouble == 0.5);
    #expect(resultLerpToQuarter.someFloat == 0.5);
    
    let resultLerpToHalf = rangeInterpolator.interpolate(inputValue: 0.5);
    #expect(resultLerpToHalf.someDouble == 1.0);
    #expect(resultLerpToHalf.someFloat == 1.0);
    
    /// input: 0.75
    /// Input Range: 0.5 -> 1.0, Delta: 0.5
    /// Delta input: 0.25
    /// output range: 1 -> 100
    ///
    let resultLerpToThreeQuarters = rangeInterpolator.interpolate(inputValue: 0.75);
    #expect(Int(resultLerpToThreeQuarters.someDouble) == 50);
    #expect(Int(resultLerpToThreeQuarters.someFloat) == 50);
    
    let resultLerpToFull = rangeInterpolator.interpolate(inputValue: 1);
    #expect(resultLerpToFull.someDouble == 100);
    #expect(resultLerpToFull.someDouble == 100);
    
    let resultLerpToDouble = rangeInterpolator.interpolate(inputValue: 2);
    #expect(resultLerpToDouble.someDouble == 200);
    #expect(resultLerpToDouble.someDouble == 200);

    print(
      #function,
      "\n - keyframeStart:", keyframeStart,
      "\n - keyframeHalf:", keyframeHalf,
      "\n - keyframeEnd:", keyframeEnd,
      "\n - resultLerpToZero:", resultLerpToZero,
      "\n - resultLerpToQuarter:", resultLerpToQuarter,
      "\n - resultLerpToHalf:", resultLerpToHalf,
      "\n - resultLerpToThreeQuarters:", resultLerpToThreeQuarters,
      "\n - resultLerpToFull:", resultLerpToFull,
      "\n - resultLerpToDouble:", resultLerpToDouble,
      "\n"
    );
    
  };
}
