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
    
    fileprivate let modelName: String = "SOD_Fashion"
    fileprivate let inputSize: Int = 320
    
    fileprivate let model: MLModel
    
    init() {
        do {
            let bundle = Bundle(for: BgRemoval.self)
            let filePath = bundle.url(forResource: modelName, withExtension:"mlmodelc")!
            self.model = try MLModel(contentsOf: filePath)
        } catch {
            print(error)
            fatalError("Couldn't load model")
        }
    }
    
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
        let imageBuffer = input.pixelBuffer(width: inputSize, height: inputSize)
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
