import SwiftUI

extension Image {
    
    init(_ symbolImage: SymbolImage) {
        self.init(symbolImage.rawValue)
    }
}
