function [ pathStream, pathLength ] =astarpathplanner( imBinMap, scaleDownFactor, toShowProcessOrNot, toGoDiagonallyOrNot, botPos, goalPos, isSilent )
%written by suprotik dey
%imBinMap is the binary map image
%scaleDownFactor is the factor for scaling down the image so that the operation can be done smoothly, please keep it high
%toShowProcessOrNot should be kept false for realtime
%toGoDiagonallyOrNot is true if bot can go diagonally else false
%botPos is the initial position of bot in x,y format
%goalPos is the destination in x,y format

%usage:  astarpathplanner(obstacle_label,4,false,true,[20,20],[300,300],false);


%parameters--------------------------------------------------------------------------

[rowsOriginal, colsOriginal] = size(imBinMap);

if(toShowProcessOrNot ==true)
    imshow(imBinMap);
    waitforbuttonpress; 
end

mapOriginal = imBinMap;

for ilab = 1:rowsOriginal
    for jlab = 1:colsOriginal
        if(imBinMap(ilab,jlab) <0.02)
            mapOriginal(ilab,jlab) = 1.000;
        end
        if(imBinMap(ilab,jlab) >0.1)
            mapOriginal(ilab,jlab) = 0.00000;
        end
    end
end

if(toShowProcessOrNot ==true)
    imshow(mapOriginal);
    waitforbuttonpress; 
end


resolutionX = colsOriginal / scaleDownFactor;
resolutionY = rowsOriginal / scaleDownFactor;

source = [botPos(2),botPos(1)];
goal = [goalPos(2),goalPos(1)];

if toGoDiagonallyOrNot == true
    conn=[1 1 1; 
      1 2 1;
      1 1 1];
else
    conn=[0 1 0; % robot (marked as 2) can move up, left, right and down (all 1s), but not diagonally (all 0). you can increase/decrease the size of the matrix
           1 2 1;
             0 1 0];  
end

%   conn=[1 1 1 1 1; % another option of conn
%         1 1 1 1 1;
%         1 1 2 1 1;
%         1 1 1 1 1
%         1 1 1 1 1];

if toShowProcessOrNot == true
  display= true; % display processing of nodesfalse;
else
display = false;
end


%%%%% parameters end here %%%%%

mapResized=imresize(mapOriginal,[resolutionX resolutionY]);
%imshow(mapResized);
 
map=mapResized; % grow boundary by a unit pixel
for i=1:size(mapResized,1)
    for j=1:size(mapResized,2)
        if mapResized(i,j)<=0.01
            if i-1>=1, map(i-1,j)=0.0; end
            if j-1>=1, map(i,j-1)=0.0; end
            if i+1<=size(map,1), map(i+1,j)=0.0; end
            if j+1<=size(map,2), map(i,j+1)=0.0; end
            if i-1>=1 && j-1>=1, map(i-1,j-1)=0.0; end
            if i-1>=1 && j+1<=size(map,2), map(i-1,j+1)=0.0; end
            if i+1<=size(map,1) && j-1>=1, map(i+1,j-1)=0.0; end
            if i+1<=size(map,1) && j+1<=size(map,2), map(i+1,j+1)=0.0; end
        end
    end
end


source=double(int32((source.*[resolutionX resolutionY])./size(mapOriginal)));
goal=double(int32((goal.*[resolutionX resolutionY])./size(mapOriginal)));

if ~(feasiblePoint(source,map))
     fprintf('bot is on obstacle');
end
if ~feasiblePoint(goal,map), error('goal lies on an obstacle or outside map'); end
if length(find(conn==2))~=1, error('no robot specified in connection matrix'); end
    
%structure of a node is taken as positionY, positionX, historic cost, heuristic cost, total cost, parent index in closed list (-1 for source) 
Q=[source 0 heuristic(source,goal) 0+heuristic(source,goal) -1]; % the processing queue of A* algorihtm, open list
closed=ones(size(map)); % the closed list taken as a hash map. 1=not visited, 0=visited
closedList=[]; % the closed list taken as a list
pathFound=false;
tic;
counter=0;
colormap(gray(256));
while size(Q,1)>0
     [A, I]=min(Q,[],1);
     n=Q(I(5),:); % smallest cost element to process
     Q=[Q(1:I(5)-1,:);Q(I(5)+1:end,:)]; % delete element under processing
     if n(1)==goal(1) && n(2)==goal(2) % goal test
         pathFound=true;break;
     end
     [rx,ry,rv]=find(conn==2); % robot position at the connection matrix
     [mx,my,mv]=find(conn==1); % array of possible moves
     for mxi=1:size(mx,1) %iterate through all moves
         newPos=[n(1)+mx(mxi)-rx n(2)+my(mxi)-ry]; % possible new node
         if checkPath(n(1:2),newPos,map) %if path from n to newPos is collission-free
              if closed(newPos(1),newPos(2))~=0 % not already in closed
                  historicCost=n(3)+historic(n(1:2),newPos);
                  heuristicCost=heuristic(newPos,goal);
                  totalCost=historicCost+heuristicCost;
                  add=true; % not already in queue with better cost
                  if length(find((Q(:,1)==newPos(1)) .* (Q(:,2)==newPos(2))))>=1
                      I=find((Q(:,1)==newPos(1)) .* (Q(:,2)==newPos(2)));
                      if Q(I,5)<totalCost, add=false;
                      else Q=[Q(1:I-1,:);Q(I+1:end,:);];add=true;
                      end
                  end
                  if add
                      Q=[Q;newPos historicCost heuristicCost totalCost size(closedList,1)+1]; % add new nodes in queue
                  end
              end
         end           
     end
     closed(n(1),n(2))=0;closedList=[closedList;n]; % update closed lists
     if display
        image((map<=0.01).*0 + ((closed==0).*(map>=0.8)).*125 + ((closed==1).*(map>=0.8)).*255);
        counter=counter+1;
        M(counter)=getframe;
     end
end
if ~pathFound
    error('no path found')
end
if display 
    disp('click/press any key');
    waitforbuttonpress; 
end

pathStream=[n(1:2)]; %retrieve path from parent information
prev=n(6);
while prev>0
    pathStream=[closedList(prev,1:2);pathStream];
    prev=closedList(prev,6);
end
pathStream=[(pathStream(:,1)*size(mapOriginal,1))/resolutionX (pathStream(:,2)*size(mapOriginal,2))/resolutionY];
pathLength=0;
for i=1:length(pathStream)-1, pathLength=pathLength+historic(pathStream(i,:),pathStream(i+1,:)); end

if isSilent == false

    fprintf('processing time=%d \npathStream Length=%d \n\n', toc,pathLength);
    imshow(mapOriginal);
    rectangle('position',[1 1 size(mapOriginal)-1],'edgecolor','k')
    line(pathStream(:,2),pathStream(:,1));
end



end

