function theResults = experiment(subjectID)

%% query subjectID and generate parameters
if ~exist('subjectID','var')
    subjectID = [];
    while isempty(subjectID)
        subjectID =  input('Please enter subject ID: ','s');
    end
end
theResults.params = makeParams(subjectID);

%% initialize, etc
% metadata
theResults.info.dir=getDirInfo;
theResults.info.computer=Screen('Computer');
theResults.info.runTime=now;
theResults.info.subject = subjectID;

% pre-allocate for the data ...
testcount = length(theResults.params.testwhen);
theResults.data.rt = nan(testcount, 1);
theResults.data.response = nan(testcount, 1);
theResults.data.correct = nan(testcount, 1);
testindex = 1; % increases with each test to always refer to the place in 
               % testwhen denoting when the next test should happen

%% setting up the display and upcoming objects
Screen('Preference', 'SkipSyncTests', 1); % living life dangerously
PsychDefaultSetup(2); % default settings for Psychtoolbox
screenNumber = 0;     % set screen
sDim = Screen('Rect',screenNumber);
screenX = sDim(3);
screenY = sDim(4);
textColor = [1 1 1];
fixationColor = [1 1 1];
dotSize = 4;
xCenter = (screenX/2);
yCenter = (screenY/2);
bg = GrayIndex(screenNumber, .35);
[mainWindow, ~] = PsychImaging('OpenWindow', screenNumber, bg);
flipTime = Screen('GetFlipInterval',mainWindow);
Screen(mainWindow, 'TextFont', 'Arial');
Screen(mainWindow, 'TextSize', 18);

% fixation dot rect, square, wheel 
HideCursor();
fixDotRect = [xCenter-dotSize,yCenter-dotSize,xCenter+dotSize,yCenter+dotSize];
square = CenterRectOnPointd([0 0 200 200], xCenter, yCenter);
wheelRect = CenterRectOnPointd([0 0 800 800], xCenter, yCenter);
blackarcRect = CenterRectOnPointd([0 0 550 550], xCenter, yCenter);

%% instructions
instructString = 'COLOR MEMORY TASK:';
boundRect = Screen('TextBounds', mainWindow, instructString);
Screen('drawtext',mainWindow,instructString, xCenter-boundRect(3)/2, yCenter-boundRect(4)/5, textColor);

instructString = 'In each block, a series of colored squares will be displayed one after another.';
boundRect = Screen('TextBounds', mainWindow, instructString);
Screen('drawtext',mainWindow,instructString, xCenter-boundRect(3)/2, yCenter-boundRect(4)/5+30, textColor);

instructString = 'Every so often, instead of a square, only its outline and a color wheel will be shown.';
boundRect = Screen('TextBounds', mainWindow, instructString);
Screen('drawtext',mainWindow,instructString, xCenter-boundRect(3)/2, yCenter-boundRect(4)/5+60, textColor);

instructString = 'Move the mouse to the color wheel entry that matches your best guess of the square''s color based on the squares you''ve seen so far.';
boundRect = Screen('TextBounds', mainWindow, instructString);
Screen('drawtext',mainWindow,instructString, xCenter-boundRect(3)/2, yCenter-boundRect(4)/5+90, textColor);

instructString = 'To continue press the spacebar.';
boundRect = Screen('TextBounds', mainWindow, instructString);
Screen('drawtext',mainWindow,instructString, xCenter-boundRect(3)/2, yCenter-boundRect(4)/5+220, textColor);

Screen('Flip',mainWindow);

% wait for spacebar press
while(1)
    FlushEvents('keyDown');
    temp = GetChar;
    if (temp == ' ')
        break;
    end
end

Screen(mainWindow,'FillRect', bg);
Screen('Flip',mainWindow);
WaitSecs(3); % breathe

%% present stimuli

% start the experiment at the earliest valid location
startTrial = find(isnan(theResults.data.correct),1);
if isempty(startTrial)
    sca;
    warning('MATLAB:idunno','\nAll data already recorded for this participant, aborting!');
    return    
end

