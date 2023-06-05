%% Script to load the SVM parameters from the saved model, it will then
% display them in a way which directly allow to copy/paste into the C code
% To be noted: not guaranteed that it displays betas, mus and sigmas in the
% correct order with respect with the VHDL code, make sure before pasting

clear
id_num = 2;

%% Load the SVM's parameters
load("svm" + string(id_num) + ".mat");
    
betas = trainedModel.ClassificationSVM.Beta;
mus = trainedModel.ClassificationSVM.Mu';
sigmas = trainedModel.ClassificationSVM.Sigma';
bias = trainedModel.ClassificationSVM.Bias;
scale = trainedModel.ClassificationSVM.KernelParameters.Scale;
   
%% Convert all these values to expected input
% ie: signed, 42 bits and 12 of decimal

scale_bin = bin(fi(scale, 1, 42, 12));
bias_bin = bin(fi(bias, 1, 42, 12));
betas_bin = bin(fi(betas, 1, 42, 12));
mus_bin = bin(fi(mus, 1, 42, 12));
sigmas_bin = bin(fi(sigmas, 1, 42, 12));

num_predictor = size(betas, 1);

%% Display them to be copied into the C code

disp("const uint32_t scale_msb = 0b" + scale_bin(1:10) + ";")
disp("const uint32_t scale_lsb = 0b" + scale_bin(11:42) + ";")

disp("const uint32_t bias_msb = 0b" + bias_bin(1:10) + ";")
disp("const uint32_t bias_lsb = 0b" + bias_bin(11:42) + ";")

betas_msb = char(strjoin("0b" + string(betas_bin(:, 1:10)) + ","));
disp("const uint32_t betas_msb[" + num_predictor + "] = {" + betas_msb(1:(end-1)) + "};")
betas_lsb = char(strjoin("0b" + string(betas_bin(:, 11:42)) + ","));
disp("const uint32_t betas_lsb[" + num_predictor + "] = {" + betas_lsb(1:(end-1)) + "};")

mus_msb = char(strjoin("0b" + string(mus_bin(:, 1:10)) + ","));
disp("const uint32_t mus_msb[" + num_predictor + "] = {" + mus_msb(1:(end-1)) + "};")
mus_lsb = char(strjoin("0b" + string(mus_bin(:, 11:42)) + ","));
disp("const uint32_t mus_lsb[" + num_predictor + "] = {" + mus_lsb(1:(end-1)) + "};")

sigmas_msb = char(strjoin("0b" + string(sigmas_bin(:, 1:10)) + ","));
disp("const uint32_t sigmas_msb[" + num_predictor + "] = {" + sigmas_msb(1:(end-1)) + "};")
sigmas_lsb = char(strjoin("0b" + string(sigmas_bin(:, 11:42)) + ","));
disp("const uint32_t sigmas_lsb[" + num_predictor + "] = {" + sigmas_lsb(1:(end-1)) + "};")