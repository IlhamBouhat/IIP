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
