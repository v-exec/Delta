import processing.video.*;

int brightnessThresh = 120;
int dotDensity = 7;
int dotSize = 2;
int offsetZ = 350;
boolean printCameras = false;
int cameraNumber = 1;
color backgroundColor = color(0, 0, 0, 255);
color dotColor = color(10);
color[] pPixels;
boolean createdPixels = false;
float rotX = 0.04;
float rotY = 0.04;
float rotationOffsetX = 0;
float rotationOffsetY = 0;
float offsetIncrementX = 0.01;
float offsetIncrementY = 0.01;

Capture cam;
String[] cameras = Capture.list();

void setup() {
  size(640, 480, P3D);

  if (printCameras) {
    for (int i = 0; i < cameras.length; i++) {
      println("camera number " + i + ": " + cameras[i]);
      println("");
    }
  }

  cam = new Capture(this, cameras[cameraNumber]);
  cam.start();
}

void draw() {
  background(backgroundColor);
  if (cam.available()) {
    cam.read();

    if (!createdPixels) {
      cam.loadPixels();
      pPixels = new color[cam.pixels.length];
      cam.updatePixels();

      for (int i = 0; i < pPixels.length; i++) {
        pPixels[i] = color(0, 0, 0);
      }
      createdPixels = true;
    }
  }

  blendFrames();
  drawImage();
  //image(cam, 0, 0);
}

void blendFrames() {
  cam.loadPixels();
  for (int x = 0; x < cam.width; x++) {
    for (int y = 0; y < cam.height; y++) {
      int loc = x + (y * cam.width);
      color pixel = cam.pixels[loc];
      int r = int(red(pixel) + abs(red(pPixels[loc]) - red(pixel)) / 1.1);
      int g = int(green(pixel) + abs(green(pPixels[loc]) - green(pixel)) / 1.1);
      int b = int(blue(pixel) + abs(blue(pPixels[loc]) - blue(pixel)) / 1.1);
      cam.pixels[loc] = color(r, g, b);
      pPixels[loc] = color(r, g, b);
    }
  }
  cam.updatePixels();
}

void drawImage() {
  cam.loadPixels();
  pushMatrix();
  translate(width/2, height/2);
  rotateCam();

  for (int x = 0; x < cam.width; x += dotDensity) {
    for (int y = 0; y < cam.height; y += dotDensity) {
      int loc = x + (y * cam.width);
      int brightness = int(brightness(pPixels[loc]));
      if (brightness > brightnessThresh) {
        noStroke();
        fill(brightness);
        pushMatrix();
        translate(x - width/2, y - width/2.7, brightness - offsetZ);
        ellipse(0, 0, dotSize, dotSize);
        popMatrix();
      }
    }
  }
  cam.updatePixels();
  popMatrix();
}

void rotateCam() {
  rotateX(sin(rotationOffsetX) * rotX);
  rotateY(cos(rotationOffsetY) * rotY);
  rotationOffsetX+=offsetIncrementX;
  rotationOffsetY+=offsetIncrementY;
}

void keyPressed() {
  if (key == 'q') {
    brightnessThresh+=5;
    println(brightnessThresh);
  }

  if (key == 'a') {
    brightnessThresh-=5;
    println(brightnessThresh);
  }

  if (key == 'w') offsetZ+=5;
  if (key == 's') offsetZ-=5;
}