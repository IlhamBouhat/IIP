//*********************************************
// Example Code for Interactive Intelligent Products
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

int div = 2;
PImage src, threshBlur, dst;
int blurSize = 12;
int grayThreshold = 80;

ArrayList<Contour> contours;

String featureText = "Face";

void setup() {
  size(640, 480);
  video = new Capture(this, 640/div, 480/div);
  opencv = new OpenCV(this, 640/div, 480/div);
  opencv.loadCascade( OpenCV.CASCADE_FRONTALFACE  );
  opencv.useColor();
  video.start();
  fill(255);
  textSize(12);
  textAlign(LEFT, TOP);
}

void draw() {
  background(0);
  pushMatrix();
  scale(2);
 
  //https://github.com/atduskgreg/opencv-processing/blob/master/src/gab/opencv/OpenCV.java
  
      opencv.loadCascade(  OpenCV.CASCADE_FRONTALFACE  );
      featureText = "Face";   
      opencv.loadImage(video);
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
  }
  popMatrix();
}

void captureEvent(Capture c) {
  c.read();
}
