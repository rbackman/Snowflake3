import processing.svg.*;


/*
Snowflake 2.0

Open-source "snowflake" drawing app with true vector output.
Click the "save" button to create a PDF document of your snowflake,
suitable for editing in Inkscape, Corel, Illustrator, or so forth.

   
Written by Windell H. Oskay, www.evilmadscientist.com
Copyright 2009, all rights reserved.
Distributed under the GPL 3.0.

Saves files named "snowflake-####.pdf" in the directory where this .pde file
resides. 

 */




import processing.pdf.*;

int sides = 6;

void DrawVertex(float x,float y,float angle)
{    // Angle is in radians
  vertex(x*cos(angle) + y*sin(angle), y*cos(angle) - x*sin(angle));
}

boolean ReflectMode = true;
boolean HoleMode = false;


int SidesMax = 99;

float StartTime, InitTime;
float CircStartTime;


float timeNow;
float LastActiveTime;
float xValues[];
float yValues[];
float holeX[];
float holeY[];

int SideLength;
color circleColor;
color circleStroke;

color bgColor;
color symColor;
color segmentColor;
int CircleDia;
int mtCircleDia;
boolean dragging; 
boolean draggingHole;

int MovePoint;
boolean pointsActive;
boolean pointsActiveOld;
color emptyCircle;

PFont font_MB48;
PFont font_MB24;


boolean overCircle(int x, int y, int diameter) 
{
  float disX = x - mouseX;
  float disY = y - mouseY;
  if(sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } 
  else {
    return false;
  }
}


boolean overRect(int x, int y, int width, int height) 
{
  if (mouseX >= x && mouseX <= x+width &&  mouseY >= y && mouseY <= y+height) 
    return true; 
  else 
    return false;
  
}



 
void setup() 
{

  size(640, 640); 
  smooth();

  xValues = new float[2];
  yValues = new float[2];

  holeX = new float[3];
  holeY = new float[3];
  
  bgColor = color(70, 70, 200);
  background(bgColor);
  
  StartTime = millis();
  
  InitTime=  millis();
  LastActiveTime = StartTime;
  dragging = false; 
  draggingHole = false;
  
  pointsActive = false;


  symColor = 0;  
  segmentColor = 255;
  CircleDia =  10;
  circleColor = color(255, 128, 0);

  mtCircleDia =  10;
  emptyCircle = color(255,128,0,0);

  SideLength = width*9/20;

   font_MB48  = loadFont("Miso-Bold-48.vlw");
 
   font_MB24  = loadFont("Miso-Bold-24.vlw");
  textFont( font_MB24, 20);  // MISO Typeface from http://omkrets.se/typografi/
  
  
   
  ClearShape();  
  
  stroke(255);
  circleStroke = 255;
 strokeWeight(1); 

  pushMatrix();
  translate(width/2,height/2);
  drawShape();
  popMatrix();

}




void ClearShape() { 

  // This sets the initial shape and draws it on the screen,
  // with a triangular section highlighted.

  xValues = subset(xValues, 0, 2);
  yValues = subset(yValues, 0, 2); 

  xValues[0] = 0;
  xValues[1] = SideLength*sqrt(3)/4; 

  yValues[0] = -SideLength;
  yValues[1] = -0.75*SideLength; 
  
   
   holeX[0] = 14;
   holeY[0] = -250;
   
   holeX[1] = 93;
   holeY[1] = -205;
   
   holeX[2] = 12;
   holeY[2] = -59;



  pointsActive = true;
  StartTime = millis(); 
}








