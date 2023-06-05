function [non_ictal, ictal] = generate_epochs_from_EEG(EEG, epoch_size, pretime, posttime)
    % Assuming :
    %  - EEG is a column vector
    % window_size represents the size of each epoch to generate
    %  - pretime and posttime represents the number of samples before
    % and after the seizure itself

    % Returns matrices with each column being one epoch of correct size
    
    preictal_data = EEG(1:pretime);
    postical_data = EEG(end-posttime+1:end);

    non_ictal_data = [preictal_data; postical_data];

    num_non_ictal_epochs = floor(length(non_ictal_data)/epoch_size);
    non_ictal = reshape(non_ictal_data, [], num_non_ictal_epochs);

    ictal_length = size(EEG,1) - posttime - pretime;
    % To get an array that we can divide intoarrays of size window_size
    % Might lose some data
    ictal_length = floor(ictal_length/epoch_size) * epoch_size; 

    ictal_data = EEG(pretime+1:pretime+ictal_length);

    ictal = reshape(ictal_data, [],floor(ictal_length / epoch_size));
end