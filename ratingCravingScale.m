function [rating, RT] = ratingCravingScale(question, device, timeLimit, startingPosition, isBaseline) 

%   Usage: [position, secs] = slideScale(ScreenPointer, question, center, rect, endPoints, varargin)
%   Mandatory input:
%    ScreenPointer  -> Pointer to the window.
%    question       -> Text string containing the question.
%    rect           -> Double contatining the screen size.
%                      Obtained with [myScreen, rect] = Screen('OpenWindow', 0);
%    'device'         -> A string specifying the response device. Either 'mouse' 
%   'startingPosition 

%   Output:
%    'rating'      -> Deviation from zero in percentage, 
%                       with -100 <= position <= 100 to indicate left-sided
%                       and right-sided deviation.
%    'RT'            -> Reaction time in milliseconds.

global mainwin screenrect
global  cueRect dstRects imageTexture 

t0                         = GetSecs;
answer                     = 0;
AssertOpenGL;
Range = 10; %number of blocks

% Hiding the mourse cursor
HideCursor;

% Color details
scaleColor = [255 255 255];
frameColor = [125 125 125];
textColor  = [255 255 255];
cmap = colormap('winter'); close all;
blockColorIdx = fliplr(int16(linspace(1,length(cmap),Range)));
blue  = [135 206 235];

KbName('UnifyKeyNames');
responseKeys  = [KbName('return') KbName('LeftArrow') KbName('RightArrow')];
% Get information about the screen and set general things
Screen('TextSize', mainwin, 40);

[xCenter, yCenter] = RectCenter(screenrect);

RatingPositionX   = xCenter;
RatingPositionY   = screenrect(4)*.8;
RatingWidth  = screenrect(3)*.8;
RatingHeight = screenrect(4)*.1;

ratingRect = CenterRectOnPointd([0 0 RatingWidth RatingHeight], RatingPositionX, RatingPositionY);
frameRect  = CenterRectOnPointd([0 0 RatingWidth+10 RatingHeight+10], RatingPositionX, RatingPositionY);

nblock = startingPosition; 
while answer == 0
    
    if strcmp(device, 'mouse')
        [x,~,buttons,~,~,~] = GetMouse(screenPointer, 1);
    elseif strcmp(device, 'keyboard')
        [~, ~, keyCode] = KbCheck;
        if keyCode(responseKeys(2)) == 1
            nblock = nblock - 1; % Goes stepSize pixel to the left
        elseif keyCode(responseKeys(3)) == 1
            nblock = nblock + 1; % Goes stepSize pixel to the left
        end
    elseif strcmp(device,'joystick')
        [~,~,~, buttons]           = WinJoystickMex(0);
        responseButton = find(buttons);
        if responseButton == 2 
            nblock = nblock - 1; 
        elseif responseButton == 3
            nblock = nblock + 1;
        end 
    else 
        error('Unknown device');
    end
    
    if nblock < 0
        nblock = 0;
    elseif nblock > 10
        nblock = 10;
    end
    
    % Check if answer has been given
    if strcmp(device, 'mouse')
        secs = GetSecs;
        if buttons(mouseButton) == 1
            answer = 1;
        end
    elseif strcmp(device, 'keyboard')
        
        [~, ~, keyCode] = KbCheck;
        
        if keyCode(responseKeys(1)) == 1
            secs = GetSecs;
            answer = 1;
        end
        
    elseif strcmp(device, 'joystick')
        
        [~,~,~, buttons] = WinJoystickMex(0);
        responseButton = find(buttons);
        
        if responseButton == 1
            secs = GetSecs;
            answer = 1;
        else
            secs = GetSecs;
        end
        
    end

    blockWidth = nblock*RatingWidth/Range;
    blockHeight = RatingHeight;

    blockPositionY = RatingPositionY;
    blockPositionX = screenrect(3)*.1 + blockWidth/2;
    blockRect = CenterRectOnPointd([0 0 blockWidth blockHeight],...
        blockPositionX, blockPositionY);
    
    if nblock > 0
        blockColor = cmap(blockColorIdx(nblock),:).*255;
    end
    
    DrawFormattedText(mainwin, question, 'center', frameRect(3) - 0.1); 
    Screen('DrawTexture', mainwin, imageTexture, [], dstRects);
    if isBaseline
        Screen('FillOval', mainwin , blue, cueRect);
    elseif ~isBaseline
        Screen('FillRect', mainwin, blue, cueRect);
    end
    Screen('FillRect', mainwin, frameColor, frameRect);
    Screen('FillRect', mainwin, scaleColor, ratingRect);
    Screen('FillRect', mainwin, blockColor, blockRect);
    for n=1:Range+1
        tickX = (n-1)*RatingWidth/Range;
        tickPositionX = screenrect(3)*.09 + tickX;
        Screen('TextSize', mainwin, 20);
        Screen('DrawText', mainwin, num2str(n-1), tickPositionX, screenrect(4)*.88,textColor);
    end
    Screen('Flip', mainwin);
 
    % Check if answer has been given
    if strcmp(device, 'mouse')
        secs = GetSecs;
        if buttons(mouseButton) == 1
            answer = 1;
        end
    elseif strcmp(device, 'keyboard')
        [~, secs, keyCode] = KbCheck;
        if keyCode(responseKeys(1)) == 1
            secs = GetSecs;
            answer = 1;
        end
    elseif strcmp(device, 'joystick')
        
        [~,~,~, buttons] = WinJoystickMex(0);
         responseButton = find(buttons);

        if responseButton == 1
            secs = GetSecs;
            answer = 1;
        end
    end    
    
    WaitSecs(.1);
    
    % Abort if answer takes too long
    if secs - t0 > timeLimit
        break
    end
    
end

rating = nblock;
%% Calculating the rection time and the position

RT                = (secs - t0);     
disp(num2str(RT))
