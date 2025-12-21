// ColliderSettingForChildObjects.js
// Version 0.1.0
// Event : onAwake
// Overwrite Physics Collider Settings for all full body colliders in the Collider Guides
//@input bool setWorldSetting
//@input Physics.WorldSettingsAsset worldSettingAsset {"showIf":"setWorldSetting"}
//@input bool setMatter
//@input Physics.Matter matter {"showIf":"setMatter"}
//@input bool intangible
//@input bool showColliders
//@input bool enableSmoothing 
//@input float translateSmoothFactor {"showIf":"enableSmoothing"}
//@input float rotateSmoothFactor {"showIf":"enableSmoothing"}

var obj = script.getSceneObject();
var childCount = obj.getChildrenCount();

var colliders = [];
for (var i = 0; i<childCount;i++) {
    colliders.push(obj.getChild(i).getChild(0).getComponent("Physics.ColliderComponent"));
}

function findParentWithComponentType(childObject, componentType) {
    
    while (childObject.getParent() != null) {
        var componets = childObject.getParent().getComponents(componentType);
        for (var i =0; i<componets.length;i++) {
            var component = childObject.getParent().getComponents(componentType)[i];
            return component;
        }

        childObject = childObject.getParent();
    }
    print("ERROR: Can't find ObjectTracking3D Component in parent objects");
    return null;
}

var bodyTrackingComponent = findParentWithComponentType(obj,"Component.ObjectTracking3D");
if (bodyTrackingComponent) {
    bodyTrackingComponent.attachmentModeInheritScale = true;
}



if (script.setWorldSetting) {
    if (!script.worldSettingAsset) {
        print("ERROR: World Setting is not set");
        return;
    }
    setWorld(script.worldSettingAsset);
}

if (script.setMatter) {
    if (!script.matter) {
        print("ERROR: Physics Matter is not set");
        return;
    }
    setMatter(script.matter);
}

setIntangible(script.intangible);
setDebugDraw(script.showColliders);
setSmoothing(script.enableSmoothing,script.translateSmoothFactor,script.rotateSmoothFactor);

function setMatter(matter) {
    for (var i = 0; i < colliders.length ; i++) {
        colliders[i].matter = matter;
    }  
}

function setWorld(world) {
    for (var i = 0; i < colliders.length ; i++) {
        colliders[i].worldSettings = world;
    }  
}

function setIntangible(intangible) {
    for (var i = 0; i < colliders.length ; i++) {
        colliders[i].intangible = intangible;
    }  
}

function setDebugDraw(debugDrawEnabled) {
    for (var i = 0; i < colliders.length ; i++) {
        colliders[i].debugDrawEnabled = debugDrawEnabled;
    }  
}

function setSmoothing(smooth, posTension,rotTension) {
    for (var i = 0; i < colliders.length; i++) {
        colliders[i].smooth = smooth;
        if (smooth) {
            colliders[i].translateSmoothFactor = posTension;
            colliders[i].rotateSmoothFactor = rotTension;            
        }
       
    }  
}
