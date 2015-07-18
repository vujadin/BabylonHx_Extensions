package com.babylonhxext.procgeom.plane;

import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
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
/// A fence mesh.
/// </summary>
class ProcFence extends ProcBase {
	
	//post width and height:
	public var m_PostWidth:Float = 0.2;
	public var m_PostHeight:Float = 1.0;

	//maximum random variation of the post height (set to 0.0 for no variation):
	public var m_PostHeightVariation:Float = 0.25;

	//maximum random angle (in degrees) for tilting the posts (set to 0.0 for no variation):
	public var m_PostTiltAngle:Float = 10.0;

	//crosspiece width and height:
	public var m_CrossPieceHeight:Float = 0.2;
	public var m_CrossPieceWidth:Float = 0.1;

	//base Y offset for the crosspieces (a value of 0.0 will sit the crosspieces on the ground):
	public var m_CrossPieceY:Float = 0.5;

	//maximum random variation of the crosspiece Y offset (set to 0.0 for no variation):
	public var m_CrossPieceYVariation:Float = 0.25;

	//number of sections in the fence:
	public var m_SectionCount:Int = 10;

	//distance between posts:
	public var m_DistBetweenPosts:Float = 1.0;
	

	public function new(scene:Scene) {
		super(scene);
	}
	
	//Build the mesh:
	override public function BuildMesh():Mesh {
		//Create a new mesh builder:
		var meshBuilder:MeshBuilder = new MeshBuilder();
		
		//some variables to hold values needed by the loop:
		var prevCrossPosition:Vector3 = Vector3.Zero();
		var prevRotation:Quaternion = Quaternion.Identity();
		
		//interate over all the posts in this fence:
		for (i in 0...m_SectionCount + 1) {
			//calculate the position and rotation of this post:
			var offset:Vector3 = Vector3.Right().scale(m_DistBetweenPosts * i);
			
			var xAngle:Float = Tools.randomFloat(-m_PostTiltAngle, m_PostTiltAngle);
			var zAngle:Float = Tools.randomFloat(-m_PostTiltAngle, m_PostTiltAngle);
			var rotation:Quaternion = Quaternion.RotationYawPitchRoll(xAngle, 0.0, zAngle);
			
			//Any level-specific position offsets (eg. the height of the terrain at this position) should be applied here.
			
			//build the post:
			BuildPost(meshBuilder, offset, rotation);
			
			//build the crosspiece:
			
			//start with the post position:
			var crossPosition:Vector3 = offset;
			
			//offset to the back of the post:
			crossPosition.addInPlace(rotation.multVector(Vector3.Back().scale(m_PostWidth * 0.5)));
			
			//calculate 2 random Y offsets (one for each end of the crosspiece):
			var randomYStart:Float = Tools.randomFloat(-m_CrossPieceYVariation, m_CrossPieceYVariation);
			var randomYEnd:Float = Tools.randomFloat(-m_CrossPieceYVariation, m_CrossPieceYVariation);
			
			//calculate Y offsets for the start and end positions:
			var crossYOffsetStart:Vector3 = prevRotation.multVector(Vector3.Up().scale(m_CrossPieceY + randomYStart));
			var crossYOffsetEnd:Vector3 = rotation.multVector(Vector3.Up().scale(m_CrossPieceY + randomYEnd));
			
			//if this is not the first section (ie. if there is a previous post to join to), build the crosspiece:
			if (i != 0) {
				BuildCrossPiece(meshBuilder, prevCrossPosition.add(crossYOffsetStart), crossPosition.add(crossYOffsetEnd));
			}
			
			//store the position and rotation for use by the next section:
			prevCrossPosition = crossPosition;
			prevRotation = rotation;
		}
		
		//initialise the BabylonHx mesh and return it:
		return meshBuilder.CreateMesh(_scene);
	}

