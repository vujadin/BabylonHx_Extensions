package com.babylonhxext.procgeom.common;

import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Quaternion;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */

// based on http://jayelinda.com/modelling-by-numbers-part-two-b/

/// <summary>
/// Base class for procedural meshes. Contains generic initialisation code and shared methods such as BuildQuad() and BuildRing()
/// </summary>
class ProcBase {
	
	private var _scene:Scene;

	public function new(scene:Scene) {
		_scene = scene;
	}
	
	/// <summary>
	/// Method for building a mesh.
	/// </summary>
	/// <returns>The completed mesh</returns>
	public function BuildMesh():Mesh {
		throw("Override me!");
	}

	/// <summary>
	/// Builds a single quad in the XZ plane, facing up the Y axis.
	/// </summary>
	/// <param name="meshBuilder">The mesh builder currently being added to.</param>
	/// <param name="offset">A position offset for the quad.</param>
	/// <param name="width">The width of the quad.</param>
	/// <param name="length">The length of the quad.</param>
	private function BuildQuad(meshBuilder:MeshBuilder, offset:Vector3, width:Float, length:Float) {
		meshBuilder.Vertices.push(new Vector3(0.0, 0.0, 0.0).add(offset));
		meshBuilder.UVs.push(new Vector2(0.0, 0.0));
		meshBuilder.Normals.push(Vector3.Up());
		
		meshBuilder.Vertices.push(new Vector3(0.0, 0.0, length).add(offset));
		meshBuilder.UVs.push(new Vector2(0.0, 1.0));
		meshBuilder.Normals.push(Vector3.Up());
		
		meshBuilder.Vertices.push(new Vector3(width, 0.0, length).add(offset));
		meshBuilder.UVs.push(new Vector2(1.0, 1.0));
		meshBuilder.Normals.push(Vector3.Up());
		
		meshBuilder.Vertices.push(new Vector3(width, 0.0, 0.0).add(offset));
		meshBuilder.UVs.push(new Vector2(1.0, 0.0));
		meshBuilder.Normals.push(Vector3.Up());
		
		//we don't know how many verts the meshBuilder is up to, but we only care about the four we just added:
		var baseIndex = meshBuilder.Vertices.length - 4;
		
		meshBuilder.AddTriangle(baseIndex, baseIndex + 1, baseIndex + 2);
		meshBuilder.AddTriangle(baseIndex, baseIndex + 2, baseIndex + 3);
	}

	/// <summary>
	/// Builds a single quad based on a position offset and width and length vectors.
	/// </summary>
	/// <param name="meshBuilder">The mesh builder currently being added to.</param>
	/// <param name="offset">A position offset for the quad.</param>
	/// <param name="widthDir">The width vector of the quad.</param>
	/// <param name="lengthDir">The length vector of the quad.</param>
	private function BuildQuad2(meshBuilder:MeshBuilder, offset:Vector3, widthDir:Vector3, lengthDir:Vector3) {
		var normal:Vector3 = Vector3.Cross(lengthDir, widthDir).normalize();
		
		meshBuilder.Vertices.push(offset);
		meshBuilder.UVs.push(new Vector2(0.0, 0.0));
		meshBuilder.Normals.push(normal);
		
		meshBuilder.Vertices.push(offset.add(lengthDir));
		meshBuilder.UVs.push(new Vector2(0.0, 1.0));
		meshBuilder.Normals.push(normal);
		
		meshBuilder.Vertices.push(offset.add(lengthDir).add(widthDir));
		meshBuilder.UVs.push(new Vector2(1.0, 1.0));
		meshBuilder.Normals.push(normal);
		
		meshBuilder.Vertices.push(offset.add(widthDir));
		meshBuilder.UVs.push(new Vector2(1.0, 0.0));
		meshBuilder.Normals.push(normal);
		
		//we don't know how many verts the meshBuilder is up to, but we only care about the four we just added:
		var baseIndex = meshBuilder.Vertices.length - 4;
		
		meshBuilder.AddTriangle(baseIndex, baseIndex + 1, baseIndex + 2);
		meshBuilder.AddTriangle(baseIndex, baseIndex + 2, baseIndex + 3);
	}

