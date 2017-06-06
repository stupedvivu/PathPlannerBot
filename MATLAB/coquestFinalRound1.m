%this is an image processing code for conquest event, IIT, kharagpur
%This code is written by VIVEK SHARMA..
%IIEST,SHIBPUR...
%GIVEN THRESHOLD VALUES MAY NOT WORK FOR YOUR ENVIROMENT...
%CHANGE THE THRESHOLDS ACCORDINGLY..

%=========initializing Bluetooth Module===================================%
msgbox('initiating the connection with HC-05...');
arduino = Bluetooth('HC-05',1);
fopen(arduino);
%=========================================================================%


%=========adding the image path and acquiring the first image=============%
 msgbox('first image acquired');
 path = 'C:\Users\vivu-pc\Desktop\fwood\';%path of the image feed coming from other computer...
 list = dir(path);
 [r,~] = size(list);
 imname = strcat('im',int2str(r-5),'.png');
 img_resource = imread(strcat(path,imname));
%=========================================================================%

%=================declaring global variables==============================%
%adjust these threshold variables for better movement of the bot.
distance_thresh = 15;
angle_thresh = 20;
flag_reached = 0;
%=========================================================================%


%=======================labeling the targets==============================%
%find bounding box.....
%find Area.....
msgbox('Finding the bounding box and Area of the objects');
[img_resource_labeled,no_of_resource] = bwlabel(img_resource);
stat_bounding_box = regionprops(img_resource_labeled,'BoundingBox');
stat_area = regionprops(img_resource_labeled,'Area');
stat_resource_centroid = regionprops(img_resource_labeled,'centroid');

% [img_town_labeled,no_of_town] = bwlabel(img_town);
% stat_town_centroid = regionprops(img_town_labeled,'centroid');
% x_centre = stat_town_centroid(1).Centroid(1); %important parameter....
% y_centre = stat_town_centroid(1).Centroid(2); %important parameter....

%%UNCOMMENT THE FOLLOWING PIECE OF STATEMENTS IF THE BOT IS NOT PLACED AT
%%THE ORIGINAL CENTRE POSITION...
% path = 'C:\Users\vivu-pc\Desktop\twnctr';%path of the image feed coming from other computer...
% list = dir(path);
% [r,~] = size(list);
% filename = strcat(path,'twnctr',num2str(r-5),'.dat');
% information_array = load(filename);

x_centre = information_array(1,1);  % information_array(1,1); %assuming the town centre is at initial position of the bot..
y_centre = information_array(1,2);  % information_array(1,2);
%=========================================================================%


%=======storing the distances from town to targets in a no_of_resource x 3 matrix======%
%detecting the corresponding cost....
msgbox('generating the Target_matrix array');
Target_matrix = zeros(no_of_resource,3);
for i = 1:no_of_resource
    distance = sqrt( ( ( stat_resource_centroid(i).Centroid(1) - x_centre ) ^ 2 ) + ( ( stat_resource_centroid(i).Centroid(2) - y_centre ) ^ 2 ) );
    area_ratio = ( stat_area(i).Area / ( stat_bounding_box(i).BoundingBox(3) * stat_bounding_box(i).BoundingBox(4) ) );
    
    %determining cost......
    if stat_area(i).Area >= 90
    if area_ratio >=0.5 && area_ratio <= 0.8
        cost = 108;
    else
        cost = 100;
    end
    end
    
    Target_matrix(i,1) = i;
    Target_matrix(i,2) = distance;
    Target_matrix(i,3) = cost;
end
%=========================================================================%

%%Algorithm to select the target according to the maximum cost collection
%%of the resources..
msgbox('running sorting algorithm');
%==============================sort algo==================================%
for i = 1:no_of_resource
    for j = (i+1):no_of_resource
        if Target_matrix(i,2) >Target_matrix(j,2)
            t1 = Target_matrix(i,1);
            t2 = Target_matrix(i,2);
            t3 = Target_matrix(i,3);
            Target_matrix(i,1) = Target_matrix(j,1);
            Target_matrix(i,2) = Target_matrix(j,2);
            Target_matrix(i,3) = Target_matrix(j,3);
            Target_matrix(j,1) = t1;
            Target_matrix(j,2) = t2;
            Target_matrix(j,3) = t3;
        end
    end
end

for i = 1:no_of_resource
    if( i==no_of_resource )
        break;
    end
    for j = (i+1):no_of_resource
        if abs( Target_matrix(i,2) - Target_matrix(j,2) ) <= 50 && ( Target_matrix(i,3) < Target_matrix(j,3) )
            t1 = Target_matrix(i,1);
            t2 = Target_matrix(i,2);
            t3 = Target_matrix(i,3);
            Target_matrix(i,1) = Target_matrix(j,1);
            Target_matrix(i,2) = Target_matrix(j,2);
            Target_matrix(i,3) = Target_matrix(j,3);
            Target_matrix(j,1) = t1;
            Target_matrix(j,2) = t2;
            Target_matrix(j,3) = t3;
        end
    end
end
%=========================================================================%



