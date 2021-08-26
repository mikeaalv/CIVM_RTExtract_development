function [peaks] = ridges2peaks()
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

      samp_i = sample(samp_i_i);
      data = matrix;
      ppm = ppm;
      peaks = struct();
      ridgenumbers = 1:length(Sample(samp_i_i).ridges);
      for r = 1:length(ridgenumbers)
        if ~isempty(Sample(samp_i_i).ridges(ridgenumbers(r)).result)
          % peaks(i).Ridges = ppm(Sample(samp_i_i).ridges(ridgenumbers(i)).result.colind);
          peaks(r).Ridges = Sample(samp_i_i).ridges(ridgenumbers(r)).result.ppm';
          peaks(r).RowInds = Sample(samp_i_i).ridges(ridgenumbers(r)).result.rowind';
          peaks(r).RidgeIntensities = Sample(samp_i_i).ridges(ridgenumbers(r)).result.intensity';
          peaks(r).CompoundNames = Sample(samp_i_i).ridges(ridgenumbers(r)).result.names;
          peaks(r).quantifiable = Sample(samp_i_i).ridges(ridgenumbers(r)).result.quanvec;
        else
          peaks(r).Ridges = [];
          peaks(r).RowInds = [];
          peaks(r).RidgeIntensities = [];
          peaks(r).CompoundNames = [];
          peaks(r).quantifiable = [];
        end
      end



end