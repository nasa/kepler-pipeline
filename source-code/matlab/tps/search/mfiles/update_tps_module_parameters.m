function tpsModuleParameters = update_tps_module_parameters( tpsModuleParameters, ...
    nCadences, cadenceDurationInMinutes )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function tpsModuleParameters = update_tps_module_parameters( tpsModuleParameters )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Description: This function examines the tps module parameters and updates
% them where needed.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% convert a -1 in the maxFoldingLoopCount to an inf (ie, if it's -1, then loop as many
% times as is needed

if tpsModuleParameters.maxFoldingLoopCount == -1
    tpsModuleParameters.maxFoldingLoopCount = inf ;
end

% compute cadencesPerHour and cadencesPerDay and add them
cadencesPerHour = 1 / (get_unit_conversion('min2hour') * cadenceDurationInMinutes); % in days
cadencesPerDay = get_unit_conversion('day2min') / cadenceDurationInMinutes;
tpsModuleParameters.cadencesPerHour = cadencesPerHour;
tpsModuleParameters.cadencesPerDay = cadencesPerDay;


% check that the number of cadences is > minimumSearchPeriodInDays
minSearchPeriodInCadences = tpsModuleParameters.minimumSearchPeriodInDays * tpsModuleParameters.cadencesPerDay;

if(~tpsModuleParameters.tpsLiteEnabled)
    if(nCadences <= minSearchPeriodInCadences)
        
        error('TPS:validateTpsInputStructure:minimumSearchPeriodTooLong', ...
            ['validate_tps_input_structure: minimum transit search period of ' num2str(tpsModuleParameters.minimumSearchPeriodInDays) ' days [=' ...
            num2str(minSearchPeriodInCadences) ' cadences]  > number of cadences ' num2str(nCadences) ' in tps input structure; \n can''t search for a period longer than the length of input flux timeseries ...']);
        
    end
    
    timeSeriesLengthInDays = nCadences/tpsModuleParameters.cadencesPerDay;
    
    % During TPS verification and validation, it was noticed that 150.TPS.2 was not completely met. Because of this
    % defect, 151.TPS.2 could also not be signed.
    % 150.TPS. 2TPS trial orbital periods shall be configurable from one day to mission duration to date with resolution
    % of one long cadence. 151.TPS.1 TPS shall search for 3 hour, 6 hour, and 12 hour transits for orbital periods of 1
    % day to mission duration to date.
    
    minSesCount = tpsModuleParameters.minSesInMesCount ;
    maxComputedSearchPeriodInCadences = ceil(nCadences/(minSesCount-1)) - 1 ;
    maxComputedSearchPeriodInDays = maxComputedSearchPeriodInCadences / cadencesPerDay ;
    maximumSearchPeriodInDays = tpsModuleParameters.maximumSearchPeriodInDays ;
    
    if isequal(maximumSearchPeriodInDays, -1)
        % max period set to -1 so compute it internally
        tpsModuleParameters.maximumSearchPeriodInDays = maxComputedSearchPeriodInCadences / cadencesPerDay ;
    elseif (maximumSearchPeriodInDays > maxComputedSearchPeriodInDays)
        if tpsModuleParameters.debugLevel >= 0
          disp( ...
            [    '    current maximum transit search period of ' num2str(tpsModuleParameters.maximumSearchPeriodInDays) ' days >= '] ) ;
           disp(['        allowed given minSesInMesCount and length of input time series (', ...
               num2str(timeSeriesLengthInDays) '  days) in tps input structure;' ] ) ;
           disp(['        setting it to ' num2str(maxComputedSearchPeriodInDays) ' days...']);
        end
        
        tpsModuleParameters.maximumSearchPeriodInDays = maxComputedSearchPeriodInDays;
    elseif (maximumSearchPeriodInDays > -1 && maximumSearchPeriodInDays <= 0)
        error('TPS:validateTpsInputStructure:MaxPeriodLessThanZero', ...
            ['validate_tps_input_structure: maximum transit search period of ' num2str(tpsModuleParameters.maximumSearchPeriodInDays) ' days <= 0 \n' ...
            '  must be > 0 or -1; can''t perform transit search  ...']);
    end
    
    
    if(tpsModuleParameters.minimumSearchPeriodInDays > tpsModuleParameters.maximumSearchPeriodInDays)
        
        error('TPS:validateTpsInputStructure:MinPeriodGreaterThanMaxPeriod', ...
            ['validate_tps_input_structure: minimum transit search period of ' num2str(tpsModuleParameters.minimumSearchPeriodInDays) ' days <=  \n maximum transit search period of ' ...
            num2str(tpsModuleParameters.maximumSearchPeriodInDays) '  days in tps input structure; can''t perform transit search  ...']);
        
    end
    
    
end
%______________________________________________________________________
% set the superResolution factor to 1 for TPS-Lite;
% need it only when folding statistics; give a warning if set > 1
%______________________________________________________________________

if(tpsModuleParameters.tpsLiteEnabled)
    
    if(tpsModuleParameters.superResolutionFactor ~= 1)
        
        disp( ...
            ['    tps_matlab_controller: setting the superResolutionFactor which currently has a value of ' ...
            num2str(tpsModuleParameters.superResolutionFactor) ' to 1 for TPS-Lite.' ]);
        
        tpsModuleParameters.superResolutionFactor = 1;
    end
    
end

if(~tpsModuleParameters.tpsLiteEnabled)
    if(tpsModuleParameters.cadencesPerHour > 20) % if we choose process the short cadence data
        disp( ...
            ['    tps_matlab_controller: setting the superResolutionFactor which currently has a value of ' ...
            num2str(tpsModuleParameters.superResolutionFactor) ' to 1 for processing short cadence data.' ]);
        
        tpsModuleParameters.superResolutionFactor = 1;
    end
    
end
  
return
  