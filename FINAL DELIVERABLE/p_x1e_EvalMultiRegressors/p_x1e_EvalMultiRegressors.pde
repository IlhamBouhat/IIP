//*********************************************
// Example Code for Interactive Intelligent Products
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

ArrayList<Attribute>[] attributes = new ArrayList[2];
Instances[] instances = new Instances[2];
Classifier[] classifiers = new Classifier[2];

void setup() {
  size(500, 500);             //set a canvas
  instances[0] = loadTrainARFFToInstances(dataset="PostureTrainData.arff");
  instances[1] = loadTrainARFFToInstances(dataset="AccData.arff");
  attributes[0] = loadAttributesFromInstances(instances[0]);
  attributes[1] = loadAttributesFromInstances(instances[1]);
  classifiers[0] = loadModelToClassifier(model="Regressor.model"); //load a pretrained model.
  classifiers[1] = loadModelToClassifier(model="LinearSVC.model"); //load a pretrained model.
 // classifiers[2] = loadModelToClassifier(model="KSVR.model"); //load a pretrained model.
  loadTestARFF(dataset="PostureTestData.arff");//load a ARFF dataset
  evaluateTestSet(classifiers[0],test,isRegression = true, showEvalDetails=true);  //5-fold cross validation
 // evaluateTestSet(classifiers[1],test,isRegression = false, showEvalDetails=true);  //5-fold cross validation
//  evaluateTestSet(classifiers[2],test,isRegression = true, showEvalDetails=true);  //5-fold cross validation
}
void draw() {
  background(255);
  float[] X = {mouseX, mouseY};
  double[] Y = new double[classifiers.length];
  for(int i = 0 ; i < classifiers.length ; i++){
    Y[i] = getPredictionIndex(X, classifiers[i], attributes[0]);
    drawPrediction(X, Y[i], colors[i]); //draw the prediction
  }
}
