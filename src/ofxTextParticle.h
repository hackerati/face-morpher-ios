//
//  ofxTextParticle.h
//  FaceSubstitutionCamera
//
//  Created by James Lilard on 2014/10/30.
//
//

#ifndef __FaceSubstitutionCamera__ofxTextParticle__
#define __FaceSubstitutionCamera__ofxTextParticle__

#include "ofMain.h"

class Particle{

public:
    
    void setup(ofPoint _center, float _radius, ofColor _color){
    
        center = _center;
        radius = _radius;
        color  = _color;
        
    }
    
    void setVel(ofVec2f _vel){
    
        vel = _vel;
        
    }
    
    void update(){}
    
    void draw(){
    
        ofPushStyle();
        
        ofSetColor(color);
        
        ofCircle(center, radius);
        
        ofPopStyle();
        
    }
    
    void noiseDraw(){
        ofPushStyle();
        
        ofSetColor(color);
        
        ofPoint noisedCenter = center + ofNoise(ofRandom(10), ofRandom(10))*5;

        ofCircle(noisedCenter, radius);
        
        ofPopStyle();
        
        
    }
    
    
private:
    ofPoint center;
    float   radius;
    ofColor color;
    
    ofVec2f vel;
    
};

class ofxTextParticle{
public:
    void setup(string _text, ofPoint _center);
    void update();
    void draw();
    void noiseDraw();
    
    void setString(string _text);
    
    
private:
    float diffPoints(ofPoint p1, ofPoint p2);
    
    ofPoint        center;
    
    ofTrueTypeFont myFont;
    string text;
    vector<Particle>    particles;
    
    float           threshold;
    
};

#endif /* defined(__FaceSubstitutionCamera__ofxTextParticle__) */
