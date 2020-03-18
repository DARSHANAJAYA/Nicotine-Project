% Preliminary stuff
% check for Opengl compatibility, abort otherwise:
AssertOpenGL;

% Hiding the mourse cursor
HideCursor;

% Back ground colour
bgColor   = [128 128 128];

% Get information about the screen and set general things
Screen('Preference', 'SuppressAllWarnings',1);
Screen('Preference', 'SkipSyncTests', 1);

% Creating screen etc.
[myScreen, rect] = Screen('OpenWindow', 0, bgColor);

% Input for slide scale
question  = 'Rate this image based on your craving levels';
endPoints = {'0', '10'};

% The code below creates as slide scale form 0 to 100 for keyboard use with
% left starting position. The left and right control keys are used to
% control the slider and enter is used to log the response. 
[position, RT, answer] = slideScale(myScreen, ...
    question, ...
    rect, ...
    endPoints, ...
    'device', 'keyboard', ...
    'stepsize', 10, ...
    'responseKeys', [KbName('return') KbName('LeftArrow') KbName('RightArrow')], ...
    'startposition', 'left', ...
    'range', 2, ...
    'displayposition', 1);

% Close window
Screen('CloseAll') 