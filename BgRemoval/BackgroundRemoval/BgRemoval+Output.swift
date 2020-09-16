//
//  BackgroundRemoval+Output.swift
//  BgRemoval
//
//  Created by Marco@GaspardBruno on 16/09/2020.
//  Copyright © 2020 Marco João. All rights reserved.
//

import CoreML

extension BgRemoval {
    
    class Output : MLFeatureProvider {
        fileprivate let kOutputName: String = "Identity"
        
        /// Source provided by CoreML
        private let provider : MLFeatureProvider


        /// Predicted Mask as multidimensional array of floats
        lazy var Identity: MLMultiArray = {
            [unowned self] in return self.provider.featureValue(for: kOutputName)!.multiArrayValue
        }()!

        var featureNames: Set<String> {
            return self.provider.featureNames
        }
        
        func featureValue(for featureName: String) -> MLFeatureValue? {
            return self.provider.featureValue(for: featureName)
        }

        init(Identity: MLMultiArray) {
            self.provider = try! MLDictionaryFeatureProvider(dictionary: [kOutputName : MLFeatureValue(multiArray: Identity)])
        }

        init(features: MLFeatureProvider) {
            self.provider = features
        }
    }
}
