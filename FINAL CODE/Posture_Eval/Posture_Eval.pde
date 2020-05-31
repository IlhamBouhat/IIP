/**
 * Posture evaluation code
 * @author Ilham El Bouhattaoui, Luuk Stavenuiter, Nadine Schellekens
 * @id 1225930, 
 * date: 31/05/2020
 * 
 * The baseline for this code is the same as the Posture_Trainer code
 * One change is that it loads the model made in the Trainer code, and the data set, and will then do a live prediction under which label each scenario falls
 
 * Uses example codes from Rong Hao's github library for the course DBB220 Interactive Intelligent Products topic 3.1 and 8.2
 
 * Links to the source code: 
 *
 *
 *
 **/

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

/**
 * Setup for the evaluation code set
 * Defines libraries used, and which features are selected
 * Initialises serial communication
 * Loads the training set and the model
 * Evaluates the training set 
 **/
void setup() {
  size(640, 480);
  

  //initialises the video library and opencv library
  video = new Capture(this, 640/div, 480/div);
  opencv = new OpenCV(this, 640/div, 480/div);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  video.start();

  loadTrainARFF(dataset="accData.arff"); //load a ARFF dataset
  loadModel(model="LinearSVC.model"); //load a pretrained model.
  evaluateTrainSet(fold = 5, isRegression = false, showEvalDetails=true); 
  
  //initialises the Serial communication. Each time Arduino sends a value, that value is loaded in a list
  for (int i = 0; i < Serial.list().length; i++) println("[", i, "]:", Serial.list()[i]);
  String portName = Serial.list()[Serial.list().length-1];
  port = new Serial(this, portName, 115200);
  port.bufferUntil('\n'); // arduino ends each data packet with a carriage return 
  port.clear(); 
  
  background(52);
}

/**
 * draw method 
 * reads the width from the webcam and the distance from the IR sensor
 * it then predicts the label {@code Y} as A or B 
 **/

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

    //predicts the label and reads it out real time on the screen 
    float[] X = {features[i].width, rawData}; 
    String Y = getPrediction(X);
    textSize(12);
    textAlign(CENTER, CENTER);
    String text = "Prediction: "+Y+
      "\n X="+features[i].width+
      "\n Y="+rawData;

    text(text, 40, 50);
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


    println(features[i].width, rawData, Y);
  }
  popMatrix();
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
