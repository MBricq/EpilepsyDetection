function stats = compute_stats(signal, window_size)
    % First remove all leading zeros and then keep only the correct amount
    % of samples. This might lose some information if by mischance the
    % first values of the signal are real 0, this is assumed to never occur
    start = find(signal, 1); % = position of first non zero value
    work_signal = signal(start:start+window_size-1);
    
    % Energy
    energy = mean(work_signal.^2);

    % Standard deviation
    std_dev = std(work_signal);

    % Curve length
    curve_len = sum(abs(diff(work_signal)));
    
    % Max
    max_x = max(work_signal);

    % Min
    min_x = min(work_signal);
    

    stats = [energy, std_dev, curve_len, max_x, min_x];
end