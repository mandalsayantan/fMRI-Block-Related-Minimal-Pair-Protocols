%% Set up experimental parameters
clear all;
close all;

% Ask for participant number
participant_num = input('Enter participant number: ','s');

% Define the duration and number of blocks
num_blocks = 6;
block_duration = 50; % in seconds
rest_duration = 15; % in seconds

% Define the words to present in each condition
voiced_word = 'zoo';
voiceless_word = 'sue';

% Define the color and size of the text
text_color = [0 0 0];
text_size = 120;

% Define the interstimulus interval
isi_duration = 1; % in seconds

% Define the output file name and path
output_file = sprintf('sub-%s_production_timestamps.txt', participant_num);

%% Initialize the experiment
 %Get all available screens
screens = Screen('Screens');

% Added this because projector was failing sync test. Disabling sync only
% results in about 0.001 ms timing discrepancy. Given a TR of 2 seconds with
% around 32 slices, this well within the HRF tolerance limit. While ideal to run
% the sync tests, and get accurate VBL timing, for fMRI analyses this is absolutely
% fine, especially if getting projectors to sync becomes a hassle. Also, DO NOT
% use MS Windows if you care about psychophysics toolbox's ability to keep track
% of time accurately.One hard-learnt lesson here is to ensure that you set your screen
%  settings to "mirror" IFF you are adding an external monitor that has a different
% refresh rate than your stimulus presentation laptop. I couldn't figure out a way
% to get the projector box of the GE MRI machine to pass the sync test at all.

Screen('Preference', 'SkipSyncTests', 1);

% Sync to the external projector display (assuming it is the second screen). One
% hard-learnt lesson here is to ensure that you set your screen settings to "mirror"
% IFF you are adding an external monitor that has a different refresh rate than your
% stimulus presentation laptop. I couldn't figure o
screenNumber = max(screens);
if length(screens) > 1
    screenNumber = 2;
end

% Open a window
[win, winRect] = Screen('OpenWindow', screenNumber, [255 255 255]);
HideCursor();

% Get the center coordinates of the window
[xCenter, yCenter] = RectCenter(winRect);

% Set the font size and style
Screen('TextSize', win, text_size);
Screen('TextStyle', win, 1);

% Initialize the timestamp file
output_fid = fopen(output_file, 'w');

% Initialize the start time of the experiment
first_start_time = GetSecs();

% Wait for trigger (for fMRI scanning)
DrawFormattedText(win, '+', 'center', 'center', text_color);
Screen('Flip', win);
% Specify the desired keyboard input
targetKey = 'equal';

% Wait for the specified key press
while 1
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown && strcmpi(KbName(keyCode), targetKey)
        break;
    end
end

% Loop through each block
for block = 1:num_blocks
% Determine the condition (voiced or voiceless)
if mod(block, 2) == 0
    word = voiced_word;
    block_name = 'voiced';
else
    word = voiceless_word;
    block_name = 'voiceless';
end

% Write the start time and duration to the output file
start_time = GetSecs();
start_time_seconds = start_time - first_start_time;
fprintf(output_fid, '%f\t%d\t%s\n', start_time_seconds, block_duration, block_name);

% Present the block
for trial = 1:25

    % Show the word
    DrawFormattedText(win, word, 'center', 'center', text_color);
    Screen('Flip', win);
    WaitSecs(1);

    % Show a blank screen
    Screen('Flip', win);
    WaitSecs(isi_duration);
end

% Show the rest period
rest_start_time = GetSecs();
rest_start_time_seconds = rest_start_time - first_start_time;
fprintf(output_fid, '%f\t%d\t%s\n', rest_start_time_seconds, rest_duration, 'rest');
DrawFormattedText(win, '+', 'center', 'center', text_color);
Screen('Flip', win);
WaitSecs(rest_duration);
end

% Close the output file
fclose(output_fid);

% Close the window
Screen('CloseAll');
ShowCursor();
