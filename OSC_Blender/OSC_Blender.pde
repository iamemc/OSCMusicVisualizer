import oscP5.*;
import netP5.*;
import processing.sound.*;
import ddf.minim.*;
import controlP5.*;

Amplitude amp;
AudioIn in;
Minim minim;
AudioPlayer groove;
SoundFile file;

OscP5 oscP5;
NetAddress myRemoteLocation;

ControlP5 cp5;
Textlabel oscMessageLabel;
boolean isPlaying = false;
String oscMessageText = "";
float lastPlaybackTime = 0;
float framesPerBeat = 90; // Adjust this value as needed for animation smoothness

void setup() {
  size(400, 425);
  frameRate(30); // Default frame rate until we determine the BPM

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 12000);

  myRemoteLocation = new NetAddress("127.0.0.1", 14001);

  amp = new Amplitude(this);
  in = new AudioIn(this, 0);
  in.start();
  amp.input(in);

  minim = new Minim(this);

  // Default audio file for initialization
  groove = minim.loadFile("migration.mp3", 4096);
  groove.loop();
  groove.setGain(0);

  cp5 = new ControlP5(this);

  // Create GUI elements
  cp5.addButton("loadFile")
     .setLabel("Load Audio File")
     .setPosition(10, 35)
     .setSize(100, 30);

  cp5.addSlider("setVolume")
     .setPosition(10, 75)
     .setSize(200, 20)
     .setRange(0, 1)
     .setValue(groove.getGain());

  cp5.addButton("selectPrevious")
     .setLabel("Select Previous")
     .setPosition(10, 115)
     .setSize(100, 30);

  cp5.addButton("selectNext")
     .setLabel("Select Next")
     .setPosition(120, 115)
     .setSize(100, 30);

  // Create the label for displaying OSC messages
  oscMessageLabel = cp5.addTextlabel("oscMessageLabel")
                        .setText(oscMessageText)
                        .setPosition(10, 155)
                        .setColor(color(255))
                        .setFont(createFont("Arial", 12));

  // Determine BPM from the default audio file
  float musicBPM = getBPM(groove);
  if (musicBPM > 0) {
    adjustFrameRate(musicBPM);
  }
}

void loadFile(int theValue) {
  selectInput("Select an audio file:", "fileSelected");
}

void fileSelected(File selection) {
  if (selection != null) {
    // Stop and unload the current audio player
    groove.close();

    // Load and play the selected audio file
    groove = minim.loadFile(selection.getAbsolutePath(), 4096);
    groove.loop();
    groove.setGain(0);

    if (isPlaying) {
      groove.play();
    }

    isPlaying = true;

    // Determine BPM from the newly loaded audio file
    float musicBPM = getBPM(groove);
    if (musicBPM > 0) {
      adjustFrameRate(musicBPM);
    }
  }
}

void controlEvent(ControlEvent event) {
  if (event.isController()) {
    if (event.getName().equals("setVolume")) {
      float vol = event.getValue();
      groove.setGain(vol);
    }
  }
}

void selectPrevious(int theValue) {
  println("Select Previous");
  oscMessageText = "Selected Previous";
  oscMessageLabel.setText(oscMessageText);
  // Implement code to select the previous audio file here
}

void selectNext(int theValue) {
  println("Select Next");
  oscMessageText = "Selected Next";
  oscMessageLabel.setText(oscMessageText);
  // Implement code to select the next audio file here
}

void draw() {
  background(0);
  OscMessage myMessage2 = new OscMessage("/vj1");

  for (int i = 0; i < groove.bufferSize() - 1; i++) {
    float vj = (abs(groove.left.get(i)) + abs(groove.right.get(i)) * 3 / 2);
    float vj2 = floor(vj);

    myMessage2.add(vj);
    oscP5.send(myMessage2, myRemoteLocation);
  }

  // Check if the audio is not playing and enough time has passed, then play it
  if (!isPlaying && millis() - lastPlaybackTime >= 1000) {
    groove.play();
    isPlaying = true;
  }

  // Display a message to indicate playback status
  fill(255);
  textAlign(CENTER);
  textSize(16);
  if (isPlaying) {
    text("Playing", width / 2, height - 20);
  } else {
    text("Paused", width / 2, height - 20);
  }
}

void oscEvent(OscMessage theOscMessage) {
  print("### received an osc message.");
  print(" addrpattern: " + theOscMessage.addrPattern());
  println(" typetag: " + theOscMessage.typetag());
}

void keyPressed() {
  if (isPlaying) {
    groove.pause();
    isPlaying = false;
  } else if (groove.position() == groove.length()) {
    groove.rewind();
    groove.play();
    isPlaying = true;
  } else {
    groove.play();
    isPlaying = true;
  }
  lastPlaybackTime = millis();
}

// Function to calculate BPM from an audio player
float getBPM(AudioPlayer player) {
  // Calculate the BPM here (you can use beat detection algorithms)
  // For simplicity, I'll assume a constant BPM of 120 for demonstration purposes
  return 120.0;
}

// Function to adjust frame rate based on BPM
void adjustFrameRate(float musicBPM) {
  framesPerBeat = 30; // Adjust this value as needed for animation smoothness
  frameRate((musicBPM / 60) * framesPerBeat);
}