tt = startTrial;
testcount = 0;
testcorrect = 0;
while tt <= theResults.params.count.numSquares % trial loop
    Priority(MaxPriority(mainWindow)); % ???????????]
    
    % timing
    trialStart = GetSecs;
    itemOns = trialStart + theResults.params.timing.fix;
    isiOns = itemOns + theResults.params.timing.stimDur; % the rest depends on test
    
    % init fix
    Screen(mainWindow,'FillRect',bg);
    Screen(mainWindow,'FillOval',fixationColor,fixDotRect);
    Screen('Flip',mainWindow,trialStart-flipTime);
    
    % item onset
    Screen(mainWindow,'FillRect',bg);
    color = cell2mat(theResults.params.seq.colors(:,tt));
    Screen('FillRect', mainWindow, color, square);
    Screen('Flip',mainWindow,itemOns-flipTime);
    
    % isi
    Screen(mainWindow,'FillRect',bg);
    Screen('Flip',mainWindow,isiOns-flipTime);
    
    % it might be time for a test!
    if testindex < length(theResults.params.testwhen)
        if tt == theResults.params.testwhen(testindex)
            
            % timing 
            testStart = GetSecs;
            testOns = testStart + theResults.params.timing.fix;
            trialMax = testOns + theResults.params.timing.respRW;
            respFB = theResults.params.timing.respFB;
            isiOns = testOns + respFB;
            
            % initial fix
            Screen(mainWindow,'FillRect',bg);
            Screen(mainWindow,'FillOval',fixationColor,fixDotRect);
            Screen('Flip',mainWindow,testStart-flipTime);
            
            % stim
            ShowCursor('CrossHair');
            SetMouse(xCenter, yCenter, mainWindow)
            Screen(mainWindow,'FillRect',bg);
            size = theResults.params.seq.alphasize;
            for i = 1:size
                letter = theResults.params.seq.alphabet(i,:);
                Screen('FillArc',mainWindow,letter,wheelRect,(i-1)*360/size,360/size);
            end
            Screen('FillArc',mainWindow,bg,blackarcRect,0,360)
            Screen('FrameRect', mainWindow, [1 1 1], square)
            Screen('Flip',mainWindow,testOns-flipTime);
            
            % resp window
            tic
            [x, y] = GetMouse;
            x = x - xCenter;
            y = y - yCenter;
            while (GetSecs < trialMax) && mousedist(x, y) < 550/2
                [x, y] = GetMouse;
                x = x - xCenter;
                y = y - yCenter;
            end
            
            % store response and correct
            theResults.data.rt(testindex) = toc;
            theResults.data.response(testindex) = determinechoice(theResults.params.seq.alphasize, x, y, xCenter, yCenter);
            seq = convert2numbers(theResults.params.seq.alphabet, theResults.params.seq.colors);
            theResults.data.correct(testindex) = theResults.params.seq.correct(seq(tt));
            if theResults.data.correct(testindex) ~= -1
                testcount = testcount + 1;
            end
            if theResults.data.response(testindex) == theResults.data.correct(testindex)
                testcorrect = testcorrect + 1;
            end
                
            % wait and flip
            WaitSecs(respFB);
            Screen('Flip',mainWindow);
            HideCursor();
            testindex = testindex + 1;
            
            % isi
            Screen(mainWindow,'FillRect',bg);
            Screen('Flip',mainWindow,isiOns-flipTime);
            
            if testindex == 4
                instructString = 'END OF PRACTICE SESSION ';
                boundRect = Screen('TextBounds', mainWindow, instructString);
                Screen('drawtext',mainWindow,instructString, xCenter-boundRect(3)/2, yCenter-boundRect(4)/5, textColor);
        
                instructString = 'Please confirm your understanding of the task with the experimenter.';
                boundRect = Screen('TextBounds', mainWindow, instructString);
                Screen('drawtext',mainWindow,instructString, xCenter-boundRect(3)/2, yCenter-boundRect(4)/5+40, textColor);

                instructString = 'Remember: Move the mouse to the color wheel entry that matches your best guess of the square''s color.';
                boundRect = Screen('TextBounds', mainWindow, instructString);
                Screen('drawtext',mainWindow,instructString, xCenter-boundRect(3)/2, yCenter-boundRect(4)/5+70, textColor);

                instructString = 'To continue press the spacebar';
                boundRect = Screen('TextBounds', mainWindow, instructString);
                Screen('drawtext',mainWindow,instructString, xCenter-boundRect(3)/2, yCenter-boundRect(4)/5+220, textColor);

                Screen('Flip',mainWindow);

                while(1)
                    FlushEvents('keyDown');
                    temp = GetChar;
                    if (temp == ' ')
                        break;
                    end
                end

                Screen(mainWindow,'FillRect',bg);
                Screen('Flip',mainWindow);
                WaitSecs(3); % breathe
            end
        end
    end
    
    if any(tt+1 == theResults.params.count.block)        
        instructString = ['END OF BLOCK ' num2str(find(tt+1==theResults.params.count.block)-1)];
        boundRect = Screen('TextBounds', mainWindow, instructString);
        Screen('drawtext',mainWindow,instructString, xCenter-boundRect(3)/2, yCenter-boundRect(4)/5, textColor);
        
        instructString = ['Feel free to take a short break. During this block, your best guess was correct ' num2str(round((testcorrect/testcount)*100)) '% of the time.'];
        boundRect = Screen('TextBounds', mainWindow, instructString);
        Screen('drawtext',mainWindow,instructString, xCenter-boundRect(3)/2, yCenter-boundRect(4)/5+40, textColor);
        
        instructString = 'Remember: Move the mouse to the color wheel entry that matches your best guess of the square''s color.';
        boundRect = Screen('TextBounds', mainWindow, instructString);
        Screen('drawtext',mainWindow,instructString, xCenter-boundRect(3)/2, yCenter-boundRect(4)/5+70, textColor);
                
        instructString = 'To continue press the spacebar';
        boundRect = Screen('TextBounds', mainWindow, instructString);
        Screen('drawtext',mainWindow,instructString, xCenter-boundRect(3)/2, yCenter-boundRect(4)/5+220, textColor);
        
        Screen('Flip',mainWindow);
        
        while(1)
            FlushEvents('keyDown');
            temp = GetChar;
            if (temp == ' ')
                break;
            end
        end
        
        Screen(mainWindow,'FillRect',bg);
        Screen('Flip',mainWindow);
        WaitSecs(3); % breathe
    end
    
    % increment tt
    tt = tt + 1;
end

save(strcat(subjectID, '.mat'), 'theResults')
sca;

%% Launch Debriefing Form
web('https://docs.google.com/forms/d/1yxdJ7wOhZtuYBECQe8UU05Gko8Gv3_ET6FI_ow1bCnA/viewform?usp=send_form','-browser');
