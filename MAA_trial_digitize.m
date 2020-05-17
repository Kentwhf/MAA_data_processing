% GoPro camera has inconvenient file naming convention
% Completely unfriendly to oragnizing and labeling 
% Here is a script summarizing infomation of wanted video clips 
% However we may not get equal number of videos as sensor files 
% Due to connection problems, human mistakes of not turning camera on...
% Created by Kent

% Tipper does not zero the trial number itself, unless we restart the model. 

clear
path1 = 'K:\winterlab\data\tipper\2020-01-15';
path2 = 'J:\winterlab\footwear database\Tipper Operator\GoPro video\2019-09-06\';

% Get all videos in the current folder
videos = dir(strcat(path2, '*.mp4'));
videos_dir = [];

for id = 1:length(videos)
    % Get the file name (minus the extension)
    name = videos(id).name;
    folder = videos(id).folder;
    videos_dir = [videos_dir; strcat(folder, '\', name)];
end

% Get trail features 
features = extract_trial_info(path1);

% level speed 
level = features(((cell2mat(features(:,7)) == 0)), :);

level_files = [];
for k = 1:length(level(:, 11))
    level_files = [level_files; dir(char(level(k, 11)))];
end

idapt_map = make_obj_map(level_files);

ice_temp_median = [];
air_temp_median = [];
humidity_median = [];
table = [];

for idapt = idapt_map.keys
    temp = idapt_map(cell2mat(idapt));
    for sub = temp.keys
        temp2 = temp(cell2mat(sub));
        
        % Velocity calculation
        distance = temp2(8, 1: 42 : end); % 42 denotes downsampling to the sampling rate of 6 herzs
        % distance = distance(4 > distance > 0.5); % sensor only detects object that is at least 0.5 meters far
        time = temp2(1, 1: 42: end); % 42 denotes downsampling to the sampling rate of 6 herzs
        % time = time(4 > distance > 0.5);

        velocity = zeros(length(time)-1,1);
        for i = 1:length(time)-1
            velocity(i) = (distance(i+1)-distance(i))/(time(i+1)-time(i)) ;
        end
        velocity = abs(velocity);

        % Remove outliers
        % normality = filloutliers(velocity, 0, 'median');
        normality = isoutlier(velocity, 'quartiles');
        velocity = velocity(normality ~= 1);
        time = time(normality ~= 0);

        max_velocity = max(abs(velocity));
        average_velocity = mean(velocity); 
        
%         ice_temp_median = [ice_temp_median ; median(temp2(4, :))  double(cell2mat(idapt)) double(cell2mat(sub))];
%         air_temp_median = [air_temp_median ; median(temp2(6, :))  double(cell2mat(idapt)) double(cell2mat(sub))];
%         humidity_median = [humidity_median ; median(temp2(5, :))  double(cell2mat(idapt)) double(cell2mat(sub))];
        
        if median(temp2(4, :)) < -2
            walkway = 0; % dry
        else
            walkway = 1; % wet
        end
        
        table = [table; double(cell2mat(idapt)) double(cell2mat(sub)) walkway double(average_velocity)];
        
    end
end

% ice_median_table = array2table(ice_temp_median, 'VariableNames', {'Ice', 'IDAPT', 'SUBJECT'});
% air_median_table = array2table(air_temp_median, 'VariableNames', {'Air', 'IDAPT', 'SUBJECT'});
% humidity_median_table = array2table(humidity_median, 'VariableNames', {'Humidity', 'IDAPT', 'SUBJECT'});
table = array2table(table, 'VariableNames', {'IDAPT', 'SUBJECT', 'WALKWAY' , 'VELOCITY'});

features = features(:, 1 : end - 3);
videos_dir = cellstr(videos_dir);





