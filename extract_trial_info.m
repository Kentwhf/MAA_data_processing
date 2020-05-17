% A helper function extracting features of each trail in the same folder 

function [result] = extract_trial_info(rootdir)

result = [];
f = dir(rootdir);

for i = 3:length(f)
    
    % A list of file paths
%     if f(i).isdir
%         new_folder = strcat(f(i).folder, '\', f(i).name);
%         result = [result; info(new_folder)];
%     end
    
    % make sure file extension is .mat
    format = f(i).name(end-3:end);
    
    if strcmp(format, '.mat')
        temp = split((f(i).name), '_');
        trial_time = f(i).date;
        
        str = temp{3}; % Third element of the array
        outcome = extractAfter(str,1);
        direction = extractBefore(str, 2);
        
        % Use integers or N/A to categorize outcome of each trial
        if strcmp(outcome, 'P')
            outcome = {'1'};
        elseif strcmp(outcome, 'F')
            outcome = {'0'};
        else
            outcome = {'N/A'};
        end
        
        % Summarize the data set
        other_data = miscellaneous(f(i));
        new = horzcat({f(i).name}, temp(1), temp(2), direction, outcome, trial_time, other_data);
        
        result = [result; new];
    end
end  
end

function [result] = miscellaneous(file)
current_file = strcat(file.folder, '\', file.name);

% Trial info
temp = importdata(current_file);
angle = round(temp(3,1));
trialnum = temp(2,1);

% Velocity calculation
distance = temp(8, 1: 42 : end); % 42 denotes downsampling to the sampling rate of 6 herzs

% sensor only detects object that is at least 0.5 meters far
time = temp(1, 1: 42: end); % 42 denotes downsampling to the sampling rate of 6 herzs

velocity = zeros(length(time)-1,1);

for i = 1:length(time)-1
    velocity(i) = (distance(i+1)-distance(i))/(time(i+1)-time(i)) ;
end

velocity = abs(velocity);
velocity = velocity(velocity > 0.2);

% figure;
% plot(time,distance);
% saveas(gcf,strcat(file.name,'.png'))

% Remove outliers
isNormal = isoutlier(velocity, 'quartiles');
velocity = velocity(isNormal ~= 1);
time = time(isNormal ~= 0);

max_velocity = max(abs(velocity));
average_velocity = mean(velocity); 

result = {angle, trialnum, average_velocity, max_velocity, current_file, median(temp(4,:)), median(temp(5,:)), median(temp(6,:))};

end
