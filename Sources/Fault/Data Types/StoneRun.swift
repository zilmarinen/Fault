//
//  StoneRun.swift
//
//  Created by Zack Brown on 19/11/2023.
//

import Bivouac
import Euclid
import Foundation
import GameplayKit

extension GKNoiseMap {
    
    static func perlin() -> GKNoiseMap {
        
        let source = GKPerlinNoiseSource()
        
        source.persistence = 0.9
        
        let noise = GKNoise(source)
        let size = vector2(10.0, 10.0)
        let origin = vector2(0.0, 0.0)
        let sampleCount = vector2(Int32(100), Int32(100))
        
        return  GKNoiseMap(noise,
                           size: size,
                           origin: origin,
                           sampleCount: sampleCount,
                           seamless: false)
    }
    
    func sample(_ vector: Vector) -> Double { Double(value(at: vector2(Int32(vector.x), Int32(vector.z)))) }
}

extension GeologyType {
    
    enum StoneRun {
        
        public static func mesh(area: Grid.Footprint.Area) throws -> Mesh {
            
            let noise = GKNoiseMap.perlin()
            
            var mesh = Mesh([])
            area.footprint.vertices
            try area.footprint.forEach {
                
                let triangle = Grid.Triangle($0)
                let stencil = triangle.stencil(for: .tile)
                
                var polygons: [Euclid.Polygon] = []
                
                for division in Grid.Triangle.Stencil.triangles {
                    
                    let baseVertices = division.map { stencil.vertex(for: $0) }
                    let sample = abs(noise.sample(baseVertices.average * 10.0))
                    let apexVertices = baseVertices.map { $0 + Vector(0.0, 0.1 + sample, 0.0) }
                    
                    let apex = Face(apexVertices,
                                    color: .red)
                    let base = Face(baseVertices.reversed(),
                                    color: .yellow)
                    
                    try polygons.glue(apex?.polygon)
                    try polygons.glue(base?.polygon)
                    
                    for i in baseVertices.indices {
                        
                        let j = (i + 1) % baseVertices.count
                        
                        let v0 = baseVertices[i]
                        let v1 = baseVertices[j]
                        let v2 = apexVertices[j]
                        let v3 = apexVertices[i]
                        
                        let face = Face([v0,
                                         v1,
                                         v2,
                                         v3],
                                        color: .orange)
                        
                        try polygons.glue(face?.polygon)
                    }
                }
                
                mesh = mesh.union(Mesh(polygons))
            }
            
            return mesh
        }
    }
}
