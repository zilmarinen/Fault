//
//  AppView.swift
//
//  Created by Zack Brown on 19/11/2023.
//

import Bivouac
import SceneKit
import SwiftUI

struct AppView: View {
    
    @ObservedObject private var viewModel = AppViewModel()
    
    var body: some View {
        
        #if os(iOS)
            NavigationStack {
        
                viewer
            }
        #else
            viewer
        #endif
    }
    
    var viewer: some View {
        
        ZStack(alignment: .bottomTrailing) {
            
            sceneView
            
            Text("Polygons: [\(viewModel.profile.polygonCount)] Vertices: [\(viewModel.profile.vertexCount)]")
                .foregroundColor(.black)
                .padding()
        }
    }
    
    var sceneView: some View {
        
        SceneView(scene: viewModel.scene,
                  pointOfView: viewModel.scene.camera.pov,
                  options: [.allowsCameraControl,
                            .autoenablesDefaultLighting])
        .toolbar {
            
            ToolbarItemGroup {
                
                toolbar
            }
        }
    }
    
    @ViewBuilder
    var toolbar: some View {
        
        Picker("Geology Type",
               selection: $viewModel.geologyType) {
            
            ForEach(GeologyType.allCases, id: \.self) { geologyType in
                
                Text(geologyType.id.capitalized)
                    .id(geologyType)
            }
        }
    }
}
