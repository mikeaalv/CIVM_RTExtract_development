function [peaks] = ridges2peaks(ridges)
%% ridges2peaks
%
%   This function allows ridges from a more complex data structure to be
%   condensed into a simpler (peaks) structure for plotting purposes using
%   stackSpectra_paintRidges3().
%   Args:
%   
%       ???
%
%   Return:
%
%       peaks:  

%       ridges = thisExp.region.ridges;
            
      peaks = struct();
      ridgenumbers = 1:length(ridges);
      
      for r = 1:length(ridgenumbers)
        if ~isempty(ridges(ridgenumbers(r)))
          peaks(r).Ridges = ridges(ridgenumbers(r)).ppm';
          peaks(r).RowInds = ridges(ridgenumbers(r)).rowind';
          peaks(r).RidgeIntensities = ridges(ridgenumbers(r)).intensity';
          peaks(r).CompoundNames = ridges(ridgenumbers(r)).names;
          peaks(r).quantifiable = ridges(ridgenumbers(r)).quanvec;
        else
          peaks(r).Ridges = [];
          peaks(r).RowInds = [];
          peaks(r).RidgeIntensities = [];
          peaks(r).CompoundNames = [];
          peaks(r).quantifiable = [];
        end
      end



end