	/// <summary>
	/// Builds a single quad as part of a mesh grid.
	/// </summary>
	/// <param name="meshBuilder">The mesh builder currently being added to.</param>
	/// <param name="position">A position offset for the quad. Specifically the position of the corner vertex of the quad.</param>
	/// <param name="uv">The UV coordinates of the quad's corner vertex.</param>
	/// <param name="buildTriangles">Should triangles be built for this quad? This value should be false if this is the first quad in any row or collumn.</param>
	/// <param name="vertsPerRow">The number of vertices per row in this grid.</param>
	private function BuildQuadForGrid(meshBuilder:MeshBuilder, position:Vector3, uv:Vector2, buildTriangles:Bool, vertsPerRow:Int) {
		meshBuilder.Vertices.push(position);
		meshBuilder.UVs.push(uv);
		
		if (buildTriangles) {
			var baseIndex = meshBuilder.Vertices.length - 1;
			
			var index0 = baseIndex;
			var index1 = baseIndex - 1;
			var index2 = baseIndex - vertsPerRow;
			var index3 = baseIndex - vertsPerRow - 1;
			
			meshBuilder.AddTriangle(index0, index2, index1);
			meshBuilder.AddTriangle(index2, index3, index1);
		}
	}

	/// <summary>
	/// Builds a single quad as part of a mesh grid.
	/// </summary>
	/// <param name="meshBuilder">The mesh builder currently being added to.</param>
	/// <param name="position">A position offset for the quad. Specifically the position of the corner vertex of the quad.</param>
	/// <param name="uv">The UV coordinates of the quad's corner vertex.</param>
	/// <param name="buildTriangles">Should triangles be built for this quad? This value should be false if this is the first quad in any row or collumn.</param>
	/// <param name="vertsPerRow">The number of vertices per row in this grid.</param>
	/// <param name="normal">The normal of the quad's corner vertex.</param>
	private function BuildQuadForGrid2(meshBuilder:MeshBuilder, position:Vector3, uv:Vector2, buildTriangles:Bool, vertsPerRow:Int, normal:Vector3) {
		meshBuilder.Vertices.push(position);
		meshBuilder.UVs.push(uv);
		meshBuilder.Normals.push(normal);
		
		if (buildTriangles) {
			var baseIndex = meshBuilder.Vertices.length - 1;
			
			var index0 = baseIndex;
			var index1 = baseIndex - 1;
			var index2 = baseIndex - vertsPerRow;
			var index3 = baseIndex - vertsPerRow - 1;
			
			meshBuilder.AddTriangle(index0, index2, index1);
			meshBuilder.AddTriangle(index2, index3, index1);
		}
	}

	/// <summary>
	/// Builds a ring as part of a cylinder.
	/// </summary>
	/// <param name="meshBuilder">The mesh builder currently being added to.</param>
	/// <param name="segmentCount">The number of segments in this ring.</param>
	/// <param name="centre">The position at the centre of the ring.</param>
	/// <param name="radius">The radius of the ring.</param>
	/// <param name="v">The V coordinate for this ring.</param>
	/// <param name="buildTriangles">Should triangles be built for this ring? This value should be false if this is the first ring in the cylinder.</param>
	private function BuildRing(meshBuilder:MeshBuilder, segmentCount:Int, centre:Vector3, radius:Float, v:Float, buildTriangles:Bool) {
		var angleInc = (Math.PI * 2.0) / segmentCount;
		
		for (i in 0...segmentCount + 1) {
			var angle:Float = angleInc * i;
			
			var unitPosition:Vector3 = Vector3.Zero();
			unitPosition.x = Math.cos(angle);
			unitPosition.z = Math.sin(angle);
			
			meshBuilder.Vertices.push(centre.add(unitPosition.scaleInPlace(radius)));
			meshBuilder.Normals.push(unitPosition);
			meshBuilder.UVs.push(new Vector2(i / segmentCount, v));
			
			if (i > 0 && buildTriangles) {
				var baseIndex = meshBuilder.Vertices.length - 1;
				
				var vertsPerRow = segmentCount + 1;
				
				var index0 = baseIndex;
				var index1 = baseIndex - 1;
				var index2 = baseIndex - vertsPerRow;
				var index3 = baseIndex - vertsPerRow - 1;
				
				meshBuilder.AddTriangle(index0, index2, index1);
				meshBuilder.AddTriangle(index2, index3, index1);
			}
		}
	}

	/// <summary>
	/// Builds a ring as part of a cylinder.
	/// </summary>
	/// <param name="meshBuilder">The mesh builder currently being added to.</param>
	/// <param name="segmentCount">The number of segments in this ring.</param>
	/// <param name="centre">The position at the centre of the ring.</param>
	/// <param name="radius">The radius of the ring.</param>
	/// <param name="v">The V coordinate for this ring.</param>
	/// <param name="buildTriangles">Should triangles be built for this ring? This value should be false if this is the first ring in the cylinder.</param>
	/// <param name="rotation">A rotation value to be applied to the whole ring.</param>
	private function BuildRing2(meshBuilder:MeshBuilder, segmentCount:Int, centre:Vector3, radius:Float, v:Float, buildTriangles:Bool, rotation:Quaternion) {
		var angleInc = (Math.PI * 2.0) / segmentCount;
		
		for (i in 0...segmentCount + 1) {
			var angle:Float = angleInc * i;
			
			var unitPosition:Vector3 = Vector3.Zero();
			unitPosition.x = Math.cos(angle);
			unitPosition.z = Math.cos(angle);
			
			unitPosition = rotation.multVector(unitPosition);
			
			meshBuilder.Vertices.push(centre.add(unitPosition.scaleInPlace(radius)));
			meshBuilder.Normals.push(unitPosition);
			meshBuilder.UVs.push(new Vector2(i / segmentCount, v));
			
			if (i > 0 && buildTriangles) {
				var baseIndex = meshBuilder.Vertices.length - 1;
				
				var vertsPerRow = segmentCount + 1;
				
				var index0 = baseIndex;
				var index1 = baseIndex - 1;
				var index2 = baseIndex - vertsPerRow;
				var index3 = baseIndex - vertsPerRow - 1;
				
				meshBuilder.AddTriangle(index0, index2, index1);
				meshBuilder.AddTriangle(index2, index3, index1);
			}
		}
	}

	/// <summary>
	/// Builds a ring as part of a cylinder.
	/// </summary>
	/// <param name="meshBuilder">The mesh builder currently being added to.</param>
	/// <param name="segmentCount">The number of segments in this ring.</param>
	/// <param name="centre">The position at the centre of the ring.</param>
	/// <param name="radius">The radius of the ring.</param>
	/// <param name="v">The V coordinate for this ring.</param>
	/// <param name="buildTriangles">Should triangles be built for this ring? This value should be false if this is the first ring in the cylinder.</param>
	/// <param name="rotation">A rotation value to be applied to the whole ring.</param>
	/// <param name="slope">The normalised slope (rise and run) of the cylinder at this height.</param>
	private function BuildRing3(meshBuilder:MeshBuilder, segmentCount:Int, centre:Vector3, radius:Float, v:Float, buildTriangles:Bool, rotation:Quaternion, slope:Vector2) {
		var angleInc = (Math.PI * 2.0) / segmentCount;
		
		for (i in 0...segmentCount + 1) {
			var angle:Float = angleInc * i;
			
			var unitPosition:Vector3 = Vector3.Zero();
			unitPosition.x = Math.cos(angle);
			unitPosition.z = Math.sin(angle);
			
			var normalVertical:Float = -slope.x;
			var normalHorizontal:Float = slope.y;
			
			var normal:Vector3 = unitPosition.scaleInPlace(normalHorizontal);
			normal.y = normalVertical;
			
			normal = rotation.multVector(normal);
			
			unitPosition = rotation.multVector(unitPosition);
			
			meshBuilder.Vertices.push(centre.add(unitPosition.scaleInPlace(radius)));
			meshBuilder.Normals.push(normal);
			meshBuilder.UVs.push(new Vector2(i / segmentCount, v));
			
			if (i > 0 && buildTriangles) {
				var baseIndex = meshBuilder.Vertices.length - 1;
				
				var vertsPerRow = segmentCount + 1;
				
				var index0 = baseIndex;
				var index1 = baseIndex - 1;
				var index2 = baseIndex - vertsPerRow;
				var index3 = baseIndex - vertsPerRow - 1;
				
				meshBuilder.AddTriangle(index0, index2, index1);
				meshBuilder.AddTriangle(index2, index3, index1);
			}
		}
	}

