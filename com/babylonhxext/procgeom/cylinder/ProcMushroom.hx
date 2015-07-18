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
/// A mushroom mesh.
/// </summary>
class ProcMushroom extends ProcBase {
	
	//cap data:

	//height and radius of the cap:
	public var m_CapRadius:Float = 0.5;
	public var m_CapHeight:Float = 0.5;

	//data to define the Bézier handles for the cap curve:
	public var m_CapPeakHandleLength:Float = 0.5;
	public var m_CapRimHandleLength:Float = 1.0;
	public var m_CapRimHandleAngle:Float = 0.0;

	//vertical thickness of the cap (at the peak):
	public var m_CapThickness:Float = 0.2;

	//number of radial segments in the cap:
	public var m_CapRadialSegmentCount:Int = 10;

	//stem data:

	//height and radius of the stem:
	public var m_StemHeight:Float = 1.0;
	public var m_StemRadius:Float = 0.3;

	//the angle to bend the stem:
	public var m_StemBendAngle:Float = 45.0;

	//number of radial segments in the stem:
	public var m_StemRadialSegmentCount:Int = 10;

	//number of height segments in the stem:
	public var m_StemHeightSegmentCount:Int = 10;
	

	public function new(scene:Scene) {
		super(scene);
	}
	
	override public function BuildMesh():Mesh {
		var meshBuilder:MeshBuilder = new MeshBuilder();
		
		//store the current position and rotaion of the stem:
		var currentRotation:Quaternion = Quaternion.Identity();
		var currentOffset:Vector3 = Vector3.Zero();
		
		//build the stem:
		
		//build a straight stem if m_StemBendAngle is zero:
		if (m_StemBendAngle == 0.0) {
			//straight cylinder:
			var heightInc:Float = m_StemHeight / m_StemHeightSegmentCount;
			
			for (i in 0...m_StemHeightSegmentCount + 1) {
				currentOffset = Vector3.Up().scale(heightInc * i);
				
				BuildRing(meshBuilder, m_StemRadialSegmentCount, currentOffset, m_StemRadius, i / m_StemHeightSegmentCount, i > 0);
			}
		}
		else {
			//get the angle in radians:
			var stemBendRadians:Float = m_StemBendAngle * (Math.PI / 180);
			
			//the radius of our bend (vertical) circle:
			var stemBendRadius:Float = m_StemHeight / stemBendRadians;
			
			//the angle increment per height segment (based on arc length):
			var angleInc:Float = stemBendRadians / m_StemHeightSegmentCount;
			
			//calculate a start offset that will place the centre of the first ring (angle 0.0f) on the mesh origin:
			//(x = cos(0.0f) * bendRadius, y = sin(0.0f) * bendRadius)
			var startOffset:Vector3 = new Vector3(stemBendRadius, 0.0, 0.0);
			
			//build the rings:
			for (i in 0...m_StemHeightSegmentCount + 1) {
				//current normalised height value:
				var heightNormalised:Float = i / m_StemHeightSegmentCount;
				
				//unit position along the edge of the vertical circle:
				currentOffset = Vector3.Zero();
				currentOffset.x = Math.cos(angleInc * i);
				currentOffset.y = Math.sin(angleInc * i);
				
				//rotation at that position on the circle:
				var zAngleDegrees:Float = angleInc * i * (Math.PI / 180);
				currentRotation = Quaternion.RotationYawPitchRoll(0.0, 0.0, zAngleDegrees);
				
				//multiply the unit postion by the radius:
				currentOffset.scaleInPlace(stemBendRadius);
				
				//offset the position so that the base ring (at angle zero) centres around zero:
				currentOffset.subtractInPlace(startOffset);
				
				//build the ring:
				BuildRing2(meshBuilder, m_StemRadialSegmentCount, currentOffset, m_StemRadius, heightNormalised, i > 0, currentRotation);
			}
		}
		
		//build the cap:
		
		//positions of the cap peak and rim in the XY cross-section:
		var capPeak:Vector3 = new Vector3(0.0, m_CapThickness, 0.0);
		var capRim:Vector3 = new Vector3(m_CapRadius, -m_CapHeight + m_CapThickness, 0.0);
		
		//Bézier handles to define the cap curve:
		var peakHandle:Vector3 = new Vector3(m_CapPeakHandleLength, 0.0, 0.0);
		
		var rimAngleRadians:Float = m_CapRimHandleAngle * (Math.PI / 180);
		var rimHandle:Vector3 = new Vector3(Math.cos(rimAngleRadians), Math.sin(rimAngleRadians), 0.0);
		rimHandle.scaleInPlace(m_CapRimHandleLength);
		
		//build the outer surface of the cap:
		BuildCap(meshBuilder, currentOffset, currentRotation, capRim, capPeak, capRim.add(rimHandle), capPeak.add(peakHandle));
		
		//build the gills:
		
		//adjust the Bézier handles for our inner curve:
		capPeak.y -= m_CapThickness;
		rimHandle = new Vector3( -rimHandle.y, rimHandle.x, 0.0);
		
		//build the gills (inner surface of the cap)
		//note the reversal of the control points to make the mesh face inward instead of outward:
		BuildCap(meshBuilder, currentOffset, currentRotation, capPeak, capRim, capPeak.add(peakHandle), capRim.add(rimHandle));
		
		return meshBuilder.CreateMesh(_scene);
	}

