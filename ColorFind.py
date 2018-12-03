#!/usr/bin/env python
# coding: utf-8

# In[26]:


import serial
import numpy as np
import cv2

cap = cv2.VideoCapture(0)

Lower = np.array([[130, 40, 15], [55, 50, 30], [55, 35, 90]]) # BGR x BGR Lower values
Upper = np.array([[160, 60, 25], [65, 65, 45], [70, 50, 110]])

ser = serial.Serial('COM3', 9600)
cam = cv2.VideoCapture(0)

while True:
    ret_val, image = cam.read()
    
    color = cv2.mean(image)
    color = color[0:3]
    
    if (color[0] < Upper[0,0] and color[0] > Lower[0,0] and
        color[1] < Upper[0,1] and color[1] > Lower[0,1] and
        color[2] < Upper[0,2] and color[2] > Lower[0,2]):
        
        serial_color = 3
        
    elif (color[0] < Upper[1,0] and color[0] > Lower[1,0] and
        color[1] < Upper[1,1] and color[1] > Lower[1,1] and
        color[2] < Upper[1,2] and color[2] > Lower[1,2]):
        
        serial_color = 2
        
    elif (color[0] < Upper[2,0] and color[0] > Lower[2,0] and
        color[1] < Upper[2,1] and color[1] > Lower[2,1] and
        color[2] < Upper[2,2] and color[2] > Lower[2,2]):
        
        serial_color = 1
    
    else:
        serial_color = 0
        
        
    print(serial_color)
    ser.write(serial_color)
    
    if cv2.waitKey(1) == 27: 
        break  # esc to quit
    cv2.destroyAllWindows()


# In[ ]:




