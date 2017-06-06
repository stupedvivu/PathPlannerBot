# -*- coding: utf-8 -*-
"""
Created on Mon Jan 23 10:05:28 2017

@author: guest123
"""

# -*- coding: utf-8 -*-
"""
Created on Sun Jan 22 12:10:14 2017

@author: guest123
"""

import cv2
import numpy as np

#optional argument
def nothing(x):
    pass

cv2.namedWindow('image')

#easy assigments
hh='Hue High'
hl='Hue Low'
sh='Saturation High'
sl='Saturation Low'
vh='Value High'
vl='Value Low'

cv2.createTrackbar(hl, 'image',0,179,nothing)
cv2.createTrackbar(hh, 'image',0,179,nothing)
cv2.createTrackbar(sl, 'image',0,255,nothing)
cv2.createTrackbar(sh, 'image',0,255,nothing)
cv2.createTrackbar(vl, 'image',0,255,nothing)
cv2.createTrackbar(vh, 'image',0,255,nothing)



frame=cv2.imread('C:\Users\guest123\Desktop\conquest new\1.jpg',1)

#rame=cv2.GaussianBlur(frame,(5,5),0)
    #convert to HSV from BG
hsv=cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)

cv2.imshow('hsv', hsv)

    #read trackbar positions for all
hul=cv2.getTrackbarPos(hl, 'image')
huh=cv2.getTrackbarPos(hh, 'image')
sal=cv2.getTrackbarPos(sl, 'image')
sah=cv2.getTrackbarPos(sh, 'image')
val=cv2.getTrackbarPos(vl, 'image')
vah=cv2.getTrackbarPos(vh, 'image')
    #make array for final values
HSVLOW=np.array([hul,sal,val])
HSVHIGH=np.array([huh,sah,vah])

    #apply the range on a mask
mask = cv2.inRange(hsv,HSVLOW, HSVHIGH)
res = cv2.bitwise_and(frame,frame, mask =mask)

cv2.imshow('image', res)
cv2.imshow('yay', frame)
    
cv2.waitKey(0)
cv2.destroyAllWindows()
