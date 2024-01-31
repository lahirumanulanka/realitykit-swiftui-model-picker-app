//
//  ContentView.swift
//  ModelPickerApp
//
//  Created by ADL on 2024-01-31.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @State private var isPlacementEnable = false
    @State private var selectedModels: String?
    @State private var modelConfirmedForPlacements: String?
    
        private var models: [String] = {
            let filemanager = FileManager.default
            guard let path = Bundle.main.resourcePath, let files = try? filemanager.contentsOfDirectory(atPath: path) else {  return [] }
            var availableModels: [String] = []
            for filename in files where filename.hasSuffix("usdz") {
                let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
                availableModels.append(modelName)
            }
            return availableModels
        }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedForPlacements: $modelConfirmedForPlacements)
            if self.isPlacementEnable {
                PlacemntButtonView(modelConfirmedForPlacements: $modelConfirmedForPlacements, selectedModels: $selectedModels, isPlacementEnable: $isPlacementEnable)
            } else {
                ModelPickerView(isPlacementEnable: $isPlacementEnable, selectedModels: $selectedModels, models: models)
            }
        }
    }
}

struct ModelPickerView: View {
    @Binding var isPlacementEnable: Bool
    @Binding var selectedModels: String?
    var models: [String]
    var body: some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30, content: {
                ForEach(self.models,  id: \.self) { model in
                    Button {
                        self.selectedModels = model
                        self.isPlacementEnable = true
                    } label: {
                        Image(uiImage: UIImage(named: model)!)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .cornerRadius(15)
                    }
                }
            })
        }
        .padding(20)
        .background(Color.black.opacity(0.2))
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacements: String?
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        arView.session.run(config)
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
            if let modelName = self.modelConfirmedForPlacements {
                print("DEBUG: adding model to cene \(modelName)")
                let fileName = modelName + ".usdz"
                let ModelEntity = try! ModelEntity.loadModel(named: fileName)
                let ancherEntity = AnchorEntity(plane: .horizontal)
                ancherEntity.addChild(ModelEntity)
                uiView.scene.addAnchor(ancherEntity)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.modelConfirmedForPlacements = nil
                }
            }
    }
    
}

struct PlacemntButtonView: View {
    @Binding var modelConfirmedForPlacements: String?
    @Binding var selectedModels: String?
    @Binding var isPlacementEnable: Bool
    var body: some View{
        HStack{
            Button {
                resetPlacementParameeters()
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
            Button {
                modelConfirmedForPlacements = selectedModels
                resetPlacementParameeters()
            } label: {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }
    
    func resetPlacementParameeters() {
        self.isPlacementEnable = false
    }
}

#Preview {
    ContentView()
}
