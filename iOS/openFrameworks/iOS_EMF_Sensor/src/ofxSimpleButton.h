#pragma once

class ofxSimpleButton {
	
public:
	
	ofxSimpleButton(){
		_rect = ofRectangle();
	}
	
	void setFont(ofTrueTypeFont & f) {
		_font = &f;
	}
	
	void setLabel(string l){
		_label = l;
	}
	
	void setRect( float px, float py, float w, float h ){
		_rect.set(px, py, w, h);
	}
	
	void draw() {
		ofPushStyle();
		
		ofFill();
		ofSetColor(80);
		ofRect( _rect );
		ofNoFill();
		ofSetColor(255);
		ofRect( _rect );
		
		ofSetColor(255);
		ofRectangle rect = _font->getStringBoundingBox(_label, 0, 0);
		_font->drawString(_label, _rect.x + (_rect.width/2)-(rect.width/2), (_rect.y + rect.height) + (_rect.height/2) - (rect.height/2));
		
		ofPopStyle();
	}
	
	bool inside(float x, float y){
		return _rect.inside( x, y );
	}
	
private:

	ofTrueTypeFont* _font;
	string _label;
	ofRectangle _rect;
};