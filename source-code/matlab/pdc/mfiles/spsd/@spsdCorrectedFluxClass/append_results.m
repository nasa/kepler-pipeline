%%  append_results 
% Combines information from previous and new spsd analyses 
% For the first call, oldStruct is empty, [].
% For subsequent calls, oldStruct is the result of previous
% append_results call, and new information is added.
% spsd = Sudden Pixel Sensitivity Dropouts
% 
%   Revision History:
%
%       Version 0 - 3/14/11     released for Science Office use.
% 
% <html>
% <style type="text/css"> pre.codeinput {background: #FFFF66; padding: 30px;} </style>
% </html>
% 
%%
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
function append_results( obj, detectionResultsStruct, correctionResultsStruct )
%% 1.0 ARGUMENTS
% 
% Function returns: 
%
% * |newStruct    	            -| structure containing combined old and new spsd information. 
% * |.clean                     -| Information about CLEAN targets:
% * |-.count                    -| how many
% * |-.index                    -| which ones, relative to input timeseries order
% * |-.keplerId                 -| which ones, Kepler IDs
% * |.spsds                     -| Information about spsd-containing targets:
% * |-.count                    -| how many?
% * |-.index                    -| which ones, relative to input timeseries order
% * |-.keplerId                 -| which ones, Kepler IDs
% * |-.targets{K1}           	-| Information about each spsd-containing target:
% * |-.-.index                  -| index, relative to input timeseries order
% * |-.-.keplerId               -| Kepler ID
% * |-.-.spsdCount         	    -| how many SPSDs in this time series
% * |-.-.uncorrectedSuspectedDiscontinuity -| The target contains at least one suspected SPSD event that could not be corrected.
% * |-.-.correctedTimeSeries	-| timeseries with all SPSDs removed (See |correct.m| )
% * |-.-.spsd{K2}           	-| Information about each spsd in this target's timeseries:
% * |-.-.-.spsdCadence          -| LC number relative to start of timeseries (See |detect.m| )
% * |-.-.-.longCoefs         	-| local fit coefficients for long window (See |detect.m| )
% * |-.-.-.longStepHeight       -| estimated step height for long window (See |detect.m| )
% * |-.-.-.longMADs            	-| MAD of residuals & MAD of residual differences for long window (See |detect.m| )
% * |-.-.-.shortCoefs        	-| local fit coefficients for short window (See |detect.m| )
% * |-.-.-.shortStepHeight      -| estimated step height for short window (See |detect.m| )
% * |-.-.-.shortMADs           	-| MAD of residuals & MAD of residual differences for short window (See |detect.m| )
% * |-.-.-.persistentStep      	-| correction timeseries for persistent step (See |correct.m| )
% * |-.-.-.recoveryTerm       	-| correction timeseries for recovery (See |correct.m| )
%
% Function Arguments:
%
% * |oldStruct      -| structure containing old spsd information, if any or empty for first call. 
% * if not empty, structure is the same as |newStruct|.
%
% * |detectionResultsStruct   -| structure containing new spsd informatin to be appended. 
% * See | detect.m | for structure details
%
% * |correctionResultsStruct   -| structure containing corrections associated with new SPSDs. 
% * See | correct.m | for structure details
%
%% 2.0 INITIALIZATION
% If |oldStruct| is empty, create a new one from scratch,
% otherwise copy old to new.

oldStruct = obj.resultsStruct;

if isempty(oldStruct)
    newStruct.clean.count = 0;
    newStruct.spsds.count  = 0;
else
    newStruct=oldStruct;
end
    
    
%% 3.0 BUILD OR MODIFY OUTPUT STRUCTURE
% If |oldStruct| is empty, fill |newStruct| with all contents,
% otherwise simply append newly detected spsd information to existing targets.

%% -> 3.1 IF EMPTY, BUILD INFO ABOUT CLEAN TARGETS
% clean targets are spsds on the first pass only, they are unchanged for
% subsequent passes.

if newStruct.clean.count==0

    newStruct.clean.count = detectionResultsStruct.clean.count;
    newStruct.clean.index = detectionResultsStruct.clean.index;
    newStruct.clean.keplerId = detectionResultsStruct.clean.keplerId;
    
end

%% -> 3.2 IF EMPTY, BUILD INFO ABOUT spsd-containing TARGETS
% Targets are spsds on the first pass only.
% This code creates a structure for the first detected spsd

if newStruct.spsds.count==0
    
    newStruct.spsds.count = detectionResultsStruct.spsds.count;
    newStruct.spsds.index = detectionResultsStruct.spsds.index;
    newStruct.spsds.keplerId = detectionResultsStruct.spsds.keplerId;
    for k=1:detectionResultsStruct.spsds.count
        newStruct.spsds.targets{k}.index                   = obj.tss_index_to_tds_index(detectionResultsStruct.spsds.index(k));
        newStruct.spsds.targets{k}.keplerId                = detectionResultsStruct.spsds.keplerId(k);
        newStruct.spsds.targets{k}.spsdCount               = 1; % first spsd for this target
        newStruct.spsds.targets{k}.gapIndicators           = obj.inputTargetDataStruct(newStruct.spsds.targets{k}.index).gapIndicators;
        newStruct.spsds.targets{k}.uncorrectedSuspectedDiscontinuity = false; % On the first pass, we assume detected SPSDs were successfully corrected. This value may be changed on subsequent passes.
        newStruct.spsds.targets{k}.correctedTimeSeries	   = correctionResultsStruct.correctedTimeSeries(k,:);
        newStruct.spsds.targets{k}.spsd{1}.spsdCadence     = detectionResultsStruct.spsds.spsdCadence(k);
        newStruct.spsds.targets{k}.spsd{1}.longCoefs       = detectionResultsStruct.spsds.longCoefs(k,:);
        newStruct.spsds.targets{k}.spsd{1}.longStepHeight  = detectionResultsStruct.spsds.longStepHeight(k);
        newStruct.spsds.targets{k}.spsd{1}.longMADs        = detectionResultsStruct.spsds.longMADs(k,:);
        newStruct.spsds.targets{k}.spsd{1}.shortCoefs      = detectionResultsStruct.spsds.shortCoefs(k,:);
        newStruct.spsds.targets{k}.spsd{1}.shortStepHeight = detectionResultsStruct.spsds.shortStepHeight(k);
        newStruct.spsds.targets{k}.spsd{1}.shortMADs       = detectionResultsStruct.spsds.shortMADs(k,:);
        newStruct.spsds.targets{k}.spsd{1}.persistentStep  = correctionResultsStruct.persistentStep(k,:);
        newStruct.spsds.targets{k}.spsd{1}.recoveryTerm    = correctionResultsStruct.recoveryTerm(k,:);
    end
    
%% -> 3.3 OTHERWISE, APPEND NEW INFO ABOUT ADDITIONAL SPSDs TO EXISTING TARGETS
% Only the corrected timeseries and the number of SPSDs in a target changes
    
else

    for k=1:detectionResultsStruct.spsds.count
        thisTarget = newStruct.spsds.keplerId==detectionResultsStruct.spsds.keplerId(k); % which target?
        thisSPSD   = newStruct.spsds.targets{thisTarget}.spsdCount+1; % increment spsd count for this target?
        newStruct.spsds.targets{thisTarget}.spsdCount                      = thisSPSD;
        newStruct.spsds.targets{thisTarget}.correctedTimeSeries            = correctionResultsStruct.correctedTimeSeries(k,:);
        newStruct.spsds.targets{thisTarget}.spsd{thisSPSD}.spsdCadence     = detectionResultsStruct.spsds.spsdCadence(k);
        newStruct.spsds.targets{thisTarget}.spsd{thisSPSD}.longCoefs       = detectionResultsStruct.spsds.longCoefs(k,:);
        newStruct.spsds.targets{thisTarget}.spsd{thisSPSD}.longStepHeight  = detectionResultsStruct.spsds.longStepHeight(k);
        newStruct.spsds.targets{thisTarget}.spsd{thisSPSD}.longMADs        = detectionResultsStruct.spsds.longMADs(k,:);
        newStruct.spsds.targets{thisTarget}.spsd{thisSPSD}.shortCoefs      = detectionResultsStruct.spsds.shortCoefs(k,:);
        newStruct.spsds.targets{thisTarget}.spsd{thisSPSD}.shortStepHeight = detectionResultsStruct.spsds.shortStepHeight(k);
        newStruct.spsds.targets{thisTarget}.spsd{thisSPSD}.shortMADs       = detectionResultsStruct.spsds.shortMADs(k,:);
        newStruct.spsds.targets{thisTarget}.spsd{thisSPSD}.persistentStep  = correctionResultsStruct.persistentStep(k,:);
        newStruct.spsds.targets{thisTarget}.spsd{thisSPSD}.recoveryTerm    = correctionResultsStruct.recoveryTerm(k,:);
    end

end

obj.resultsStruct = newStruct;

%% 4.0 RETURN
%
return
end
