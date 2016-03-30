#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
	
    ofSetFrameRate(30);
    ofBackground(0);
	ofSetCircleResolution(64);
	ofxiOSDisableIdleTimer();
	
	//TOUCH EVENTS
	ofAddListener(touchEvents.onLongPress, this, & ofApp::touchLongPress);
	
	//FONTS
	ofTrueTypeFont::setGlobalDpi(72);
	futura24.loadFont("fonts/FuturaStd-Book.ttf", 24, true, true);
	futura24.setLineHeight(18.0f);
	futura24.setLetterSpacing(1.037);
	
	ofLogNotice("width:" + ofToString(ofGetWidth()) + ", height:" + ofToString(ofGetHeight()));
	
	// load the gradient files
	for (int i = 0; i < NUM_GRADIENTS; i++) {
		gradients[i].loadImage("gradients/col" + ofToString(i) + ".png");
	}
	
	//------
	// attempt to load the settings
	ofLogNotice("loading mySettings.xml");
	if ( XML.loadFile(ofxiOSGetDocumentsDirectory() + XML_SETTINGS_FILE) ) {
		ofLogNotice("settings loaded from iOS documents");
	}
	else if ( XML.loadFile( XML_SETTINGS_FILE ) ) {
		ofLogNotice("settings loaded from data folder");
	}
	else {
		ofLogNotice("unable to load settings!");
	}
	//------
	
	setBaseButton.setFont(futura24);
	setBaseButton.setLabel("SET BASE");
	
	resetButton.setFont(futura24);
	resetButton.setLabel("RESET MIN/MAX");
	
	useMinMaxButton.setFont(futura24);
	useMinMaxButton.setLabel("USE MIN/MAX");
	
	minRange.set("MIN", XML.getValue("SENSOR:RANGE:MIN", 0), -2000, 0);
	minRangeSlider.setFont(futura24);
	minRangeSlider.setParameter(minRange);
	
	maxRange.set("MAX", XML.getValue("SENSOR:RANGE:MAX", 1), 1, 2000);
	maxRangeSlider.setFont(futura24);
	maxRangeSlider.setParameter(maxRange);
	
	minSize.set("MIN", XML.getValue("SHAPE:SIZE:MIN", 0), 1, ofGetWidth() * 0.5f );
	minSizeSlider.setFont(futura24);
	minSizeSlider.setParameter( minSize );
	
	maxSize.set( "MAX", XML.getValue("SHAPE:SIZE:MAX", ofGetWidth() * 0.5f), 1, ofGetWidth() * 0.5f );
	maxSizeSlider.setFont(futura24);
	maxSizeSlider.setParameter( maxSize );
	
	blinkSpeed.set("BLINK", XML.getValue("BLINK:SPEED", 1), 1, 30);
	blinkSpeedSlider.setFont(futura24);
	blinkSpeedSlider.setParameter(blinkSpeed);
	//-
	
	// setup starting values
	sensorBaseline = XML.getValue("SENSOR:REST", 0);
	activeGradient = XML.getValue("GRADIENT:ACTIVE_INDEX", 0);
	bBlinkOn = false;
	lineWeight.set(10); // default line weight
	drawingMode = DRAWING_MODE_A;
	
	// setup sensor
    coreMotion.setupMagnetometer();
}

//--------------------------------------------------------------
void ofApp::update(){
	
    coreMotion.update();
	
	// magnetometer data parse
	ofVec3f m = coreMotion.getMagnetometerData();
	magnitude = m.length()/10;
	
	// record the peak values
	if (magnitude-sensorBaseline > sensorMax) {
		sensorMax = magnitude-sensorBaseline;
	}
	else if (magnitude-sensorBaseline < sensorMin) {
		sensorMin = magnitude-sensorBaseline;
	}
	
	// convert the values in to usefulness
	int x = abs(magnitude - sensorBaseline);
	targetSize = ofMap(x, 0, maxRange, minSize, maxSize, true);
	currentSize += (targetSize - currentSize)  * EASING;
	//	blinkSpeed = ofMap(x, 0, maxRange, blinkSlowSpeed, blinkFastSpeed, true);
	
	touchEvents.update();
	
	/*if(bDoBlink) {
		if (!bBlinkOn && now - lastBlinkTime > blinkSpeed) {
			bBlinkOn = true;
			lastBlinkTime = now;
		}
		
		if (bBlinkOn && now - lastBlinkTime > 100) {
			bBlinkOn = false;
			lastBlinkTime = now;
		}
	}*/
}

