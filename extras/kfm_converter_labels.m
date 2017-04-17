% converter to YOLO2 labels from JSON
% D Pogosov

% requirements
% toolkit:  https://github.com/kyamagu/matlab-json
% data:     https://github.com/autoliuweijie/Kaggle/tree/master/NCFM/datasets

clear all
close all
fclose all
delete('day.txt')
delete('night*.txt')
delete('validation.txt')
delete('train.txt')
clc

% map of the classes 
classes = {...
    'ALB',...   % 0
    'BET',...   % 1
    'DOL',...   % 2
    'LAG',...   % 3
    'SHARK',... % 4
    'YFT',...   % 5
    'OTHER' };  % 6

% rate of the validation dataset
valid = 0.1;

% no fish - there is no dataset, so only clas proboability threshold

% for day/nigth statistics
stat = zeros(2,length(classes));
% for single/multifish
stat_mult = zeros(2,length(classes));

% cd matlab-json-master
json.startup;
mkdir('output');
disp('started');
for c = 1:length(classes)
    
    JSON = json.read([char(classes(c)) '.json']);
    val = fix(length(JSON)*valid);
    for i=1:length(JSON)    

        % open file for writing
        strl = length(char(classes(c)))+2;
        
        % default image size 
        iw = 1280; ih = 720;
        
        Im  = imread([JSON(i).filename(strl:strl+9) 'jpg']);
        stat(1,c) = stat(1,c)+1;
        iw = size(Im,2);
        ih = size(Im,1);
        RGB = mean(mean(Im));
        if var( RGB/mean(RGB) )>0.05,
            % it is night image            
            f2ID = fopen('night.txt','a');            
            fprintf(f2ID, [JSON(i).filename(strl:strl+9) 'jpg' '\n']);
            fclose(f2ID);
            
            f2ID = fopen('train.txt','a');            
            fprintf(f2ID, ['data/KFM/' JSON(i).filename(strl:strl+9) 'jpg' '\n']);
            fclose(f2ID);
            
            % extra list of night images by classes
            f2ID = fopen(['night_' char(classes(c)) '.txt'],'a');            
            fprintf(f2ID, [JSON(i).filename(strl:strl+9) 'jpg' '\n']);
            fclose(f2ID);                   
            
            stat(2,c) = stat(2,c)+1;
        else
            % it is day image            
            f2ID = fopen('day.txt','a');
            fprintf(f2ID, [JSON(i).filename(strl:strl+9) 'jpg' '\n']);
            fclose(f2ID);
            
            if val, % put day images to valiation set first
                val = val -1;               
                
                f2ID = fopen('validation.txt','a');
                fprintf(f2ID, ['data/KFM/' JSON(i).filename(strl:strl+9) 'jpg' '\n']);
                fclose(f2ID);
            else
                
                f2ID = fopen('train.txt','a');            
                fprintf(f2ID, ['data/KFM/' JSON(i).filename(strl:strl+9) 'jpg' '\n']);
                fclose(f2ID);
            end
        end
        
        
        clear Im;
        
        fname = ['output/' JSON(i).filename(strl:strl+9) 'txt'];
        fileID = fopen(fname,'w');       
        
        for j = 1: length(JSON(i).annotations)
        
            if length(JSON(i).annotations)>1, 
                h1 = JSON(i).annotations(j).height;
                w1 = JSON(i).annotations(j).width;
                x1 = JSON(i).annotations(j).x;
                y1 = JSON(i).annotations(j).y;
                % multi-fish image - add statitics
                stat_mult(c) = stat_mult(c) + 1;
            else % stupid matlab array access
                h1 = JSON(i).annotations{1,1}.height;
                w1 = JSON(i).annotations{1,1}.width;
                x1 = JSON(i).annotations{1,1}.x;
                y1 = JSON(i).annotations{1,1}.y;
            end
        
            x = (x1+w1/2)/iw;
            y = (y1+h1/2)/ih;
            w = w1/iw;
            h = h1/ih;
                
            % fill a text line into a file
            fprintf(fileID, [num2str(c-1) ' '...
                num2str(x) ' '...
                num2str(y) ' '...
                num2str(w) ' '...
                num2str(h) '\n']);
        end
        
        % close file
        fclose(fileID);
    end
    disp([ num2str(fix(100*c/length(classes))) '% progress']);

end
disp('statistics of night images:')
disp(num2str( fix(100*(stat(2,:)./stat(1,:))) ));
disp('statistics of multi-fish images:')
disp(stat_mult(1,:));
disp( fix(100*stat_mult(1,:)./stat(1,:)) );