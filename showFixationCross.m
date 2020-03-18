function showFixationCross(protocolImagesDirectory, latency) 
% Shows a fixationCross in Screen
% Use
%      showFixationCross(protocolImagesDirectory, latency)
%Params
%      latency: latency of fixationCross
%      fixCrossDimPix: size of arms of fixation cross
%      lineWidthPix   : thickness of fixation cross.

global mainwin screenrect

screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

[screenXpixels, screenYpixels] = Screen('WindowSize', mainwin);

ifi = Screen('GetFlipInterval', mainwin);
[xCenter, yCenter] = RectCenter(screenrect);

Screen('BlendFunction', mainwin, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
theImage = imread([protocolImagesDirectory,filesep, 'protocol images', filesep, 'fixation.jpg']);

[s1, s2, s3] = size(theImage);

if s1 > screenYpixels || s2 > screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end

% Make the image into a texture
imageTexture = Screen('MakeTexture', mainwin, theImage);
Screen('DrawTexture', mainwin, imageTexture, [], [], 0);
Screen('Flip', mainwin);

WaitSecs(latency);
