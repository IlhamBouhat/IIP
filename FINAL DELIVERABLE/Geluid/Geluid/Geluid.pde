import processing.sound.*;
//create a variable of type SoundFile
SoundFile mySoundFile;

void setup() {
 size(640, 360);
 background(255);
 
 // Load a soundfile from the /data folder of the sketch and play it back
 mySoundFile = new SoundFile(this, "ambient_forest.wav");
 mySoundFile.play();
} 

void draw() {
} 