//--------------------------------------------------------------
void ofApp::draw(){
	
	// decide what to draw
	switch (drawingMode) {
		case DRAWING_MODE_A:
			// grow a circle
			drawModeA();
			break;
			
		case DRAWING_MODE_B:
			// blink a circle
			drawModeB();
			break;
			
		case DRAWING_MODE_C:
			// draw a line
			drawModeC();
			break;
			
		default:
			// also DRAWING_MODE_CONTROLS
			// draw the controls
			drawController();
			break;
	}
}

//--------------------------------------------------------------
void ofApp::drawModeA() {
	
	ofPushStyle();
	
	// set colour based on gradient
	int x = ofMap(currentSize, minSize, maxSize, 1, 300);
	ofSetColor( gradients[activeGradient].getColor(x, 1) );
	
	// draw a circle in the middle of the screen
	ofCircle(ofGetWidth()/2, ofGetHeight()/2, currentSize);
	ofSetColor(0, 0, 0);
	ofCircle(ofGetWidth()/2, ofGetHeight()/2, currentSize-lineWeight);
	
	ofPopStyle();
}

//--------------------------------------------------------------
void ofApp::drawModeB() {
	
	ofPushStyle();
	
	// set colour based on gradient
	int x = ofMap(currentSize, minSize, maxSize, 1, 300);
	ofSetColor( gradients[activeGradient].getColor(x, 1) );
	
	// draw a circle but use the maxSize
	ofCircle(ofGetWidth()/2, ofGetHeight()/2, maxSize);
	
	ofPopStyle();
}

//--------------------------------------------------------------
void ofApp::drawModeC() {
	
	ofPushStyle();
	
	ofSetColor( 255,255,255 );
	ofCircle(ofGetWidth()/2, ofGetHeight()/2, maxSize);
	
	ofPopStyle();
}

//--------------------------------------------------------------

void ofApp::drawController() {
	
	//baseline
	ofPushStyle();
	ofSetColor(100);
	ofSetLineWidth(1);
	for (int i = 0; i < ofGetHeight(); i += 20) {
		//		ofLine(0, i, ofGetWidth(), i);
	}
	ofPopStyle();
	
	// titles
	futura24.drawString("ACTUAL", 0, 40);
	futura24.drawString("BASE", 160, 40);
	futura24.drawString("MIN", 320, 40);
	futura24.drawString("MAX", 480, 40);
	
	// numbers
	ofPushMatrix();
	ofTranslate(0, 80);
	futura24.drawString(ofToString(magnitude), 0, 0);
	futura24.drawString(ofToString(sensorBaseline), 160, 0);
	
	ofPushStyle();
	if (sensorMin < minRange) ofSetColor(255, 0, 0);
	futura24.drawString(ofToString(sensorBaseline + sensorMin), 320, 0);
	ofPopStyle();
	
	ofPushStyle();
	if (sensorMax > maxRange) ofSetColor(255, 0, 0);
	futura24.drawString(ofToString(sensorBaseline + sensorMax), 480, 0);
	ofPopStyle();
	
	ofPopMatrix();
	
	//buttons
	setBaseButton.setRect( 0, 120, 200, 80 );
	setBaseButton.draw();
	resetButton.setRect( 220, 120, 200, 80);
	resetButton.draw();
	useMinMaxButton.setRect( 440, 120, 200, 80 );
	useMinMaxButton.draw();
	
	// sliders
	futura24.drawString("SENSOR RANGE", 0, 260);
	
	minRangeSlider.setRect( 0, 280, 640, 80 );
	minRangeSlider.draw();
	maxRangeSlider.setRect( 0, 380, 640, 80 );
	maxRangeSlider.draw();
	
	futura24.drawString("CIRCLE", 0, 520);
	
	minSizeSlider.setRect( 0, 540, 640, 80 );
	minSizeSlider.draw();
	maxSizeSlider.setRect( 0, 640, 640, 80 );
	maxSizeSlider.draw();
	blinkSpeedSlider.setRect( 0, 740, 640, 80 );
	blinkSpeedSlider.draw();
	
	// gradients
	ofPushStyle();
	ofSetColor(255);
	ofRect(-3+(activeGradient*100), 850-3, 80+6, 80+6);
	for (int i = 0; i < NUM_GRADIENTS; i++) {
		gradients[i].draw(0+(i*100), 850, 80, 80 );
	}
	
	ofPopStyle();
}

