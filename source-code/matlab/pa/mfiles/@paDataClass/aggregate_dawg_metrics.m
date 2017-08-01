function aggregate_dawg_metrics( paDataObject )
%**************************************************************************
% function aggregate_dawg_metrics( paDataObject )
%**************************************************************************
% THE FOLLOWING FORMERLY DONE ON LAST CALL IN
% generate_pa_validation_metrics_and_plots.m    
%**************************************************************************
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
% 
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%

    % DAWG metrics filenames
    motionDawgFilename       = 'pa-dawg-motion.mat';
    fluxDawgFilename         = 'pa-dawg-flux.mat';
    centroidDawgFilename     = 'pa-dawg-centroid.mat';

    subTaskDirPrefix         = 'st-';
    fluxVarName              = 'fluxOutputStruct';
    centroidVarName          = 'centroidOutputStruct';
        
    paRootTaskDir = char(get_cwd_parent);

    % Get fields from input structure
    simulatedTransitsEnabled = ...
        paDataObject.paConfigurationStruct.simulatedTransitsEnabled;

    % Set long and short cadence flags
    cadenceType              = paDataObject.cadenceType;
    if strcmpi(cadenceType, 'long')
        processLongCadence   = true;
        processShortCadence  = false;
    elseif strcmpi(cadenceType, 'short')
        processLongCadence   = false;
        processShortCadence  = true;
    end
    
    paDataStruct = struct(paDataObject);
    
    %----------------------------------------------------------------------
    % Do motion polynomial related stuff
    %----------------------------------------------------------------------
    if processLongCadence && ~simulatedTransitsEnabled
        motionOutputStruct = produce_pa_motion_metrics( paDataStruct );
        save(motionDawgFilename,'motionOutputStruct');
        z.motionOutputStruct = motionOutputStruct;
        clear motionMetricsStruct;
    end

    %----------------------------------------------------------------------
    % Aggregate target flux and centroid metrics
    %----------------------------------------------------------------------
    dirStructArray = dir(fullfile(paRootTaskDir, [subTaskDirPrefix, '*']));
    subTaskDirNames = {dirStructArray.name};
    
    fluxOutputStruct     = [];
    centroidOutputStruct = [];
    
    for i = 1:numel(subTaskDirNames)
        subTaskDir = subTaskDirNames{i};
        
        %**
        % aggregate variables in fluxDawgFilename and store
        fluxDawgFilePath = ...
            fullfile(paRootTaskDir, subTaskDir, fluxDawgFilename);
        if( exist(fluxDawgFilePath,'file') )
            w = whos('-file',fluxDawgFilePath);
            if(ismember(fluxVarName,{w.name}))
                s = load(fluxDawgFilePath, fluxVarName);
                fName = fieldnames(s.(fluxVarName));
                if(isempty(fluxOutputStruct))
                    fluxOutputStruct = s.(fluxVarName);
                end
                for j=1:length(fName)
                    fluxOutputStruct.(fName{j}) = [fluxOutputStruct.(fName{j}), s.(fluxVarName).(fName{j})];
                end
            else
                disp(['Variable ',fluxVarName,' missing in ',fluxDawgFilePath]);
            end            
        end
        
        %**
        % aggregate variables in centroidDawgFilename and store    
        centroidDawgFilePath = ...
            fullfile(paRootTaskDir, subTaskDir, centroidDawgFilename);
        if( exist(centroidDawgFilePath,'file') )
            w = whos('-file',centroidDawgFilePath);
            if(ismember(centroidVarName,{w.name}))
                s = load(centroidDawgFilePath, centroidVarName);
                fName = fieldnames(s.(centroidVarName));
                if(isempty(centroidOutputStruct))
                    centroidOutputStruct = s.(centroidVarName);
                end
                for j=1:length(fName)
                    centroidOutputStruct.(fName{j}) = [centroidOutputStruct.(fName{j}), s.(centroidVarName).(fName{j})];
                end
            else
                disp(['Variable ',centroidVarName,' missing in ',centroidDawgFilePath]);
            end            
        end
        
    end % for i = 1:numel(subTaskDirNames)

    % Save fluxOutputStruct to the current directory.
    fluxOutputStruct.ccdModule = paDataStruct.ccdModule;
    fluxOutputStruct.ccdOutput = paDataStruct.ccdOutput;
    save(fluxDawgFilename, fluxVarName);
    
    % Save centroidOutputStruct to the current directory.
    centroidOutputStruct.ccdModule = paDataStruct.ccdModule;
    centroidOutputStruct.ccdOutput = paDataStruct.ccdOutput;
    save(centroidDawgFilename, centroidVarName);

end