void mousePressed() { 

  int i,len,xt,yt; 

  len = xValues.length;
  dragging = false;
  draggingHole = false;
  
  i = 0;
  while (i < len)
  { 
    if (overCircle((int) xValues[i] + width/2, (int) yValues[i] + height/2, CircleDia))
    {
      dragging = true; 
      MovePoint = i; 
      i = len; // break
    } 
    i++; 
  }
  
  if (HoleMode)
  {
    i = 0;
    while (i < holeX.length)
    {
  
      
      if (overCircle((int) holeX[i] + width/2, (int) holeY[i] + height/2, CircleDia))
      {
        draggingHole = true; 
        MovePoint = i; 
        i = len; // break
      } 
      i++; 
    }
    if ( draggingHole == false)
    {
      i = 0;
      while (i  < holeX.length) 
      { 
        if (i == holeX.length-1)
        {
           xt = (int) (holeX[i] + holeX[0] )/2;
           yt = (int) (holeY[i] + holeY[0] )/2;   
        }
        else
        {
          xt = (int) (holeX[i] + holeX[i+1] )/2;
          yt = (int) (holeY[i] + holeY[i+1] )/2;   
        }
        //over the halfway circle point so splice in a new point
        if (overCircle (xt + width/2, yt+ height/2,  CircleDia))
        {
          draggingHole = true; 
          MovePoint = i+1;
  
          holeX = splice(holeX, xt, i+1);
          holeY = splice(holeY, yt, i+1); 
          i = len; // break    
        } 
        i++;
      }
    } 
  }
  if ( dragging == false)
  {
    i = 0;
    while (( i + 1) < len) 
    { 
      xt = (int) (xValues[i] + xValues[i+1] )/2;
      yt = (int) (yValues[i] + yValues[i+1] )/2;    
      //over the halfway circle point so splice in a new point
      if (overCircle (xt + width/2, yt+ height/2,  CircleDia))
      {
        dragging = true; 
        MovePoint = i+1;

        xValues = splice(xValues, xt, i+1);
        yValues = splice(yValues, yt, i+1); 
        i = len; // break    
      } 
      i++;
    }
  } 
 

  if (overRect(425, 610, 40, 25))  // Mirror
  {
    ReflectMode = !ReflectMode;
    
  }
  
  if (overRect(475, 610, 40, 25))  // Hole
  {
    HoleMode = !HoleMode;
  }
  
  
  if (overRect(525, 610, 40, 25))  // Clear
  {
    ClearShape(); 
  }

  

  if (overRect(575, 610, 40, 25) )  // Save
  { 
    beginRecord(SVG, "snowflake-####.svg"); 
    pushMatrix();
    translate(width/2,height/2);
    background(255);
    stroke(0);
    strokeWeight(1);

    drawShape();
    popMatrix(); 
    endRecord();

    strokeWeight(0);
    stroke(255);

  }


}

void mouseReleased() {
  dragging = false;
  if(draggingHole)
  {
    print("hole x,y ",holeX[MovePoint],holeY[MovePoint]);
  }
  draggingHole = false;
}



void drawShape()
{

  float angle;
  int i,j;
  fill(symColor); 
  
  if(HoleMode)
  {
  i = 0;
  
  while (i < sides)
  {

    angle = -i*TWO_PI/sides;
     j = 0;
     beginShape(POLYGON);
    while(j<holeY.length)
    {
      
      DrawVertex(holeX[j],holeY[j],angle);
      j++;
    }
    endShape(CLOSE);
    j=0;
    if(ReflectMode)
    {
      beginShape(POLYGON);
      while(j<holeY.length)
      {
        
        DrawVertex(-holeX[j],holeY[j],angle);
        j++;
      }
      endShape(CLOSE);
    }
    i++;
  }
  
  }
  beginShape(POLYGON);
  i = 0;
  while (i < sides)
  {

    angle = -i*TWO_PI/sides;

    if (ReflectMode){
      xValues = reverse(xValues);
      yValues = reverse(yValues);
      j = 0;
      while (j < xValues.length)
      { 
        DrawVertex(-1*xValues[j],yValues[j],angle);  
        j++;
      }

      xValues = reverse(xValues);
      yValues = reverse(yValues);

      j = 0;

      while (j < xValues.length)
      { 
        DrawVertex(xValues[j],yValues[j],angle);  
        j++;
      }  
      i++;
    } 
    else { 
      j = 0; 
      while (j < xValues.length)
      { 
        DrawVertex(xValues[j],yValues[j],angle);  
        j++;
      }  
      i++;
    }


  } 
  endShape(CLOSE);

}