//--------------------------------------------------------------
void ofApp::saveSettings(){
	// save the current settings
	XML.setValue("SENSOR:RANGE:MIN", minRange);
	XML.setValue("SENSOR:RANGE:MAX", maxRange);
	XML.setValue("SENSOR:REST", sensorBaseline);
	XML.setValue("SHAPE:SIZE:MIN", minSize);
	XML.setValue("SHAPE:SIZE:MAX", maxSize);
	XML.setValue("GRADIENT:ACTIVE_INDEX", activeGradient);
	if ( XML.saveFile( ofxiOSGetDocumentsDirectory() + XML_SETTINGS_FILE) )
	{
		ofLogNotice("saved settings to app documents folder");
	}
	else {
		ofLogNotice("unable to save settings");
	}
}

//--------------------------------------------------------------
void ofApp::exit(){
	ofLogNotice("exit");
	saveSettings();
}

//--------------------------------------------------------------
void ofApp::touchLongPress(unsigned long & e)
{
	if (drawingMode == DRAWING_MODE_CONTROLS)
	{
		// currently showing controls
		drawingMode = DRAWING_MODE_A;
		ofLogNotice( "hide the controls" );
	}
	else
	{
		// currently drawing
		drawingMode = 0;
		ofLogNotice( "show the controls" );
	}
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
	
	touchEvents.touchDown(touch);
	
	followTouch = true;
	touchStartMillis = ofGetElapsedTimeMillis();
	
	if(drawingMode == DRAWING_MODE_CONTROLS)
	{
		// tell all the sliders to listen
		minSizeSlider.touchDown(touch);
		maxSizeSlider.touchDown(touch);
		minRangeSlider.touchDown(touch);
		maxRangeSlider.touchDown(touch);
		blinkSpeedSlider.touchDown(touch);
	}
	
	lastTouchPoint.set(touch.x, touch.y);
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
	
	touchEvents.touchMoved(touch);
	
	if (followTouch)
	{
		// tell the buttons
		if ( (lastTouchPoint.x - touch.x) > 50 ) {
			ofLogNotice("swipe left");
			followTouch = false;
		}
		else if ( (lastTouchPoint.x - touch.x) < -50 ) {
			ofLogNotice("swipe right");
			followTouch = false;
		}
		else if ( (lastTouchPoint.y - touch.y) > 50 ) {
			ofLogNotice("swipe up");
			followTouch = false;
		}
		else if ( (lastTouchPoint.y - touch.y) < -50 ) {
			ofLogNotice("swipe down");
			followTouch = false;
		}
		
		// update
		lastTouchPoint.set(touch.x, touch.y);
	}
	
	if (drawingMode == DRAWING_MODE_CONTROLS)
	{
		// tell all the sliders to listen
		minSizeSlider.touchMoved(touch);
		maxSizeSlider.touchMoved(touch);
		minRangeSlider.touchMoved(touch);
		maxRangeSlider.touchMoved(touch);
		blinkSpeedSlider.touchMoved(touch);
	}
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
	//pass to controller
	touchEvents.touchUp(touch);
	
	followTouch = false;
	
	if(drawingMode == DRAWING_MODE_CONTROLS)
	{
		if ( resetButton.inside(touch.x, touch.y)) {
			sensorMin = 0;
			sensorMax = 0;
			ofLogNotice("reset sensor");
		}
		else if ( setBaseButton.inside(touch.x, touch.y) ) {
			sensorBaseline = magnitude;
			ofLogNotice("set baseline");
		}
		else if ( useMinMaxButton.inside(touch.x, touch.y) ) {
			minRange.set(sensorMin);
			maxRange.set(sensorMax);
			ofLogNotice("set min/max");
		}
		else {
			
			ofRectangle r = ofRectangle();
			for (int i = 0; i < NUM_GRADIENTS; i++) {
				
				r.set(i*100, 850, 60, 60);
				
				if (r.inside(touch.x, touch.y)) {
					activeGradient = i;
					ofLogNotice("activeGradient = " + ofToString(activeGradient));
				}
			}
		}
	}
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
	touchEvents.touchDoubleTap(touch);
	//do nothing
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
	touchEvents.touchCancelled(touch);
	followTouch = false;
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
	ofLogNotice("lostFocus");
	saveSettings();
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
	ofLogNotice("gotFocus");
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
	
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
	ofLogNotice("deviceOrientationChanged, new = " + ofToString(newOrientation)	);
}