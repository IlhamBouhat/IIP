/**
 * Posture determining code
 * @author Ilham El Bouhattaoui, Luuk Stavenuiter, Nadine Schellekens
 * @id 1225930, 
 * date: 31/05/2020
 * 
 * This code uses the opencv library and the processing video library to determine the distance between the face and the webcam and 
 * saves it to a parameter, {@ code A} being good posture and {@code B} being bad posture
 *
 * Uses example codes from the github library for the course DBB220 Interactive Intelligent Products
 * Links to the source code: 
 * https://github.com/howieliang/IIP1920/tree/master/Example%20Codes/2_2_Serial_Communication/Processing/p2_2c_SaveSerialAsARFF_A012
 * https://github.com/howieliang/IIP1920/tree/master/Example%20Codes/8_2_Camera_Based_Activity_Recognition/t3_FaceDetection/HAARCascade
 *
 *
 *
 **/
import processing.serial.*;
Serial port;

import java.awt.*;


int dataNum = 100;
int dataIndex = 0;
int dataSet = 0;

int sensorNum = 3;
int[][] rawData = new int[sensorNum][dataNum];

Table csvData;
boolean b_saveCSV = false;
String dataSetName = "accData"; 
String[] attrNames = new String[]{"x", "y", "z", "Label"};
boolean[] attrIsNominal = new boolean[]{false, false, false, true};
int labelIndex = 0;

/**
 * Setup for the posture code set
 * Defines libraries used, and which features are selected
 * Initialises serial communication
 * creates a csv file
 **/

void setup() {
  size(500, 500);

  //initialises the Serial communication. Each time Arduino sends a value, that value is loaded in a list
  for (int i = 0; i < Serial.list().length; i++) println("[", i, "]:", Serial.list()[i]);
  String portName = Serial.list()[0];
  port = new Serial(this, portName, 115200);
  port.bufferUntil('\n'); // arduino ends each data packet with a carriage return 
  port.clear();

  //Initiate the dataList and set the header of table
  csvData = new Table();
  for (int i = 0; i < attrNames.length; i++) {
    csvData.addColumn(attrNames[i]);
    if (attrIsNominal[i]) csvData.setColumnType(i, Table.STRING);
    else csvData.setColumnType(i, Table.FLOAT);
  }
}


/**
 * draw method 
 * In this method, the opencv library is initialised
 * Furthermore, it is calibrated to detect the face and draw a bounding box around it
 * The bounding box is determined with the x, y, width and height of the face to the webcam
 * It also saves the width variable to determine the distance. The larger the bounding box, the closer 
 * the user is to the webcam and vice versa
 * These variables are then saved to a parameter {@ code A} or {@ code B}, being good and bad posture
 **/
void draw() {
  background(255);
  float pointSize = height/dataNum;
  for (int i = 0; i < dataIndex; i++) {
    for (int n = 0; n < sensorNum; n++) {
      noStroke();
      if (n==0) fill(255, 0, 0);
      if (n==1) fill(0, 255, 0);
      if (n==2) fill(0, 0, 255);
      ellipse(i*pointSize, rawData[n][i], pointSize, pointSize);
      textSize(pointSize);
      textAlign(CENTER, CENTER);
      fill(0);
      text(getCharFromInteger(labelIndex), i*pointSize, rawData[n][i]);
    }
  }

  //https://github.com/atduskgreg/opencv-processing/blob/master/src/gab/opencv/OpenCV.java
  //if(dataIndex == dataNum){
    if (b_saveCSV) {
      for (int n = dataSet; n < dataIndex; n ++) {
        TableRow newRow = csvData.addRow();
        newRow.setFloat("x", rawData[0][n]);
        newRow.setFloat("y", rawData[1][n]);
        newRow.setFloat("z", rawData[2][n]);
        newRow.setString("Label", getCharFromInteger(labelIndex));
        println("Label =" + labelIndex);
      }
      saveCSV(dataSetName, csvData);
      saveARFF(dataSetName, csvData);
      b_saveCSV = false;
      dataSet = dataIndex;
    }
  //}

  keyPressed();
  keyReleased();
}

/**
 * Writes back from Processing to Arduino to give a signal that the number has been received and to signal that someone
 * is in bad posture using an LED light
 **/

void serialEvent(Serial port) {
  String inData = port.readStringUntil('\n');
  if(dataIndex<dataNum){
  if (inData.charAt(0) == 'B') {
    rawData[0][dataIndex] = int(trim(inData.substring(1)));
    println(rawData[0][dataIndex]);
  }
  if (inData.charAt(0) == 'C') {
    rawData[1][dataIndex] = int(trim(inData.substring(1)));
    println(rawData[1][dataIndex]);
  }
  if (inData.charAt(0) == 'D') {
    rawData[2][dataIndex] = int(trim(inData.substring(1)));
    println(rawData[2][dataIndex]);
    ++dataIndex;
  }
  }
  return;
}


/**
 * On the right mouseclick, one changes the label index from A to B
 **/
void mousePressed() {
  if (mouseButton == RIGHT) {
    ++labelIndex;
    labelIndex %= 10;
  }
}



void keyPressed() {
  if (key == 'S' || key == 's') { //saves to CSV
    b_saveCSV = true;
  }
  if (key == ' ') { //cleans the data index
    dataIndex = 0;
  }
  if (key == 'C' || key == 'c') { //starts the measuring over
    csvData.clearRows();
  }
}

void keyReleased(){
if(key == 'S' || key == 's'){
b_saveCSV = false;
}
}


String getCharFromInteger(double i) { //0 = A, 1 = B, and so forth
  return ""+char(min((int)(i+'A'), 90));
}

void saveCSV(String dataSetName, Table csvData) {
  saveTable(csvData, dataPath(dataSetName+".csv")); //save table as CSV file
  println("Saved as: ", dataSetName+".csv");
}

void saveARFF(String dataSetName, Table csvData) {
  String[] attrNames = csvData.getColumnTitles();
  int[] attrTypes = csvData.getColumnTypes();
  int lineCount = 1 + attrNames.length + 1 + (csvData.getRowCount()); //@relation + @attribute + @data + CSV
  String[] text = new String[lineCount];
  text[0] = "@relation "+dataSetName;
  for (int i = 0; i < attrNames.length; i++) {
    String s = "";
    ArrayList<String> dict = new ArrayList<String>();
    s += "@attribute "+attrNames[i];
    if (attrTypes[i]==0) {
      for (int j = 0; j < csvData.getRowCount(); j++) {
        TableRow row = csvData.getRow(j);
        String l = row.getString(attrNames[i]);
        boolean found = false;
        for (String d : dict) {
          if (d.equals(l)) found = true;
        }
        if (!found) dict.add(l);
      }
      s += " {";
      for (int n=0; n<dict.size(); n++) {
        s += dict.get(n);
        if (n != dict.size()-1) s += ",";
      }
      s += "}";
    } else s+=" numeric";
    text[1+i] = s;
  }
  text[1+attrNames.length] = "@data";
  for (int i = 0; i < csvData.getRowCount(); i++) {
    String s = "";
    TableRow row = csvData.getRow(i);
    for (int j = 0; j < attrNames.length; j++) {
      if (attrTypes[j]==0) s += row.getString(attrNames[j]);
      else s += row.getFloat(attrNames[j]);
      if (j!=attrNames.length-1) s +=",";
    }
    text[2+attrNames.length+i] = s;
  }
  saveStrings(dataPath(dataSetName+".arff"), text);
  println("Saved as: ", dataSetName+".arff");
}
