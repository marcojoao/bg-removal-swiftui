import SwiftUI
import UIKit

struct ContentView: View {
    
    @State private var openSheet = false
    @State private var isShowCamera = false
    @State private var image: UIImage?
    @State var onTap = false
    @State var useBackCamera: Bool = true
    
    fileprivate let bgRemoval = BackgroundRemoval()
    
    fileprivate func customCameraView() -> some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            VStack {
                CameraView(takePicture: self.$onTap,
                           useBackCamera: self.$useBackCamera)
                { (result) in
                    self.image = result
                    self.openSheet = false
                }
                .onTapGesture(count: 2) {
                    self.useBackCamera.toggle()
                }

                Button(action: {
                    if self.onTap == false {
                        self.onTap = true
                    }
                }) {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 65, height: 65)
                }
                
                .padding(.all, 24)
            }
        }
    }
    

    
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
                        Text("Remove Background")
                        .font(.headline)
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
                    self.isShowCamera = true
                    self.openSheet = true
                }) {
                    Text("Take photo")
                    .font(.headline)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.all)
                }
                
                
                
                Button(action: {
                    self.isShowCamera = false
                    self.openSheet = true
                }) {
                    Text("Choose from library")
                    .font(.headline)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.all)
                }
            }
            
        }
        .sheet(isPresented: self.$openSheet) {
            if self.isShowCamera == true {
                self.customCameraView()
            } else {
                ImagePicker(selectedImage: self.$image)
            }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
