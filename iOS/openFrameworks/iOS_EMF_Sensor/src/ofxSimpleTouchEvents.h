#pragma once

class ofxSimpleTouchEvents {
	
public:
	
	bool						isTouching;
	unsigned long				touchStartMillis;
	bool						doDetectLongPress;
	ofEvent<unsigned long>		onLongPress;
	ofPoint						firstPosition;
	ofPoint						currentPosition;
	
	
	//--------------------------------------------------------------
	ofxSimpleTouchEvents()
	{
		isTouching = false;
		doDetectLongPress = false;
	}
	
	//--------------------------------------------------------------
	void update()
	{
		if (isTouching)
		{
			unsigned long now = ofGetElapsedTimeMillis();
			
			//LONGPRESS
			if (doDetectLongPress && (firstPosition == currentPosition) && now-touchStartMillis > 1000)
			{
				ofNotifyEvent(onLongPress, now);
				doDetectLongPress = false;
			}
		}
	}
	
	//--------------------------------------------------------------
	void touchDown(ofTouchEventArgs & touch)
	{
		touchStartMillis = ofGetElapsedTimeMillis();
		firstPosition.set(touch.x, touch.y);
		currentPosition.set(touch.x, touch.y);
		doDetectLongPress = true;
		isTouching = true;
	}
	
	//--------------------------------------------------------------
	void touchMoved(ofTouchEventArgs & touch)
	{
		isTouching = true;
		currentPosition.set(touch.x, touch.y);
	}
	
	//--------------------------------------------------------------
	void touchUp(ofTouchEventArgs & touch)
	{
		isTouching = false;
		currentPosition.set(touch.x, touch.y);
	}
	
	//--------------------------------------------------------------
	void touchDoubleTap(ofTouchEventArgs & touch)
	{
		isTouching = true;
	}
	
	//--------------------------------------------------------------
	void touchCancelled(ofTouchEventArgs & touch)
	{
		isTouching = false;
	}
	
};