/*
M&M Dispenser
ENME 351 Final Project
Author: Ian Michel-Tyler
*/

#include <Servo.h>

Servo red_servo; // Create servo objects for three servos
Servo green_servo;
Servo blue_servo;

int U = 0; // Define global variables
int L = 0;
int D = 0;
int R = 0;
int color; // variable to control which motor actuates

// Initial servo angles found by trial and error
int b_angle_init = 84;
int g_angle_init = 89;
int r_angle_init = 79;

// Interval between actuating to desired angle and initial angle
int dur = 50;

// Define pin for which control script runs
int controlPin = 12;

void setup() {
  Serial.begin(9600);

  // Attach servos to pins
  red_servo.attach(8);
  green_servo.attach(9);
  blue_servo.attach(10);

  // Set servo to starting position
  red_servo.write(r_angle_init);
  green_servo.write(g_angle_init);
  blue_servo.write(b_angle_init);

  // Set button pins and control pin to input
  pinMode(2,INPUT);
  pinMode(3,INPUT);
  pinMode(4,INPUT);
  pinMode(5,INPUT);
  pinMode(controlPin,INPUT);

  // Establish handshake with processing over serial
  // Code adapted from Arduino Serial_Call_Response example at https://www.arduino.cc/en/Tutorial/SerialCallResponse
  establishContact();
}

void loop() {

  // If the switch is HIGH, the input to the dispenser is the processing game
  if (digitalRead(controlPin) == HIGH){
    // If bytes are available from the serial stream, do:
    if (Serial.available() > 0){
      // Accept information before sending
      color = Serial.read();
      // Read button pins and write to serial
      U = digitalRead(2);
      L = digitalRead(3);
      D = digitalRead(4);
      R = digitalRead(5);
      Serial.write(U);Serial.write(L);Serial.write(D);Serial.write(R);
      // Delay ample time to allow processing to execute
      delay(50);
  }
  // If the code received is red, actuate red servo to dispense red M&M
  if (color == 1){
      red_servo.write(r_angle_init+15);
      delay(dur);
      red_servo.write(r_angle_init);
  }
  // Same but green
  else if(color == 2){
      green_servo.write(g_angle_init+15);
      delay(dur);
      green_servo.write(g_angle_init);
  }
  // Same but blue
  else if(color == 3){
      blue_servo.write(b_angle_init+15);
      delay(dur);
      blue_servo.write(b_angle_init);
  }
}
  // If switch is LOW, input becomes python script running rudimentary color classifier
  else if(digitalRead(controlPin) == LOW){
    if (Serial.available() > 0) {
      color = Serial.read();
      // For some reason I decided to use characters for this one
      if(color == 'R'){
        red_servo.write(r_angle_init+15);
        delay(dur);
        red_servo.write(r_angle_init);
      }
      else if(color == 'G'){
        green_servo.write(g_angle_init+15);
        delay(dur);
        green_servo.write(g_angle_init);
      }
      else if(color == 'B'){
        blue_servo.write(b_angle_init+15);
        delay(dur);
        blue_servo.write(b_angle_init);
      }
      else{
        delay(50);
      }
    }
    else{
      delay(50);
    }
    delay(50);
  }
}

// Code adapted from Arduino Serial_Call_Response example at https://www.arduino.cc/en/Tutorial/SerialCallResponse
void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print('A');   // send a capital A until reciprocated
    delay(300);
}
}
