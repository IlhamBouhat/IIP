

import processing.serial.*;
Serial port; 
import java.awt.*;

int dataNum = 100;
int dataIndex = 0;
int dataSet = 0;
int sensorNum = 3;
int[][] rawData = new int[sensorNum][dataNum];
boolean dataUpdated = false;


/**
 * Setup for the evaluation code set
 * Defines libraries used, and which features are selected
 * Initialises serial communication
 * Loads the training set and the model
 * Evaluates the training set 
 **/
void setup() {
  size(640, 480);

  loadTrainARFF(dataset="accData.arff"); //load a ARFF dataset
  loadTestARFF(dataset="accData-Test.arff");//load a ARFF dataset
  loadModel(model="LinearSVC-128.model"); //load a pretrained model.
  setModelDrawing(unit=2);         //set the model visualization (for 2D features)
  evaluateTestSet(isRegression = false, showEvalDetails=true);  //5-fold cross validation
}

/**
 * draw method 
 * reads the width from the webcam and the distance from the IR sensor
 * it then predicts the label {@code Y} as A or B 
 **/

void draw() {
  background(0);
}
