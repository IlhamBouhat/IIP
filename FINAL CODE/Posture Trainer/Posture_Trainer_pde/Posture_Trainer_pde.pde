import processing.serial.*;
Serial port; 

import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

int div = 2;
PImage src, threshBlur, dst;
int blurSize = 12;
int grayThreshold = 80;

int sensorNum = 1;
int rawData;
boolean dataUpdated = false;


ArrayList<Contour> contours;

String featureText = "Face";

int dataNum = 1;
int dataIndex = 0;


void setup() {
  size(640, 480);
  for (int i = 0; i < Serial.list().length; i++) println("[", i, "]:", Serial.list()[i]);
  String portName = Serial.list()[Serial.list().length-1];
  port = new Serial(this, portName, 115200);
  port.bufferUntil('\n'); // arduino ends each data packet with a carriage return 
  port.clear(); 

  video = new Capture(this, 640/div, 480/div);
  opencv = new OpenCV(this, 640/div, 480/div);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  video.start();
  loadTrainARFF(dataset="accData.arff"); //load a ARFF dataset
  println(train);
  trainLinearSVC(C=64);               //train a KNN classifier
  //setModelDrawing(unit=2); //set the model visualization (for 2D features)
  evaluateTrainSet(fold=5, showEvalDetails=true);  //5-fold cross validation
  saveSVC(model="LinearSVC.model"); //save the model

  background(52);
}


void draw() {
  background(0);
  pushMatrix();
  scale(2);

  //https://github.com/atduskgreg/opencv-processing/blob/master/src/gab/opencv/OpenCV.java

  featureText = "Face";   
  opencv.loadImage(video);
  opencv.useColor();
  src = opencv.getSnapshot();
  image(src, 0, 0);

  Rectangle[] features = opencv.detect();

  // draw detected face area(s)
  for ( int i=0; i<features.length; i++ ) {
    noFill();
    stroke(255, 0, 0);
    rect( features[i].x, features[i].y, features[i].width, features[i].height );
    noStroke();
    fill(255);
    text(featureText, features[i].x, features[i].y-20);
    //println(features[i].x, features[i].y, features[i].width, features[i].height);

    if (dataUpdated) {
      background(52);
      fill(255);
      float[] X = {features[i].width, rawData}; 
      String Y = getPrediction(X);
      textSize(32);
      textAlign(CENTER, CENTER);
      String text = "Prediction: "+Y+
        "\n X="+features[i].width+
        "\n Y="+rawData;

      text(text, width/2, height/2);
      switch(Y) {
      case "A": 
        port.write('a'); 
        break;
      case "B": 
        port.write('b'); 
        break;
      default: 
        break;
      }
      dataUpdated = false;
      //println(features[i].width, rawData, Y);
    }
  }
  popMatrix();
  //drawMouseCursor(labelIndex);
}

void serialEvent(Serial port) {
  String inData = port.readStringUntil('\n');
  if (inData.charAt(0) == 'A') {
    rawData = int(trim(inData.substring(1)));
    //println(rawData);
  }
  if (rawData >= 900) {
    port.write('a');
  } else {
    port.write('b');
  }
  return;
}

void captureEvent(Capture c) {
  c.read();
}
