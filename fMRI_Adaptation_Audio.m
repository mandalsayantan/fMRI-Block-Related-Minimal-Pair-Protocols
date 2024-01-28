% Initialize Psychtoolbox
PsychDefaultSetup(1);
Screen('Preference', 'SkipSyncTests', 1); % Skip screen synchronization tests for faster execution
Screen('Preference', 'VisualDebugLevel', 0); % Disable PTB's visual debugging

% Get participant number
participantNumber = input('Enter participant number: ');

% Set up experiment parameters
numBlocks = 4;
blockOrder = repmat(["L", "V"], 1, numBlocks/2); % Randomize the order if needed
stimulusDuration = 1; % Duration of each stimulus token in seconds
restDuration = 15; % Duration of rest block in seconds
screenColor = [255 255 255]; % White background
textColor = [0 0 0]; % Black text

% Define audio file names
minusWordFile = 'minusword.wav';
plusWordFile = 'plusword.wav';

% Open a window and get screen parameters
screenNumber = max(Screen('Screens'));
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, screenColor);
[~, screenYpixels] = Screen('WindowSize', window);
Screen('TextSize', window, 40);

% Create timestamps file
timestampFile = sprintf('production_timestamps_%d.txt', participantNumber);
fid = fopen(timestampFile, 'w');
fprintf(fid, 'Block\tToken\tOnsetTime\tDuration\n');

% Wait for "=" key press to start the experiment
DrawFormattedText(window, 'Press "=" to start the experiment.', 'center', 'center', textColor);
Screen('Flip', window);
KbStrokeWait;

% Loop through blocks
for block = 1:numBlocks
    % Display block name
    blockName = blockOrder(block);

    % Loop through stimuli within the block
    for stimulus = 1:4
        % Load audio file based on block type
        if blockName == "L"
            audioFile = minusWordFile;
        else
            audioFile = plusWordFile;
        end

        % Play audio stimulus
        [audioData, sampleRate] = audioread(audioFile);
        sound(audioData, sampleRate);
        onsetTime = PsychPortAudio('Start', [], [], GetSecs + 0.1, 1);

        % Save timestamp
        fprintf(fid, '%s\t%s\t%.3f\t%.3f\n', blockName, audioFile, onsetTime, stimulusDuration);

        % Wait for stimulus duration
        WaitSecs(stimulusDuration);

        % Display fixation cross "+"
        DrawFormattedText(window, '+', 'center', 'center', textColor);
        Screen('Flip', window);

        % Save timestamp
        fprintf(fid, '%s\t+\t%.3f\t%.3f\n', blockName, GetSecs, 1);

        WaitSecs(1);
    end

    % Insert rest block if not the last block
    if block < numBlocks
        DrawFormattedText(window, '+', 'center', 'center', textColor);
        Screen('Flip', window);

        % Save timestamp
        fprintf(fid, 'Rest\t+\t%.3f\t%.3f\n', GetSecs, restDuration);

        WaitSecs(restDuration);
    end
end

% Close the window and file
fclose(fid);
sca;

