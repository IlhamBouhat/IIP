

/**
 * Posture evaluation code
 * @author Ilham El Bouhattaoui, Luuk Stavenuiter, Nadine Schellekens
 * @id 1225930, 
 * date: 31/05/2020
 * 
 * The baseline for this code is the same as the Posture_Trainer code
 * One change is that it loads the model made in the Trainer code, and the data set, and will then do a live prediction under which label each scenario falls
 
 * Uses example codes from the github library for the course DBB220 Interactive Intelligent Products topic 2.2, 3.1 and 8.2
 
 * Links to the source code: 
 * https://github.com/howieliang/IIP1920/tree/master/Example%20Codes/2_2_Serial_Communication/Processing/p2_2c_SaveSerialAsARFF_A012
 * https://github.com/howieliang/IIP1920/tree/master/Example%20Codes/3_1_Linear_Support_Vector_Classification/Processing/p3_1b_loadLSVC
 * https://github.com/howieliang/IIP1920/tree/master/Example%20Codes/8_2_Camera_Based_Activity_Recognition/t3_FaceDetection/HAARCascade
 * https://github.com/howieliang/IIP1920/tree/master/Example%20Codes/8_2_Camera_Based_Activity_Recognition/t3_FaceDetection/SaveARFF_FaceRecognition
 * https://github.com/howieliang/IIP1920/tree/master/Example%20Codes/8_2_Camera_Based_Activity_Recognition/t3_FaceDetection/TrainLSVC_FaceRecognition
 **/

import processing.serial.*;
Serial port; 
import gab.opencv.*;
import processing.video.*;
import processing.sound.*;
import java.awt.*;



ArrayList<Attribute>[] attributes = new ArrayList[2];
Instances[] instances = new Instances[2];
Classifier[] classifiers = new Classifier[2];

Capture video;
OpenCV opencv;

int div = 2;
PImage src, threshBlur, dst;
int blurSize = 12;
int grayThreshold = 80;


boolean dataUpdated = false;

ArrayList<Contour> contours;

String featureText = "Face";

int dataSet = 0;
int dataNum = 100;
int sensorNum = 3;
int dataIndex = 0;
int rawData;
int[][] accData = new int[sensorNum][dataNum];
int count = 0; 

boolean slouch = false; 
boolean read = true; 
SoundFile wiiFitTrainer; 

/**
 * Setup for the evaluation code set
 * Defines libraries used, and which features are selected
 * Initialises serial communication
 * Loads the training set and the model
 * Evaluates the training set 
 **/

void settings () {
  size(640, 480);
} 
void setup() {
  wiiFitTrainer = new SoundFile(this, "WiiFit.wav");


  //initialises the video library and opencv library
  video = new Capture(this, 640/div, 480/div);
  opencv = new OpenCV(this, 640/div, 480/div);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  video.start();




  //initialises the Serial communication. Each time Arduino sends a value, that value is loaded in a list
  for (int i = 0; i < Serial.list().length; i++) println("[", i, "]:", Serial.list()[i]);
  String portName = Serial.list()[Serial.list().length-1];
  port = new Serial(this, portName, 115200);
  port.bufferUntil('\n'); // arduino ends each data packet with a carriage return 
  port.clear(); 


  instances[0] = loadTrainARFFToInstances(dataset="PostureTrainData.arff");

  attributes[0] = loadAttributesFromInstances(instances[0]);


  classifiers[0] = loadModelToClassifier(model="Regressor.model"); //load a pretrained model.


  background(52);
  noLoop();
}

/**
 * draw method 
 * reads the width from the webcam and the distance from the IR sensor
 * it then predicts the label {@code Y} as A or B 
 **/

void draw() {
  loop();
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
    loop();
    noFill();
    stroke(255, 0, 0);
    rect( features[i].x, features[i].y, features[i].width, features[i].height );
    noStroke();
    noFill();
    stroke(0,0,0);
    rect( 0, 0, 20, 80);
    noStroke();
    fill(255,0,0);
    stroke(255,0,0);
    rect(0, (180-features[i].width), 20, 5);
    text(featureText, features[i].x, features[i].y-20);

    //predicts the label and reads it out real time on the screen 
    float[] X = {features[i].width, rawData}; 
    double Y = getPredictionIndex(X, classifiers[0], attributes[0]);
    /*textSize(12);
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
     } */

    if (Y >= 0.2) {
      //loop();
      count++;
      if (count >10) {
        slouch = true;
        count = 0;
        if (slouch == true) { 
          noLoop();
          println("doe normaal");
          PopupWindow window = new PopupWindow();
          runSketch(new String[]{"PopupWindow"}, window);
          read = false;
        }
      }
    }
    println(features[i].width, rawData, Y);
  }

  popMatrix();
}

class PopupWindow extends PApplet {
  public void settings() {
    size(640, 480);
  }

  public void setup () {
    instances[1] = loadTrainARFFToInstances(dataset="AccData.arff");
    attributes[1] = loadAttributesFromInstances(instances[1]);
    classifiers[1] = loadModelToClassifier(model="LinearSVC.model"); //load a pretrained model.
    wiiFitTrainer.play();
    noLoop();
  } 

  public void draw() {
    loop();
    background(0, 0, 0);
    stroke(255,0,0);
    fill(255,0,0);
    rect(195, 210, 160, 60);
    triangle(445,180,535,240,445,300);
    rect(285,210,160,60);
    triangle(195,180,105,240,195,300);
    rect(290,145,60,160);
    triangle(260,145,380,145,320,35); 
    for (int n = dataSet; n <dataIndex; n++) {
      float[] X1 = {accData[0][n], accData[1][n], accData[2][n]};
      String Y1 = getPrediction(X1, classifiers[1], attributes[1], instances[1]);
      println(accData[0][n], accData[1][n], accData[2][n], Y1);
      println(X1, Y1);
     /* if(Y1 == "A"){
        stroke(255,0,0);
        fill(255,0,0);
        rect(195, 210, 160, 60);
        triangle(355,180,445,240,355,300);
      }
      else if(Y1 == "B"){
        stroke(255,0,0);
        fill(255,0,0);
        rect(285,210,160,60);
        triangle(285,180,195,240,285,300);
      }
      else if(Y1 == "C"){
        stroke(255,0,0);
        fill(255,0,0);
        rect(290,205,60,160);
        triangle(260,205,320,115,350,205);
      } */
    }
  }
}

void serialEvent(Serial port) {
  String inData = port.readStringUntil('\n');
  if (read == true) {
    if (inData.charAt(0) == 'A') {
      rawData = int(trim(inData.substring(1)));
    }
  }
  if (dataIndex<dataNum) {
    if (inData.charAt(0) == 'B') {
      accData[0][dataIndex] = int(trim(inData.substring(1)));
      println(accData[0][dataIndex]);
    }
    if (inData.charAt(0) == 'C') {
      accData[1][dataIndex] = int(trim(inData.substring(1)));
      println(accData[1][dataIndex]);
    }
    if (inData.charAt(0) == 'D') {
      accData[2][dataIndex] = int(trim(inData.substring(1)));
      println(accData[2][dataIndex]);
      ++dataIndex;
    }
  }

  return;
}

void captureEvent(Capture c) {
  c.read();
}
