function [varargout] = showImage(protocolImagesDirectory, image, latency, heightScaler, isBaseline, isRating) 
% Shows a fixationCross in Screen
% Use
%      showFixationCross(protocolImagesDirectory, latency)
%Params
%      latency: latency of fixationCross
%      fixCrossDimPix: size of arms of fixation cross
%      lineWidthPix   : thickness of fixation cross.

global mainwin screenrect escKey outfile
global  cueRect dstRects imageTexture 
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
blue  = [135 206 235];
[screenXpixels, screenYpixels] = Screen('WindowSize', mainwin);

ifi = Screen('GetFlipInterval', mainwin);
[xCenter, yCenter] = RectCenter(screenrect);

Screen('BlendFunction', mainwin, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
theImage = imread([protocolImagesDirectory,filesep, 'pretest_images', filesep, num2str(image), '.jpg']);

[s1, s2, s3] = size(theImage);
aspectRatio = s2 / s1; % ratio between height and width 
imageHeight = screenYpixels .* heightScaler; % we will define the scale based on the height of the screen
imageWidth = imageHeight .* aspectRatio;

theRect = [0 0 imageWidth imageHeight];
dstRects = CenterRectOnPointd(theRect, screenXpixels / 2,...
    screenYpixels / 2);

if s1 > screenYpixels || s2 > screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end

% Make the image into a texture
imageTexture = Screen('MakeTexture', mainwin, theImage);
Screen('DrawTexture', mainwin, imageTexture, [], dstRects);

%add cue
cuePositionX   = screenrect(3)*.8;
cuePositionY   = yCenter;

cueRect = CenterRectOnPointd([0 0 75 75], cuePositionX, cuePositionY);

if isBaseline 
    Screen('FillOval', mainwin , blue, cueRect);
elseif ~isBaseline
    Screen('FillRect', mainwin, blue, cueRect);
end

if isRating
    question  = 'Rate this image based on your craving levels';
    device = 'joystick'; 
    timeLimit = latency; 
    [rating, RT] = ratingCravingScale(question, device, timeLimit, 5, isBaseline);
    varargout = {rating,  RT}; 
end

Screen('Flip', mainwin);

if ~isRating
    WaitSecs(latency);
end 

[keyIsDown, secs, keyCode] = KbCheck;
if keyIsDown && keyCode(escKey)
    ShowCursor;
    fclose(outfile);
    Screen('CloseAll');
    sca
    return;
end


