%% This script require to be run after current_epoch was set as one the output
% of the function generate_epochs_from_EEG and with num_sample set as the
% size of the window used for calculation

t_samples = [0:size(current_epoch,2)-1].';
signal_in = [t_samples current_epoch.'];

% Get size of input as stop time + a constant due to delay in computations,
% because of that delay, there will be always leading zeros in the output
% this is taken care before computing the stats
simulation_time = num_sample + 550;

% Call the simulink model of the 4-level DWT implemented for FPGA
out = sim("simulink\hdlcoder_dwt", 'StartTime', '0', 'StopTime', string(simulation_time));

A6 = downsample(reshape(out.approx,  [simulation_time+1 1]), 64);
D6 = downsample(reshape(out.detail6, [simulation_time+1 1]), 64);
D5 = downsample(reshape(out.detail5, [simulation_time+1 1]), 32);
D4 = downsample(reshape(out.detail4, [simulation_time+1 1]), 16);
D3 = downsample(reshape(out.detail3, [simulation_time+1 1]), 8);
D2 = downsample(reshape(out.detail2, [simulation_time+1 1]), 4);
D1 = downsample(reshape(out.detail1, [simulation_time+1 1]), 2);

% Compute the different statistics that are to be tested for the machine
% learning, note the number of sample is divided each time by an extra 2
% because every level of DWT undergoes a downsampling by 2
statistics = [compute_stats(double(D1), num_sample / 2) 0];
D1_ene = [D1_ene; statistics(1)];
D1_std = [D1_std; statistics(2)];
D1_cur = [D1_cur; statistics(3)];
D1_max = [D1_max; statistics(4)];
D1_min = [D1_min; statistics(5)];

statistics = [compute_stats(double(D2), num_sample / 4) 0];
D2_ene = [D2_ene; statistics(1)];
D2_std = [D2_std; statistics(2)];
D2_cur = [D2_cur; statistics(3)];
D2_max = [D2_max; statistics(4)];
D2_min = [D2_min; statistics(5)];

statistics = [compute_stats(double(D3), num_sample / 8) 0];
D3_ene = [D3_ene; statistics(1)];
D3_std = [D3_std; statistics(2)];
D3_cur = [D3_cur; statistics(3)];
D3_max = [D3_max; statistics(4)];
D3_min = [D3_min; statistics(5)];

statistics = [compute_stats(double(D4), num_sample / 16) 0];
D4_ene = [D4_ene; statistics(1)];
D4_std = [D4_std; statistics(2)];
D4_cur = [D4_cur; statistics(3)];
D4_max = [D4_max; statistics(4)];
D4_min = [D4_min; statistics(5)];

statistics = [compute_stats(double(D5), num_sample / 32) 0];
D5_ene = [D5_ene; statistics(1)];
D5_std = [D5_std; statistics(2)];
D5_cur = [D5_cur; statistics(3)];
D5_max = [D5_max; statistics(4)];
D5_min = [D5_min; statistics(5)];

statistics = [compute_stats(double(D6), num_sample / 64) 0];
D6_ene = [D6_ene; statistics(1)];
D6_std = [D6_std; statistics(2)];
D6_cur = [D6_cur; statistics(3)];
D6_max = [D6_max; statistics(4)];
D6_min = [D6_min; statistics(5)];

statistics = [compute_stats(double(A6), num_sample / 64) 0];
A6_ene = [A6_ene; statistics(1)];
A6_std = [A6_std; statistics(2)];
A6_cur = [A6_cur; statistics(3)];
A6_max = [A6_max; statistics(4)];
A6_min = [A6_min; statistics(5)];

% Compute parameters for original signal
Activity = [Activity; var(current_epoch)];
Signal_ene = [Signal_ene; mean(current_epoch.^2)];
Signal_cur = [Signal_cur; sum(abs(diff(current_epoch)))];
Signal_max = [Signal_max; max(current_epoch)];
Signal_min = [Signal_min; min(current_epoch)];