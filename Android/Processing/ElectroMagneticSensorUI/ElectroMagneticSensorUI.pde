import controlP5.*;
import ketai.sensors.*;
import ketai.ui.*;
import android.view.MotionEvent;
import java.io.File;

ControlP5 cp5;
RadioButton r;
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
int hueStart = 90;
int hueEnd = 0;
int saturation = 255;
int brightness = 255;

void setup() {
  orientation(PORTRAIT);
  frameRate(30);
  colorMode(HSB,360,255,255);

  displayMode = 0;
  currentSize = 0;
  targetSize = 0;
  configFilename = "\\sdcard\\config2.xml";

  println(">>>> SETUP <<<<<");

  // first load the settings from the xml before initialising ControlP5
  loadConfigSettings();

  int w = int(width*0.66);
  int h = 50;
  PFont p = createFont("Arial",20);
  


  cp5 = new ControlP5(this);
  cp5.setControlFont(p);
  
  cp5.addTab("drawing")
     .setWidth(width/2)
     .setHeight(100)
     ;
     
  // if you want to receive a controlEvent when
  // a  tab is clicked, use activeEvent(true)
  
  cp5.getTab("default")
     .activateEvent(true)
     .setLabel("sensor")
     .setColorBackground(color(110))
     .setColorForeground(color(110))
     .setColorActive(color(170))
     .setWidth(width/2)
     .setHeight(100)
     .activateEvent(true)
     .setId(1)
     ;

  cp5.getTab("drawing")
     .activateEvent(true)
     .setColorBackground(color(110))
     .setColorForeground(color(110))
     .setColorActive(color(170))
     .setId(2)
     ;
  //These are in tab Sensor
  cp5.addSlider("minRange").setPosition(10, 120).setRange(0, 2000).setValue(minRange).setWidth(w).setHeight(h);
  cp5.addSlider("maxRange").setPosition(10, 1*(h+20)+120).setRange(0, 2000).setValue(maxRange).setWidth(w).setHeight(h);
  cp5.addSlider("calibration").setPosition(10, 2*(h+20)+120).setRange(0, 100).setValue(calibration).setWidth(w).setHeight(h);

  //These are in tab Drawing
  cp5.addSlider("minSize").setPosition(10, 120).setRange(0, height).setValue(minSize).setWidth(w).setHeight(h);
  cp5.addSlider("maxSize").setPosition(10, 1*(h+20)+120).setRange(0, height).setValue(maxSize).setWidth(w).setHeight(h);
  cp5.addSlider("easing").setPosition(10, 2*(h+20)+120).setRange(0.001, 0.999).setValue(easing).setWidth(w).setHeight(h);
  cp5.addSlider("speed").setPosition(10, 3*(h+20)+120).setRange(0.1, 30).setValue(speed).setWidth(w).setHeight(h);
  
  cp5.addTextlabel("label1")
                    .setText("Select gradient")
                    .setPosition(10, 4*(h+20)+120)
                    ;
                    
  r = cp5.addRadioButton("colors")
         .setPosition(10, 4*(h+20)+120)
         .setSize(50,50) 
         .setColorForeground(color(120))
         .setColorActive(color(255))
         .setColorLabel(color(255))
         .setItemsPerRow(5)
         .setSpacingColumn(50)
         .addItem("W",1)
         .addItem("C1",2)
         .addItem("C2",3)
         .addItem("C3",4)
         ;
  int i=0; 
  
  //Set the backgrounds for the gradient picker radio buttons  
  for(Toggle t:r.getItems()) {
         t.setImages(loadImage("col"+i+"-off.png"),loadImage("col"+i+"-off.png"),loadImage("col"+i+"-on.png"));
         i++;
       }
  
  //Sending some of the controllers to relevant tabs.      
  cp5.getController("minSize").moveTo("drawing");  
  cp5.getController("maxSize").moveTo("drawing"); 
  cp5.getController("easing").moveTo("drawing");
  cp5.getController("speed").moveTo("drawing");
  cp5.getController("label1").moveTo("drawing");
  
  magnitude = new PVector(0, 0, 0);

  gesture = new KetaiGesture(this);
  sensor = new KetaiSensor(this);
  sensor.start();

  textAlign(LEFT, TOP);
  textSize(30);
}

void draw() {
  background(170);

  pushMatrix();
  translate(width/2, height/2);

  currentSize += (targetSize - currentSize)  * easing;
  currentSize = constrain(currentSize, minSize, maxSize-12);
  color col = color(map(currentSize, minSize, maxSize, hueStart,hueEnd), saturation, brightness);

  switch(displayMode) {
    
  case 0 :
    // an bottom aligned outlined circle
    background(0);
    fill(col, 50);
    stroke(col);
    strokeWeight(12);
    ellipse(0, (height/2) - (currentSize/2) - 6, currentSize, currentSize);
    break;
    
  case 1 :
    // a fixed size, flashing circle that changes colour
    if (frameCount % speed == 0) {
      background(0);
      noStroke();
      fill(col);
      ellipse(0, 0, maxSize, maxSize);
    }
    break;
  }

  popMatrix();

  // DEBUGGING
  if (cp5.isVisible()) {
    stroke(170);
    noFill();
    rect(0,100,width,height-100);
    fill(255, 255);
    text("Magnetometer(x , y , z) \n" + 
      nfp(magnitude.x, 1, 3) + "                  " +
      nfp(magnitude.y, 1, 3) + "                  " +
      nfp(magnitude.z, 1, 3) + "\n\n" +
      "Magnitude " + "\n" + (magnitude.mag() - calibration) + "\n\n" + 
      "CurrentSize: " + "\n" + currentSize, 10, (2*height)/3, width, height);
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

void onLongPress( float x, float y) {
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
    minRange = 10;
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

void colors(int a) {
  switch(a){

      case 1: hueStart = 0;
              hueEnd = 0;
              saturation = 0;
              brightness = 255;
              break; 
              
      case 2: hueStart = 90;
              hueEnd = 0;
              saturation = 255;
              break;
              
      case 3: hueStart = 220;
              hueEnd = 310;
              saturation = 255;
              break;  
              
      case 4: hueStart = 170;
              hueEnd = 260;
              saturation = 255;
              break;
     
      default: break;
  }
}


