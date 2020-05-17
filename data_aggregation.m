% A simple function concatenating the data frames under the same folder.

function [result] = data_aggregation(rootdir)
result = [];
f = dir(rootdir);  
for i = 3:length(f)
    if f(i).isdir
        new_folder = strcat(f(i).folder, '\', f(i).name); % Get subfolders' directory 
%         new_folder = strcat(new_folder, f(i).name); 
        result = [result data_aggregation(new_folder)];
    end
    format = f(i).name(end-3:end);
    if strcmp(format,'.mat') % Check if file extension is .mat
        current_file = strcat(f(i).folder, '\');
        current_file = strcat(current_file, f(i).name);
        temp = importdata(current_file);
        result = [result temp];
    end
end    
end
