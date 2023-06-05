%% Script to just load an already saved test and then plot it
% The tests themselves are performed ny the script rs232_com

clear
close all

id_num = 3;
seizure = 2;

load("fpga_output_id" + string(id_num) + ".mat");

%% Plot the results

TP = 0;
FN = 0;
TN = 0;
FP = 0;

% Convert the data so they can be nicely plotted and compute the needed stats
results = zeros(1,512*length(output));
for i=1:length(output)
    index = 512*(i-1) + 1;
    results(index:index+511) = 80*output(i);

    % All non ictal points
    if (i <= 180) || (i >= length(output) - 179)
        if (output(i) == 0)
            TN = TN + 1;
        else
            FP = FP + 1;
        end
    else
        if (output(i) == 1)
            TP = TP + 1;
        else
            FN = FN + 1;
        end
    end
end

% Load the seizure to visually compare
load("Datas/ID" + string(id_num) + "/Sz" + string(seizure) + ".mat");
working_channel = mean(EEG,2);

figure
plot(working_channel);
hold on
plot(results);
xline(92160, '-', {'Ictal'});
xline(length(working_channel)-92160);
title("FPGA implementation of the predictor for patient " + string(id_num) + " and seizure " + string(seizure))
legend("EEG signal", "Prediction")
xlabel("Time [s]")
ylabel("Amplitude [-]")
xlim([0 length(working_channel)])
xticks(0:30*512:length(working_channel))
xticklabels(string(0:30:(length(working_channel))/512))

disp([TP, FN; TN, FP])