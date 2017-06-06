The bot have to collect the resources by making maximum profit, for more details open: ProblemStatement.pdf.
The top image feed of the arena was providede by a USB WebCam.

HARDWARE REQUIRED:
1. arduino.
2. L293D motor driver.  
3. two BO motors.
4. caster wheel.
5. HC-05 blutooth module.
6. LED.

SOFTWARE:
The code consists of three parts: 1. openCV using python, 2. Matlab, 3. Arduino

this requires two seperate computers, one for image processing part using openCV and other to manipulate the images
and send the required instructions to the bot.

PROCEDURE:
1. connect two computers via LAN CABLE.
2. copy the OpenCVCode.py code to any python IDE and connect the camera feed.
3. upload ArduinoUpload.ino file to the arduino using arduino ide.
4. copy the codes of matlab from matlab folder in a single directory.
5. switch on the arduino and connect the blutooth(HC-05) with the computer in which matlab codes are going to be executed.
6. run OpenCVCode.py.
7. run MatlabUpload.m. 
