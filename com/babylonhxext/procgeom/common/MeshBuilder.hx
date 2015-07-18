package com.babylonhxext.procgeom.common;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */

// based on http://jayelinda.com/modelling-by-numbers-part-two-b/

/// <summary>
/// Class for holding all the data needed for a mesh in progress.
/// </summary>
class MeshBuilder {
	
	/// <summary>
	/// The vertex positions of the mesh.
	/// </summary>
	private var m_Vertices:Array<Vector3> = [];
	public var Vertices(get, never):Array<Vector3>; 
	private function get_Vertices() { 
		return m_Vertices;  
	}	

	/// <summary>
	/// The vertex normals of the mesh.
	/// </summary>
	private var m_Normals:Array<Vector3> = [];
	public var Normals(get, never):Array<Vector3>;
	private function get_Normals() { 
		return m_Normals; 
	}	

	/// <summary>
	/// The UV coordinates of the mesh.
	/// </summary>
	private var m_UVs:Array<Vector2> = [];
	public var UVs(get, never):Array<Vector2>;
	private function get_UVs() { 
		return m_UVs; 
	}	

	//indices for the triangles:
	private var m_Indices:Array<Int> = [];
	public var Indices(get, never):Array<Int>;
	private function get_Indices():Array<Int> {
		return m_Indices;
	}
	

	public function new() {
		
	}

	/// <summary>
	/// Adds a triangle to the mesh.
	/// </summary>
	/// <param name="index0">The vertex index at corner 0 of the triangle.</param>
	/// <param name="index1">The vertex index at corner 1 of the triangle.</param>
	/// <param name="index2">The vertex index at corner 2 of the triangle.</param>
	public function AddTriangle(index0:Int, index1:Int, index2:Int) {
		m_Indices.push(index0);
		m_Indices.push(index1);
		m_Indices.push(index2);
	}

	/// <summary>
	/// Initialises an instance of the Unity Mesh class, based on the stored values.
	/// </summary>
	/// <returns>The completed mesh.</returns>
	public function CreateMesh(scene:Scene):Mesh {
		//Create an instance of the Unity Mesh class:
		var mesh:Mesh = new Mesh(Tools.uuid(), scene);
		
		var finalVertices:Array<Float> = [];
		for (vert in m_Vertices) {
			finalVertices.push(vert.x);
			finalVertices.push(vert.y);
			finalVertices.push(vert.z);
		}
				
		mesh.setVerticesData(VertexBuffer.PositionKind, finalVertices);
		mesh.setIndices(m_Indices);
		
		//Normals are optional. Only use them if we have the correct amount:
		if (m_Normals.length == m_Vertices.length) {
			var finalNormals:Array<Float> = [];
			for (norm in m_Normals) {
				finalNormals.push(norm.x);
				finalNormals.push(norm.y);
				finalNormals.push(norm.z);
			}
			
			//finalNormals.reverse();
			
			mesh.setVerticesData(VertexBuffer.NormalKind, finalNormals);
		}
		//UVs are optional. Only use them if we have the correct amount:
		if (m_UVs.length == m_Vertices.length) {
			var finalUVs:Array<Float> = [];
			for (uv in m_UVs) {
				finalUVs.push(uv.x);
				finalUVs.push(uv.y);
			}
			
			mesh.setVerticesData(VertexBuffer.UVKind, finalUVs);
		}
		
		mesh.computeWorldMatrix(true);
		
		mesh.material = scene.defaultMaterial;
		mesh.material.backFaceCulling = false;
		//mesh.material.wireframe = true;
		
		return mesh;
	}
	
}
