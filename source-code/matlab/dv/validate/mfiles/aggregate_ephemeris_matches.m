function [matchStructArray, matchedKois, unmatchedKois] = ...
aggregate_ephemeris_matches(instanceDir)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [matchStructArray, matchedKois, unmatchedKois] = ...
% aggregate_ephemeris_matches(instanceDir)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Function to loop through all task/sub-task directories and aggregate the
% ephemeris matching results.
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

OUTPUT_FILE = 'dv-outputs-0.mat';

baseDir = pwd();

if exist('instanceDir', 'var')
    if exist(instanceDir, 'dir')
        cd(instanceDir);
    else
        error('Instance directory (%s) does not exist', instanceDir);
    end % if / else
end % if
instanceDir = pwd();

matchStructArray = [];
matchedKois = {};
unmatchedKois = {};

d = dir('dv-matlab-*');

for name1 = {d.name}
    
    name = char(name1);
    if exist(name, 'dir')
        disp(name);
        cd(name);
    else
        continue;
    end
    taskDir = pwd();
    
    s = dir('st-*');
    
    for name2 = {s.name}
        
        name = char(name2);
        if exist(name, 'dir')
            cd(name);
        else
            continue;
        end
        subTaskDir = pwd();
    
        if exist(OUTPUT_FILE, 'file')
            load(OUTPUT_FILE);
            if ~isempty(outputsStruct.targetResultsStruct.koiId)
                matchStruct.keplerId = ...
                    outputsStruct.targetResultsStruct.keplerId;
                matchStruct.subTaskDir = ...
                    subTaskDir;
                matchStruct.koiId = ...
                    outputsStruct.targetResultsStruct.koiId;
                matchStruct.keplerName = ...
                    outputsStruct.targetResultsStruct.keplerName;
                matchStruct.matchedKoiIds = ...
                    outputsStruct.targetResultsStruct.matchedKoiIds;
                matchStruct.unmatchedKoiIds = ...
                    outputsStruct.targetResultsStruct.unmatchedKoiIds;
                load(fullfile(sprintf('target-%09d', matchStruct.keplerId), 'koi-match.mat'));
                matchStruct.transits = transits;
                matchStruct.correlations = correlations;
                matchStructArray = [matchStructArray, matchStruct];        %#ok<AGROW>
            end % if
        end % if
        
        cd(taskDir);
        
    end % for name2
    
    cd(instanceDir);
    
end % for name1

cd(baseDir);

if ~isempty(matchStructArray)
    koiIds = {matchStructArray.koiId};
    [~, ix] = sort(koiIds);
    matchStructArray = matchStructArray(ix);
    matchedKois = sort([matchStructArray.matchedKoiIds]);
    unmatchedKois = sort([matchStructArray.unmatchedKoiIds]);
end

return
