//
//  Promontory.swift
//
//  Created by Zack Brown on 21/11/2023.
//

import Bivouac
import Euclid
import Foundation

extension GeologyType {
    
    enum Promontory {
        
        static let apexInset = 0.05
        static let apexElevation = Vector(0.0, 0.1, 0.0)
        
        static let crownInset = 0.1
        static let crownElevation = Vector(0.0, 0.2, 0.0)
        
        static let chamfer = 0.1
        
        public static func mesh(footprint: [Coordinate]) throws -> Mesh {
            
            let primaryColor = Color("B0A695")
            let secondaryColor = Color("776B5D")
            
            let pool: [[Grid.Triangle.Stencil.Vertex]] = [[.v5, .v6],
                                                          [.v9, .v12],
                                                          [.v10, .v14]]
            
            let vertices = footprint.map {
                
                let triangle = Grid.Triangle($0)
                let stencil = triangle.stencil(for: .tile)
                let candidates = pool[triangle.position.sumAbs % pool.count]
                let vertex = candidates[abs(triangle.position.index) % candidates.count]
                
                return Vertex(stencil.vertex(for: vertex),
                              -.up,
                              nil,
                              secondaryColor)
            }
            
            guard let stencil = Polygon(vertices.reversed()),
                  let apex = stencil.inset(by: crownInset + apexInset),
                  let crown = stencil.inset(by: crownInset) else { throw MeshError.invalidStencil }
            
            var polygons = [stencil]
            
            for i in crown.vertices.indices {

                let j = (i + 1) % crown.vertices.count
                
                let cv0 = crown.vertices[i].position + crownElevation
                let cv1 = crown.vertices[j].position + crownElevation
                let bv0 = stencil.vertices[i].position
                let bv1 = stencil.vertices[j].position

                let face = Face([cv0,
                                 cv1,
                                 bv1,
                                 bv0],
                                color: secondaryColor)
                
                try polygons.glue(face?.polygon)
            }
            
            var perimeter: [Vector] = []
            
            for i in apex.vertices.indices {
                
                let j = (i + 1) % apex.vertices.count
                let k = ((apex.vertices.count - 1) + i) % apex.vertices.count
                
                let av0 = apex.vertices[k].position + crownElevation + apexElevation
                let av1 = apex.vertices[i].position + crownElevation + apexElevation
                let av2 = apex.vertices[j].position + crownElevation + apexElevation
                let cv0 = crown.vertices[i].position + crownElevation
                let cv1 = crown.vertices[j].position + crownElevation
                
                let c0 = av1.lerp(av0, chamfer)
                let c1 = av1.lerp(av2, chamfer)
                let c2 = av2.lerp(av1, chamfer)
                
                perimeter.append(contentsOf: [c0, c1])
                
                let corner = Face([c0,
                                   c1,
                                   cv0],
                                  color: primaryColor)
                
                let face = Face([c1,
                                c2,
                                cv1,
                                cv0],
                                color: primaryColor)
                
                try polygons.glue(corner?.polygon)
                try polygons.glue(face?.polygon)
            }
            
            let face = Face(perimeter.reversed(),
                            color: primaryColor)
            
            try polygons.glue(face?.polygon)
            
            return Mesh(polygons)
        }
    }
}
