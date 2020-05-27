import processing.serial.*;
Serial port;

int dataNum = 100;
int[] rawData = new int[dataNum];
int dataIndex = 0;

void setup(){
  
  for (int i = 0; i < Serial.list().length; i++) println("[", i, "]:", Serial.list()[i]);
  String portName = Serial.list()[0];
  port = new Serial(this, portName, 115200);
  port.bufferUntil('\n'); // arduino ends each data packet with a carriage return 
  port.clear();
}

void draw(){
}

void serialEvent(Serial port){
  String inData = port.readStringUntil('\n');
  if(dataIndex<dataNum){
    if(inData.charAt(0) == 'A'){
      rawData[dataIndex] = int(trim(inData.substring(1)));
      ++dataIndex;
    }
  }
  return;
}
