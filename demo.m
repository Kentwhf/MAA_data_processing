file = dir("U:\Projects\Winter Projects\Kent\WinterLab\sensor data sample\2019-07-11\idapt502_sub257_UP_14-26-35.mat"); 
current_file = strcat(file.folder, '\', file.name);

% Trial info
temp = importdata(current_file);
angle = round(temp(3,1));
trialnum = temp(2,1);

% Velocity calculation
distance = temp(8, 1: 42 : end); % 42 denotes downsampling to the sampling rate of 6 herzs
% distance = distance(4 > distance > 0.5); % sensor only detects object that is at least 0.5 meters far
time = temp(1, 1: 42: end); % 42 denotes downsampling to the sampling rate of 6 herzs
time = time - time(1);
% time = time(4 > distance > 0.5);

velocity = zeros(length(time)-1,1);
for i = 1:length(time)-1
    velocity(i) = (distance(i+1)-distance(i))/(time(i+1)-time(i)) ; % velocity at index i
end

figure(1);
plot(time, distance);
hold on
title('A random trial on July 11');
xlabel('time(s)') 
ylabel('distance(m)') 

time = time(1:end-1);

figure(2);
plot(time, velocity);


% Remove outliers
% outlier = filloutliers(velocity, 0, 'median');
outlier = isoutlier(velocity, 'quartiles');
% velocity = velocity(outlier ~= 1);
% time = time(outlier ~= 1);

% Mark outliers 
outlier_indice = find(outlier);
disp(outlier_indice);

% moving_average = abs(velocity) > 0.1; % filtering with 0 and 1 
% moving_average = velocity(moving_average); % indexing

figure(3);
plot(time,velocity)
hold on 
plot(time,velocity, '*' ,'MarkerIndices',outlier_indice);
legend({'Original data','Detected outlier'},'FontSize',14)

average_velocity = ((sum(velocity))/length(velocity)); 
