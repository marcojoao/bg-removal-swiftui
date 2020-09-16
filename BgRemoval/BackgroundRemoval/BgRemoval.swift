//
//  BackgroundRemoval.swift
//  BgRemoval
//
//  Created by Marco@GaspardBruno on 13/08/2020.
//  Copyright © 2020 Marco João. All rights reserved.
//

import SwiftUI
import CoreML
import Accelerate
import CoreGraphics

class BgRemoval {
    
    fileprivate let kImageSize: Int = 320
    
    class var localModelUrl : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "SOD_Fashion", withExtension:"mlmodelc")!
    }
    
    let model: MLModel = {
        do {
            return try MLModel(contentsOf: BgRemoval.localModelUrl)
        } catch {
            print(error)
            fatalError("Couldn't load model")
        }
    }()
    
    func prediction(input: Input) throws -> Output {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    func prediction(input: Input, options: MLPredictionOptions) throws -> Output {
        let outFeatures = try model.prediction(from: input, options:options)
        return Output(features: outFeatures)
    }

    func prediction(input: CVPixelBuffer) throws -> Output {
        let input_ = Input(input: input)
        return try self.prediction(input: input_)
    }

    
    func prediction(input: UIImage) -> UIImage? {
        let imageBuffer = input.pixelBuffer(width: kImageSize, height: kImageSize)
        if let safeImageBuffer = imageBuffer {
            do {
                let result = try self.prediction(input: safeImageBuffer)
                if let resultImage = result.Identity.cgImage(min: 0, max: 1) {
                    let original = input.cgImage!
                    if let result = original.masking(resultImage) {
                        return UIImage(cgImage: result)
                    }
                }
            } catch  {
                print("Failed to predict model")
            }
        }
        return nil
    }
}
