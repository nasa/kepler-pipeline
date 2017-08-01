function initialize_debug_struct(obj, debugLevel)
%**************************************************************************
% function initialize_debug_struct(obj, debugLevel)
%**************************************************************************
% Initialize a structure containing debugging flags and related data. PA
% module parameters include a 'debugLevel' field which is used here to set
% the various flags. The debug struct is also intended to be a container
% for any related data we want to accumulated during processing.
%
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
    debugFlagsByLevel  = struct(... % Debug level: [0 1 2 3 4 5]
        'verbose',                        logical( [0 1 1 1 1 1] ), ...
        'plotEstimatedSignalComponents',  logical( [0 0 0 1 0 0] ), ...
        'plotInnovationPlusOutliers',     logical( [0 0 1 0 0 0] ), ...
        'retainPredictionComponents',     logical( [0 0 0 0 1 1] ), ...
        'retainPrediction',               logical( [1 1 1 1 1 1] ) ...
    );

    % Determine valid range for debugLevel.
    minDebugLevel = 0;
    maxDebugLevel = 0;
    names = fieldnames(debugFlagsByLevel);            
    if ~isempty(names)
        minLen = length(debugFlagsByLevel.(names{1}));
        for i = 2:length(names)
            len = length(debugFlagsByLevel.(names{i}));
            if len < minLen
                minLen = len;
            end
        end
        maxDebugLevel = minLen - 1; % Debug levels are zero-based.
    end

    % Clamp debugLevel to valid range.
    debugLevel = fix(debugLevel);
    if debugLevel < minDebugLevel
        debugLevel = minDebugLevel;
    elseif debugLevel > maxDebugLevel
        debugLevel = maxDebugLevel;
    end

    % Set debugging flags.
    if ~isempty(names)
        for i = 1:length(names)
            obj.debugStruct.flags.(names{i}) = ...
                debugFlagsByLevel.(names{i})(debugLevel + 1);
        end
    end

    % Set default directory in which to save results.
    obj.debugStruct.saveDir = '.';
end

%********************************** EOF ***********************************