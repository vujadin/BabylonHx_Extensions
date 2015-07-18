# BabylonHx_Extensions
Extensions/plugins for BabylonHx

<b>ObjParser use:</b><br/>
```
// instantiate ObjParser
// first param: root url (contains obj, mtl files as well as textures)
// seccond param: file name
// third param: scene object
var objLoader = new ObjLoader(scene);
objLoader.load("assets/models/", "mesh.obj", function(meshes:Array<Mesh>) {
	...
});
