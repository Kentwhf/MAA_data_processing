function [obj_map] = make_obj_map(filenames)
% make_obj_map - Create an object map, given file contents
%   Input: struct variable (output of dir function)
%          Filenames must be in the format:
%          '[A-z]<objID>_[A-z]<subID>_[A-z]_<hour>-<min>-<sec>'
%          Where [A-z] is a continuous string of letters (case insensitive)
%          E.g. 'idapt499_sub240_UP_13-34-26'
%   Output: Map data structure; each key corresponds to an iDAPT number, which
%   contains another map data structure. Each key for these maps correspond
%   to a subject ID, which contains a vector of test results.

obj_map = containers.Map('KeyType', 'int32', 'ValueType', 'any');
% convert struct to cell array
filenames = struct2cell(filenames(~ismember({filenames.name},{'.','..'})));
for i = 1: length(filenames(1, :))
    result = struct2array(load(strcat(char(filenames(2,i)), '\', char(filenames(1, i)))));
    nums = sscanf(char(filenames(1, i)), '%*[A-Z a-z]%d_%*[A-Z a-z]%d_%*[A-Z a-z]_%d-%d-%d');
    % nums is a vector with the following format:
    % nums(1) = object ID
    % nums(2) = subject ID
    % nums(3:5) = Timestamp (hour, minute, second)
    
    % Add the test result to obj_map
    % FIXME: add if condition for new subject
    if(ismember(nums(1), cell2mat(obj_map.keys)))
        temp = obj_map(nums(1));
        if (ismember(nums(2), cell2mat(temp.keys)))
            temp(nums(2)) = [temp(nums(2)) result];
            obj_map(nums(1)) = temp;
        else
            temp(nums(2)) = result;
            obj_map(nums(1)) = temp;
        end
    else
        obj_map(nums(1)) = containers.Map('KeyType', 'int32', 'ValueType', 'any');
        temp = obj_map(nums(1));
        temp(nums(2)) = result;
        obj_map(nums(1)) = temp;
    end
end

end

