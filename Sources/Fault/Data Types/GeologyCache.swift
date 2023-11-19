//
//  GeologyCache.swift
//
//  Created by Zack Brown on 19/11/2023.
//

import Bivouac
import Euclid
import Foundation

public struct GeologyCache {
    
    public let meshes: [GeologyType : Mesh]
    
    public func mesh(for geologyType: GeologyType) -> Mesh? { meshes[geologyType] }
}