	/// <summary>
	/// 
	/// </summary>
	/// <param name="meshBuilder">The mesh builder currently being added to.</param>
	/// <param name="offset">The position offset to apply to the whole cap (position at the top of the stem).</param>
	/// <param name="rotation">The rotation offset to apply to the whole cap (rotation at the top of the stem).</param>
	/// <param name="capRim">Position at the rim of the cap (in XY cross-section), or the start point of the Bézier curve.</param>
	/// <param name="capPeak">Position at the peak of the cap (in XY cross-section), or the end point of the Bézier curve.</param>
	/// <param name="controlRim">The first of the inner control points of the Bézier curve (the rim position plus the rim handle).</param>
	/// <param name="controlPeak">The second of the inner control points of the Bézier curve (the peak position plus the peak handle).</param>
	private function BuildCap(meshBuilder:MeshBuilder, offset:Vector3, rotation:Quaternion, capRim:Vector3, capPeak:Vector3, controlRim:Vector3, controlPeak:Vector3) {
		//we'll use a quarter of the radial segments for the height (the same segment allocation as a hemisphere):
		var capHeightSegmentCount:Int = Std.int(m_CapRadialSegmentCount / 4);
		
		//build the rings:
		for (i in 0...capHeightSegmentCount + 1) {
			//current normalised height value:
			var heightNormalised:Float = i / capHeightSegmentCount;
			
			//interpolated position along the Bézier curve:
			var bezier:Vector3 = Bezier(capRim, controlRim, controlPeak, capPeak, heightNormalised);
			
			//calculate a height offset and radius based on the Bézier curve position:
			var centrePos:Vector3 = new Vector3(0.0, bezier.y, 0.0);
			var radius:Float = bezier.x;
			
			//interpolated tangent along the Bézier curve:
			var tangent:Vector3 = BezierTangent(capRim, controlRim, controlPeak, capPeak, heightNormalised);
			var slope:Vector2 = new Vector2(tangent.x, tangent.y);
			
			//build the ring:
			BuildRing3(meshBuilder, m_CapRadialSegmentCount, offset.add(rotation)multVector(centrePos), radius, heightNormalised, i > 0, rotation, slope);
		}
	}
	
	/// <summary>
	/// Gets a position along a Bézier curve.
	/// 
	/// For more information:
	/// http://pomax.github.io/bezierinfo/
	/// </summary>
	/// <param name="start">The first of the four control points for the Bézier curve.</param>
	/// <param name="controlMid1">The second of the four control points for the Bézier curve.</param>
	/// <param name="controlMid2">The third of the four control points for the Bézier curve.</param>
	/// <param name="end">The last of the four control points for the Bézier curve.</param>
	/// <param name="t">The interpolation value, should be between 0.0 and 1.0</param>
	/// <returns>The interpolated position along the Bézier curve.</returns>
	public function Bezier(start:Vector3, controlMid1:Vector3, controlMid2:Vector3, end:Vector3, t:Float):Vector3 {
		var t2 = t * t;
		var t3 = t2 * t;
		
		var mt = 1 - t;
		var mt2 = mt * mt;
		var mt3 = mt2 * mt;
		
		return (start.scale(mt3)).add(controlMid1.scale(mt2 * t * 3.0)).add(controlMid2.scale(mt * t2 * 3.0)).add(end.scale(t3));
	}

	/// <summary>
	/// Gets a tangent along a Bézier curve.
	/// 
	/// For more information:
	/// http://pomax.github.io/bezierinfo/
	/// </summary>
	/// <param name="start">The first of the four control points for the Bézier curve.</param>
	/// <param name="controlMid1">The second of the four control points for the Bézier curve.</param>
	/// <param name="controlMid2">The third of the four control points for the Bézier curve.</param>
	/// <param name="end">The last of the four control points for the Bézier curve.</param>
	/// <param name="t">The interpolation value, should be between 0.0 and 1.0</param>
	/// <returns>The interpolated tangent along the Bézier curve.</returns>
	public function BezierTangent(start:Vector3, controlMid1:Vector3, controlMid2:Vector3, end:Vector3, t:Float):Vector3 {
		var t2 = t * t;
		
		var mt = 1 - t;
		var mt2 = mt * mt;
		
		var mid = 2.0 * t * mt;
		
		var tangent:Vector3 = (start.scale( -mt2)).add(controlMid1.scale(mt2 - mid)).add(controlMid2.scale( -t2 + mid)).add(end.scale(t2));
		
		return tangent.normalize();
	}
	
}
