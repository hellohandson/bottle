//arduino button connected to pin7, toggled

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.spi.*;
import processing.serial.*;

Serial myPort;
Minim minim;

// for recording
AudioInput in;
AudioRecorder [] recorders;

// for playing back
AudioOutput out;
FilePlayer player;

String val;
int linefeed = 10;
int numberOfRecordings = -1;

String recordingStatus = "";
Boolean keytoggle = false;

String stats[]  = {"record", "play"};
int currentPlaybackIndex = 0;

void setup(){
  size(512, 200, P3D);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 2048);
  recorders = new AudioRecorder[50];
  for(int i=0; i< 50; i++){
    recorders[i] = minim.createRecorder(in, "data/" + str(i) + ".wav");
  }
  out = minim.getLineOut( Minim.STEREO );
  textFont(createFont("Arial", 12));  
  String portName = Serial.list()[3]; 
  //println(Serial.list()[3]);
  myPort = new Serial(this, portName, 9600); 
  myPort.bufferUntil(linefeed);
}

void serialEvent(Serial myPort){
  if(val != null){
    if (val.equals("0")){
      keytoggle = true;
    } else{
      keytoggle = false;
    }
  }  

  if (!keytoggle) {
    if (recordingStatus == "" ){
      int tempId = numberOfRecordings + 1;
      numberOfRecordings = tempId % 50;
      recorders[numberOfRecordings].beginRecord();
      recordingStatus = "record";

    } else if (recordingStatus == "record") {

      currentPlaybackIndex = -1;
      recorders[numberOfRecordings].endRecord();
      recorders[numberOfRecordings].save();
      recordingStatus = "play";

    } else if (recordingStatus == "play") {
      player.pause();

      int tempId = numberOfRecordings + 1;
      numberOfRecordings = tempId % 50;
      recorders[numberOfRecordings].beginRecord();

      recordingStatus = "record";
    }
    println("keyPressed : " + recordingStatus + " : " + numberOfRecordings);
  }

  keytoggle = true;  
}

void draw(){
  if(myPort.available() > 0){
    val = myPort.readStringUntil('\n');
  }
  
  background(0); 
  stroke(255);

  if (player != null ) {
    if (!player.isPlaying() && recordingStatus == "play") {
      currentPlaybackIndex = currentPlaybackIndex + 1;
      currentPlaybackIndex = (currentPlaybackIndex > numberOfRecordings) ? 0 : currentPlaybackIndex;
      String fileName = "data/" + currentPlaybackIndex + ".wav";
      AudioRecordingStream myFile = minim.loadFileStream( fileName, 1024, true);
      player = new FilePlayer( myFile );
      player.patch(out);
      player.play();
      println("currentPlaybackIndex :" +  currentPlaybackIndex);
    }
  } else {
    if (recordingStatus == "play") {
      currentPlaybackIndex = 0;
      String fileName = "data/" + currentPlaybackIndex + ".wav";
      AudioRecordingStream myFile = minim.loadFileStream( fileName, 1024, true);
      player = new FilePlayer( myFile );
      player.patch(out);
      player.play();
    } 
  } 
}

