# -*- coding: utf-8 -*-
"""
Created on Sun Jan 22 11:22:04 2017
   result1=result;
    
    rect = cv2.minAreaRect(contours[max_i])
    box = cv2.boxPoints(rect)
    box = np.int0(box)
    result1= cv2.drawContours(result1,[box],0,(40,40,0),6)

    

@author: guest123
"""
#===importing the files needed===#
import numpy as np
import cv2


#======the constants========#

#bothead is red
lower_red=np.array([0,26,0])
upper_red=np.array([10,254,255])
#bot body is green 
lower_green=np.array([58,98,34])
upper_green=np.array([88,180,255])
#targets are yellow
lower_yellow=np.array([25,36,207])
upper_yellow=np.array([37,255,255])
#obstacle are blue
lower_blue=np.array([60,181,13])
upper_blue=np.array([131,255,235])
#town center is brown
lower_brown=np.array([0,28,1])
upper_brown=np.array([42,157,211])



#========functions defined here 
def colour_seg(img,low_range,up_range,size1,size2,size3,size4):
       
       mask=cv2.inRange(img,low_range,up_range)
       kernel1 = np.ones((size1,size1),np.uint8)
       kernel2 = np.ones((size2,size2),np.uint8)
       kernel3 = np.ones((size3,size3),np.uint8)
       kernel4 = np.ones((size4,size4),np.uint8)
       opening =cv2.morphologyEx(mask,cv2.MORPH_OPEN,kernel3)
       erosion =cv2.erode(opening,kernel1,iterations=1)
       dilation =cv2.dilate(erosion,kernel2,iterations=1)
       closing =cv2.morphologyEx(dilation,cv2.MORPH_CLOSE,kernel4)
#      cv2.imshow('closing',closing)
#      im_floodfill = closing.copy()
#      # Mask used to flood filling.
#      # Notice the size needs to be 2 pixels than the image.
#      h, w = closing.shape[:2]
#      mask = np.zeros((h+2, w+2), np.uint8)
#      # Floodfill from point (0, 0)
#      cv2.floodFill(im_floodfill, mask, (0,0), 255);
#      # Invert floodfilled image
#      im_floodfill_inv = cv2.bitwise_not(im_floodfill)
#      # Combine the two images to get the foreground.
#      im_out = closing | im_floodfill_inv
       return closing
            
def colour_seg_brown(img,low_range,up_range,size1,size2,size3,size4):
    mask=cv2.inRange(img,low_range,up_range)
    kernel1 = np.ones((size1,size1),np.uint8)
    kernel3 = np.ones((size3,size3),np.uint8)
    kernel4 = np.ones((size4,size4),np.uint8)
    opening =cv2.morphologyEx(mask,cv2.MORPH_OPEN,kernel3)
    erosion =cv2.erode(opening,kernel1,iterations=1)
    closing =cv2.morphologyEx(erosion,cv2.MORPH_CLOSE,kernel4)
    return closing

      
       
       
def max_area_contour(img,contours):
    l=len(contours)
    area=0;
    max_i=0;
    for i in range(0,l-1):
      area1=cv2.contourArea(contours[i])
      if area1>area:
         max_i=i
    return max_i
    


def sendImg(outImg, path,z):
    cv2.imwrite(path+"im"+str(z)+".png" , outImg)
           
    
def bounding_box_fill(img,contours,i):
    rect = cv2.minAreaRect(contours[i])
    box = cv2.boxPoints(rect)
    box = np.int0(box)
    result = cv2.drawContours(img,[box],0,(255,255,255),-1)
    return result

    
 
        
#===folders to=====#     
folder1 = "\\\VIVU\\Users\\vivu-pc\\Desktop\\fwood\\"
folder2 = "\\\VIVU\\Users\\vivu-pc\\Desktop\\twnctr\\"
folder3 = "\\\VIVU\\Users\\vivu-pc\\Desktop\\obs\\"
folder4 = "\\\VIVU\\Users\\vivu-pc\\Desktop\\bot\\"

       
#===capture of video===#
cap = cv2.VideoCapture(1)

