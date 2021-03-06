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
/// A cylinder with a bend deformation.
/// </summary>
class ProcCylinderBend extends ProcBase {
	
	//the radius and height of the cylinder:
	public var m_Radius:Float = 0.5;
	public var m_Height:Float = 2.0;

	//the angle to bend the cylinder:
	public var m_BendAngle:Float = 90.0;

	//the number of radial segments:
	public var m_RadialSegmentCount:Int = 10;

	//the number of height segments:
	public var m_HeightSegmentCount:Int = 4;
	

	public function new(scene:Scene) {
		super(scene);
	}	

	//Build the mesh:
	override public function BuildMesh():Mesh {
		//Create a new mesh builder:
		var meshBuilder:MeshBuilder = new MeshBuilder();
		
		//our bend code breaks if m_BendAngle is zero:
		if (m_BendAngle == 0.0) {
			//straight cylinder:
			var heightInc:Float = m_Height / m_HeightSegmentCount;
			
			for (i in 0...m_HeightSegmentCount + 1) {
				var centrePos:Vector3 = Vector3.Up().scaleInPlace(heightInc * i);
				var v:Float = i / m_HeightSegmentCount;
				
				BuildRing(meshBuilder, m_RadialSegmentCount, centrePos, m_Radius, v, i > 0);
			}
		}
		else {
			//bent cylinder:
			
			//get the angle in radians:
			var bendAngleRadians:Float = m_BendAngle * (Math.PI / 180);
			
			//the radius of our bend (vertical) circle:
			var bendRadius:Float = m_Height / bendAngleRadians;
			
			//the angle increment per height segment (based on arc length):
			var angleInc:Float = bendAngleRadians / m_HeightSegmentCount;
			
			//calculate a start offset that will place the centre of the first ring (angle 0.0f) on the mesh origin:
			//(x = cos(0.0f) * bendRadius, y = sin(0.0f) * bendRadius)
			var startOffset:Vector3 = new Vector3(bendRadius, 0.0, 0.0);
			
			//build the rings:
			for (i in 0...m_HeightSegmentCount + 1) {
				//unit position along the edge of the vertical circle:
				var centrePos = Vector3.Zero();
				centrePos.x = Math.cos(angleInc * i);
				centrePos.y = Math.sin(angleInc * i);
				
				//rotation at that position on the circle:
				var zAngleDegrees:Float = angleInc * i * (Math.PI / 180);
				var rotation:Quaternion = Quaternion.RotationYawPitchRoll(0.0, 0.0, zAngleDegrees);
				
				//multiply the unit postion by the radius:
				centrePos.scaleInPlace(bendRadius);
				
				//offset the position so that the base ring (at angle zero) centres around zero:
				centrePos.subtractInPlace(startOffset);
				
				//V coordinate is based on height:
				var v:Float = i / m_HeightSegmentCount;
				
				//build the ring:
				BuildRing2(meshBuilder, m_RadialSegmentCount, centrePos, m_Radius, v, i > 0, rotation);
			}
		}
		
		return meshBuilder.CreateMesh(_scene);
	}
	
}
