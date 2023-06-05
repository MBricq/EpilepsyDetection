%% This script was built to test the SVM models on the testing seizures
% Need to set which patient and which seizure is tested, need first to
% generate the statistics by running generate_wavelets or a similar new
% script if only one seizure is required

% Note: we don't use the MATLAB trainedModel.predictFcn(T) function because
% when the models were first built and saved, more statistics were found in
% T but all non-used were removed. A good idea would be to rebuild and save
% the model with the new T but at the same time, the following script
% allows to do the moving average before applying sign function (see the
% part Compute the classifier)

clear

id_num = 14;

% Test one seizure at a time
seizure = 4;

% Load SVM, can be commented if one is currently trying a new model with
% the app Classification learner. Once a new model is considered good, run
% the following : 
% save("svm_models\svm" + string(id_num) + ".mat", "trainingModel");
load("svm_models\svm" + string(id_num) + ".mat");

T = readtable("Datas\ID" + string(id_num) + "\testing_stats_sz" + string(seizure) + ".csv");

%% Get classifier
betas = trainedModel.ClassificationSVM.Beta;
bias = trainedModel.ClassificationSVM.Bias;
mus = trainedModel.ClassificationSVM.Mu;
sigmas = trainedModel.ClassificationSVM.Sigma;
scale = trainedModel.ClassificationSVM.KernelParameters.Scale;
predictorNames = trainedModel.ClassificationSVM.PredictorNames;

predictors = T{:, predictorNames};

% Normalization
predictors = (predictors - mus) ./ sigmas;

%% Compute the classifier
predictors = predictors / scale;

predict_func = predictors * betas + bias;

% Moving average of the last four values
predict_func = movmean(predict_func, [3 0]);

classification = -sign(predict_func);

%% Compute results
TP = 0;
FN = 0;
TN = 0;
FP = 0;

results = zeros(1,512*length(classification));
for i=1:length(classification)
    index = 512*(i-1) + 1;
    results(index:index+511) = 80*(classification(i) + 1);

    % All non ictal points
    if (i <= 180) || (i >= length(classification) - 179)
        if (classification(i) == -1)
            TN = TN + 1;
        else
            FP = FP + 1;
        end
    else
        if (classification(i) == 1)
            TP = TP + 1;
        else
            FN = FN + 1;
        end
    end
end

%% Transform the prediction before sign for plotting purposes

results2 = zeros(1,512*length(classification));
for i=1:length(classification)
    index = 512*(i-1) + 1;
    results2(index:index+511) = 10*predict_func(i);
end

%% Plot along the actual seizure
load("Datas/ID" + string(id_num) + "/Sz" + string(seizure) + ".mat");

working_channel = mean(EEG,2);

figure
plot(working_channel);
hold on
plot(results);
hold on
plot(results2)
xline(92160, '-', {'Ictal'});
xline(length(working_channel)-92160);
title("MATLAB implementation of the predictor for patient " + string(id_num) + " and seizure " + string(seizure))
xlabel("Time [s]")
ylabel("Amplitude [-]")
xlim([0 length(working_channel)])
xticks(0:30*512:length(working_channel))
xticklabels(string(0:30:(length(working_channel))/512))
legend("EEG signal", "Prediction output", "Predictor before sign(x)", "", "")

disp([TP, FN; TN, FP])