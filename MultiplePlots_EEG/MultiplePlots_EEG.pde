
import grafica.*;
import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.serial.*;
import java.util.Random;

Minim minim;  

FFT fftLin;

// Serial port to connect to
String serialPortName = "COM3";
boolean mockupSerial = true;
Serial serialPort; // Serial port object

// indexes
final int DELTA = 1; // 1-4 Hz
final int THETA = 2; // 4-8 Hz
final int ALPHA = 3; // 7-13 Hz
final int BETA = 4; // 13-30 Hz
final int GAMMA = 5; // 30-55 Hz


public GPlot plotTime, plotFreq, plotHist, freqAxis;
public int Fs = 250;
  
int lastStepTime = 0;

int bufferSize = 1024;
float angle = 0;

float[] ticks = new float[] { 16.38, 28.67, 57.34, 114.59, 237.57 };

//double[] notch_b2 = new double[] { 0.956543225556877, 1.18293615779028, 2.27881429174348, 1.18293615779028, 0.956543225556877 };
//double[] notch_a2 = new double[] { 1, 1.20922304075909, 2.27692490805580, 1.15664927482146, 0.914975834801436 };

// Prepare the points for the first plot  
GPointsArray points1 = new GPointsArray(bufferSize);
GPointsArray points2 = new GPointsArray(bufferSize);
GPointsArray points3 = new GPointsArray(5);


  
float[] rawPoints = new float[bufferSize];
float[] filt_data = new float[bufferSize];
float[] notch_filt_data = new float[bufferSize];
byte[] inBuffer = new byte[100]; // holds serial message

public void setup() {
  size(1280, 720);

  minim = new Minim(this);
  fftLin = new FFT( bufferSize, Fs );
  fftLin.window( FFT.BLACKMAN );

  
  for (int i = 0; i < bufferSize; i++) {
    //points1.add(i, random(8000)-4000);
   // points2.add(i, random(1000));
    points1.add(i, 0);
    points2.add(i, 0);
    rawPoints[i] = 0;
  }

  // Setup for the first plot
  plotTime = new GPlot(this);
  plotTime.setPos(0, 0);
  plotTime.setDim(850, 280);
  plotTime.setXLim(0, bufferSize-254);
  plotTime.setYLim(-30000, 30000);
  plotTime.drawGridLines(GPlot.VERTICAL);
  plotTime.setPoints(points1);
  plotTime.setLineColor(color(100, 0, 255));

  // Setup for the third plot 
  plotFreq = new GPlot(this);
  plotFreq.setPos(0, 350);
  plotFreq.setDim(850, 280);
  plotFreq.setYLim(-50, 256);
  plotFreq.setXLim(0, bufferSize/4);
  //plotFreq.setHorizontalAxesNTicks(10);
  plotFreq.setHorizontalAxesTicks(ticks);
  plotFreq.setPoints(points2);
  plotFreq.setLineColor(color(100, 100, 255));
  
  
  // Initialize point3 data for the plotHist
  points3.add(0,DELTA);
  points3.add(0,THETA);
  points3.add(0,ALPHA);
  points3.add(0,BETA);
  points3.add(0,GAMMA);

  
   // Setup for the third plot 
  plotHist = new GPlot(this);
  plotHist.setPos(920, 0);
  plotHist.setDim(250, 620);
  plotHist.setYLim(0, 6);
  plotHist.setXLim(0, 255);
  plotHist.startHistograms(GPlot.HORIZONTAL);
  //plotHist.getHistogram().setDrawLabels(true);
  //plotHist.getHistogram().setRotateLabels(true);
  plotHist.setPoints(points3);
  plotHist.getHistogram().setBgColors(new color[] {
    color(75, 0, 130, 200), color(168, 20, 231, 200),
    color(100, 100, 255, 200), color(0, 255, 255, 150), color(255, 255, 00, 80)
  });
 
  freqAxis = new GPlot(this);
  freqAxis.setPos(0, 620);
  freqAxis.setDim(850, 10);
  freqAxis.setXLim(0, Fs/4);
  freqAxis.setHorizontalAxesNTicks(15);
  freqAxis.drawXAxis();
  
  // start serial communication
  if (!mockupSerial) {
    //String serialPortName = Serial.list()[1];
    serialPort = new Serial(this, serialPortName, 115200);
  }
  else
    serialPort = null;
}


public void draw() {
  float val2;
  
  background(255);
  
  plotTime.beginDraw();
  plotTime.drawBackground();
  plotTime.drawBox();
  plotTime.drawXAxis();
  plotTime.drawGridLines(GPlot.BOTH);
  plotTime.drawLines();
  plotTime.endDraw();

  plotHist.beginDraw();
  plotHist.drawBackground();
  plotHist.drawBox();
  plotHist.drawHistograms();
  plotHist.endDraw();
  
  
  String myString = "";
    if (!mockupSerial) {
      try {
        serialPort.readBytesUntil('\r', inBuffer);
      }
      catch (Exception e) {}
      myString = new String(inBuffer);
      //println(myString);
    }
    else {
      myString = mockupSerialFunction();
    }
 

    // split the string at delimiter (space)
    //String[] nums = split(myString, ' ');
    
    try {
      val2 = Float.parseFloat(myString);
      //println(val2);
    }
    catch(Exception e) {val2 = 0;}
    
      
      for (int i = 1; i < bufferSize; i++) {
        rawPoints[i-1] = rawPoints[i];
      }
     
      rawPoints[bufferSize-1] = val2;

      
      filterIIR(notch_b2, notch_a2, rawPoints, filt_data);

     
      //null filter for test
      //filterIIR(test_b, test_a, rawPoints, filt_data);
      
      for (int i = 0; i < bufferSize; i++) { 
        points1.setY(i, filt_data[i] );
      }
      fftLin.forward(filt_data);

      for (int i = 0; i < bufferSize; i++) { 
        //points2.setY(i, (fftLin.getBand(i)*0.1)-0);
        points2.setY(i, (20 * log(2*fftLin.getBand(i)/fftLin.timeSize())));
      }
    
    points3.setX(0,0.0005*fftLin.calcAvg(0.1,4));
    points3.setX(1,0.0005*fftLin.calcAvg(4,7.0));
    points3.setX(2,0.0005*fftLin.calcAvg(7.0,14.0));
    points3.setX(3,0.0005*fftLin.calcAvg(14.0,28.0));
    points3.setX(4,0.0005*fftLin.calcAvg(28.0,58.0));
    
    plotTime.setPoints(points1);
    plotFreq.setPoints(points2);
    plotHist.setPoints(points3);
  
  

    plotFreq.beginDraw();
    plotFreq.drawBackground();
    plotFreq.drawBox();
    plotFreq.drawTitle();
    plotFreq.drawGridLines(GPlot.VERTICAL);
    plotFreq.drawLines();
    plotFreq.endDraw();
  
    freqAxis.beginDraw();
    freqAxis.drawXAxis();
    freqAxis.endDraw();
  
  
  

}
