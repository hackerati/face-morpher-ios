#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "ofxOpenCv.h"
#include "ofxCv.h"
#include "ofxFaceTracker.h"
#include "Clone.h"
#include "ofxTextParticle.h"

enum scene{
    
    ready,
    openCamera,
    preview,
    debugging
    
};

class ofApp : public ofxiOSApp {
    
public:
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    //specific
    void setMaskFaceTracker();
    void maskTakenPhoto(ofImage &input);
    void drawMaskOnInput(ofImage &input);
    
    void changeMesh();
    // this is for titleMesh
    
    ofImage         backgoundImage;
    ofImage         camera;
    ofImage         maskImage;
    
    ofFbo           cameraFbo;
    ofFbo           maskFbo;
    
    ofxFaceTracker  cameraFaceTracker;
    ofxFaceTracker  maskFaceTracker;
    
    vector<ofVec2f> maskPoints;
    
    bool            bTakenPhoto;
    bool            cloneReady;
    
    Clone           clone;
    scene           myScene;
    
    ofImage         maskedImage;
    
    vector<ofxTextParticle> titles;
    ofTrueTypeFont  font;
    ofMesh          originalTitleMesh, titleMesh;
    ofxFaceTracker  titleFaceTracker;
};


