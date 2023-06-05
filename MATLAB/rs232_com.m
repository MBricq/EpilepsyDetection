%% Script to test the FPGA predictor for one patient
% This code should be run only when the FPGA is ready to received data (ie
% when the init phase is done = LEDs on) see the README in the FPGA
% directory for more information
clear

%% Start the communication with the FPGA
% The COM needs to correspond to the one with the RS-232 cable plugged in,
% the baud rate depends on the built system in QSys, I used 9600 as it was
% enough for my test
s = serialport("COM5", 9600);

% Load the seizure
id_num = 2;
seizure = 4;

load("Datas/ID" + string(id_num) + "/Sz" + string(seizure) + ".mat");
mean_eeg = mean(EEG, 2);
signal_in_fi = fi(mean_eeg, 1, 16, 4);
signal_in = bin2dec(bin(signal_in_fi));

output = zeros(length(signal_in_fi)/512, 1);

num_window = length(signal_in) / 512;
for window_id = 1:num_window
    % Send one window at a time and wait for the corresponding output
    start_sample = 512 * (window_id - 1) + 1;
    for i=start_sample:(start_sample+511)
        write(s, signal_in(i), "uint16");
        
        t0 = tic;
        % Function I found online which is more consistent than the
        % classical MATLAB pause, I couldnt make it work faster, it seems
        % Matlab is unable to send correclty values at 1kHz => quite slow
        % to test, it works in real-time
        pauses(0.002, t0);
    end
    
    % Some feedback on advancement
    disp("Window " + string(window_id) + "/" + string(num_window) + " sent");

    output(window_id) = read(s, 1, "uint8");
end

% Next line is to save the results, will overwrite any other save, comment
% if not sure the result need to be saved, it can be manually run after the
% script is done
%save("fpga_output_id" + string(id_num) + ".mat", "output");

%% Plot the results and compute basic stats
% the same can be done with plot_fpga_result if the output has been saved 
% with previous command

TP = 0;
FN = 0;
TN = 0;
FP = 0;

% Convert the data so they can be nicely plotted and compute the needed
% stats
results = zeros(1,512*length(output));
for i=1:length(output)
    index = 512*(i-1) + 1;
    results(index:index+511) = 80*output(i);

    % All non ictal points
    if (i <= 180) || (i >= length(output) - 179)
        % The first and last 3mins (ie 180secs) are non_ictal
        if (output(i) == 0)
            TN = TN + 1;
        else
            FP = FP + 1;
        end
    else
        % The rest is ictal
        if (output(i) == 1)
            TP = TP + 1;
        else
            FN = FN + 1;
        end
    end
end

figure
plot(mean_eeg);
hold on
plot(results);
xline(92160, '-', {'Ictal'});
xline(length(mean_eeg)-92160);
title("FPGA implementation of the predictor for patient " + string(id_num) + " and seizure " + string(seizure))
legend("EEG signal", "Prediction")
xlabel("Time [s]")
ylabel("Amplitude [-]")
xlim([0 length(mean_eeg)])
xticks(0:30*512:length(mean_eeg))
xticklabels(string(0:30:(length(mean_eeg))/512))

disp([TP, FN; TN, FP])