	/// <summary>
	/// Builds a single triangle.
	/// </summary>
	/// <param name="meshBuilder">The mesh builder currently being added to.</param>
	/// <param name="corner0">The vertex position at index 0 of the triangle.</param>
	/// <param name="corner1">The vertex position at index 1 of the triangle.</param>
	/// <param name="corner2">The vertex position at index 2 of the triangle.</param>
	private function BuildTriangle(meshBuilder:MeshBuilder, corner0:Vector3, corner1:Vector3, corner2:Vector3) {
		var normal = Vector3.Cross(corner1.subtract(corner0), corner2.subtract(corner0)).normalize();
		
		meshBuilder.Vertices.push(corner0);
		meshBuilder.UVs.push(new Vector2(0.0, 0.0));
		meshBuilder.Normals.push(normal);
		
		meshBuilder.Vertices.push(corner1);
		meshBuilder.UVs.push(new Vector2(0.0, 1.0));
		meshBuilder.Normals.push(normal);
		
		meshBuilder.Vertices.push(corner2);
		meshBuilder.UVs.push(new Vector2(1.0, 1.0));
		meshBuilder.Normals.push(normal);
		
		var baseIndex:Int = meshBuilder.Vertices.length - 3;
		
		meshBuilder.AddTriangle(baseIndex, baseIndex + 1, baseIndex + 2);
	}

	/// <summary>
	/// Builds a ring as part of a sphere. Normals are calculated as directions from the sphere's centre.
	/// </summary>
	/// <param name="meshBuilder">The mesh builder currently being added to.</param>
	/// <param name="segmentCount">The number of segments in this ring.</param>
	/// <param name="centre">The position at the centre of the ring.</param>
	/// <param name="radius">The radius of the ring.</param>
	/// <param name="v">The V coordinate for this ring.</param>
	/// <param name="buildTriangles">Should triangles be built for this ring? This value should be false if this is the first ring in the cylinder.</param>
	private function BuildRingForSphere(meshBuilder:MeshBuilder, segmentCount:Int, centre:Vector3, radius:Float, v:Float, buildTriangles:Bool = true) {
		var angleInc = (Math.PI * 2.0) / segmentCount;
		
		for (i in 0...segmentCount + 1) {
			var angle:Float = angleInc * i;
			
			var unitPosition = Vector3.Zero();
			unitPosition.x = Math.cos(angle);
			unitPosition.z = Math.sin(angle);
			
			var vertexPosition:Vector3 = centre.add(unitPosition.scaleInPlace(radius));
			
			meshBuilder.Vertices.push(vertexPosition);
			meshBuilder.Normals.push(vertexPosition.normalize());
			meshBuilder.UVs.push(new Vector2(i / segmentCount, v));
			
			if (i > 0 && buildTriangles) {
				var baseIndex = meshBuilder.Vertices.length - 1;
				
				var vertsPerRow = segmentCount + 1;
				
				var index0 = baseIndex;
				var index1 = baseIndex - 1;
				var index2 = baseIndex - vertsPerRow;
				var index3 = baseIndex - vertsPerRow - 1;
				
				meshBuilder.AddTriangle(index0, index2, index1);
				meshBuilder.AddTriangle(index2, index3, index1);
			}
		}
	}
	
}
