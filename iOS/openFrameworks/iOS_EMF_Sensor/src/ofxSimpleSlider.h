#pragma once

class ofxSimpleSlider {
	
public:
	
	ofxSimpleSlider(){
		_rect = ofRectangle();
	}
	
	void setFont(ofTrueTypeFont & f) {
		_font = &f;
	}
	
	void setParameter( ofParameter<float> & p){
		_parameter = &p;
	}
	
	void setRect( float px, float py, float w, float h ){
		_rect.set(px, py, w, h);
	}
	
	void draw(){
		
		ofPushMatrix();
		ofTranslate(_rect.x, _rect.y);
		
		ofPushStyle();
		
		ofFill();
		ofSetColor(80);
		ofRect( 0, 0, _rect.width, _rect.height );
		ofSetColor(60);
		ofRect( 0, 0, _rect.width, 20 );
		ofSetColor(255);
		ofRect( 0, 0, ofMap(_parameter->get(), _parameter->getMin(), _parameter->getMax(), 0, _rect.width), 20 );
		_font->drawString(_parameter->getName()+" ["+ofToString(_parameter->get()) + "]", 4, 50);
		
		ofPopStyle();
		ofPopMatrix();
	}
	
	void touchDown(ofTouchEventArgs & touch){
		if ( _rect.inside( touch.x, touch.y ) ) {
			// it's definately this slider, update
			_parameter->set( ofMap(touch.x, _rect.x, _rect.x+_rect.width, _parameter->getMin(), _parameter->getMax()) );
		}
	}
	
	void touchMoved(ofTouchEventArgs & touch){
		if ( _rect.inside( touch.x, touch.y ) ) {
			// it's definately this slider, update
			_parameter->set( ofMap(touch.x, _rect.x, _rect.x+_rect.width, _parameter->getMin(), _parameter->getMax()) );
			
			if ( touch.x-_rect.x < 7 ) {
				_parameter->set(_parameter->getMin());
			}
			else if ( (_rect.x+_rect.width)-touch.x < 7 ) {
				_parameter->set(_parameter->getMax());
			}
		}
	}
	
private:
	
	ofTrueTypeFont* _font;
	ofParameter<float>* _parameter;
	ofRectangle _rect;
	
};