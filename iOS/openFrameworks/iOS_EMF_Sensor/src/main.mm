#include "ofMain.h"
#include "ofApp.h"

int main(){
	
	ofAppiOSWindow * iOSWindow = new ofAppiOSWindow();
	ofSetupOpenGL(iOSWindow, 1024, 768, OF_FULLSCREEN);
	
	iOSWindow->enableDepthBuffer();
	iOSWindow->enableRetina();
	iOSWindow->enableAntiAliasing(2);
	
	ofRunApp(new ofApp());
}
