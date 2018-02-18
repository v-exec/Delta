import KinectPV2.*;

Kinect kin;
int dotDensity = 5;
float dotSize = 1.5;
int offsetZ = 100;
color backgroundColor = color(0, 0, 0, 255);
color dotColor = color(10);
int[] prevDepthPixels;
int[] prevColPixels;
boolean createdPixels = false;
float rotX = 0.3;
float rotY = 0.3;
float rotationOffsetX = 0;
float rotationOffsetY = 0;
float offsetIncrementX = 0.03;
float offsetIncrementY = 0.03;
PImage depth;
PImage col;

void setup() {
  size(512, 424, P3D);
  frameRate(60);

  kin = new Kinect();
  kin.init(this);
}

void draw() {
  if (!createdPixels) {
    loadPixels();
    prevDepthPixels = new int[pixels.length];
    prevColPixels = new int[pixels.length];
    updatePixels();

    for (int i = 0; i < prevDepthPixels.length; i++) {
      prevDepthPixels[i] = 0;
      prevColPixels[i] = 0;
    }
    createdPixels = true;
  }

  background(backgroundColor);
  kin.display();
  processDepthFrames();
  processInfraredFrames();
  drawDots();

  //image(col, 0, 0);
  //image(depth, 0, 0);
}

void processDepthFrames() {
  depth.loadPixels();
  for (int x = 0; x < depth.width; x++) {
    for (int y = 0; y < depth.height; y++) {
      int loc = x + (y * depth.width);
      int brightness = int(brightness(depth.pixels[loc]));

      brightness = constrain(int(brightness + (abs(prevDepthPixels[loc] - brightness) / 2.2)), 0, 255);
      brightness = int(map(brightness, 25, 155, 1, 255));

      depth.pixels[loc] = color(brightness, brightness, brightness);
      prevDepthPixels[loc] = brightness;
    }
  }
  depth.updatePixels();
}

void processInfraredFrames() {
  col.loadPixels();
  for (int x = 0; x < col.width; x++) {
    for (int y = 0; y < col.height; y++) {
      int loc = x + (y * col.width);
      int brightness = int(brightness(col.pixels[loc]));

      if (brightness > 220) brightness = 0;
      if (brightness > 10) {
        brightness = constrain(int(brightness + (abs(prevColPixels[loc] - brightness) / 1.4)), 0, 255);
        brightness = int(map(brightness, 10, 210, 5, 255));
      } else brightness = 0;

      col.pixels[loc] = color(brightness, brightness, brightness);
      prevColPixels[loc] = brightness;
    }
  }
  col.updatePixels();
}

void drawDots() {
  pushMatrix();
  translate(width/2, height/2);
  rotateCam();

  for (int x = 0; x < width; x += dotDensity) {
    for (int y = 0; y < height; y += dotDensity) {
      int loc = x + (y * width);
      if (prevDepthPixels[loc] > 5) {
        noStroke();
        int finalBrightness = (255 - (prevDepthPixels[loc] * 2) + prevColPixels[loc] * 1);
        fill(constrain(finalBrightness, 0, 255));
        pushMatrix();
        translate(x - width/2, y - height/2, -(prevDepthPixels[loc] * 2.5) - offsetZ);
        ellipse(0, 0, dotSize, dotSize);
        popMatrix();
      }
    }
  }
  popMatrix();
}

void rotateCam() {
  rotateX(sin(rotationOffsetX) * rotX);
  rotateY(cos(rotationOffsetY) * rotY);
  rotationOffsetX+=offsetIncrementX;
  rotationOffsetY+=offsetIncrementY;
}

class Kinect {

  KinectPV2 myKinect;
  int maxD = 1200; //at 2000, range is 4.5m
  int minD = 0;  //at 0, range is 50cm

  Kinect () {
  }

  void init (processing.core.PApplet master) {
    myKinect = new KinectPV2(master);

    myKinect.enableDepthImg(true);
    myKinect.enableColorImg(true);
    myKinect.enablePointCloud(true);
    myKinect.enableInfraredImg(true); 

    myKinect.init();
  }

  void display() {
    myKinect.setLowThresholdPC(minD);
    myKinect.setHighThresholdPC(maxD);
    depth = myKinect.getPointCloudDepthImage();
    col = myKinect.getInfraredImage();
  }
}