package com.babylonhxext.procgeom.cylinder;

import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.Scene;

import com.babylonhxext.procgeom.common.ProcBase;
import com.babylonhxext.procgeom.common.MeshBuilder;

/**
 * ...
 * @author Krtolica Vujadin
 */

// based on http://jayelinda.com/modelling-by-numbers-part-two-b/
 
/// <summary>
/// A sphere mesh.
/// </summary>
class ProcSphere extends ProcBase {
	
	//the radius of the sphere:
	public var m_Radius:Float = 0.5;

	//the number of radial segments:
	public var m_RadialSegmentCount:Int = 10;
	

	public function new(scene:Scene) {
		super(scene);
	}	

	//Build the mesh:
	override public function BuildMesh():Mesh {
		//Create a new mesh builder:
		var meshBuilder:MeshBuilder = new MeshBuilder();
		
		//height segments need to be half m_RadialSegmentCount for the sphere to be even horizontally and vertically:
		var heightSegmentCount:Int = Std.int(m_RadialSegmentCount / 2);
		
		//the angle increment per height segment:
		var angleInc:Float = Math.PI / heightSegmentCount;
		
		for (i in 0...heightSegmentCount + 1) {
			var centrePos:Vector3 = Vector3.Zero();
			
			//calculate a height offset and radius based on a vertical circle calculation:
			centrePos.y = -Math.cos(angleInc * i) * m_Radius;
			var radius:Float = Math.sin(angleInc * i) * m_Radius;
			
			var v:Float = i / heightSegmentCount;
			
			//build the ring:
			BuildRingForSphere(meshBuilder, m_RadialSegmentCount, centrePos, radius, v, i > 0);
		}
		
		return meshBuilder.CreateMesh(_scene);
	}
	
}
