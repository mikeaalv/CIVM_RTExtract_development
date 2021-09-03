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
 
    % Varargin is a set of struct arrays. Unlist the array rows (first dim) 
    % of these cells as different cell rows (preserve order). Result should
    % be a cell array of structs (singles, not arrays).

        depthMap = cell2mat(cellfun(@(x) size(x),varargin,'UniformOutput',false)');
        
            structInds = arrayfun(@(x) [1:x],...
                                                depthMap(:,1),...%1:length(,...
                                                'UniformOutput',false);
                                            
            counter = num2cell(1:length(structInds))';                                    
            vc = cellfun(@(x,y) ones(1,length(x))*y,structInds,counter,'UniformOutput',false);
            sinds = [structInds{:}];
            vinds = [vc{:}];

            flatstructs = cell(1,length(sinds));
            for v = 1:length(vinds)
                flatstructs{v} = varargin{1,vinds(v)}(sinds(v),1);
            end
                        
        fieldnames = cellfun(@fields,flatstructs,'UniformOutput',false);

        
    % May be cleaner than loop, but have to figure out how to do inds
        cells = cellfun(@struct2cell,flatstructs,'UniformOutput',false);
        
            % *** if structs are actually struct arrays, how do we handle
            % that?
                % how are these things unlisted? Only need to go down one
                % more level. 
                % ^ this will determine how indexes should be mapped. 
                    % remember that we want indexes which give new cols for
                    % each of the array rows
                    
        fieldnames = cellfun(@fields,flatstructs,'UniformOutput',false);
        
%         inds = cellfun(@(x,y) ones(size(x))*y,flatstructs,num2cell(1:length(flatstructs)));
        inds = cell(size(cells));
        
    % Just use a for loop
        for s = 1:length(flatstructs)
            inds{s} = ones(length(fieldnames{s}),1)*s;
        end
    
% Unlist the cells and assign each one an ind (to become column ind)  

    stackCells = vertcat(cells{:});
    stackInds = vertcat(inds{:});

% Generate combined fields list and get the row (field) index for each cell
% in the gridded storage structure

    [combFields,~,ic] = unique(vertcat(fieldnames{:})); % was "stackNames"
                    
% Initiate storage structure 
% (coordinates: row = field, col = structure #)

    catcells = cell(length(combFields),length(flatstructs) );
        
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
