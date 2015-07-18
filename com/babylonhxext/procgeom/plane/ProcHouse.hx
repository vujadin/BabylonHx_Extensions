package com.babylonhxext.procgeom.plane;

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
/// A basic house shape.
/// </summary>
class ProcHouse extends ProcBase {
	
	//the width, length and height of the walls:
	public var m_Width:Float = 1.0;
	public var m_Length:Float = 1.0;
	public var m_Height:Float = 1.0;

	//the height of the roof:
	public var m_RoofHeight:Float = 0.3;

	//the width of the roof overhang at the front and back of the house:
	public var m_RoofOverhangFront:Float = 0.2;

	//the width of the roof overhang at the sides of the house:
	public var m_RoofOverhangSide:Float = 0.2;

	//an offset to reduce z-fighting between the walls and roof:
	public var m_RoofBias:Float = 0.02;
	

	public function new(scene:Scene) {
		super(scene);
	}

	//Build the mesh:
	override public function BuildMesh():Mesh {
		//Create a new mesh builder:
		var meshBuilder:MeshBuilder = new MeshBuilder();
		
		//build the walls:
		
		//calculate directional vectors for the walls:
		var upDir:Vector3 = Vector3.Up().scale(m_Height);
		var rightDir:Vector3 = Vector3.Right().scale(m_Width);
		var forwardDir:Vector3 = Vector3.Forward().scale(m_Length);
		
		var farCorner:Vector3 = upDir.add(rightDir).add(forwardDir);
		var nearCorner:Vector3 = Vector3.Zero();
		
		//shift the pivot to centre bottom:
		var pivotOffset:Vector3 = (rightDir.add(forwardDir)).scaleInPlace(0.5);
		farCorner.subtractInPlace(pivotOffset);
		nearCorner.subtractInPlace(pivotOffset);
		
		//build the quads for the walls:
		BuildQuad2(meshBuilder, nearCorner, rightDir, upDir);
		BuildQuad2(meshBuilder, nearCorner, upDir, forwardDir);
		
		BuildQuad2(meshBuilder, farCorner, upDir.scale(-1), rightDir.scale(-1));
		BuildQuad2(meshBuilder, farCorner, forwardDir.scale(-1), upDir.scale(-1));
		
		//build the roof:
		
		//calculate the position of the roof peak at the near end of the house:
		var roofPeak:Vector3 = Vector3.Up().scale(m_Height + m_RoofHeight).add(rightDir.scale(0.5)).subtract(pivotOffset);
		
		//calculate the positions at the tops of the walls at the same end of the house:
		var wallTopLeft:Vector3 = upDir.subtract(pivotOffset);
		var wallTopRight:Vector3 = upDir.add(rightDir).subtract(pivotOffset);
		
		//build triangles at the tops of the walls:
		BuildTriangle(meshBuilder, wallTopLeft, roofPeak, wallTopRight);
		BuildTriangle(meshBuilder, wallTopLeft.add(forwardDir), wallTopRight.add(forwardDir), roofPeak.add(forwardDir));
		
		//calculate the directions from the roof peak to the sides of the house:
		var dirFromPeakLeft:Vector3 = wallTopLeft.subtract(roofPeak);
		var dirFromPeakRight:Vector3 = wallTopRight.subtract(roofPeak);
		
		//extend the directions by a length of m_RoofOverhangSide:
		dirFromPeakLeft.addInPlace(dirFromPeakLeft.normalize().scale(m_RoofOverhangSide));
		dirFromPeakRight.addInPlace(dirFromPeakRight.normalize().scale(m_RoofOverhangSide));
		
		//offset the roofpeak position to put it at the beginning of the front overhang:
		roofPeak.subtractInPlace(Vector3.Forward().scale(m_RoofOverhangFront));
		
		//extend the forward directional vector to make it long enough for and overhang at either end:
		forwardDir.addInPlace(Vector3.Forward().scale(m_RoofOverhangFront * 2.0));
		
		//shift the roof slightly upward to stop it intersecting the top of the walls:
		roofPeak.addInPlace(Vector3.Up().scale(m_RoofBias));
		
		//build the quads for the roof:
		BuildQuad2(meshBuilder, roofPeak, forwardDir, dirFromPeakLeft);
		BuildQuad2(meshBuilder, roofPeak, dirFromPeakRight, forwardDir);
		
		BuildQuad2(meshBuilder, roofPeak, dirFromPeakLeft, forwardDir);
		BuildQuad2(meshBuilder, roofPeak, forwardDir, dirFromPeakRight);
		
		//initialise the Unity mesh and return it:
		return meshBuilder.CreateMesh(_scene);
	}
	
}
