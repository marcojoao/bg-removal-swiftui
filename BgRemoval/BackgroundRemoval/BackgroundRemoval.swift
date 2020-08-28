//
//  BackgroundRemoval.swift
//  BgRemoval
//
//  Created by Marco@GaspardBruno on 13/08/2020.
//  Copyright © 2020 Marco João. All rights reserved.
//

import SwiftUI

struct BackgroundRemoval {

    fileprivate var model: SOD_Fashion
    fileprivate let kImageSize: Int = 320
    
    init(){
        model = SOD_Fashion()
    }
    
    func predictUIImage(_ image: UIImage) -> UIImage? {
        let imageBuffer = image.pixelBuffer(width: kImageSize, height: kImageSize)
        
        if let safeImageBuffer = imageBuffer {
            do {
                let result = try model.prediction(input_1: safeImageBuffer)
                if let resultImage = result.Identity.cgImage(min: 0, max: 1) {
                    let original = image.cgImage!
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
