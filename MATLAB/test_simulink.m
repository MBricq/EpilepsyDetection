%% This script is here to test the full_system from Simulink and
% compute the statistics associated to it for a comparison with Matlab. It
% can be qite slow to run as it needs to simulate the Simulink blocks.
% To run, need to add simulink directory to the path because the main
% Simulink files depends from others in this directory.

clear

% Choose which patient and seizure to test
id_num = 2;
seizure = 2;

%% Load the trained model to get the parameters
load("svm_models/svm" + string(id_num) + ".mat");

betas = zeros(40,1);
mus = zeros(40,1);
sigmas = ones(40,1);

names = trainedModel.ClassificationSVM.PredictorNames;
for i = 1:length(names)

    if names{i}(1) == 'D' || (names{i}(1) == 'A' && names{i} ~= "Activity")
        if names{i}(1) == 'D'
            pos = 5 * str2double(names{i}(2));
        else
            pos = 35;
        end

        if names{i}(4:6) == "ene"
            betas(pos+1) = trainedModel.ClassificationSVM.Beta(i);
            mus(pos+1) = trainedModel.ClassificationSVM.Mu(i);
            sigmas(pos+1) = trainedModel.ClassificationSVM.Sigma(i);
        elseif names{i}(4:6) == "std"
            betas(pos+2) = trainedModel.ClassificationSVM.Beta(i);
            mus(pos+2) = trainedModel.ClassificationSVM.Mu(i);
            sigmas(pos+2) = trainedModel.ClassificationSVM.Sigma(i);
        elseif names{i}(4:6) == "cur"
            betas(pos+3) = trainedModel.ClassificationSVM.Beta(i);
            mus(pos+3) = trainedModel.ClassificationSVM.Mu(i);
            sigmas(pos+3) = trainedModel.ClassificationSVM.Sigma(i);
        elseif names{i}(4:6) == "max"
            betas(pos+4) = trainedModel.ClassificationSVM.Beta(i);
            mus(pos+4) = trainedModel.ClassificationSVM.Mu(i);
            sigmas(pos+4) = trainedModel.ClassificationSVM.Sigma(i);
        else
            betas(pos+5) = trainedModel.ClassificationSVM.Beta(i);
            mus(pos+5) = trainedModel.ClassificationSVM.Mu(i);
            sigmas(pos+5) = trainedModel.ClassificationSVM.Sigma(i);
        end    
    else
        pos = 0;
        if names{i} == "Signal_ene"
            betas(pos+1) = trainedModel.ClassificationSVM.Beta(i);
            mus(pos+1) = trainedModel.ClassificationSVM.Mu(i);
            sigmas(pos+1) = trainedModel.ClassificationSVM.Sigma(i);
        elseif names{i} == "Activity"
            betas(pos+2) = trainedModel.ClassificationSVM.Beta(i);
            mus(pos+2) = trainedModel.ClassificationSVM.Mu(i);
            sigmas(pos+2) = trainedModel.ClassificationSVM.Sigma(i);
        elseif names{i} == "Signal_cur"
            betas(pos+3) = trainedModel.ClassificationSVM.Beta(i);
            mus(pos+3) = trainedModel.ClassificationSVM.Mu(i);
            sigmas(pos+3) = trainedModel.ClassificationSVM.Sigma(i);
        elseif names{i} == "Signal_max"
            betas(pos+4) = trainedModel.ClassificationSVM.Beta(i);
            mus(pos+4) = trainedModel.ClassificationSVM.Mu(i);
            sigmas(pos+4) = trainedModel.ClassificationSVM.Sigma(i);
        elseif names{i} == "Signal_min"
            betas(pos+5) = trainedModel.ClassificationSVM.Beta(i);
            mus(pos+5) = trainedModel.ClassificationSVM.Mu(i);
            sigmas(pos+5) = trainedModel.ClassificationSVM.Sigma(i);
        end    
    end
end

bias = trainedModel.ClassificationSVM.Bias;
scale = trainedModel.ClassificationSVM.KernelParameters.Scale;


%% Generate the signal to send to Simulink
load("Datas/ID" + string(id_num) + "/Sz" + string(seizure) + ".mat");

mean_eeg = mean(EEG, 2);

signal_in = [[0:(length(mean_eeg)-1)].' mean_eeg];
enable = [[0:(length(mean_eeg)-1)].' ones(length(mean_eeg), 1)];

simulation_time = length(mean_eeg) + 550;

% Call the simulink model
out = sim("simulink/full_system", 'StartTime', '0', 'StopTime', string(simulation_time));

output = 100 * reshape(out.svm_output, [simulation_time+1 1]);

%% Compute stats and display
TP = 0;
FN = 0;
TN = 0;
FP = 0;

num_epochs = length(signal_in)/512;

for i=1:num_epochs
    index = 512*(i-1) + 1;

    % All non ictal points
    if (i <= 180) || (i >= num_epochs - 179)
        if (output(index) == 0)
            TN = TN + 1;
        else
            FP = FP + 1;
        end
    else
        if (output(index) == 100)
            TP = TP + 1;
        else
            FN = FN + 1;
        end
    end
end

disp([TP, FN; TN, FP])

%% Plot the results
figure
plot(mean_eeg);
hold on
plot(output);
xline(92160, '-', {'Ictal'});
xline(length(mean_eeg)-92160);
title("Simulink implementation of the predictor for patient " + string(id_num) + " and seizure " + string(seizure))
xlabel("Time [s]")
ylabel("Amplitude [-]")
xlim([0 length(mean_eeg)])
xticks(0:30*512:length(mean_eeg))
xticklabels(string(0:30:(length(mean_eeg))/512))
legend("EEG signal", "Prediction output")
