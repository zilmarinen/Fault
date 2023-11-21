//
//  Triangle.swift
//
//  Created by Zack Brown on 19/11/2023.
//

import Bivouac
import Foundation

extension Grid.Triangle.Stencil {
    
    internal enum Segment: CaseIterable {
        
        case s0, s1, s2
        
        internal var vertices: [Grid.Triangle.Stencil.Vertex] {
            
            switch self {
                
            case .s0: return [.v0, .v3, .v4, .v5, .v6]
            case .s1: return [.v1, .v8, .v9, .v12, .v13]
            case .s2: return [.v2, .v7, .v10, .v11, .v14]
            }
        }
    }
}
