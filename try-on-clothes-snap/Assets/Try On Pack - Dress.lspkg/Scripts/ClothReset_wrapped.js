function scriptBody(script){ 
// ClothReset.js
// Version: 0.1.0
// Event: Lens Tapped
// Description: Reset Cloth Simulation on tap


if (script.clothVisuals.length===0) {
    print("ERROR: Make sure to assign Cloth Visual Component");
    return;
}

for(var i = 0; i<script.clothVisuals.length; i++){
    if (script.clothVisuals[i].getSceneObject().enabled) {
        script.clothVisuals[i].resetSimulation();
        print("Reset UI cloth simiulation on tap");   
    }    
}




 }; module.exports = scriptBody;