msgbox('main loop reached');
iMain = 1;
while iMain <= no_of_resource
    
    index = Target_matrix(iMain,1); %important parameter....
    target_centroid_x = stat_resource_centroid(index).Centroid(1);
    target_centroid_y = stat_resource_centroid(index).Centroid(2);
    
    
    for j = 1:2
    
    msgbox('going to target',num2str(index));
    while 1 %secondary loop ot reach the iMain^th target....
    
    %============reading the centroid of the bot================%
    path = 'C:\Users\vivu-pc\Desktop\bot\';
    list = dir(path);
    [r,~] = size(list);
    filename = strcat(path,'bot',num2str(r-5),'.dat');
    information_array = load(filename);
    %===========================================================%
    
    bot_head_x = information_array(1,1);
    bot_head_y = information_array(2,1);
    bot_body_x = information_array(3,1);
    bot_body_y = information_array(4,1);
    
    bot_centroid_x = ( bot_head_x + bot_body_x ) / 2;
    bot_centroid_y = ( bot_head_y + bot_head_y ) / 2;
    
    
    %calculating the current statistics....
    curr_distance = sqrt( ( ( target_centroid_x - bot_centroid_x ) ^ 2 ) + ( ( target_centroid_y - bot_centroid_y ) ^ 2 ) );
    
    if curr_distance <= distance_thresh
        msgbox('successfully reached the target',num2str(index));
        fprintf(arduino,'%c','p');
        pause(1);
        flag_reached = 1;
        break;
    end
    
    bot_angle = -atan2d( ( bot_head_y - bot_body_y ),( bot_head_x - bot_body_x ) );
    if bot_angle < 0
        bot_angle = -abs(bot_angle) + 360;
    end
    
    target_angle = -atan2d( ( target_centroid_y - bot_body_y ),( target_centroid_x - bot_body_x ) );
    if target_angle < 0
        target_angle = -abs(target_angle) + 360;
    end
    
    angle = bot_angle - target_angle;
    curr_angle = min(abs(angle),(360-abs(angle)));
    if curr_angle ~= abs(angle)
    if angle < 0
        curr_angle = abs(curr_angle);
    else
        curr_angle = -curr_angle;
    end
    else
        curr_angle = angle;
    end
    %%=========================================================================%

    
    %-----------------------------------movement of the bot---------------%
    
    if curr_angle >= -angle_thresh && curr_angle <= angle_thresh
            fprintf(arduino,'%c','f');
            pause(0.1);
    end
    
    
    if curr_angle >= angle_thresh
        %turn right..
        fprintf(arduino,'%c','r');
        pause(0.1);
    else if curr_angle <= -angle_thresh
            %turn left..
            fprintf(arduino,'%c','l');
            pause(0.1);
        end
    end
    %---------------end of secondary loop------------%
    end
    
    
    
    
    
    if flag_reached == 1 %condition to check whether the bot has reached to the target...
        msgbox('returnning to the town centre');
        while 1 %returning to the town centre....
            %============reading the centroid of the bot================%
             path = 'C:\Users\vivu-pc\Desktop\bot\';
            list = dir(path);
            [r,~] = size(list);
            filename = strcat(path,'bot',num2str(r-5),'.dat');
            information_array = load(filename);
            %===========================================================%
    
            bot_head_x = information_array(1,1);
            bot_head_y = information_array(2,1);
            bot_body_x = information_array(3,1);
            bot_body_y = information_array(4,1);
    
            bot_centroid_x = ( bot_head_x + bot_body_x ) / 2;
            bot_centroid_y = ( bot_head_y + bot_head_y ) / 2;
            
            %calculating the current statistics for PID....
            curr_distance = sqrt( ( ( x_centre - bot_centroid_x ) ^ 2 ) + ( ( y_centre - bot_centroid_y ) ^ 2 ) );
    
            if curr_distance <= distance_thresh
                msgbox('town centre reached');
                fprintf(arduino,'%c','p');
                pause(1);
                flag_reached = 0;
                break;
            end
    
            bot_angle = -atan2d( ( bot_head_y - bot_body_y ),( bot_head_x - bot_body_x ) );
            if bot_angle < 0
                bot_angle = -abs(bot_angle) + 360;
            end
    
            target_angle = -atan2d( ( y_centre - bot_body_y ),( x_centre - bot_body_x ) );
            if target_angle < 0
                target_angle = -abs(target_angle) + 360;
            end
    
            angle = bot_angle - target_angle;
            curr_angle = min(abs(angle),(360-abs(angle)));
            if curr_angle ~= abs(angle)
            if angle < 0
                curr_angle = abs(curr_angle);
            else
                curr_angle = -curr_angle;
            end
            else
                curr_angle = angle;
            end
            %%=========================================================================%
            
            %-----------------------------------movement of the bot---------------%
            
            if curr_angle >= -angle_thresh && curr_angle <= angle_thresh
                    fprintf(arduino,'%c','f');
                    pause(0.1);
            end
            
            
            if curr_angle >= angle_thresh
                    %turn right...
                    fprintf(arduino,'%c','r');
                    pause(0.1);
            else if curr_angle <= -angle_thresh
                    %turn left..
                    fprintf(arduino,'%c','l');
                    pause(0.1);
                end
            end
            %-------------movement of the bot end-------------------------%
        end
    end
    
    end
    
    iMain = iMain + 1;
end
