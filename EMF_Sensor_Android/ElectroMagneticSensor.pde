import controlP5.*;
import ketai.sensors.*;
import ketai.ui.*;
import android.view.MotionEvent;
import java.io.File;

ControlP5 cp5;
KetaiSensor sensor;
KetaiGesture gesture;

XML xml;
PVector magnitude;
int minRange, maxRange;
int minSize, maxSize;
float targetSize, currentSize;
float easing;
int calibration;
float rotation;
int speed;
String configFilename;
int displayMode;

void setup() {
  orientation(LANDSCAPE);
  frameRate(30);
  colorMode(HSB);

  displayMode = 0;
  currentSize = 0;
  targetSize = 0;
  configFilename = "\\sdcard\\config2.xml";

  println(">>>> SETUP <<<<<");

  // first load the settings from the xml before initialising ControlP5
  loadConfigSettings();

  int w = int(width * 0.4);
  int h = 50;

  println("I'm settin minRange to " + minRange);

  cp5 = new ControlP5(this);
  cp5.addSlider("minRange").setPosition(0, 0).setRange(0, 2000).setValue(minRange).setWidth(w).setHeight(h);
  cp5.addSlider("maxRange").setPosition(0, h*1).setRange(0, 2000).setValue(maxRange).setWidth(w).setHeight(h);
  cp5.addSlider("minSize").setPosition(0, h*2).setRange(0, height).setValue(minSize).setWidth(w).setHeight(h);
  cp5.addSlider("maxSize").setPosition(0, h*3).setRange(0, height).setValue(maxSize).setWidth(w).setHeight(h);
  cp5.addSlider("easing").setPosition(0, h*4).setRange(0.001, 0.999).setValue(easing).setWidth(w).setHeight(h);
  cp5.addSlider("calibration").setPosition(0, h*5).setRange(0, 100).setValue(calibration).setWidth(w).setHeight(h);
  cp5.addSlider("speed").setPosition(0, h*6).setRange(0.1, 30).setValue(speed).setWidth(w).setHeight(h);

  magnitude = new PVector(0, 0, 0);

  gesture = new KetaiGesture(this);
  sensor = new KetaiSensor(this);
  sensor.start();

  textAlign(RIGHT, TOP);
  textSize(36);
}

void draw() {
  background(0);

  pushMatrix();
  translate(width/2, height/2);

  currentSize += (targetSize - currentSize)  * easing;
  currentSize = constrain(currentSize, minSize, maxSize-12);
  color col = color(map(currentSize, minSize, maxSize, 90, 0), 255, 255);

  switch(displayMode) {
    
  case 0 :
    // an bottom aligned outlined circle
    fill(col, 50);
    stroke(col);
    strokeWeight(12);
    ellipse(0, (height/2) - (currentSize/2) - 6, currentSize, currentSize);
    break;
    
  case 1 :
    // a fixed size, flashing circle that changes colour
    if (frameCount % speed == 0) {
      noStroke();
      fill(col);
      ellipse(0, 0, maxSize, maxSize);
    }
    break;
  }

  popMatrix();

  // DEBUGGING
  if (cp5.isVisible()) {
    fill(255, 255);
    text("magnetism: \n" + 
      "x: " + nfp(magnitude.x, 1, 3) + "\n" +
      "y: " + nfp(magnitude.y, 1, 3) + "\n" +
      "z: " + nfp(magnitude.z, 1, 3) + "\n" +
      "magnitude: " + (magnitude.mag() - calibration) + "\n" + 
      "currentSize: " + currentSize, 0, 0, width, height);
  }
}

void onMagneticFieldEvent(float x, float y, float z, long time, int accuracy) {
  if (accuracy >= 0) {
    magnitude.set(x, y, z);

    // update the target size
    targetSize = map(magnitude.mag() - calibration, minRange, maxRange, minSize, maxSize);
  }
}

void onDoubleTap(float x, float y) {
  if (cp5.isVisible()) {
    cp5.hide();
  }
  else {
    cp5.show();
  }
}

void onFlick( float x, float y, float px, float py, float v) {
  displayMode = (displayMode + 1) % 2;
  println(displayMode);
}

void stop() {
  sensor.stop();

  // save the current settings
  XML saveData = createXML("config");
  XML save_minRange = saveData.addChild("minRange");
  XML save_maxRange = saveData.addChild("maxRange");
  XML save_minSize = saveData.addChild("minSize");
  XML save_maxSize = saveData.addChild("maxSize");
  XML save_easing = saveData.addChild("easing");
  XML save_calibration = saveData.addChild("calibration");
  XML save_speed = saveData.addChild("speed");

  save_minRange.setInt("value", minRange);
  save_maxRange.setInt("value", maxRange);
  save_minSize.setInt("value", minSize);
  save_maxSize.setInt("value", maxSize);
  save_easing.setFloat("value", easing);
  save_calibration.setInt("value", calibration);
  save_speed.setInt("value", speed);

  println(saveData);
  saveXML(saveData, configFilename);

  println(">>>> STOP <<<<<");

  super.stop();
}

void loadConfigSettings() {
  try {
    xml = loadXML(configFilename);
    minRange = xml.getChild("minRange").getInt("value");
    maxRange = xml.getChild("maxRange").getInt("value");
    minSize = xml.getChild("minSize").getInt("value");
    maxSize = xml.getChild("maxSize").getInt("value");
    easing = xml.getChild("easing").getFloat("value");
    calibration = xml.getChild("calibration").getInt("value");
    speed = xml.getChild("speed").getInt("value");
    println(">>>>> data exists, load from xml");
    println(xml);
  }
  catch(NullPointerException e) {
    minRange = 100;
    maxRange = 1000;
    minSize = 1;
    maxSize = 100;
    easing = 0.4;
    calibration = 45;
    speed = 1;
    println("no data exists, use defaults");
  }
}

public boolean surfaceTouchEvent(MotionEvent event) {
  //call to keep mouseX, mouseY, etc updated
  super.surfaceTouchEvent(event);

  //forward event to class for processing
  return gesture.surfaceTouchEvent(event);
}

