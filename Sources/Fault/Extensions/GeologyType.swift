//
//  GeologyType.swift
//
//  Created by Zack Brown on 19/11/2023.
//

import Bivouac
import Euclid

extension GeologyType {
    
    public func mesh() throws -> Mesh {
        
        let footprint = Grid.Triangle.Septomino.taygeta.footprint
        
        var mesh = Mesh([])
        
        try footprint.forEach {
            
            let triangle = Grid.Triangle($0)
            let stencil = triangle.stencil(for: .tile)
            
            var polygons: [Polygon] = []
            
            for division in Grid.Triangle.Stencil.triangles {
                
                let vertices = division.map { stencil.vertex(for: $0) + Vector(0.0, 0.01, 0.0) }
                
                let face = Face(vertices,
                                color: .orange)
                
                try polygons.glue(face?.polygon)
            }
            
            mesh = mesh.merge(Mesh(polygons))
        }
        
        return mesh
    }
}
