#RobotArm-CohesiveGM-Rheology
This program analyzes data taken from labview code which measures force from the nano43 FT sensor and gets displacement or strain from optitrack code

to take data which will be properly formatted for use by this analysis code, you must take data using  [ArduinoSmart](https://github.com/wsavoie/ArduinoSmarticle) repository specifically the labview code found in the [entangledSmarticle](https://github.com/wsavoie/ArduinoSmarticle/tree/Photoresistors/entangledSmarticle) folder. The receiving computer must be running motive and have matlab open while running the UDPserver.m script.

The code which runs on the robot arm to take the data is SS. A pic which shows what the setup looks like can be found at [setup picture](https://github.com/wsavoie/RobotArm-CohesiveGM-Rheology/blob/master/setupPic.jpg)
