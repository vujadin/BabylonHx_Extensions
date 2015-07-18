package com.babylonhxext.procgeom.cylinder;

import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Quaternion;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

import com.babylonhxext.procgeom.common.ProcBase;
import com.babylonhxext.procgeom.common.MeshBuilder;

/**
 * ...
 * @author Krtolica Vujadin
 */

// based on http://jayelinda.com/modelling-by-numbers-part-two-b/

/// <summary>
/// A cylinder with a taper deformation.
/// </summary>
class ProcCylinderTaper extends ProcBase {
	
	//the radii at the start and end of the cylinder:
	public var m_RadiusStart:Float = 0.5;
	public var m_RadiusEnd:Float = 0.0;

	//the height of the cylinder:
	public var m_Height:Float = 2.0;

	//the number of radial segments:
	public var m_RadialSegmentCount:Int = 10;

	//the number of height segments:
	public var m_HeightSegmentCount:Int = 4;
	

	public function new(scene:Scene) {
		super(scene);
	}

	override public function BuildMesh():Mesh {
		var meshBuilder:MeshBuilder = new MeshBuilder();
		
		var heightInc:Float = m_Height / m_HeightSegmentCount;
		
		//calculate the slope of the cylinder based on the height and difference between radii:
		var slope:Vector2 = new Vector2(m_RadiusEnd - m_RadiusStart, m_Height);
		slope.normalize();
		
		//build the rings:
		for (i in 0...m_HeightSegmentCount + 1) {
			//centre position of this ring:
			var centrePos:Vector3 = Vector3.Up().scaleInPlace(heightInc * i);
			
			//V coordinate is based on height:
			var v:Float = i / m_HeightSegmentCount;
			
			//interpolate between the radii:
			var radius:Float = Tools.Lerp(m_RadiusStart, m_RadiusEnd, i / m_HeightSegmentCount);
			
			//build the ring:
			BuildRing3(meshBuilder, m_RadialSegmentCount, centrePos, radius, v, i > 0, Quaternion.Identity(), slope);
		}
		
		return meshBuilder.CreateMesh(_scene);
	}
	
}