z=1
while(True):
    
    #image capture and read in hsv format
    ret, frame = cap.read()
    frame=cv2.GaussianBlur(frame,(7,7),0)
    #frame = cv2.fastNlMeansDenoisingColored(frame1,None,10,10,7,21)
    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
       
    #layers to be seperated
    if z<10:
       binBlue=colour_seg(hsv,lower_blue,upper_blue,4,4,4,4)
       binYellow=colour_seg(hsv,lower_yellow,upper_yellow,4,5,4,4)
       sendImg(binYellow,folder1,z)
       sendImg(binBlue,folder3,z)
       
       #send centre
#       binBrown=colour_seg_brown(hsv,lower_brown,upper_brown,2,10,5,22)
#       img,contours_brown,hierarchy = cv2.findContours(binBrown.copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_TC89_L1)
#       brown_i=max_area_contour(binBrown,contours_brown)
#       binBrown=bounding_box_fill(binBrown.copy(),contours_brown,brown_i)
#       img,contours_brown,hierarchy = cv2.findContours(binBrown.copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_TC89_L1)
#       brown_i=max_area_contour(binBrown,contours_brown)
#       cnt_brown = contours_brown[brown_i]
#       M_BROWN = cv2.moments(cnt_brown)
#       if M_BROWN["m00"] == 0:
#          M_BROWN["m00"]=0.01              
#       twn_ctr_x = int(M_BROWN["m10"] / M_BROWN["m00"])
#       twn_ctr_y = int(M_BROWN["m01"] / M_BROWN["m00"])
#       f_tc=open(folder2+"twnctr"+str(z)+".dat","w")
#       f_tc.write('{:d}\n'.format(twn_ctr_x));
#       f_tc.write('{:d}\n'.format(twn_ctr_y));
#      
       #end of giving images to nwxt end        
          
          
    #bot image body ,head and twncenter .....      
    binRed=colour_seg(hsv,lower_red,upper_red,4,5,2,4)
    binGreen=colour_seg(hsv,lower_green,upper_green,4,4,4,4) 
    
#   contours made of  different layer
    img,contours_red,hierarchy = cv2.findContours(binRed.copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_TC89_L1)
    img,contours_green,hierarchy = cv2.findContours(binGreen.copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_TC89_L1)
    
    #img,contours_yellow,hierarchy = cv2.findContours(binYellow.copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_TC89_L1)
    #img,contours_blue,hierarchy = cv2.findContours(binBlue.copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_TC89_L1)

    

    # the max area among the contours are measured    
    red_i=max_area_contour(binRed,contours_red)
    green_i=max_area_contour(binGreen,contours_green)
    
    
    #fill the max area more accurately
    binRed=bounding_box_fill(binRed.copy(),contours_red,red_i)
    binGreen=bounding_box_fill(binGreen.copy(),contours_green,green_i)
    
    
    #again calculate the  max area  more accurate centroid 
    img,contours_red,hierarchy = cv2.findContours(binRed.copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_TC89_L1)
    img,contours_green,hierarchy = cv2.findContours(binGreen.copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_TC89_L1)
    
    red_i=max_area_contour(binRed,contours_red)
    green_i=max_area_contour(binGreen,contours_green)
    
    
    #calculate moments
    cnt_red = contours_red[red_i]
    M_RED = cv2.moments(cnt_red)
       
    cnt_green = contours_green[green_i]
    M_GREEN = cv2.moments(cnt_green)
    
    
    if M_RED["m00"] == 0:
        M_RED["m00"]=0.01
    head_x = int(M_RED['m10']/M_RED['m00'])
    head_y = int(M_RED['m01']/M_RED['m00'])
        
    if M_GREEN["m00"] == 0:
        M_GREEN["m00"] =0.01
    body_x = int(M_GREEN['m10']/M_GREEN['m00'])
    body_y = int(M_GREEN['m01']/M_GREEN['m00']) 
        
    f_bot=open(folder4+"bot"+str(z)+".dat","w")
    f_bot.write('{:d}\n'.format(head_x));
    f_bot.write('{:d}\n'.format(head_y));
    f_bot.write('{:d}\n'.format(body_x));
    f_bot.write('{:d}\n'.format(body_y));
    f_bot.close()
    z=z+1
      
    cv2.imshow('frame',frame)
    cv2.imshow('binRed',binRed)
    cv2.imshow('binGreen',binGreen)
    cv2.imshow('binYellow',binYellow)
    cv2.imshow('binBlue',binBlue)
    

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()