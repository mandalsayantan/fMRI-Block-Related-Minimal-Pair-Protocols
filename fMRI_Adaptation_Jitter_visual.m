% Initialize Psychtoolbox
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1); % Skip screen synchronization tests for faster execution
Screen('Preference', 'VisualDebugLevel', 0); % Disable PTB's visual debugging

% Get participant number
participantNumber = [];
while isempty(participantNumber)
    participantNumber = input('Enter participant number: ');
    if isempty(participantNumber)
        fprintf('Invalid participant number. Please try again.\n');
    end
end

% Set up experiment parameters
numBlocks = 4;
blockOrder = repmat(["L", "V"], 1, numBlocks/2); % Randomize the order if needed
stimulusDuration = 1; % Duration of each stimulus token in seconds
restDuration = 15; % Duration of rest block in seconds
screenColor = [255 255 255]; % White background
textColor = [0 0 0]; % Black text

% Define word strings
minusWord = 'sue';
plusWord = 'zoo';

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

    % Determine number of instances for each word
    if blockName == "L"
        numMinusWords = 23;
        numPlusWords = 2;
    else
        numMinusWords = 2;
        numPlusWords = 23;
    end

    % Create a random order of plusword instances for L block
    if blockName == "L"
        plusOrder = randperm(numMinusWords + numPlusWords);
        plusIndices = plusOrder(1:numPlusWords);
    end

    % Loop through stimuli within the block
    for stimulus = 1:(numMinusWords + numPlusWords)
        % Display word based on block type
        if blockName == "L"
            if ismember(stimulus, plusIndices)
                word = plusWord;
            else
                word = minusWord;
            end
        else
            if stimulus <= numMinusWords
                word = minusWord;
            else
                word = plusWord;
            end
        end

        DrawFormattedText(window, word, 'center', 'center', textColor);
        Screen('Flip', window);
        onsetTime = GetSecs;

        % Save timestamp
        fprintf(fid, '%s\t%s\t%.3f\t%.3f\n', blockName, word, onsetTime, stimulusDuration);

        % Wait for stimulus duration
        WaitSecs(stimulusDuration);

        % Display fixation cross "+"
        DrawFormattedText(window, '+', 'center', 'center', textColor);
        Screen('Flip', window);

        % Save timestamp
        fprintf(fid, '%s\t+\t%.3f\t%.3f\n', blockName, GetSecs, 1);

        % Wait for 1 second
        WaitSecs(1);
    end

    % Insert rest block if not the last block
    if block < numBlocks
        DrawFormattedText(window, '+', 'center', 'center', textColor);
        Screen('Flip', window);
        restOnsetTime = GetSecs;

        % Save timestamp for rest block
        fprintf(fid, 'Rest\t+\t%.3f\t%.3f\n', restOnsetTime, restDuration);

        % Wait for rest duration
        WaitSecs(restDuration);
    end
end

% Close the window
sca;

% Close the timestamps file
fclose(fid);

