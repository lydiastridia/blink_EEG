%Purpose: This function opens the Psychtoolbox window.

% honestly, this came as a consequence of me pasting the errors i got and asking for a way to fix Psychtoolbox for mac

function [w, rect] = openScreen(params)

%Reset Psychtoolbox settings: the see-through debug window otherwise stays on
%for the whole MATLAB session once it was switched on
clear Screen

if params.debugWindow
    PsychDebugWindowConfiguration(0, params.debugOpacity);
end

if params.testMode
    Screen('Preference', 'SkipSyncTests', 1);

    %Mac laptops (Apple Silicon, macOS 26): Psychtoolbox's Vulkan display mode
    %drops frames, including the one-frame target. Bit 8192 of ConserveVRAM
    %switches it off. Only in test mode: the lab PC is not affected.
    if ismac
        cv = Screen('Preference', 'ConserveVRAM');
        if isempty(cv)
            cv = 0;
        end
        Screen('Preference', 'ConserveVRAM', bitor(cv, 8192));
    end
else
    Screen('Preference', 'SkipSyncTests', 0);
end

%Open the main window
[w, rect] = Screen('OpenWindow', params.screenToUse, params.screen.bgColor);

%General text settings
Screen('TextSize', w, params.stim.textSize);
Screen('TextFont', w, 'Arial');

if ~params.debugWindow
    HideCursor;
end
Priority(MaxPriority(w));
end
