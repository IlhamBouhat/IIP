import processing.serial.*;
Serial port;

int sensorNum = 1;
int rawData;

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
  if(inData.charAt(0) == 'A'){
    rawData = int(trim(inData.substring(1)));
    println(rawData);
    }
    if(rawData >= 900){
      port.write('a');
    }
    else{
      port.write('b');
    }
  return;
}

/*void threshold(){
  if(rawData >= 900){
    port.write('a');
  }
  else{
    port.write('b');
  }
} */
