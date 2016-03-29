#pragma once

#include "ofMain.h"
#include "ofEvents.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "ofxCoreMotion.h"
#include "ofxXmlSettings.h"
#include "ofxSimpleButton.h"
#include "ofxSimpleSlider.h"
#include "ofxSimpleTouchEvents.h"

#define EASING 0.5 //[0.001, 0.999]
#define NUM_GRADIENTS 4
#define XML_SETTINGS_FILE "mySettings.xml"

#define DRAWING_MODE_A 1
#define DRAWING_MODE_B 2
#define DRAWING_MODE_C 3
#define DRAWING_MODE_CONTROLS 0

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
	void touchLongPress(unsigned long & e);
	
	void lostFocus();
	void gotFocus();
	void gotMemoryWarning();
	void deviceOrientationChanged(int newOrientation);
	
	
	// Settings
	ofxXmlSettings XML;
	ofParameter<int>	lineWeight;
	ofParameter<float>	minRange;
	ofParameter<float>	maxRange;
	ofParameter<float>	minSize;
	ofParameter<float>	maxSize;
	ofParameter<bool>	bDoBlink;
	ofParameter<float>	blinkSpeed;
	
	
	// sensor values
	ofxCoreMotion coreMotion;
	int magnitude;
	int sensorBaseline;
	int sensorMin;
	int sensorMax;
	int targetSize;
	int currentSize;
	
	//Touch
	ofxSimpleTouchEvents touchEvents;
	
	// Interface values
	unsigned long touchStartMillis;
	int drawingMode;
	bool followTouch;
	ofPoint lastTouchPoint;
	
	ofTrueTypeFont futura24;
	
	// custom methods
	void drawModeA();
	void drawModeB();
	void drawModeC();
	void drawController();
	
	void onSwipe(int direction, ofTouchEventArgs & touch);
	void saveSettings();
		
	// GUI
	ofxSimpleButton resetButton;
	ofxSimpleButton setBaseButton;
	ofxSimpleButton useMinMaxButton;
	
	ofxSimpleSlider minSizeSlider;
	ofxSimpleSlider maxSizeSlider;
	ofxSimpleSlider minRangeSlider;
	ofxSimpleSlider maxRangeSlider;
	ofxSimpleSlider blinkSpeedSlider;
	
	// gradient images to colourpick
	ofImage gradients[NUM_GRADIENTS];
	int activeGradient;
	bool bBlinkOn;
	unsigned long lastBlinkTime;
	
};