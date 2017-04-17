% converter to Kaggle Fishes Monitoring labels from JSON 2nd stage
% D Pogosov
% for publishing

% requirements
% toolkit:  https://github.com/kyamagu/matlab-json

% clear everything
clear all; close all; fclose all; clc

% delete images that are not from the training set
delete('fake*json');

% get the predictions from the first stage
copyfile('../../test/out/last.csv','./')

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

% parameters for manual tuning    
coe = 0.75; % multiplier of all the likelihood, because YOLO underestimates a little bit
threshold = 0.4; % detection  threshold
valnof = 0.5; % likelihood of NoF if there is no fishes (under threshold)
mx = 0.99;
% def 1.2, 0.1, 0.7

% calculating liklihoods for NoF class
base = (1-valnof)/7;
str = ones(1,8)*base;        
str(8) = valnof;  
strnof = str;

% use the numbers from the sample submission
strnof = [0.455003,0.052938,0.030969,0.017734,0.046585,0.194283,0.079142,0.123081];

% prepare toolkit
json.startup;

% get files list
DIR = dir('*.json');

% starting to write CSV file
filename = ['stage2-' date '-32K-th0.1-mx' num2str(mx)...
    '-coe' num2str(coe) '-thres' num2str(threshold) '-valnof' num2str(valnof) '.csv'];
fileID = fopen('last.csv','a'); % we will add 2nd stage to the last predicted from the 1st stage

for i = 1:length(DIR)
    disp(i);
    try 
        JSON = json.read(DIR(i).name);    
        
        % if there are several fishes
        if length(JSON)>1,
                        
            % looking for the most likely image from the group
            M = []; idx = 0;
            for j = 1:length(JSON)                
                if JSON(j).confedence>threshold,
                    idx = idx +1;
                    % space of a fish
                    M(1,idx) = (JSON(j).bottomright.x-JSON(j).topleft.x)*...
                        (JSON(j).bottomright.y-JSON(j).topleft.y)/1000;
                    % likelihood of a fish
                    M(2,idx) = JSON(j).confedence;
                    % class of a fish
                    M(3,idx) = find(ismember(classes,JSON(j).label));
                end
            end
            [~, index] = max(M(2,:)); % pick up most likely
            %[~, index] = max(M(1,:)); % pick up the biggest one
            val = JSON(index).confedence;            
         
            % history for plotting
            hist(i) = JSON(index).confedence;            
    
            % if there are several similar fishes - increase likelihood
            if ( mean(M(3,:))==M(3,1) ) && JSON(index).confedence>(mx)
                val = 0.98;
                disp('max');
            end
                
            % class number for the most likely fish
            index = M(3,index);
            
            % in the case if all the fishes are under threshold
            if isempty(M),
                index = 8;
            end

        else % only one fish on the current image
            index = find(ismember(classes,JSON{1,1}.label));
            if JSON{1,1}.confedence<threshold,
                index = 8;
            end
            
            val = JSON{1,1}.confedence; 
            
            % history for plotting
            hist(i) = JSON{1,1}.confedence;
        end
                
        % adjusting likelohoods
        val = val*coe;
        if val>0.98
            val = 0.98;
        end
        
        % calculate likelihoods for other classes
        base = (1-val)/7;
        str = ones(1,8)*base;
        
        % for NoF class we have manually tuned likelihoods
        str(index) = val;
        if index==8,
            str=strnof;
        end
        
    catch
        % json is empty - no fishes on the current image
        str = strnof;
    end
        
    % fill in the likelihoods for the current image
    nl = length(DIR(i).name);
    fprintf(fileID, ['test_stg2/' DIR(i).name(1:nl-4) 'jpg,'...
            num2str(str(1)) ',' num2str(str(2)) ',' num2str(str(3)) ',' num2str(str(4)) ','...
            num2str(str(5)) ',' num2str(str(6)) ',' num2str(str(7)) ',' num2str(str(8)) '\n']);
end

fclose(fileID);
        
% plot distribution       
plot(sort(hist));
grid on;

% rename the file
movefile('last.csv',filename);