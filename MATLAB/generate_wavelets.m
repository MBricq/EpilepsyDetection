%% This script will go through every patients, load their seizures, apply the Simulink
% DWT algorithm, compute the needed statistics and save them all in csv
% ready for training and/or testing
% The files saved are all in Datas/IDx/... where x is the id of the patient

clear;
close all;

% For each patient decide on the number of the seizures for training, and
% thus also testing
% All the training datas will be saved in one file then the each testing
% seizure is saved independtly
num_training_all = [10, 3, 1, 5, 7, 3, 1, 1, 7, 4, 1, 7, 3, 3, 2, 4];

for id_num = 1:16

    % Dont forget to uncomment this and remove next line, it was just to
    % generate all seizures' stats
    %num_seizure_train = num_training_all(id_num);
    num_seizure_train = 0;
    
    individual_num = string(id_num);

    folder = "Datas\ID" + individual_num;
    
    all_files = dir([folder + "\*.mat"]);
    
    num_seizure = length(all_files);
    

    clear_table
    for seizure = 1:num_seizure

        seizure_id = string(seizure);
        
        %% Load data from one seizure and put it in correct shape
        load("Datas\ID" + individual_num + "\Sz" + seizure_id + ".mat");
        
        averaged_signal = mean(EEG, 2);

        num_sample = 512;
        
        [non_ictal, ictal] = generate_epochs_from_EEG(averaged_signal, num_sample, 92160, 92160);
        
        %% Compute the statistics for all epochs and put them in one matrix to get them ready for training
        for i = 1:180
            % first the pre-ictal data
            current_epoch = non_ictal(:, i)';
        
            generate_stats
        
            Class = [Class; "non_ictal"];
        end
        
        for i = 1:size(ictal, 2)
            % then the ictal data
            current_epoch = ictal(:, i)';
        
            generate_stats
        
            Class = [Class; "ictal"];
        end

        for i = 181:360
            % and finally post-ictal
            current_epoch = non_ictal(:, i)';
        
            generate_stats
        
            Class = [Class; "non_ictal"];
        end


        %% Save the data in a file
        if (seizure == num_seizure_train)
            % All the training data
            T = table(D1_ene, D2_ene, D3_ene, D4_ene, D5_ene, D6_ene, A6_ene, ...
                  D1_std, D2_std, D3_std, D4_std, D5_std, D6_std, A6_std, ...
                  D1_cur, D2_cur, D3_cur, D4_cur, D5_cur, D6_cur, A6_cur, ...
                  D1_max, D2_max, D3_max, D4_max, D5_max, D6_max, A6_max, ...
                  D1_min, D2_min, D3_min, D4_min, D5_min, D6_min, A6_min, ...
                  Activity, Signal_ene, Signal_cur, Signal_max, Signal_min, ...
                  Class);
            
            writetable(T, "Datas/ID" + individual_num + "/training_stats.csv");
            clear_table;
        elseif (seizure > num_seizure_train)
            % Each indivual testing data
            T = table(D1_ene, D2_ene, D3_ene, D4_ene, D5_ene, D6_ene, A6_ene, ...
                  D1_std, D2_std, D3_std, D4_std, D5_std, D6_std, A6_std, ...
                  D1_cur, D2_cur, D3_cur, D4_cur, D5_cur, D6_cur, A6_cur, ...
                  D1_max, D2_max, D3_max, D4_max, D5_max, D6_max, A6_max, ...
                  D1_min, D2_min, D3_min, D4_min, D5_min, D6_min, A6_min, ...
                  Activity, Signal_ene, Signal_cur, Signal_max, Signal_min, ...
                  Class);
        
            writetable(T, "Datas/ID" + individual_num + "/testing_stats_sz" + string(seizure) + ".csv");
            clear_table;
        end

    end
end