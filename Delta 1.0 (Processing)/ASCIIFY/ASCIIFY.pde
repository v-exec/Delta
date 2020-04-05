import processing.video.*;

/*
HOW TO USE
 
 1. Download the Processing Video library in tools>add tool>libraries.

 2. Make sure printCameras = true and run the sketch. A list of all cameras and camera options will be printed in the console on the bottom of the window.
 Choose the camera option you want, write its number in cameraNumber, and then make sure to set size()'s dimensions (its two first parameters) to the dimensions of the camera option you've chosen.
 
 3. Look over the user variables and adjust them to your liking.
 
 4. Run the sketch and enjoy!
 */

//-------------------------------------------------------------USER VARIABLES
//Determines at which brightness level to start drawing ascii characters. Anything under brightnessThresh will be black.
//0 means anything that isn't pure black will be renderd as an ascii character, 255 means that nothing other than pure white will be rendered as an ascii character.
int brightnessThresh = 50;

//Determines the density at which ascii characters will be drawn. The smaller the number, the denser the ascii.
int imageDensity = 12;

//Determines the size of the characters.
int ASCIIsize = 12;

//The ascii characters to be used for pseudo-dithering. Ordered from the least brightest, to the most brightest. Any number of characters can be used.
String[] chars = {".", "'", "-", "+", ";", "=", "x", "*", "#"};

//The font to be used for the ascii characters. If you want to use a custom font, put its ttf or otf file in the data folder of this program, and write its name here.
String textFont = "RobotoMono-Thin";

//Whether to print all available cameras at the bottom of the console or not.
boolean printCameras = false;

//The camera number to use.
int cameraNumber = 1;

//canvas' background color
color backgroundColor = color(0, 0, 0, 255);

//ascii character color
color textColor = color(255, 255, 255, 255);

//-------------------------------------------------------------NON-USER VARIABLES
Capture cam;
PFont font;
PImage[] charImages = new PImage[chars.length];
String[] cameras = Capture.list();

void setup() {
  //create window
  size(640, 480, P3D);
  noSmooth();

  //print all cameras
  if (printCameras) {
    for (int i = 0; i < cameras.length; i++) {
      println("camera number " + i + ": " + cameras[i]);
      println("");
    }
  }

  //create font and character images
  font = createFont(textFont, ASCIIsize);
  createCharSet();

  //start camera
  cam = new Capture(this, cameras[cameraNumber]);
  cam.start();
}

void draw() {
  //draw ascii
  background(backgroundColor);
  if (cam.available()) cam.read();
  drawImage();
}

//creates images for characters
void createCharSet() {
  textFont(font);
  textSize(ASCIIsize);

  for (int i = 0; i < charImages.length; i++) {
    background(backgroundColor);
    text(chars[i], 0, ASCIIsize);
    removeAntiAliasing();
    charImages[i] = get(0, 0, ASCIIsize, ASCIIsize);
  }
}

//makes all non-background pixels a solid color
void removeAntiAliasing() {
  loadPixels();
  for (int x = 0; x < width; x ++) {
    for (int y = 0; y < height; y ++) {
      int loc = x + (y * width);
      color pixelCol = pixels[loc];
      if (pixelCol != backgroundColor) {
        pixels[loc] = textColor;
      }
    }
  }
  updatePixels();
}

//draws ascii image
void drawImage() {
  cam.loadPixels();

  for (int x = 0; x < cam.width; x += imageDensity) {
    for (int y = 0; y < cam.height; y += imageDensity) {
      int loc = x + (y * cam.width);
      int brightness = int(brightness(cam.pixels[loc]));
      if (brightness > brightnessThresh) {
        int index = int(map(brightness, brightnessThresh, 255, 0, charImages.length - 1));
        image(charImages[index], x, y);
      }
    }
  }
  cam.updatePixels();
}