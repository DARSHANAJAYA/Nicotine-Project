% Experimental parameters

clear;

% -------------------------
% Parameters
% -------------------------
global escKey outfile

PsychDefaultSetup(2); 
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'SuppressAllWarnings',1);

fixationInterval = 3; nTrialsPerRun = 87;
imagePresentationInterval = 3; imageRatingInterval = 3; 


KbName('UnifyKeyNames');
Key1=KbName('LeftArrow'); Key2=KbName('RightArrow');
spaceKey = KbName('space'); escKey = KbName('ESCAPE');
corrkey = [37, 39]; % left and right arrow
gray = [127 127 127]; white = [255 255 255]; black = [0 0 0];
bgcolor = black; textcolor = white;
imageScaler = .4; 
% ---------------------------
% Login prompt 
% ---------------------------

prompt = {'Output file', 'Subject''s ID:', 'Age', 'Gender', 'Group', 'Number of Runs', 'Protocol Directory'};
defaults = {'Enter file name', 'Enter subject ID (e.g. NM1)', 'Enter subject age', ...
    'Enter subject gender', 'Enter subject group' , '2', 'Z:\New protocol'};

answer = inputdlg(prompt, 'ChoiceRT', 2, defaults);
[output, subid, subage, gender, group, nRuns, wdir] = deal(answer{:}); % all input variables are strings
outputname = [output,'.csv'];
nblocks = str2num(nRuns); % convert string to number for subsequent reference

if exist(outputname)==2 % check to avoid overiding an existing file
    fileproblem = input('That file already exists! Append a .x (1), overwrite (2), or break (3/default)?');
    if isempty(fileproblem) || fileproblem==3
        return;
    elseif fileproblem==1
        outputname = [outputname '.x'];
    end
end

outfile = fopen(outputname,'w'); % open a file for writing data out
fprintf(outfile, 'subid\t subage\t gender\t group\t runNumber\t TrialType\t trialNumber\t rating\t ReactionTime\t responseTime\t \n');

% --------------------------
% Screen parameters
% --------------------------
global mainwin screenrect 
[mainwin, screenrect] = Screen(0, 'OpenWindow');
Screen('FillRect', mainwin, bgcolor);
center = [screenrect(3)/2 screenrect(4)/2];
Screen(mainwin, 'Flip');

%   Experimental instructions, wait for a spacebar response to start
Screen('FillRect', mainwin ,bgcolor);
Screen('TextSize', mainwin, 20);
Screen('DrawText',mainwin,'Please press any button to start' ,center(1)*.4,center(2),textcolor);
Screen('Flip',mainwin );
keyIsDown=0;

% --------------------------
% Instructions
% --------------------------

while 1
    [~,~,~, buttons]           = WinJoystickMex(0);
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown || any(buttons)
        if any(buttons)
            break ;
        elseif keyCode(escKey)
            ShowCursor;
            fclose(outfile);
            Screen('CloseAll');
            return;
        end
    end
end

WaitSecs(0.3);
fprintf(outfile, 'experiment started at %s \n', datestr(now, 'dd/mm/yy-HH:MM:SS'));

% ----------------------------------------
% Block loop
% ----------------------------------------

nImages              = size(dir([wdir,filesep, 'pretest_images',filesep, '*.jpg']),1); 
imagesOrderOverall   = Shuffle(1:nImages);
imagesCondition      = [imagesOrderOverall(1:80); imagesOrderOverall(81:174)]; 

for r = 1:str2num(nRuns)
    
    Screen('FillRect', mainwin, bgcolor);
    Screen('TextSize', mainwin, 20);
    
    if r~=1
        Screen('DrawText',mainwin,'Please press any button to start' ,center(1)*.4,center(2),textcolor);
        Screen('Flip', mainwin);
        while 1
            [~,~,~, buttons]           = WinJoystickMex(0);
            if any(buttons)
                break
            end
        end        
        WaitSecs(.3);        
    end 
    
    if r == 1 
        imageOrderBaseline   = Shuffle(imagesCondition(1,:)); % randomize images for each block
        imageOrderRegulation = Shuffle(imagesCondition(2,:)); % randomize images for each block
    elseif r == 2
        imageOrderBaseline   = Shuffle(imagesCondition(2,:)); % randomize images for each block
        imageOrderRegulation = Shuffle(imagesCondition(1,:)); % randomize images for each block        
    end 
    
    % trial loop
    for i = 1:nTrialsPerRun
        
        Screen('FillRect', mainwin ,bgcolor);
        Screen('TextSize', mainwin, 60);
        Screen('Flip', mainwin); % must flip for the stimulus to show up on the mainwin
        
        
        % -----------------------------------
        % Fixation Cross 
        % -----------------------------------
        
        Screen('TextSize', mainwin, 60);
        Screen('DrawText', mainwin, '+', center(1), screenrect(4)*.45, textcolor);
        Screen('Flip', mainwin);
        WaitSecs(fixationInterval);

        % -----------------------------------
        % Baseline Image
        % -----------------------------------
        
        showImage(wdir, imageOrderBaseline(i), imagePresentationInterval, imageScaler, 1, 0); 

        % -----------------------------------
        % Baseline Rating
        % -----------------------------------
        
        [ratingBL(i), RTBL(i)] = showImage(wdir, imageOrderBaseline(i), imageRatingInterval, imageScaler, 1, 1); 
        
        fprintf(outfile, '%s\t %s\t %s\t %s\t %d\t %s\t %d\t %d\t %d\t %s\t \n', subid, ...
            subage, gender, group, r, 'baseline', i, ratingBL(i), RTBL(i),   );        
        % -----------------------------------
        % Fixation Cross 
        % -----------------------------------
        
        Screen('TextSize', mainwin, 60);
        Screen('DrawText', mainwin, '+', center(1), screenrect(4)*.45, textcolor);
        Screen('Flip', mainwin);
        WaitSecs(fixationInterval);
        
        % -----------------------------------
        % Regulation Image
        % -----------------------------------        
        
        showImage(wdir, imageOrderRegulation(i), imagePresentationInterval, imageScaler, 0, 0);
                
        % -----------------------------------
        % Regulation Rating
        % -----------------------------------        
        
        [ratingReg(i), RTReg(i)] = showImage(wdir, imageOrderRegulation(i), imageRatingInterval, imageScaler, 0, 1);                 
        
        fprintf(outfile, '%s\t %s\t %s\t %s\t %d\t %s\t %d\t %d\t %d\t %s\t \n', subid, ...
            subage, gender, group, r, 'regulation', i, ratingBL(i), RTBL(i), datestr(now, 'HH:MM:SS'));
        % This is for abort 
        [keyIsDown, secs, keyCode] = KbCheck;

        if keyIsDown && keyCode(escKey)
            ShowCursor;
            fclose(outfile);
            Screen('CloseAll');
            sca
            return;
        end
        
        fprintf(outfile, '%s\t %s\t %s\t %s\t %d\t %d\t %d\t %d\t %d\t %n\t %d\t %n \n', subid, ...,
    subage, gender, group, r, i, imageOrderBaseline(i), imageOrderRegulation(i), ratingBL(i), RTBL(i), ...
    ratingReg(i), RTReg(i));
    end  % end of trial loop
end % end of block loop

Screen('CloseAll');
fclose(outfile);
fprintf('\n\n\n\n\nFINISHED this part! PLEASE GET THE EXPERIMENTER...\n\n');





