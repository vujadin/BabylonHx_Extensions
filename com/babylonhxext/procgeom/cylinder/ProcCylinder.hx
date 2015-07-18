package com.babylonhxext.procgeom.cylinder;

import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Quaternion;
import com.babylonhx.Scene;

import com.babylonhxext.procgeom.common.ProcBase;
import com.babylonhxext.procgeom.common.MeshBuilder;

/**
 * ...
 * @author Krtolica Vujadin
 */

// based on http://jayelinda.com/modelling-by-numbers-part-two-b/

/// <summary>
/// A basic cylinder mesh.
/// </summary>
class ProcCylinder extends ProcBase {
	
	//the radius and height of the cylinder:
	public var m_Radius:Float = 0.5;
	public var m_Height:Float = 2.0;

	//the number of radial segments:
	public var m_RadialSegmentCount:Int = 10;

	//the number of height segments:
	public var m_HeightSegmentCount:Int = 6;
	

	public function new(scene:Scene) {
		super(scene);
	}

	//Build the mesh:
	override public function BuildMesh():Mesh {
		//Create a new mesh builder:
		var meshBuilder:MeshBuilder = new MeshBuilder();
		
		// one-segment cylinder (build two rings, one at the bottom and one at the top):
		BuildRing(meshBuilder, m_RadialSegmentCount, Vector3.Zero(), m_Radius, 0.0, false);
		BuildRing(meshBuilder, m_RadialSegmentCount, Vector3.Up().scaleInPlace(m_Height), m_Radius, 1.0, true);
		
		// multi-segment cylinder:
		var heightInc = m_Height / m_HeightSegmentCount;
				
		for (i in 0...m_HeightSegmentCount + 1) {			
			//centre position of this ring:
			var centrePos:Vector3 = Vector3.Up().scaleInPlace(heightInc * i);
			
			//V coordinate is based on height:
			var v:Float = i / m_HeightSegmentCount;
			
			BuildRing(meshBuilder, m_RadialSegmentCount, centrePos, m_Radius, v, i > 0);
		}
		
		// caps:
		BuildCap(meshBuilder, Vector3.Zero(), true);
		BuildCap(meshBuilder, Vector3.Up().scale(m_Height), false);
		
		return meshBuilder.CreateMesh(_scene);
	}

	/// <summary>
	/// Adds a cap to the top or bottom of the cylinder.
	/// </summary>
	/// <param name="meshBuilder">The mesh builder currently being added to.</param>
	/// <param name="centre">The postion at the centre of the cap.</param>
	/// <param name="reverseDirection">Should the normal and winding order of the cap be reversed? (Should be true for bottom cap, false for the top)</param>
	private function BuildCap(meshBuilder:MeshBuilder, centre:Vector3, reverseDirection:Bool) {
		//the normal will either be up or down:
		var normal:Vector3 = reverseDirection ? Vector3.Down() : Vector3.Up();
		
		//add one vertex in the center:
		meshBuilder.Vertices.push(centre);
		meshBuilder.Normals.push(normal);
		meshBuilder.UVs.push(new Vector2(0.5, 0.5));
		
		//store the index of the vertex we just added for later reference:
		var centreVertexIndex = meshBuilder.Vertices.length - 1;
		
		//build the vertices around the edge:
		var angleInc = (Math.PI * 2.0) / m_RadialSegmentCount;
		
		for (i in 0...m_RadialSegmentCount + 1) {
			var angle = angleInc * i;
			
			var unitPosition:Vector3 = Vector3.Zero();
			unitPosition.x = Math.cos(angle);
			unitPosition.z = Math.sin(angle);
			
			meshBuilder.Vertices.push(centre.add(unitPosition.scale(m_Radius)));
			meshBuilder.Normals.push(normal);
			
			var uv:Vector2 = new Vector2(unitPosition.x + 1.0, unitPosition.z + 1.0).scale(0.5);
			meshBuilder.UVs.push(uv);
			
			//build a triangle:
			if (i > 0) {
				var baseIndex = meshBuilder.Vertices.length - 1;
				
				if (reverseDirection) {
					meshBuilder.AddTriangle(centreVertexIndex, baseIndex - 1, baseIndex);
				}
				else {
					meshBuilder.AddTriangle(centreVertexIndex, baseIndex, baseIndex - 1);
				}
			}
		}
	}
	
}
