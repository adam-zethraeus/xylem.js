json = '{
	"camera": {
		"position": {"x": 0, "y": 1, "z": 0},
		"lookVector": {"x": 0, "y": 0, "z": -1},
		"fieldOfView": 35,
		"aspectRatio": {"width": 800, "height": 640},
		"nearPlane": 0.1,
		"farPlane": 10000
	},
	"triangles": [
		{
			"a":{"x": -0.1, "y": 1.5, "z": -2}, 
			"b":{"x": 0.5, "y": 0.5, "z": -2},
			"c":{"x": -0.2, "y": 0.1, "z": -2}
		}
	],
	"lights": [
		{
			"type": "point",
			"colour": "FFFFFF",
			"strength": 10
		}
	]
}'
sceneGraph = new SceneGraph(json)
renderer = new Renderer(sceneGraph)
x = RenderEffect
renderer.addEffect(x)
sceneGraph.logInfo()
