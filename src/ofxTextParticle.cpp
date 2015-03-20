//
//  ofxTextParticle.cpp
//  FaceSubstitutionCamera
//
//  Created by James Lilard on 2014/10/30.
//
//

#include "ofxTextParticle.h"

void ofxTextParticle::setup(string _text, ofPoint _center){

    // this is setting for particle.
    float particleRadius = 1.;
    ofColor particleColor= ofColor::white;
    
    
    // this is setting for textParticle.
    myFont.loadFont("Sketch_Block.ttf", 32,true, true, true, 0.3, 0);
    
    setString(_text);
    center = _center;
    threshold = 3.0;

    vector<ofTTFCharacter> str = myFont.getStringAsPoints(text);
    
    ofPoint textCenter = ofPoint(myFont.stringWidth(text)/2., myFont.stringHeight(text)/2.);
    ofPoint shift = center - textCenter;
    
    // this loop is for each string.
    for(int i=0;i<str.size();i++){
    
        // this loop is for each character's outlines.
        for(int j=0;j<str[i].getOutline().size();j++){
        
            ofPoint first, prev, prev2;
            
            // this loop is for each outline's points.
            for(int k=0;k<=str[i].getOutline()[j].size();k++){
            
                ofVec2f pos;
                
                if(k<str[i].getOutline()[j].size()){
                
                    pos = ofPoint(str[i].getOutline()[j].getVertices()[k]);
                    
                    
                }
                else{
                
                    pos = first;
                    
                }
                
                if(k == 0){
                
                    first = pos;
                    
                    prev  = pos;
                    
                    prev2 = pos;
                }
                else{
                
                    float length = diffPoints(pos, prev);
                    
                    
                    float addX = (pos.x - prev.x)*(particleRadius/length);
                    float addY = (pos.y - prev.y)*(particleRadius/length);
                    
                    for(int n=0;n<(length/particleRadius);n++){
                        
                        prev+=ofPoint(addX, addY);
                        
                        float diff = diffPoints(prev, prev2);
                        if(diff > threshold){
                            Particle tmpPartcle;
                            tmpPartcle.setup(shift+prev, particleRadius, particleColor);
                            particles.push_back(tmpPartcle);
                            prev2 = prev;
                        }
                        
                    }
                    
                    
                    
                    prev = pos;
                    
                }
                
                
            }
            
        }
        
    }
}

void ofxTextParticle::update(){
    
    for(int i=0;i<particles.size();i++){
    
        
        
    }

}

void ofxTextParticle::draw(){
    
    for(int i=0;i<particles.size();i++){
    
        particles[i].draw();
        
    }

    
}

void ofxTextParticle::noiseDraw(){

    for(int i=0;i<particles.size();i++){
    
        particles[i].noiseDraw();
        
    }
    
}



void ofxTextParticle::setString(string _text){

    text = _text;
    
}

float ofxTextParticle::diffPoints(ofPoint p1, ofPoint p2){

    return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
    
}

