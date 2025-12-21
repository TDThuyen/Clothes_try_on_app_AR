// VertexDistanceController.js
// Version: 0.1.0
// Event: Lens Initialized
// Description: Automatically determine loose vertices that
// can be simulated based on distance form skin.

// @input Component.ClothVisual clothVisual
// @input bool overrideVertexSettings = false
// @input float bindDistance = 0.7 {"widget":"slider", "min":0, "max":1, "step":0.01}
// @input bool isDebug
// @input Asset.Material debugMaterial {"showIf":"isDebug"}
// @input SceneObject debugMesh {"showIf":"isDebug"}

function initialize() {

    if (!script.clothVisual) {
        print("ERROR: Please assign a Cloth Visual");
        return;
    }
    
    if (script.isDebug && !script.debugMaterial) {
        print("ERROR: Please assign a Debug Material");
        return;
    }
    
    if (script.isDebug && !script.debugMesh) {
        print("ERROR: Please assign a Debug Mesh Scene Object");
        return;
    }
    
    if(script.isDebug){
       script.debugMesh.enabled = true;
       script.debugMaterial.mainPass.distanceThreshold = script.bindDistance;  
       script.clothVisual.getSceneObject().enabled = false;
    }

    script.clothVisual.onInitialized = clothInitCallback;

}

function clothInitCallback(clothVisualArg) {

    if (script.overrideVertexSettings) {
        setFromVertexController(clothVisualArg);
    }
    
    clothVisualArg.resetSimulation();
}

function setFromVertexController(clothVisualArg) {

    var visData = script.clothVisual.mesh.extractVerticesForAttribute("externalMeshVisData");    

    for (var j = 0, k=0; j < visData.length; j+=2, k++) {         
        if (visData[j+1] < script.bindDistance) {                          
            clothVisualArg.setVertexBinding(k, script.getSceneObject());  
        }

    }
                
}

initialize();
