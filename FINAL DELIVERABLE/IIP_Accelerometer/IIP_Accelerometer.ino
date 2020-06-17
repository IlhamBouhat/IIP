//Source: https://www.mschoeffler.de/2017/10/05/tutorial-how-to-use-the-gy-521-module-mpu-6050-breakout-board-with-the-arduino-uno/#:~:text=First%2C%20we%20connect%20the%20module's,an%20SCL%20and%20SDA%20pin.

#include <Wire.h>

#define PIN_NUM 3
int sampleRate = 100; //samples per second
int sampleInterval = 1000000/sampleRate; //Inverse of SampleRate
long timer = micros();

int TriggerPin = 11;
int EchoPin = 12;
long duration, cm;

const int MPU_ADDR = 0x68; // I2C address of the MPU-6050. If AD0 pin is set to HIGH, the I2C address will be 0x69.
int16_t accelerometer_x, accelerometer_y, accelerometer_z; // variables for accelerometer raw data
int16_t gyro_x, gyro_y, gyro_z; // variables for gyro raw data
int16_t temperature; // variables for temperature data
char tmp_str[7]; // temporary variable used in convert function
char* convert_int16_to_str(int16_t i) { // converts int16 to string. Moreover, resulting strings will have the same length in the debug monitor.
  sprintf(tmp_str, "%6d", i);
  return tmp_str;
}

void setup() {
  Serial.begin(115200);
  pinMode(TriggerPin, OUTPUT);
  pinMode(EchoPin, INPUT);
  Wire.begin();
  Wire.beginTransmission(MPU_ADDR); // Begins a transmission to the I2C slave (GY-521 board)
  Wire.write(0x6B); // PWR_MGMT_1 register
  Wire.write(0); // set to zero (wakes up the MPU-6050)
  Wire.endTransmission(true);
}
void loop() {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x3B); // starting with register 0x3B (ACCEL_XOUT_H) [MPU-6000 and MPU-6050 Register Map and Descriptions Revision 4.2, p.40]
  Wire.endTransmission(false); // the parameter indicates that the Arduino will send a restart. As a result, the connection is kept active.
  Wire.requestFrom(MPU_ADDR, 7*2, true); // request a total of 7*2=14 registers
  
  //Readings for the Ultrasonic sensor
  digitalWrite(TriggerPin, LOW);
  delay(5);
  digitalWrite(TriggerPin, HIGH);
  delay(10);
  digitalWrite(TriggerPin, LOW);

  pinMode(EchoPin, INPUT);
  duration = pulseIn(EchoPin, HIGH);

  cm = (duration/2)/29.1;
  
  // "Wire.read()<<8 | Wire.read();" means two registers are read and stored in the same variable
  accelerometer_x = Wire.read()<<8 | Wire.read(); // reading registers: 0x3B (ACCEL_XOUT_H) and 0x3C (ACCEL_XOUT_L)
  accelerometer_y = Wire.read()<<8 | Wire.read(); // reading registers: 0x3D (ACCEL_YOUT_H) and 0x3E (ACCEL_YOUT_L)
  accelerometer_z = Wire.read()<<8 | Wire.read(); // reading registers: 0x3F (ACCEL_ZOUT_H) and 0x40 (ACCEL_ZOUT_L)
  temperature = Wire.read()<<8 | Wire.read(); // reading registers: 0x41 (TEMP_OUT_H) and 0x42 (TEMP_OUT_L)
  gyro_x = Wire.read()<<8 | Wire.read(); // reading registers: 0x43 (GYRO_XOUT_H) and 0x44 (GYRO_XOUT_L)
  gyro_y = Wire.read()<<8 | Wire.read(); // reading registers: 0x45 (GYRO_YOUT_H) and 0x46 (GYRO_YOUT_L)
  gyro_z = Wire.read()<<8 | Wire.read(); // reading registers: 0x47 (GYRO_ZOUT_H) and 0x48 (GYRO_ZOUT_L)

  if (micros() - timer >= sampleInterval) { //Timer: send sensor data in every 10ms
    timer = micros();
    getDataFromProcessing();
    Serial.flush();
    //value_A0 = analogRead(IN_A0); // reads the analog input from the IR distance sensor
    //value_D0 = digitalRead(IN_D0);// reads the digital input from the IR distance sensor
    sendDataXToProcessing('B', accelerometer_x);
    sendDataYToProcessing('C', accelerometer_y);
    sendDataZToProcessing('D', accelerometer_z);
    sendDataCMToProcessing('A', cm);
    }
  /* print out data
  Serial.print("aX = "); Serial.print(convert_int16_to_str(accelerometer_x));
  Serial.print(" | aY = "); Serial.print(convert_int16_to_str(accelerometer_y));
  Serial.print(" | aZ = "); Serial.print(convert_int16_to_str(accelerometer_z));
  // the following equation was taken from the documentation [MPU-6000/MPU-6050 Register Map and Description, p.30]
  Serial.print(" | tmp = "); Serial.print(temperature/340.00+36.53);
  Serial.print(" | gX = "); Serial.print(convert_int16_to_str(gyro_x));
  Serial.print(" | gY = "); Serial.print(convert_int16_to_str(gyro_y));
  Serial.print(" | gZ = "); Serial.print(convert_int16_to_str(gyro_z));
  Serial.println(); */
  
  // delay
  delay(100);
}

void sendDataXToProcessing(char symbol, int accelerometer_x){
  Serial.print(symbol);
  Serial.println(accelerometer_x);
}

void sendDataYToProcessing(char symbol, int accelerometer_y){
  Serial.print(symbol);
  Serial.println(accelerometer_y);
}

void sendDataZToProcessing(char symbol, int accelerometer_z){
  Serial.print(symbol);
  Serial.println(accelerometer_z);
} 

void sendDataCMToProcessing(char symbol, int cm){
  Serial.print(symbol);
  Serial.println(cm);
}

void getDataFromProcessing(){
  while (Serial.available()) {
    char inChar = (char)Serial.read();
    /*if (inChar == 'a') { //when an 'a' charactor is received.
      digitalWrite(led_pin, HIGH); //turn on the built in LED on Arduino Uno
    }
    if (inChar == 'b') { //when an 'b' charactor is received.
      digitalWrite(led_pin, LOW); //turn on the built in LED on Arduino Uno
    } */
  }
} 
