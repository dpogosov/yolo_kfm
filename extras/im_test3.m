% function to check images and save a name in a list if necessary
function im_test3
    close all;
    fclose all;
    clc

    % get list of the files
    DIR = dir('im*jpg');
    images = length(DIR);
    index = 1;

    
    
    
    % generate image window with buttons
    hFig=figure;
    IM=imread(DIR(index).name); 
    imshow(IM);
    hold on;
    
    
    uicontrol('Parent',hFig,'Style','pushbutton','String', 'Next image','Units','normalized',...
        'Position',[0.0 0.0 0.175 0.07],'Visible','on', 'Callback', @imagenext);
    title(['Image selector, ' DIR(index).name]);
    
    uicontrol('Parent',hFig,'Style','pushbutton','String', 'ALB','Units','normalized',...
        'Position',[0.2 0.0 0.1 0.07],'Visible','on', 'Callback', @alb );
    uicontrol('Parent',hFig,'Style','pushbutton','String', 'BET','Units','normalized',...
        'Position',[0.3 0.0 0.1 0.07],'Visible','on', 'Callback', @bet );
    uicontrol('Parent',hFig,'Style','pushbutton','String', 'DOL','Units','normalized',...
        'Position',[0.4 0.0 0.1 0.07],'Visible','on', 'Callback', @dol );
    uicontrol('Parent',hFig,'Style','pushbutton','String', 'LAG','Units','normalized',...
        'Position',[0.5 0.0 0.1 0.07],'Visible','off', 'Callback', @lag );
    uicontrol('Parent',hFig,'Style','pushbutton','String', 'SHARK','Units','normalized',...
        'Position',[0.6 0.0 0.1 0.07],'Visible','on', 'Callback', @shark );
    uicontrol('Parent',hFig,'Style','pushbutton','String', 'YFT','Units','normalized',...
        'Position',[0.7 0.0 0.1 0.07],'Visible','on', 'Callback', @yft );
    uicontrol('Parent',hFig,'Style','pushbutton','String', 'OTHER','Units','normalized',...
        'Position',[0.8 0.0 0.1 0.07],'Visible','on', 'Callback', @other );
    uicontrol('Parent',hFig,'Style','pushbutton','String', 'NoFish','Units','normalized',...
        'Position',[0.9 0.0 0.1 0.07],'Visible','on', 'Callback', @nof );
    
    
    
%    tfname = DIR(index).name(1: length(DIR(index).name)-3 );
%    T = textread([tfname 'txt']);
%    [h, w, ~] = size(IM);
%    for i = 1:size(T,1)            
%        rectangle('Position',[(T(i,2)-T(i,4)/2)*w (T(i,3)-T(i,5)/2)*h T(i,4)*w T(i,5)*h],'LineWidth',1.5);
%    end
    
    
    % open file to write list
%    file_w = fopen('aug_list.txt','w');

    % fille name in the list and swith to next image
    %fprintf(file_w,[DIR(index).name '\n']);
function alb(~,~)
    movefile(DIR(index).name, './alb/')
    next();    
end

function nof(~,~)
    movefile(DIR(index).name, './nof/')
    next();    
end

function bet(~,~)
    movefile(DIR(index).name, './bet/')
    next();    
end

function dol(~,~)
    movefile(DIR(index).name, './dol/')
    next();    
end

function lag(~,~)
    movefile(DIR(index).name, './lag/')
    next();    
end

function yft(~,~)
    movefile(DIR(index).name, './yft/')
    next();    
end

function shark(~,~)
    movefile(DIR(index).name, './shark/')
    next();    
end

function other(~,~)
    movefile(DIR(index).name, './other/')
    next();    
end

function imagenext(~,~)
    next();
end

function next()
    % next image
    index = index +1;
    if index>images,
        % finish saving the file
        title('All images are ended');
        cla;
%        fclose (file_w);
    else
        % read and show a new image
        IM=imread(DIR(index).name); 
        imshow(IM);
        title(['Image selector, ' DIR(index).name ', ' num2str(index) '/' num2str(images) ]);
                      
        % show bounding boxes from TXT
%        tfname = DIR(index).name(1: length(DIR(index).name)-3 );
%        T = textread([tfname 'txt']);
%        [h, w, ~] = size(IM);
        %for i = 1:size(T,1)            
%            rectangle('Position',[(T(i,2)-T(i,4)/2)*w (T(i,3)-T(i,5)/2)*h T(i,4)*w T(i,5)*h],'LineWidth',1.5);
%        end
        
        
        
    end        
end


end 