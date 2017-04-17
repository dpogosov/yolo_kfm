% converter pseudo labels (from JSON to TXT YOLO format)
% D Pogosov

% requirements
% toolkit:  https://github.com/kyamagu/matlab-json

% clear everything
clear all; close all; fclose all; clc

% delete images that are not from the training set
delete('fake*json');
delete('image*txt');
delete('train.txt');
delete('output/*');

% threshold of detection
threshold = 0.4; 

% map of the classes 
classes = {...
    'ALB',...   % 0
    'BET',...   % 1
    'DOL',...   % 2
    'LAG',...   % 3
    'SHARK',... % 4
    'YFT',...   % 5
    'OTHER' };  % 6
    % NOF       % 7

% prepare toolkit
json.startup;

% get files list
DIR = dir('*.json');

fileID = 0;
flag = 0; % to fill in a jpg into train.txt

for i = 1:length(DIR)
    
    flag = 0;
    try 
        JSON = json.read(DIR(i).name);    
        filenamet = [DIR(i).name(1:length(DIR(i).name)-4) 'txt'];
        filenamej = [DIR(i).name(1:length(DIR(i).name)-4) 'jpg'];        
        
        % if there are several fishes
        if length(JSON)>1,
            for j = 1:length(JSON)                
                if JSON(j).confedence>threshold,
                    flag = 1;
                    if fileID<1,
                        fileID = fopen(filenamet,'a');
                    end
                    
                    fprintf(fileID, [num2str(find(ismember(classes,JSON(j).label))-1), ' ',...
                        num2str(JSON(j).coords.x), ' ',...
                        num2str(JSON(j).coords.y), ' ',...
                        num2str(JSON(j).size.w), ' ',...
                        num2str(JSON(j).size.h), ' ',...
                        '\n']);                    
                end
            end
        else % only one fish on the current image            
            if JSON{1,1}.confedence>threshold,                
                flag = 1;
                fileID = fopen(filenamet,'a');                    
                fprintf(fileID, [num2str(find(ismember(classes,JSON{1,1}.label))-1), ' ',...
                        num2str(JSON{1,1}.coords.x), ' ',...
                        num2str(JSON{1,1}.coords.y), ' ',...
                        num2str(JSON{1,1}.size.w), ' ',...
                        num2str(JSON{1,1}.size.h), ' ',...
                        '\n']);            
            end            
        end
        
    catch
        flag = 0;
    end
        
    % fill in train.txt
    if flag,        
        fileID2 = fopen('train.txt','a');
        fprintf(fileID2, ['data/KFM/' filenamej '\n']);        
    end
    
    fclose all;
    disp([num2str(i) ' ' num2str(flag) ]);
end

% move the files
mkdir('output');
fclose all;
movefile('*txt','output/');

%zip('output/stg2', 'output/*txt');
%movefile('output/stg2.zip', 'C:\YOLO\DARKFLOW\OUT');