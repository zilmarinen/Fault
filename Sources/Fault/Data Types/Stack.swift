//
//  Stack.swift
//
//  Created by Zack Brown on 19/11/2023.
//

import Bivouac
import Euclid
import Foundation

extension GeologyType {
    
    enum Stack {
        
        public static func mesh(area: Grid.Footprint.Area) throws -> Mesh {
            
            let triangle = Grid.Triangle.zero
            let stencil = triangle.stencil(for: .tile)
            let corners = [stencil.vertex(for: .v0),
                           stencil.vertex(for: .v1),
                           stencil.vertex(for: .v2)]
            
            let stacks = 1
            let steps = 5
            let elevation = 1.0 / Double(stacks)
            
            var polygons: [Polygon] = []
            
            for i in 0..<stacks {
                
                let height = Vector(0.0,
                                    elevation * Double(i + 1),
                                    0.0)
                
                let candidates = Grid.Triangle.Stencil.Segment.allCases.compactMap { $0.vertices.randomElement() }
                let vertices = candidates.map { stencil.vertex(for: $0) }
                
                for j in vertices.indices {
                    
                    let k = ((vertices.count - 1) + j) % vertices.count
                    
                    let curve = Bezier.Quadratic(start: vertices[k],
                                                 end: vertices[j],
                                                 c: corners[k],
                                                 steps: steps)
                    
                    let apex = Face((curve.points + [stencil.center]).map { $0 + height }.reversed(),
                                    color: .red)
                    let base = Face((curve.points + [stencil.center]),
                                    color: .yellow)
                    
                    try? polygons.glue(apex?.polygon)
                    try? polygons.glue(base?.polygon)
                    
                    for u in 0..<(curve.points.count - 1) {
                        
                        let v = (u + 1) % curve.points.count
                        
                        let v0 = curve.points[u]
                        let v1 = curve.points   [v]
                        let v2 = v1 + height
                        let v3 = v0 + height
                        
                        let face = Face([v0,
                                         v1,
                                         v2,
                                         v3].reversed(),
                                        color: .yellow)
                        
                        try? polygons.glue(face?.polygon)
                    }
                }
            }
            
            return Mesh(polygons)
        }
    }
}
