%% Ridge tracking a CIVM dataset

    % This script is to trace ridges from experimental data. 
    % The tracing process is semi-automatic
    % It is based on preset ppm region.

%% Set your toolbox paths; functions imported from these directories:

% ->>>          Public toolbox found @  https://github.com/artedison/Edison_Lab_Shared_Metabolomics_UGA

                    localPaths.public_toolbox = '>>YOUR_LOCAL_PATH<<';
        
% ->>>          RTExtract updates found @  https://github.com/judgemt/CIVM_RTExtract_development

                    localPaths.rtextract_dvpt_path = '>>YOUR_LOCAL_PATH (make sure it includes the /RTExtract_updates <<';
        
%% Add the toolboxes (run this when Matlab starts)

    % Add Public toolbox    
        addpath(genpath(localPaths.public_toolbox)) 
        
    % Add RTExtract toolbox        
        addpath(genpath(localPaths.rtextract_dvpt_path)) 

        pause(1),clc
    
%% Load the datasets

    [~,p] = findCurrentFile();
    cd(p)
    load('gradient_data.mat')

%% Set data

% ->>>  Set the dataset manually:
    
            thisExp = qax_18_short;
            thisExp.traceMats = length(thisExp.smoothedData);
                % thisExp = qax_20_short;
                % thisExp = qax_23_short;
                % thisExp = qax_24_short;

    % Get the data out:
        matrix = vertcat(thisExp.smoothedData(thisExp.traceMats).data);
        currentppm = thisExp.ppm;
%             matrix = matrix(:,fillRegion(allregionsele(22,:),currentppm));
        
        thisExp.plotRes = 100;
            [thisExp.plotInds,thisExp.plotIndsCat,thisExp.matrix] = calc_stackPlotInds(matrix,thisExp.plotRes,'smooth');

        ppm = thisExp.ppm;
        timepoints = vertcat(thisExp.smoothedTimes(thisExp.traceMats).timepoints(:));
            timepoints = timepoints(thisExp.plotInds{:});
            plotTitle = thisExp.plotTitle;        

    
%% Plot to make sure the spectra look good. Params used for plotting later?

    thisExp.horzshift = .002;
    thisExp.vertshift = 1E-2;
    
%     stackSpectra(thisExp.matrix,currentppm,thisExp.horzshift,thisExp.vertshift,plotTitle,...
%                  'autoVert')
             
%% Get tracking regions 

    % Estimate using guessRegions
%         allregionsele = guessRegions(matrix,ppm,15,...  number of desired regions across spectrum
%                                                 0.75);  % ~signal/noise threshold for Peakpick1D
    % Load from previous template
    
      [allregionsele,~,f] = extractROIs('regions_1.fig'); close(f);clear('f')
      
      % Modify Template: 
%             [~,regions] = refineBuckets(matrix,ppm,allregionsele,'expandedBuckets');
%             allregionsele = regions'; clear('regions'),
            
            % Don't forget to save the figure if modified!
                
    thisExp.trackingRegions = allregionsele;
    startPath = pwd;
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Switch to master branch of the toolbox %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%% test run %%%%%%%%%%%%%%

%     % Clustering params
%         wander = 10;      % the main tuning parameter; default 10. was 'thredseg', guessing 'threshold distance (ppm) between segments'
%         intensityVariation = 30;    % large intensity variation along a ridge requires this to be higher, default 1
% 
%     % Run the function
%         [returndata] = ridgetrace_power2_ext(thisExp.matrix,ppm,timepoints,... timepoints must be a column
%                                             thisExp.trackingRegions(1,:),... current region being tracked
%                                             path,...                  not even used in the function...?
%                                             wander,...                ~ window size for clustering segments together; allows ridges to wander across the spectrum
%                                             intensityVariation);                % intensity variation tolerance
                                    
        
                                        
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        % Set up default wander and intVar params
        
            thisExp.wander_settingByRegion = repmat(10,[1 size(thisExp.trackingRegions,1)]);% default 10
            thisExp.intensityVariation_ByRegion = repmat(1,[1 size(thisExp.trackingRegions,1)]);%default 1
           
        % Set up sample structure
            
        
%% the production run

    % Keep records of parameter adjustments for each region
    
        % Wander params
            thisExp.wander_settingByRegion(10) = 10;
            thisExp.wander_settingByRegion(11) = 5;
            thisExp.wander_settingByRegion(13) = 5;
            thisExp.wander_settingByRegion(14) = 3;
            thisExp.wander_settingByRegion(15) = 5;
            thisExp.wander_settingByRegion(16) = 5;
            thisExp.wander_settingByRegion(17) = 5;
            thisExp.wander_settingByRegion(18) = 5;
%             thisExp.wander_settingByRegion(4) = 5;
%             thisExp.wander_settingByRegion(7) = 5;
%             thisExp.wander_settingByRegion(8) = 2;
%             thisExp.wander_settingByRegion(9) = 5;
        % intensityVariation params
            thisExp.intensityVariation_ByRegion([1]) = 30;
            thisExp.intensityVariation_ByRegion([11]) = 30;
            thisExp.intensityVariation_ByRegion([12]) = 30;
            thisExp.intensityVariation_ByRegion([13]) = 30;
            thisExp.intensityVariation_ByRegion([14]) = 30;
            thisExp.intensityVariation_ByRegion([15]) = 30;
            thisExp.intensityVariation_ByRegion([16]) = 30;
            thisExp.intensityVariation_ByRegion([17]) = 30;
            thisExp.intensityVariation_ByRegion([18]) = 30;
%             thisExp.intensityVariation_ByRegion([2]) = 6;
%             vintensityVariation_ByRegion([2]) = 2;
%             thisExp.intensityVariation_ByRegion([5]) = 6;
%             thisExp.intensityVariation_ByRegion([6]) = 3;


%%
i = 1;
%%
% i = i - 1;
   %% Loop through the regions
   
        cd(startPath)
        [thisExp.region(i).ridges,thisExp.region(i).parameters] = ridgeTracking_wrapper(thisExp,i);

i = i + 1;        
        
% Issues:
% No true cancel option with compound naming/quant. Should default back to picking
% final clusters mode.

% Line 283 warning: "there is no maxaddon number of maximum for some spectra, use the real maximal number of local maximum instead"
% makes no sense. Re-write for clarity.

% After refine ridges, you need to give the option to undo the refinement.
% User cannot know what the result will be without trying first, and it's
% really annoying to have to retrace the region. A menu like the
% refineBuckets is best, where one menu gives access to all options.


%% plotting
for samp_i_i = 1:length(sample)
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
  plotTitle = [num2str(samp_i) '.' 'region'];
  stackSpectra_paintRidges_3return(matrix,ppm,0.0,0.02,plotTitle,peaks,10)
%   saveas(fig,strcat(path,plotTitle,'.scatter.experiment.manual.fig'));
%   close(fig);
end
% save([workdir 'tracing.newmeth.experiment.manual.mat'],'Sample')



