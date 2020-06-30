

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
