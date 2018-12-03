/*
M&M Dispenser
ENME 351 Final Project
Author: Ian Michel-Tyler
*/

import processing.serial.*;
Serial myPort;

int dot_size = 20;
int x_min = 10;
int y_min = 10;
int x_max = 790;
int y_max = 790;
int x_now = (10 + 20*floor(random(39)));
int y_now = (10 + 20*floor(random(39)));
int prize_x = 20*floor(random(40));
int prize_y = 20*floor(random(40));
int prize_id = ceil(random(3));
int score = 0;
int px_adjust;
int py_adjust;
int x_prev;
int y_prev;
boolean firstContact = false;
int serialCount = 0;
int serialInArray[] = new int[4];
boolean reset = false;

// Function to reset board after prize is captured
void reset_board(){
  
  // Reset the reset variable
  reset = false;
  // Flash screen 
  background(225);
  // Redraw player
  fill(0,225,225);
  ellipse(x_now,y_now,dot_size,dot_size);
  
  // Create random location and color for prize
  prize_id = ceil(random(3));
  prize_x = 20*floor(random(40));
  prize_y = 20*floor(random(40));
  
  // Draw prize
  if (prize_id == 1){
    fill(255,0,0);
    rect(prize_x,prize_y,dot_size,dot_size);
  }
  else if (prize_id == 2){
    fill(0,255,0);
    rect(prize_x,prize_y,dot_size,dot_size);
  }
  else if (prize_id == 3){
    fill(0,0,255);
    rect(prize_x,prize_y,dot_size,dot_size);
  }
  
  // Because the rectangle object uses top left corner location and ellipse uses center location as parameters, this variable "translates" location
  py_adjust = prize_y+10;
  px_adjust = prize_x+10;
}

void setup(){
  
  // Initializes background and size
  background(225); 
  size(800,800);
  stroke(225);
  
  // Draws cyan circle at random player starting point
  fill(0,225,225); 
  ellipse(x_now,y_now,dot_size,dot_size); 
  
  // Initialize prize location and color
  if (prize_id == 1){
    fill(255,0,0);
    rect(prize_x,prize_y,dot_size,dot_size);
  }
  else if (prize_id == 2){
    fill(0,255,0);
    rect(prize_x,prize_y,dot_size,dot_size);
  }
  else if (prize_id == 3){
    fill(0,0,255);
    rect(prize_x,prize_y,dot_size,dot_size);
  }
  
  py_adjust = prize_y+10;
  px_adjust = prize_x+10;

  // Create serial object using COM3 and clear buffer
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.clear();
  
}





void draw() {
  
  // Display score in top right corner
  fill(0);
  textSize(20);
  text("Score = " + str(score),650,50);
  
  // Cover previous circle
  fill(225);
  stroke(225);
  rect(x_prev,y_prev,dot_size,dot_size);
  
  // Draw circle at new player location
  fill(0,225,225);
  ellipse(x_now,y_now,dot_size,dot_size);
  
  // If board needs reseting
  if (reset == true){
    reset_board(); // Calls reset function to create new prize object
  }
}

// Establish handshake with arduino over serial
// Code adapted from Arduino Serial_Call_Response example at https://www.arduino.cc/en/Tutorial/SerialCallResponse
void serialEvent(Serial myPort) {
  
    // read incoming byte from buffer
    int inByte = myPort.read();
    
    // If the byte is the first 'A' read from the arduino then clear buffer and send confirmation receipt to serial. Processing starts listening.
    if (firstContact == false) {
      if (inByte == 'A') {
        myPort.clear();
        firstContact = true;
        myPort.write('A');
      }
    }
    // After handshake established, incoming bytes representing game controls are stored in an array. 
    // When all four are received they are configured to the game inputs.
    else {
      serialInArray[serialCount] = inByte;
      serialCount++;
      
      if (serialCount > 3){
        int U = serialInArray[0];
        int L = serialInArray[1];
        int D = serialInArray[2];
        int R = serialInArray[3];
        
        // Store previous coordinates for later use. Probably a smarter way to do the later computations without this variable.
        x_prev = x_now-10;
        y_prev = y_now-10;
        
        // Compute new coordinates of player after move
        x_now = x_now + 20 * (R-L);
        y_now = y_now + 20 * (D-U);
        
        // Boundary conditions
        if (x_now < x_min){
          x_now = x_max;
        }
        
        if (x_now > x_max){
          x_now = x_min;
        }
        
        if (y_now < y_min){
          y_now = y_max;
        }
        
        if (y_now > y_max){
          y_now = y_min;
        }    

        // If the player gets the prize ---> send prize color code to arduino for dispensing
        if ((x_now == px_adjust) && (y_now == py_adjust)){
          // Cast variable from int to byte for serial transfer
          myPort.write(byte(prize_id));
          // Make sure new prize is generated
          reset = true;
          // Keep track of score
          score++;
        }
        
        // Otherwise ready for next move
        else{
          myPort.write('A');
        }
        // Prepare for new set of four bytes
        serialCount = 0;
      }
        
     }
}
