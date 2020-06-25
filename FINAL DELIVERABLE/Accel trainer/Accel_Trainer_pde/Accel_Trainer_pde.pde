/**
 * Training code for the posture determiner code
 * @author Ilham El Bouhattaoui, Luuk Stavenuiter, Nadine Schellekens
 * @id 1225930, 
 * date: 31/05/2020
 * 
 * The baseline for this code is the same as the Posture code
 * It will load the dataset made in the posture set
 * It will then train a model with that set and save it
 * It also shows the predictions in real time
 * Uses example codes from Rong Hao Liang's github library for the course DBB220 Interactive Intelligent Products topic 2.2and 8.2
 * Links to the source code: 
 * https://github.com/howieliang/IIP1920/tree/master/Example%20Codes/2_2_Serial_Communication/Processing/p2_2c_SaveSerialAsARFF_A012
 * https://github.com/howieliang/IIP1920/tree/master/Example%20Codes/8_2_Camera_Based_Activity_Recognition/t3_FaceDetection/HAARCascade
 * https://github.com/howieliang/IIP1920/tree/master/Example%20Codes/8_2_Camera_Based_Activity_Recognition/t3_FaceDetection/SaveARFF_FaceRecognition
 * https://github.com/howieliang/IIP1920/tree/master/Example%20Codes/8_2_Camera_Based_Activity_Recognition/t3_FaceDetection/TrainLSVC_FaceRecognition
 *
 *
 *
 **/ 

/**
 * Setup for the training code set
 * Defines libraries used, and which features are selected
 * Initialises serial communication
 * Loads the training set and the model
 * Evaluates the training set 
 **/

void setup() {
  size(500, 500);
  
  loadTrainARFF(dataset="accData.arff"); //load a ARFF dataset
  trainLinearSVC(C=256);               //train a KNN classifier
  setModelDrawing(unit=3);
  evaluateTrainSet(fold=5, isRegression= false, showEvalDetails=true);  //5-fold cross validation
  saveModel(model="LinearSVC-256.model"); //save the model
}


void draw() {
drawModel(0, 0); //draw the model visualization (for 2D features)
  drawDataPoints(train); //draw the datapoints
  float[] X = {mouseX, mouseY}; 
  String Y = getPrediction(X);
  drawPrediction(X, Y); //draw the prediction
}
