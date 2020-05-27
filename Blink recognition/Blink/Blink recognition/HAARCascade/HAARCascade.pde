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

int dataNum = 1;
int dataIndex = 0;

Table csvData;
boolean b_saveCSV = false;
String dataSetName = "accData"; 
String[] attrNames = new String[]{"box"};
boolean[] attrIsNominal = new boolean[]{false};
//int labelIndex = 0;

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
  
  //Initiate the dataList and set the header of table
  csvData = new Table();
  for (int i = 0; i < attrNames.length; i++) {
    csvData.addColumn(attrNames[i]);
    if (attrIsNominal[i]) csvData.setColumnType(i, Table.STRING);
    else csvData.setColumnType(i, Table.FLOAT);
  }
    
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
    println(features[i].x, features[i].y, features[i].width, features[i].height);
    
    if (b_saveCSV) {
      for (int n = 0; n < dataNum; n ++) {
        TableRow newRow = csvData.addRow();
       // newRow.setFloat("x", features[i].x);
       // newRow.setFloat("y", features[i].y);
        newRow.setFloat("box", features[i].width);
        
      }
      saveCSV(dataSetName, csvData);
      saveARFF(dataSetName, csvData);
      
      b_saveCSV = false;
    }
  }
  popMatrix();
  
  
    //drawMouseCursor(labelIndex);
}

void captureEvent(Capture c) {
  c.read();
}

void keyPressed() {
  if (key == 'S' || key == 's') {
    b_saveCSV = true;
  }
  if (key == ' ') {
    dataIndex = 0;
  }
  if (key == 'C' || key == 'c') {
    csvData.clearRows();
  }
  
}
void saveCSV(String dataSetName, Table csvData){
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
