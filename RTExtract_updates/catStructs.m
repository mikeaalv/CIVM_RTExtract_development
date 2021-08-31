function [newStruct] = catStructs(varargin)
%% catStructs
% Takes in any number of structures and concatenates them, regardles of
% field overlap.
% 
%   Inputs:
%       varargin:   any number of structures to be concatenated as a struct
%                   array (non-overlapping fields are preserved as empty).
%                   note: deal() may be helpful. I may update this to accept a 
%                   cell array of structs as well, so options (like 'remove
%                   non-overlapping fields') could be added.
%   Outputs:
%       newStruct:  field=matched, concatenated struct
% 
% MTJ 30AUG2021 based on the following:
% https://www.mathworks.com/matlabcentral/answers/350213-match-fields-of-two-structs-without-a-loop-if-possible

%% Get the data out
   
    % May be cleaner than loop, but have to figure out how to do inds
        cells = cellfun(@struct2cell,varargin,'UniformOutput',false);
        fieldnames = cellfun(@fields,varargin,'UniformOutput',false);
        
%         inds = cellfun(@(x) ones(size(x)),varargin);
        inds = cell(size(cells));
    % Just use a for loop
        for s = 1:length(varargin)
            inds{s} = ones(length(fieldnames{s}),1)*s;
        end
    
% Unlist the cells and assign each one an ind (to become column ind)  

        %stackNames = vertcat(fieldnames{:});
    stackCells = vertcat(cells{:});
    stackInds = vertcat(inds{:});

% Generate combined fields list and get the row (field) index for each cell
% in the gridded storage structure

    [combFields,~,ic] = unique(vertcat(fieldnames{:})); % was "stackNames"
                    
% Initiate storage structure 
% (coordinates: row = field, col = structure #)

    catcells = cell(length(combFields),length(varargin));
        
% Calculate the linear inds from the coordinates (Note: order of the
% unlisted struct2cell (stackCells) contents follows same linear index as ic and
% stackInds, which combined give the coordinates for each stackCells element in
% the final storage structure catcells. 

    linind = sub2ind(size(catcells),ic,stackInds);

% Fill in the appropriate cells in catcells with the linearly indexed cell
% contents

    [catcells{linind}] = stackCells{:};
    newStruct = cell2struct(catcells,combFields);
               
                    
end
