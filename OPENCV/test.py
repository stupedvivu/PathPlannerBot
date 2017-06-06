# -*- coding: utf-8 -*-
"""
Created on Mon Jan 23 19:20:31 201
@author: guest123
"""
import numpy as np
import cv2

contours = np.array( [ [50,50], [50,150], [150, 150], [150,50] ] )

img = np.zeros( (200,200) ) # create a single channel 200x200 pixel black image 
epsilon = 0.1*cv2.arcLength(contours,True)
approx = cv2.approxPolyDP(contours,epsilon,True)

cv2.fillPoly(img, pts =[contours], color=(255,255,255))
cv2.imshow(" ", img)
cv2.waitKey()