void draw() 
{ 
  int i,j,len,xt,yt;
  float xf,yf;
  float TimeTemp;
  
  len = xValues.length;

  timeNow = millis(); 


  if (pointsActive) 
    LastActiveTime = timeNow;

  if ((timeNow - LastActiveTime) < 5000)
    pointsActiveOld = true;
  else
    pointsActiveOld = false;

  pointsActive = false;



  pushMatrix();
  translate(width/2,height/2);
  background(bgColor);

  stroke(255);
  strokeWeight(1); 

  drawShape();
  popMatrix();


  if ((timeNow - CircStartTime) < 2550) 
  {
    j =  (int) (timeNow - CircStartTime) / 10;
    circleStroke =  color(255,255,255,255-j); 
  }


  //fade from initial view of polygon
  if ((timeNow - StartTime) < 9525)// 6350
  { 
    j =  (int) (timeNow - StartTime) / 25;

    if (j < 176)
    {
      symColor = color(255,255,255,j); 
      CircStartTime = timeNow; 
    }
    else
    {
      symColor = color(255,255,255,176);  
    }

    if (j <= 255)
      segmentColor = color(255,255,255,255-j);    
    else
      segmentColor = color(255,255,255,0);    
 
    
    fill(segmentColor);
    strokeWeight(0);
    stroke(segmentColor);
    pushMatrix();
    translate(width/2,height/2);
    beginShape(POLYGON);
    DrawVertex(0,0,0);  

    
    i = 0;
    while (i < xValues.length)
    { 
      DrawVertex(xValues[i],yValues[i],0);  
      i++;
    }
    
    DrawVertex(0,0,0);  
    
    endShape(CLOSE);
    popMatrix();
    
    
    strokeWeight(1);
    stroke(circleStroke);

   
    i = 0;
    while (i < len)
    {  
      {

        pushMatrix();
        translate(width/2,height/2); 
        fill(red(circleColor),green(circleColor),blue(circleColor),255-j); 
        ellipse(xValues[i], yValues[i], CircleDia, CircleDia);
        popMatrix();
      }
      if (( i + 1) < len)
      {
        xt = (int) (xValues[i] + xValues[i+1] )/2;
        yt = (int) (yValues[i] + yValues[i+1] )/2;    
        {
          pushMatrix();
          translate(width/2,height/2); 
          ellipse(xt, yt,CircleDia, CircleDia);
          popMatrix();
        } 
      } 
      i++;
    }

    if(HoleMode)
    {
    i = 0;
    while (i < holeX.length)
    {  
      {

        pushMatrix();
        translate(width/2,height/2); 
        fill(red(circleColor),green(circleColor),blue(circleColor),255-j); 
        ellipse(holeX[i], holeY[i], CircleDia, CircleDia);
        popMatrix();
      }
      if (( i + 1) == holeX.length)
      {
        //connect the last point with the first one
        xt = (int) (holeX[i] + holeX[0] )/2;
        yt = (int) (holeY[i] + holeY[0] )/2;    
        {
          pushMatrix();
          translate(width/2,height/2); 
          ellipse(xt, yt,CircleDia, CircleDia);
          popMatrix();
        } 
      }
      
      else
      {
        xt = (int) (holeX[i] + holeX[i+1] )/2;
        yt = (int) (holeY[i] + holeY[i+1] )/2;    
        {
          pushMatrix();
          translate(width/2,height/2); 
          ellipse(xt, yt,CircleDia, CircleDia);
          popMatrix();
        } 
      } 
      i++;
    }
    }
  }
  
  else
  { 
    symColor = color(255,255,255,176);
    segmentColor = symColor; 
  }
  

  strokeWeight(1);
  stroke(255);



  if (draggingHole && HoleMode)
  {
      pointsActive = true;
      CircStartTime = timeNow;
      holeX[MovePoint] = mouseX - width/2;
      holeY[MovePoint] = mouseY - height/2;   
      xt = mouseX;
      yt = mouseY;
      fill(circleColor);
      ellipse(xt, yt,CircleDia, CircleDia);  
  }
  

  if ( dragging)
  {

    pointsActive = true;
    CircStartTime = timeNow;

    if (MovePoint == 0)
    {
      xt = width/2;

      if (mouseY < height/2)
      {      
        yValues[MovePoint] = mouseY - height/2; 
        yt = mouseY;    
      }
      else
      {     
        yValues[MovePoint] = 0; 
        yt = height/2;    
      }
 

    } 
    else if (MovePoint == len -1)    // Last point in array.
    { 

      xf = mouseX - width/2;
      yf = mouseY - height/2; 

      xf = -yf/sqrt(3); 

      if (yf > 0)
      {
        xf = 0;
        yf = 0; 
      }
       
      xValues[MovePoint] = (int) xf;
      yValues[MovePoint] = (int) yf;

      xt = (int) ( width/2  + xf);
      yt = (int) ( height/2  + yf);   

    } 
    else
    {
      xValues[MovePoint] = mouseX - width/2;
      yValues[MovePoint] = mouseY - height/2;   
      xt = mouseX;
      yt = mouseY;

    }
    fill(circleColor);
    ellipse(xt, yt,CircleDia, CircleDia);  
  }
  else
  {
    if(HoleMode)
    {
      i = 0;
      while(i<holeX.length)
      {
        
        if (overCircle((int) holeX[i] + width/2, (int) holeY[i] + height/2, CircleDia))
        {
          pointsActive=true; 
          CircStartTime = timeNow;
          pushMatrix();
          translate(width/2,height/2);
          fill(circleColor);
          stroke(circleStroke);
          ellipse(holeX[i], holeY[i], CircleDia, CircleDia);
          popMatrix();
        }
        else if (pointsActiveOld) 
        {   
          pushMatrix();
          translate(width/2,height/2);
          fill(emptyCircle);
          stroke(circleStroke);
          ellipse(holeX[i], holeY[i], mtCircleDia, mtCircleDia);
          popMatrix(); 
        }
      
        if (i < holeX.length-1)
        {
  
          xt = (int) (holeX[i] + holeX[i+1] )/2;
          yt = (int) (holeY[i] + holeY[i+1] )/2;    
        }
        else
        {
          xt = (int) (holeX[i] + holeX[0] )/2;
          yt = (int) (holeY[i] + holeY[0] )/2;   
        }
      
        if (overCircle (xt + width/2,yt+ height/2,  CircleDia)) 
        {
          pointsActive=true; 

          CircStartTime = timeNow;
          pushMatrix();
          translate(width/2,height/2);
          fill(circleColor);
          ellipse(xt, yt,CircleDia, CircleDia);
          popMatrix();
        } 
        else if (pointsActiveOld) 
        { 
          pushMatrix();
          stroke(circleStroke);
          translate(width/2,height/2);
          fill(emptyCircle);
          ellipse(xt, yt,mtCircleDia, mtCircleDia);
          popMatrix(); 
        } 
      
      
        i++;
      }
    }
    i = 0;
    while (i < len)
    { 
      if (overCircle((int) xValues[i] + width/2, (int) yValues[i] + height/2, CircleDia))
      {
        pointsActive=true; 
        CircStartTime = timeNow;
        pushMatrix();
        translate(width/2,height/2);
        fill(circleColor);
        stroke(circleStroke);
        ellipse(xValues[i], yValues[i], CircleDia, CircleDia);
        popMatrix();
      }
      else if (pointsActiveOld) 
      {   
        pushMatrix();
        translate(width/2,height/2);
        fill(emptyCircle);
        stroke(circleStroke);
        ellipse(xValues[i], yValues[i], mtCircleDia, mtCircleDia);
        popMatrix(); 
      }

      if (( i + 1) < len)
      {

        xt = (int) (xValues[i] + xValues[i+1] )/2;
        yt = (int) (yValues[i] + yValues[i+1] )/2;    

        if (overCircle (xt + width/2,yt+ height/2,  CircleDia)) 
        {
          pointsActive=true; 

          CircStartTime = timeNow;
          pushMatrix();
          translate(width/2,height/2);
          fill(circleColor);
          ellipse(xt, yt,CircleDia, CircleDia);
          popMatrix();
        } 
        else if (pointsActiveOld) 
        { 
          pushMatrix();
          stroke(circleStroke);
          translate(width/2,height/2);
          fill(emptyCircle);
          ellipse(xt, yt,mtCircleDia, mtCircleDia);
          popMatrix(); 
        } 
      } 
      i++;
    } 
  }



  // Draw text:

  fill(255,255,255,128);
  text("Clear", 530, 630);
  text("Save", 580, 630);
  text("Mirror", 430, 630);
   text("Hole", 480, 630);
 

  if (overRect(525, 610, 40, 25) )
  {
    CircStartTime = timeNow;
    pointsActive=true; 
    //fill(circleColor);
    //rect(525, 610, 40, 25);
    fill(255);
    text("Clear", 530, 630);
  }

  if (overRect(575, 610, 40, 25) )
  {
    CircStartTime = timeNow;
    pointsActive=true; 
    //fill(circleColor);
    //rect(575, 610, 40, 25);
    fill(255); 
    text("Save", 580, 630);

  }




  if ((timeNow - InitTime) < 10540)// 6350
  {  
      
    
    TimeTemp = (timeNow - InitTime);
      
      if (TimeTemp > 8000)
      j = (int) ((TimeTemp - 8000) / 20);    
    else
      j = 0;  

 fill(255,255,255,128-j); 


 textFont(font_MB48, 48); 
 text("Snowflake 2.0", 10, 40); 
// text("SymmetriSketch", 176, 355); 
 
 textFont( font_MB24, 20);  
  
  text("Evil Mad Scientist Laboratories", 425, 25); 
  text("www.evilmadscientist.com", 450, 42); 
 fill(255);  
  } 
 



} 
