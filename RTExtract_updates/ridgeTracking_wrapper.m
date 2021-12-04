function [ridges,parameters] = ridgeTracking_wrapper(thisExp,i,addregion,wander,intensity)
% So we don't have to look at all this in the main workflow.
% Always cd(startPath) before return
%
% MTJ 10AUG2021

    startpath = cd();
    

%% Set up data structure
                
    mkdir(thisExp.plotTitle{:})
        cd(thisExp.plotTitle{:})
        mkdir('Production_Run')
        cd Production_Run

            %% Get the data
                
            %         matrix = vertcat(thisExp.smoothedData(thisExp.traceMats).data);
            %             matrix = matrix(thisExp.plotInds{:},:);
            % 
                    matrix = thisExp.matrix;
                    ppm = thisExp.ppm;

                    timepoints = vertcat(thisExp.smoothedTimes(thisExp.traceMats).timepoints(:));
                        timepoints = timepoints(thisExp.plotInds{:});

                    % Add a region if passed (for retracking)
                        if exist('addregion','var')
                            thisExp.trackingRegions(end+1,:) = addregion;
                            i = size(thisExp.trackingRegions,1);
                            
                            if exist('wander','var')
                                thisExp.wander_settingByRegion(i) = wander;
                            else % default
                                thisExp.wander_settingByRegion(i) = 10;
                            end
                            
                            if exist('intensity','var')
                                thisExp.intensityVariation_ByRegion(i) = intensity;
                            else % default
                                thisExp.intensityVariation_ByRegion(i) = 1;
                            end
                            
                        end
                        
                    regionsele = thisExp.trackingRegions;
                    
                    wander_settingByRegion = thisExp.wander_settingByRegion;
                    intensityVariation_ByRegion = thisExp.intensityVariation_ByRegion;
                    currentTrackingRegion = regionsele(i,:);
                    plotTitle = [num2str(currentTrackingRegion(1)),'-',num2str(currentTrackingRegion(2)),'ppm - ',thisExp.plotTitle{:},'.testplot'];
                    fprintf(['\n\n\t\t\t', thisExp.plotTitle{:},   ' region ', num2str(i),'\n\n']);
            
            %% Initialize storage structures using existing or new ridges
                                    
                    [ridges,parameters] = initiatetempridges(thisExp,i); % this is important, as premature program termination 
                                                                     % may otherwise return empty objects which overwrite 
                                                                     % previous data
                    
            %% Run the Function
            try
                [returndata] = ridgetrace_power2_ext(matrix,ppm,timepoints,currentTrackingRegion,path,wander_settingByRegion(i),intensityVariation_ByRegion(i));
            catch 
                warning('Program terminated prematurely. Data were not saved.');
                cd(startpath)
                return
            end
            
            %% Options for Saving
                fig = gcf;
%                 saveas(fig,strcat(cd(),'/',plotTitle,'.surf.experiment.manual.fig'));
              
                answer = menu('RTExtract Complete. Save this result?','Yes - Save and Exit','No - Just Exit');
                close(fig);
                switch answer
                    case 0
                        
                    case 1
                        
                    case 2
                        cd(startpath)
                        return
                end
                
                
            % Store the data?
                if ~isempty(fieldnames(returndata))
                    result = returndata.result;
                    ridnames = returndata.names;
                    quanvec = returndata.quantifyvec;
                    groups = result(:,5);
                else
                    warning('RTExtract did not return data. No data were saved')
                    return
                end
                
            % Store as a struct array

                uniqueGroups = unique(groups,'stable')';
            
                tempridges = struct();
                for r = 1:length(uniqueGroups) % for each ridge:
                  g = uniqueGroups(r);
                  groupind = find(result(:,5) == g);
                  temptab = result(groupind,:);
                  temptab(:,5) = [];
                  
                      tempridges(r).linearind = temptab(:,1);
                      tempridges(r).colind = temptab(:,2);
                      tempridges(r).rowind = temptab(:,3);
                      tempridges(r).intensity = temptab(:,4);
                      tempridges(r).names = ridnames(groupind);
                      tempridges(r).quanvec = quanvec(groupind);
                      tempridges(r).time = temptab(:,5);
                      tempridges(r).ppm = temptab(:,6);
                                                
                end
                
    % Remove empty ridges
        tempridges(cellfun(@isempty,{tempridges.colind})) = [];
        
    % Assign runNumber based on previous runs (necessary for alignment with
    % corresponding parameters struct indices)
    
        if isequal(ridges,struct()) && isequal(parameters,struct())
            % If this is a new run, initiate runNumber as 1
            
                ridges = tempridges;
                    [ridges(:).runNumber] = deal(1);
                parameters = returndata.para;
                
        else
            % If a previous run has been recorded
            
                % First, update the structure (in case there isn't runNumber)
                    if ~isfield(ridges,'runNumber')
                        [ridges(:).runNumber] = deal(1);
                    end
                    
                % At this point, every row in ridges has a runNumber
                % assigned. Next, increase the runNumber for the new  
                % rows in tempridges (to beconcatentated to ridges)
                
                    % Which rows are from the most recent run?
                        previousRidges = find([ridges.runNumber] == ridges(end).runNumber);

                    % Get the most recent run number, set current runNumber to prev +1
                        [tempridges(:).runNumber] = deal(ridges(previousRidges(end)).runNumber + 1);
                        
                        if size(tempridges,1) > 1 % make sure these will cat with ridges
                            tempridges = tempridges';
                        end
                        if size(ridges,1) > 1 % make sure these will cat with ridges
                            ridges = ridges';
                        end
                        
                % Concatenate tempridges to the end of ridges. Store
                % params (index to match the runNumber for this run).
                    ridges = [ridges,tempridges]';
                    parameters = catStructs(parameters,returndata.para);                    
        end
        
    %% Save the data

            save(['region_',num2str(currentTrackingRegion(1)),'-',num2str(currentTrackingRegion(2)),'ppm.mat'],'ridges','parameters');

    cd(startpath)
    return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Accessory functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [yesRidges] = hasridges(thisExp,i)

    % Find out if we have ridge data
           try 
               yesRidges = ~isempty(thisExp.region(i).ridges(1).colind(1));
           catch 
               yesRidges = 0;
           end

end

function [ridges,parameters] = initiatetempridges(thisExp,i)

    % Initialize as struct objects
    
            ridges = struct();
            parameters = struct();
            currentTrackingRegion = thisExp.trackingRegions(i,:);
            
    % If ridges exist, give the option to re-initialize using old ridges
            if hasridges(thisExp,i)

                response = menu({['Ridges have been tracked for region ',num2str(i)];...
                    [' (',num2str(currentTrackingRegion(1)),'-',num2str(currentTrackingRegion(2)),' ppm) in '];...
                    thisExp.plotTitle{:};...
                    'What do you want to do with new ridges?'},'Append (default)','Overwrite existing ridges','Cancel');

                 switch response
                    case 1
                        ridges = thisExp.region(i).ridges;
                        parameters = thisExp.region(i).parameters;
                    case 2
                        % do nothing
                    case 3
                        ridges = thisExp.region(i).ridges;
                        parameters = thisExp.region(i).parameters;
                        return
                 end
            end
end