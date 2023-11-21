//
//  AppViewModel.swift
//
//  Created by Zack Brown on 19/11/2023.
//

import Bivouac
import Euclid
import Fault
import Foundation
import SceneKit

class AppViewModel: ObservableObject {
    
    @Published var geologyType: GeologyType = .promontory {
        
        didSet {
            
            guard oldValue != geologyType else { return }
            
            updateScene()
        }
    }
    
    @Published var area: Grid.Footprint.Area = .truchet {
        
        didSet {
            
            guard oldValue != area else { return }
            
            updateScene()
        }
    }
    
    @Published var profile: Mesh.Profile = .init(polygonCount: 0,
                                                 vertexCount: 0)
    
    internal let scene = Scene()
    
    private let operationQueue = OperationQueue()
    
    private var cache: GeologyCache?
    
    init() {
        
        generateCache()
    }
}

extension AppViewModel {
    
    private func generateCache() {
        
        updateScene()
    }
    
    private func createNode(with mesh: Mesh?) -> SCNNode? {
        
        guard let mesh else { return nil }
        
        let node = SCNNode()
        let wireframe = SCNNode()
        let material = SCNMaterial()
        
        node.geometry = SCNGeometry(mesh)
        node.geometry?.firstMaterial = material
        
        wireframe.geometry = SCNGeometry(wireframe: mesh)
        
        node.addChildNode(wireframe)
        
        return node
    }
    
    private func updateScene() {
        
        self.scene.clear()
        
        self.updateSurface()
        
        guard let mesh = try? geologyType.mesh(area: area),
              let node = self.createNode(with: mesh) else { return }
        
        self.scene.rootNode.addChildNode(node)
        
        self.updateProfile(for: mesh)
    }
    
    private func updateSurface() {
        
        var polygons: [Euclid.Polygon] = []
                
        for coordinate in area.footprint {
            
            let triangle = Grid.Triangle(coordinate)
            
            let vertices = triangle.corners(for: .tile).map { Vertex($0, .up) }
            
            guard let polygon = Polygon(vertices) else { continue }
            
            polygons.append(polygon)
        }
        
        let mesh = Mesh(polygons)
        
        guard let node = createNode(with: mesh) else { return }
        
        scene.rootNode.addChildNode(node)
    }
    
    private func updateProfile(for mesh: Mesh) {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self else { return }
            
            self.profile = mesh.profile
        }
    }
}

