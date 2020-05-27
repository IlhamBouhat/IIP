//https://www.mschoeffler.de/2017/11/27/arduino-tutorial-ir-distance-line-tracing-line-tracking-sensor-mh-sensor-series-ky-033-tcrt5000/
#include <Wire.h>

char val;
int buzz_pin = 7;
boolean buzz_state = LOW;

int sampleRate = 100; //samples per second
int sampleInterval = 1000000/sampleRate; //Inverse of SampleRate
const int IN_A0 = A0; // analog input
const int IN_D0 = 8; // digital input
long timer = micros();

void setup() {
  Serial.begin(115200);
  pinMode (IN_A0, INPUT);
  pinMode (IN_D0, INPUT);
}

int value_A0;
bool value_D0;

void loop() {
  if(Serial.available() > 0){
    val = Serial.read();

  if(val == '1'){
    buzz_state= !buzz_state;
    digitalWrite(buzz_pin, buzz_state);
  }
  delay(100);
  }
  else{
  if (micros() - timer >= sampleInterval) { //Timer: send sensor data in every 10ms
    value_A0 = analogRead(IN_A0); // reads the analog input from the IR distance sensor
    value_D0 = digitalRead(IN_D0);// reads the digital input from the IR distance sensor
    sendDataToProcessing('A', value_A0);
  }
  delay(100);
  }
}

void sendDataToProcessing(char symbol, int value_A0){
  Serial.print(symbol);
  Serial.println(value_A0);
}
