% aughmenter to YOLO2 labels from JPG for the test set
% D Pogosov

clear all
close all
fclose all

DIR = dir('im*jpg');

for i=1:length(DIR)
    
    %counter = counter +1;
    strl = length(DIR(i).name);
    jpg_file{1} = DIR(i).name(1:strl-4);
    IM0  = imread([jpg_file{1} '.jpg']);
    
    % how deep we do augmentaion
    aug_list = [1 1 1 0 0];
    
    %add_string_to_txt('train', jpg_file{1});
    IM = struct('im',IM0);
    imwrite(IM(1).im,[jpg_file{1} '.jpg']);
    
    if aug_list(2) % rotation
        jpg_file(2) = {[jpg_file{1} 'r']};
        IM(2).im = rot90(IM(1).im,45);
        imwrite(IM(2).im,[jpg_file{2} '.jpg']);
    end
    
    if aug_list(3) % flip
        for ii = 1:2
            jpg_file(2+ii) = {[jpg_file{ii} 'f']};
            IM(2+ii).im = fliplr(IM(ii).im);
            imwrite(IM(2+ii).im,[jpg_file{2+ii} '.jpg']);
        end
    end    
    
    if aug_list(4) % crop and move
        for ii = 1:4
            jpg_file(4+ii) = {[jpg_file{ii} 'c']};
            
            ish = size(IM(ii).im,1);
            isw = size(IM(ii).im,2);
            ltx = 0.02; lty = 0.2;
            bdx = 0.98; bdy = 0.98;
            
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
            imwrite(IM(4+ii).im,[jpg_file{4+ii} '.jpg']);
        end
    end
    
    if aug_list(5) % white noise
        for ii = 1:8
            jpg_file(8+ii) = {[jpg_file{ii} 'd']};
            ish = size(IM(ii).im,1);
            isw = size(IM(ii).im,2);
            IM(8+ii).im = imnoise(IM(ii).im, 'gaussian', 0, 0.01);
            imwrite(IM(8+ii).im,[jpg_file{8+ii} '.jpg']);
        end
    end
    
    % DEBUG ONLY
    %delete([jpg_file{1} '.jpg']);
    
    disp([ num2str(i) '/12153'   ' progress']);
end

