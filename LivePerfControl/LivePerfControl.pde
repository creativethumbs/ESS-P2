//Import the MIDI library
import themidibus.*; 

//Import OSC libraries
import oscP5.*; 
import netP5.*;

MidiBus myBus; // The MidiBus

OscP5 oscP5;
NetAddress myRemoteLocation;

boolean poweredon = false;

boolean debug = true;

boolean phasing = false;
boolean movingright = true; 
int phase_freq = 0; 

int prevMillis; 

int x = 0; 

int progress = 0; 

float warrior_val = 0f; 
float philosopher_val = 0f; 

/*
MIDI NOTE KEY:

60: Play song
61: Stop song
62: Light
63: Sand
64: Wind
65: Sea
66: Flame
67: Snow
68: Cloud
69: Grass
70: Flame

*/

/* 

IMPORTANT NOTE: when sending multiple pitch bend messages, must ensure that each one is on a different channel! 
(that means you can only send up to 16 unique pitch bend messages in one program)

*/

void setup() {
  //size(1024, 768);
  background(0);
  
  // SET UP OSC
  frameRate(25);
  oscP5 = new OscP5(this, 8000);

  // change ip address to the ip address of the current machine
  // remember to change that in touch osc as well!
  myRemoteLocation = new NetAddress("172.20.10.8", 9000);
  
  // SET UP MIDI
  myBus = new MidiBus(this, -1, "To Ableton"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
   
  textAlign(CENTER);
}

void draw() {
  pushMatrix();
  
  translate(width,height);
  rotate(radians(180));
  
  background(0);  
  
  if(poweredon) {
    fill(255);
    
    textSize(50);
    text("hello", width/2,height/2);
  }
  
  if(phasing && millis() >= prevMillis + 50) {
    if(phase_freq >= 127) {
      movingright = false;
    }
    else if(phase_freq <= 0) {
      movingright = true;
    }
    
    if(movingright) {
      phase_freq++;
    }
    else {
      phase_freq--;
    }
    
    int status_byte = 0xE0; // Send pitch bend
    int channel_byte = 5; 
    int first_byte = 0; 
    int second_byte = phase_freq; 
  
    myBus.sendMessage(status_byte, channel_byte, first_byte, second_byte);
    
    prevMillis = millis();
    
  }
  
  popMatrix();
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  
  if(debug) {
    print("### received an osc message.");
    print(" addrpattern: "+theOscMessage.addrPattern());
    println(" typetag: "+theOscMessage.typetag());
    println(" value: "+theOscMessage.get(0).floatValue());
  }
  
  if(theOscMessage.checkAddrPattern("/1/power") &&
      theOscMessage.get(0).floatValue() == 0.0) {
    println("turned on ");
    
    myBus.sendNoteOn(0, 60, 100); // Send a Midi noteOn
    delay(2);
    myBus.sendNoteOff(0, 60, 100); // Send a Midi nodeOff
    
    /*
    OscMessage myMessage = new OscMessage("/numbers");
    myMessage.add(120);
    oscP5.send(myMessage, myRemoteLocation); 
    
    */
    poweredon = true;
  }
  
  else if(theOscMessage.checkAddrPattern("/1/power") &&
      theOscMessage.get(0).floatValue() == 1.0) {
    println("turned off ");
    
    myBus.sendNoteOn(0, 61, 100); // Send a Midi noteOn
    delay(2);
    myBus.sendNoteOff(0, 61, 100); // Send a Midi nodeOff
    /*
    OscMessage myMessage = new OscMessage("/numbers");
    myMessage.add(121);
    oscP5.send(myMessage, myRemoteLocation); 
    
    */
    poweredon = false;
  }
  
  else if(theOscMessage.checkAddrPattern("/1/warrior")) {
    warrior_val = theOscMessage.get(0).floatValue(); 
    OscMessage myMessage = new OscMessage("/warriorlight");
   
    // black => pink
    if(philosopher_val <= 0.1) {
      float lightoutput = map(theOscMessage.get(0).floatValue(), 0,1,1,2);
    
      myMessage.add(lightoutput);
      oscP5.send(myMessage, myRemoteLocation); 
    }
    // blue + pink => pink
    else {
      float lightoutput = map(theOscMessage.get(0).floatValue(), 0,1,7,8);
    
      myMessage.add(lightoutput);
      oscP5.send(myMessage, myRemoteLocation); 
    }
    
  }
  
  else if(theOscMessage.checkAddrPattern("/1/philosopher")) {
    philosopher_val = theOscMessage.get(0).floatValue(); 
    OscMessage myMessage = new OscMessage("/philosopherlight");
    
    // black => blue
    if(warrior_val <= 0.1) {
      float lightoutput = map(theOscMessage.get(0).floatValue(), 0,1,5,6);
    
      myMessage.add(lightoutput);
      oscP5.send(myMessage, myRemoteLocation); 
    }
    // blue + pink => blue
    else {
      float lightoutput = map(theOscMessage.get(0).floatValue(), 0,1,2,3);
    
      myMessage.add(lightoutput);
      oscP5.send(myMessage, myRemoteLocation); 
    }
    
    
  }
  
  else if(theOscMessage.checkAddrPattern("/1/light") &&
          theOscMessage.get(0).floatValue() == 0.0) {
    
    myBus.sendNoteOn(0, 62, 100); // Send a Midi noteOn
    delay(2);
    myBus.sendNoteOff(0, 62, 100); // Send a Midi nodeOff
    
    phasing = true;
  }
  
  else if(theOscMessage.checkAddrPattern("/1/light") &&
          theOscMessage.get(0).floatValue() == 1.0) {
    myBus.sendNoteOn(0, 62, 100); // Send a Midi noteOn
    delay(2);
    myBus.sendNoteOff(0, 62, 100); // Send a Midi nodeOff
    
    phasing = false;
  }
  
  else if(theOscMessage.checkAddrPattern("/1/sand")) {
    myBus.sendNoteOn(0, 63, 100); // Send a Midi noteOn
    delay(2);
    myBus.sendNoteOff(0, 63, 100); // Send a Midi nodeOff
    
  }
  
  else if(theOscMessage.checkAddrPattern("/1/wind")) {
    myBus.sendNoteOn(0, 64, 100); // Send a Midi noteOn
    delay(2);
    myBus.sendNoteOff(0, 64, 100); // Send a Midi nodeOff
    
  }
  
  else if(theOscMessage.checkAddrPattern("/1/sea")) {
    myBus.sendNoteOn(0, 65, 100); // Send a Midi noteOn
    delay(2);
    myBus.sendNoteOff(0, 65, 100); // Send a Midi nodeOff
    
  }
  
  else if(theOscMessage.checkAddrPattern("/1/flame")) {
    myBus.sendNoteOn(0, 66, 100); // Send a Midi noteOn
    delay(2);
    myBus.sendNoteOff(0, 66, 100); // Send a Midi nodeOff
    
  }
  
  else if(theOscMessage.checkAddrPattern("/1/snow")) {
    myBus.sendNoteOn(0, 67, 100); // Send a Midi noteOn
    delay(2);
    myBus.sendNoteOff(0, 67, 100); // Send a Midi nodeOff
    
  }
  
  else if(theOscMessage.checkAddrPattern("/1/cloud")) {
    myBus.sendNoteOn(0, 68, 100); // Send a Midi noteOn
    delay(2);
    myBus.sendNoteOff(0, 68, 100); // Send a Midi nodeOff
    
  }
  
  else if(theOscMessage.checkAddrPattern("/1/grass")) {
    myBus.sendNoteOn(0, 69, 100); // Send a Midi noteOn
    delay(2);
    myBus.sendNoteOff(0, 69, 100); // Send a Midi nodeOff
    
  }
  
  else if(theOscMessage.checkAddrPattern("/1/flame")) {
    myBus.sendNoteOn(0, 70, 100); // Send a Midi noteOn
    delay(2);
    myBus.sendNoteOff(0, 70, 100); // Send a Midi nodeOff
    
  }
  
  else if(theOscMessage.checkAddrPattern("/1/trial1")) {
    
    int bendamt = (int) map(theOscMessage.get(0).floatValue(), 0, 1, 0, 127);
    
    int status_byte = 0xE0; // Send pitch bend
    int channel_byte = 0; 
    int first_byte = 0; 
    int second_byte = bendamt; 
  
    myBus.sendMessage(status_byte, channel_byte, first_byte, second_byte);
    
  }
  
  else if(theOscMessage.checkAddrPattern("/1/trial2")) {
    
    int bendamt = (int) map(theOscMessage.get(0).floatValue(), 0, 1, 0, 127);
    
    int status_byte = 0xE0; // Send pitch bend
    int channel_byte = 1; 
    int first_byte = 0; 
    int second_byte = bendamt; 
  
    myBus.sendMessage(status_byte, channel_byte, first_byte, second_byte);
    
  }
  
  else if(theOscMessage.checkAddrPattern("/1/trial3")) {
    
    int bendamt = (int) map(theOscMessage.get(0).floatValue(), 0, 1, 0, 127);
    
    int status_byte = 0xE0; // Send pitch bend
    int channel_byte = 2; 
    int first_byte = 0; 
    int second_byte = bendamt; 
  
    myBus.sendMessage(status_byte, channel_byte, first_byte, second_byte);
    
  }
  
  else if(theOscMessage.checkAddrPattern("/1/herethere")) {
    
    int bendamt = (int) map(theOscMessage.get(0).floatValue(), 0, 1, 0, 127);
    
    int status_byte = 0xE0; // Send pitch bend
    int channel_byte = 3; 
    int first_byte = 0; 
    int second_byte = bendamt; 
  
    myBus.sendMessage(status_byte, channel_byte, first_byte, second_byte);
    
  }
  
  else if(theOscMessage.checkAddrPattern("/1/goldenpath")) {
    
    int bendamt = (int) map(theOscMessage.get(0).floatValue(), 0, 1, 0, 127);
    
    int status_byte = 0xE0; // Send pitch bend
    int channel_byte = 4; 
    int first_byte = 0; 
    int second_byte = bendamt; 
  
    myBus.sendMessage(status_byte, channel_byte, first_byte, second_byte);
    
  }
  
  
  
}

void delay(int time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}