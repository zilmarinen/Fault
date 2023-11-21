//
//  GeologyType.swift
//
//  Created by Zack Brown on 19/11/2023.
//

import Bivouac
import Euclid

extension GeologyType {
    
    public func mesh(area: Grid.Footprint.Area) throws -> Mesh {
        
        switch self {
            
        case .promontory: return try Promontory.mesh(footprint: area.perimeter)
        case .stack: return try Stack.mesh(area: area)
        case .stoneRun: return try StoneRun.mesh(area: area)
        case .tor: return try Stack.mesh(area: area)
        }
    }
}
