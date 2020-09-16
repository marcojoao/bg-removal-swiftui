//
//  BackgroundRemoval+Input.swift
//  BgRemoval
//
//  Created by Marco@GaspardBruno on 16/09/2020.
//  Copyright © 2020 Marco João. All rights reserved.
//

import CoreML

extension BgRemoval {
    
    class Input : MLFeatureProvider {
        
        fileprivate let kInputName: String = "input_1"

        var input: CVPixelBuffer

        var featureNames: Set<String> {
            get {
                return [kInputName]
            }
        }
        
        func featureValue(for featureName: String) -> MLFeatureValue? {
            if (featureName == kInputName) {
                return MLFeatureValue(pixelBuffer: input)
            }
            return nil
        }
        
        init(input: CVPixelBuffer) {
            self.input = input
        }

        convenience init(inputWith input: CGImage) throws {
            let __input = try MLFeatureValue(cgImage: input, pixelsWide: 320, pixelsHigh: 320, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
            self.init(input: __input)
        }

        convenience init(inputAt input: URL) throws {
            let __input = try MLFeatureValue(imageAt: input, pixelsWide: 320, pixelsHigh: 320, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
            self.init(input: __input)
        }

        func setinput(with input: CGImage) throws  {
            self.input = try MLFeatureValue(cgImage: input, pixelsWide: 320, pixelsHigh: 320, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
        }

        func setinput(with input: URL) throws  {
            self.input = try MLFeatureValue(imageAt: input, pixelsWide: 320, pixelsHigh: 320, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
        }
    }

}
