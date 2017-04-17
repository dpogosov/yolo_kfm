% aughmenter to YOLO2 labels from JSON
% D Pogosov

% requirements
% toolkit:  https://github.com/kyamagu/matlab-json
% data:     https://github.com/autoliuweijie/Kaggle/tree/master/NCFM/datasets

function aughmenter_yolo

clear all
close all
fclose all
delete('train.txt')
delete('output/*')
clc

% how deep we aughment the dataset
aug_class = [0,... % ALB
             3,... % BET
             3,... % DOL
             4,... % LAG
             3,... % SHARK
             1,... % YFT
             2];   % OTHER

% map of the classes 
classes = {...
    'ALB',...   % 0
    'BET',...   % 1
    'DOL',...   % 2
    'LAG',...   % 3
    'SHARK',... % 4
    'YFT',...   % 5
    'OTHER' };  % 6


% cd matlab-json-master
total = 0;
counter = 0;
json.startup;
mkdir('output');
mkdir('images');
disp('checking the amount of work');
for c = 1:length(classes)
    JSON = json.read([char(classes(c)) '.json']);
    total = total + length(JSON);
end
total = total - 2;

disp('started');
for c = 1:length(classes)
    
    JSON = json.read([classes{c} '.json']);
    if c==1, % file is broken
        JSON(:,1592)= [];
        JSON(:,112) = [];
    end
    
    
    for i=1:length(JSON)    
        counter = counter +1;
        
        strl = length(char(classes(c)))+2;                
        jpg_file(1) = {JSON(i).filename(strl:strl+8)};
                     
        IM0  = imread([jpg_file{1} '.jpg']);
        
        iw = size(IM0,2);
        ih = size(IM0,1);
       
        % get cycles from aug_class
        aug_list = zeros(1, max(aug_class)+1);
        aug_list(1,1:aug_class(c)+1) = 1;        
        add_string_to_txt('train', jpg_file{1});
        IM = struct('im',IM0);        
        imwrite(IM(1).im,['images/' jpg_file{1} '.jpg']);        
        for j = 1: length(JSON(i).annotations)
            [x,y,w,h] = get_coords(i);
            add_coords_to_txt(jpg_file{1},c,x,y,w,h); % add as is
        end        
        
        if aug_list(2) % rotation
            jpg_file(2) = {[jpg_file{1} 'r']};
            add_string_to_txt('train', jpg_file{2});
            IM(2).im = rot90(IM(1).im,45);
            imwrite(IM(2).im,['images/' jpg_file{2} '.jpg']);
            for j = 1: length(JSON(i).annotations)
                [x,y,w,h] = get_coords(i);
                add_coords_to_txt(jpg_file{2},c,y,1-x,h,w); % add rotated
            end
        end
            
        if aug_list(3) % flip
            for ii = 1:2
                jpg_file(2+ii) = {[jpg_file{ii} 'f']};
                add_string_to_txt('train', jpg_file{2+ii});
                IM(2+ii).im = fliplr(IM(ii).im);
                imwrite(IM(2+ii).im,['images/' jpg_file{2+ii} '.jpg']);                
                T = textread(['output/' jpg_file{ii} '.txt']);                
                for j = 1:size(T,1)                    
                    x = T(j,2); y = T(j,3); w = T(j,4); h = T(j,5);
                    add_coords_to_txt(jpg_file{2+ii},c,1-x,y,w,h); % add flipped                    
                end
            end
        end        
                    
        if aug_list(4) % crop and move
            for ii = 1:4
                jpg_file(4+ii) = {[jpg_file{ii} 'c']};
                add_string_to_txt('train', jpg_file{4+ii});                
                T = textread(['output/' jpg_file{ii} '.txt']);                
                for j = 1:size(T,1)
                    x = T(j,2); y = T(j,3); w = T(j,4); h = T(j,5);
                    ltx(j) = x-w/2;
                    lty(j) = y-h/2;
                    bdx(j) = x+w/2;
                    bdy(j) = y+h/2;                    
                end                
                ltx = min(ltx); lty = min(lty);
                bdx = max(bdx); bdy = max(bdy);                
                ish = size(IM(ii).im,1);
                isw = size(IM(ii).im,2);                
                if rand >= 0.5, 
                    ltx = rand*ltx; 
                    bdx = 1;                    
                else
                    bdx = (1-bdx)*rand+bdx; 
                    ltx = 0; 
                end                
                if rand >= 0.5, 
                    lty = rand*lty; 
                    bdy = 1;
                else
                    bdy = (1-bdy)*rand+bdy; 
                    lty = 0; 
                end                
                IM(4+ii).im = imcrop(IM(ii).im,[ltx*isw lty*ish (1-ltx)*bdx*isw (1-lty)*bdy*ish]);               
                imwrite(IM(4+ii).im,['images/' jpg_file{4+ii} '.jpg']);                
                for j = 1:size(T,1)
                    x = T(j,2); y = T(j,3); w = T(j,4); h = T(j,5);
                    add_coords_to_txt(jpg_file{4+ii},c,...
                        (x-ltx)/(bdx*(1-ltx)),...
                        (y-lty)/(bdy*(1-lty)),...
                        w/((1-ltx)*bdx),...
                        h/((1-lty)*bdy)); % add cropped                    
                end
            end
        end
         
        if aug_list(5) % white noise
            for ii = 1:8
                jpg_file(8+ii) = {[jpg_file{ii} 'd']};
                add_string_to_txt('train', jpg_file{8+ii});                
                ish = size(IM(ii).im,1);
                isw = size(IM(ii).im,2);
                IM(8+ii).im = imnoise(IM(ii).im, 'gaussian', 0, 0.01);                
                imwrite(IM(8+ii).im,['images/' jpg_file{8+ii} '.jpg']);                
                T = textread(['output/' jpg_file{ii} '.txt']);                
                for j = 1:size(T,1)
                    x = T(j,2); y = T(j,3); w = T(j,4); h = T(j,5);
                    add_coords_to_txt(jpg_file{8+ii},c,x,y,w,h); % add as is                    
                end
            end
        end   
        disp([classes{c} ' ' num2str(i) '/' num2str(length(JSON)) ', ' num2str(counter/total) ' progress']);
    end
   
end


function add_string_to_txt(name, string)
	f2ID = fopen([name '.txt'],'a');            
    fprintf(f2ID, ['data/KFM/' string '.jpg' '\n']);
    fclose(f2ID);
end

function add_coords_to_txt(name,c,x,y,w,h)
    fname = ['output/' name '.txt'];
    fileID = fopen(fname,'a');   
    % fill a text line into a file
    fprintf(fileID, [num2str(c-1) ' '...
    	num2str(x) ' '...
        num2str(y) ' '...
        num2str(w) ' '...
        num2str(h) '\n']);        
    fclose(fileID);
end

function [x,y,w,h] = get_coords(i)      
	if length(JSON(i).annotations)>1, 
        h1 = JSON(i).annotations(j).height;
        w1 = JSON(i).annotations(j).width;
        x1 = JSON(i).annotations(j).x;
        y1 = JSON(i).annotations(j).y;
    else % stupid matlab array access
        h1 = JSON(i).annotations{1,1}.height;
        w1 = JSON(i).annotations{1,1}.width;
        x1 = JSON(i).annotations{1,1}.x;
        y1 = JSON(i).annotations{1,1}.y;
	end           
            
	% resize to yolo format
    x = (x1+w1/2)/iw;
    y = (y1+h1/2)/ih;
    w = w1/iw;
    h = h1/ih;
end


end