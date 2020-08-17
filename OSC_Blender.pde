import oscP5.*;
import netP5.*;
import processing.sound.*;
import ddf.minim.*;

Amplitude amp;
AudioIn in;
Minim minim;
AudioPlayer groove;
SoundFile file;
  
OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(400,400);
  
   //ALTERAR BEAT
   
                  frameRate(3); // <<<<--------------------
                  
   //ALTERAR BEAT
  
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);

  myRemoteLocation = new NetAddress("127.0.0.1",14001); // <=== nº da Input port no BLENDER
  
  amp = new Amplitude(this);
  in = new AudioIn(this, 0);
  in.start();
  amp.input(in);
  
  minim = new Minim(this);
  
    //ALTERAR NOME DA MÚSICA PARA A OUVIR
              groove = minim.loadFile("migration.mp3", 4096); // <<<---------
    //ALTERAR NOME DA MÚSICA PARA A OUVIR
    
// MATERIAIS RECOMENDADOS NO BLENDER POR MUSICA
     // SWING - BLACK&ORANGE
     // EMIR  - METAL_COLORS
     // MIGRATION - SINGLE_COLOR
     // CAESAR - METAL_B&W
// MATERIAIS RECOMENDADOS NO BLENDER POR MUSICA
  
  groove.loop();
  
  groove.setGain(0);
}
void keyPressed() {
if ( groove.isPlaying() )
  {
    groove.pause();
  }
  // if the player is at the end of the file,
  // we have to rewind it before telling it to play again
  else if ( groove.position() ==groove.length() )
  {
    groove.rewind();
    groove.play();
  }
  else
  {
    groove.play();
  }
}

void draw() {
  background(0);
   OscMessage myMessage2 = new OscMessage("/vj1");
  
  for(int i = 0; i < groove.bufferSize() - 1; i++)
  {
    
    float vj =  (abs(groove.left.get(i)) + abs(groove.right.get(i))*15 / 2); // O VALOR 15 É UM MULTIPLICADOR DE AMPLITUDE. RECOMENDADO ENTRE 10-25
    float vj2 = floor(vj) ;
    
    //int a=int(vj);
    //String vj3 = nf(a, 0, 1);
    //println(vj3);  //
    
    myMessage2.add(vj);
    oscP5.send(myMessage2, myRemoteLocation);
    //if(frameCount %30 == 0);
    
    //print(vj2);

  if ( groove.isPlaying() )
    {
      text("Press any key to pause playback.", 10, 20 );
    }
    else
    {
    text("Press any key to start playback.", 10, 20 );
    }
  }
}

/* incoming osc message are forwarded to the oscEvent method. */
  void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
    print("### received an osc message.");
    print(" addrpattern: "+theOscMessage.addrPattern());
    println(" typetag: "+theOscMessage.typetag()); 
}
