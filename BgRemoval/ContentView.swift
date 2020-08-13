import SwiftUI
import UIKit

struct ContentView: View {
    
    @State private var isShowPhotoLibrary = false
    @State private var image: UIImage?
    
    fileprivate let bgRemoval = BackgroundRemoval()
    
    var body: some View {
        VStack {
            if self.image != nil{
                Spacer()
                Image(uiImage: self.image!)
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .padding()
                    
                Spacer()
                HStack(spacing: 0) {
                    Button(action: {
                        self.image = nil
                    }) {
                        Text("Back")
                            .font(.headline)
                            .frame(minWidth: 0, maxWidth: 80, minHeight: 0, maxHeight: 50)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .padding(.vertical)
                            .padding(.horizontal, 10)
                    }
                    Button(action: {
                        if let safeimage = self.image {
                            self.image = self.bgRemoval.predictUIImage(safeimage)
                        }
                    }) {
                        HStack {
                            Image(systemName: "star")
                                .font(.system(size: 20))
                            
                            Text("Remove Background")
                                .font(.headline)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding(.vertical)
                        .padding(.horizontal, 10)
                    }
                }
                
            } else {
                Button(action: {
                    self.isShowPhotoLibrary = true
                }) {
                    HStack {
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                        
                        Text("Photo library")
                            .font(.headline)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.all)
                }
            }
            
        }
        .sheet(isPresented: $isShowPhotoLibrary) {
            ImagePicker(selectedImage: self.$image)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
