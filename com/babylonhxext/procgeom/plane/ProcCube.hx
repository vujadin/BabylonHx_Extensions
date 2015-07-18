package com.babylonhxext.procgeom.plane;

import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.Scene;

import com.babylonhxext.procgeom.common.ProcBase;
import com.babylonhxext.procgeom.common.MeshBuilder;

/**
 * ...
 * @author Krtolica Vujadin
 */

// based on http://jayelinda.com/modelling-by-numbers-part-two-b/

/// <summary>
/// A cube mesh with a single quad on each side.
/// </summary>
class ProcCube extends ProcBase {
	
	//the width, length and height of the cube:
	public var m_Width:Float = 1.0;
	public var m_Length:Float = 1.0;
	public var m_Height:Float = 1.0;
	

	public function new(scene:Scene) {
		super(scene);
	}
	
	//Build the mesh:
	override public function BuildMesh():Mesh {
		//Create a new mesh builder:
		var meshBuilder:MeshBuilder = new MeshBuilder();
		
		//calculate directional vectors for all 3 dimensions of the cube:
		var upDir:Vector3 = Vector3.Up().scaleInPlace(m_Height);
		var rightDir:Vector3 = Vector3.Right().scaleInPlace(m_Width);
		var forwardDir:Vector3 = Vector3.Forward().scaleInPlace(m_Length);
		
		//calculate the positions of two corners opposite each other on the cube:
		
		//positions that will place the pivot at the corner of the cube:
		var nearCorner:Vector3 = Vector3.Zero();
		var farCorner:Vector3 = upDir.add(rightDir).add(forwardDir);
				
		//build the 3 quads that originate from nearCorner:
		BuildQuad2(meshBuilder, nearCorner, forwardDir, rightDir);
		BuildQuad2(meshBuilder, nearCorner, rightDir, upDir);
		BuildQuad2(meshBuilder, nearCorner, upDir, forwardDir);
		
		//build the 3 quads that originate from farCorner:
		BuildQuad2(meshBuilder, farCorner, rightDir.scale(-1), forwardDir.scale(-1));
		BuildQuad2(meshBuilder, farCorner, upDir.scale(-1), rightDir.scale(-1));
		BuildQuad2(meshBuilder, farCorner, forwardDir.scale(-1), upDir.scale(-1));
		
		//initialise the Unity mesh and return it:
		return meshBuilder.CreateMesh(_scene);
	}
	
}