	/// <summary>
	/// Builds a post extending upward from the specified position:
	/// </summary>
	/// <param name="meshBuilder">The mesh builder currently being added to.</param>
	/// <param name="position">The position of the post.</param>
	/// <param name="rotation">The rotation or the post.</param>
	private function BuildPost(meshBuilder:MeshBuilder, position:Vector3, rotation:Quaternion) {
		//get the post height, including a random offset:
		var postHeight:Float = m_PostHeight + Tools.randomFloat(-m_PostHeightVariation, m_PostHeightVariation);
		
		//calculate directional vectors for all 3 dimensions of the cube:
		var upDir:Vector3 = rotation.multVector(Vector3.Up().scale(postHeight));
		var rightDir:Vector3 = rotation.multVector(Vector3.Right().scale(m_PostWidth));
		var forwardDir:Vector3 = rotation.multVector(Vector3.Forward().scale(m_PostWidth));
		
		//calculate the positions of two corners opposite each other on the cube:
		var farCorner:Vector3 = upDir.add(rightDir).add(forwardDir).add(position);
		var nearCorner:Vector3 = position;
		
		//shift pivot to centre base:
		var pivotOffset:Vector3 = rightDir.add(forwardDir.scale(0.5));
		farCorner.subtractInPlace(pivotOffset);
		nearCorner.subtractInPlace(pivotOffset);
		
		//build the quads that originate from nearCorner (minus the bottom quad):
		BuildQuad2(meshBuilder, nearCorner, rightDir, upDir);
		BuildQuad2(meshBuilder, nearCorner, upDir, forwardDir);
		
		//build the 3 quads that originate from farCorner:
		BuildQuad2(meshBuilder, farCorner, rightDir.scale(-1), forwardDir.scale(-1));
		BuildQuad2(meshBuilder, farCorner, upDir.scale(-1), rightDir.scale(-1));
		BuildQuad2(meshBuilder, farCorner, forwardDir.scale(-1), upDir.scale(-1));
	}

	/// <summary>
	/// Builds a crosspiece extending from a starting position to an end position.
	/// </summary>
	/// <param name="meshBuilder">The mesh builder currently being added to.</param>
	/// <param name="start">The start position.</param>
	/// <param name="end">The end position.</param>
	private function BuildCrossPiece(meshBuilder:MeshBuilder, start:Vector3, end:Vector3) {
		//calculate a directional vector from start to end:
		var dir:Vector3 = end.subtract(start);
		
		//get a look-at roation based on this direction:
		var rotation:Quaternion = Quaternion.LookRotation(dir);
		
		//calculate directional vectors for all 3 dimensions of the cube:
		var upDir:Vector3 = rotation.multVector(Vector3.Up().scale(m_CrossPieceHeight));
		var rightDir:Vector3 = rotation.multVector(Vector3.Right().scale(m_CrossPieceWidth));
		var forwardDir:Vector3 = rotation.multVector(Vector3.Forward().scale(dir.length()));
		
		//calculate the positions of two corners opposite each other on the cube:
		var farCorner:Vector3 = upDir.add(rightDir).add(forwardDir).add(start);
		var nearCorner:Vector3 = start;
		
		//build the 3 quads that originate from nearCorner:
		BuildQuad2(meshBuilder, nearCorner, forwardDir, rightDir);
		BuildQuad2(meshBuilder, nearCorner, rightDir, upDir);
		BuildQuad2(meshBuilder, nearCorner, upDir, forwardDir);
		
		//build the 3 quads that originate from farCorner:
		BuildQuad2(meshBuilder, farCorner, rightDir.scale(-1), forwardDir.scale(-1));
		BuildQuad2(meshBuilder, farCorner, upDir.scale(-1), rightDir.scale(-1));
		BuildQuad2(meshBuilder, farCorner, forwardDir.scale(-1), upDir.scale(-1));
	}

	/// <summary>
	/// Builds a crosspiece extending from a starting position over a distance of m_DistBetweenPosts.
	/// </summary>
	/// <param name="meshBuilder">The mesh builder currently being added to.</param>
	/// <param name="start">The position of the crosspiece.</param>
	private function BuildCrossPiece2(meshBuilder:MeshBuilder, start:Vector3) {
		//calculate directional vectors for all 3 dimensions of the cube:
		var upDir:Vector3 = Vector3.Up().scale(m_CrossPieceHeight);
		var rightDir:Vector3 = Vector3.Right().scale(m_CrossPieceWidth);
		var forwardDir:Vector3 = Vector3.Forward().scale(m_DistBetweenPosts);
		
		//calculate the positions of two corners opposite each other on the cube:
		var farCorner:Vector3 = upDir.add(rightDir).add(forwardDir).add(start);
		var nearCorner:Vector3 = start;
		
		//build the 3 quads that originate from nearCorner:
		BuildQuad2(meshBuilder, nearCorner, forwardDir, rightDir);
		BuildQuad2(meshBuilder, nearCorner, rightDir, upDir);
		BuildQuad2(meshBuilder, nearCorner, upDir, forwardDir);
		
		//build the 3 quads that originate from farCorner:
		BuildQuad2(meshBuilder, farCorner, rightDir.scale(-1), forwardDir.scale(-1));
		BuildQuad2(meshBuilder, farCorner, upDir.scale(-1), rightDir.scale(-1));
		BuildQuad2(meshBuilder, farCorner, forwardDir.scale(-1), upDir.scale(-1));
	}
	
}
