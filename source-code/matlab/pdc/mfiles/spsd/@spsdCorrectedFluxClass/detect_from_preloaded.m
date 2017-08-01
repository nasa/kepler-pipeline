function detectionResultsStruct = detect_from_preloaded( obj )
% function detectionResultsStruct = detect_from_preloaded( obj )
%
%     performs a 'fake' SPSD detection, by converting the preloaded SPSD events (spsdBlobIn)
%     into a proper detectionResultsStruct
%
%
% * |detectionResultsStruct     -| structure containing output parameters. 
% * |.clean                     -| Information about CLEAN targets:
% * |-.count                    -| how many
% * |-.index                    -| which ones, relative to input timeseries order
% * |-.keplerId                 -| which ones, Kepler IDs
% * |.spsds                     -| Information about spsd-containing targets:
% * |-.count                    -| how many?
% * |-.index                    -| which ones, relative to input timeseries order
% * |-.keplerId                 -| which ones, Kepler IDs
% * |-.keplerMag                -| kepler magnitude
% * |-.spsdCadence          	-| LC number relative to start of timeseries (See |detect.m| )
% * |-.longCoefs                -| local fit coefficients for long window (See |detect.m| )
% * |-.longStepHeight          	-| estimated step height for long window (See |detect.m| )
% * |-.longMADs              	-| MAD of residuals & MAD of residual differences for long window (See |detect.m| )
% * |-.shortCoefs        	    -| local fit coefficients for short window (See |detect.m| )
% * |-.shortStepHeight       	-| estimated step height for short window (See |detect.m| )
% * |-.shortMADs           	    -| MAD of residuals & MAD of residual differences for short window (See |detect.m| )
%
% ===========================================================================
%
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

    
    %% some initialization
    % using the same framework here as in detect_from_scratch()
    
    % but all targets in timeSeriesStruct are valid
    spsdBlobIn = obj.preLoadedEvents;
    spsdBlobOut = [];
    nValid = size(obj.timeSeriesStruct.fluxResiduals,1);
    validInd = 1:nValid;
    obj.lcCorrectionRecovery = [];
    obj.lcCorrectionPersistentStep = [];
    nFound = 0;
    
    %% init empty struct
    detectionResultsStruct.clean.count = 0;
    detectionResultsStruct.clean.index = [];
    detectionResultsStruct.clean.keplerId = [];
    detectionResultsStruct.clean.keplerMag = [];
    detectionResultsStruct.spsds.count = 0;
    detectionResultsStruct.spsds.index = [];
    detectionResultsStruct.spsds.keplerId = [];
    detectionResultsStruct.spsds.keplerMag = [];
    detectionResultsStruct.spsds.spsdCadence = [];
    detectionResultsStruct.spsds.longCoefs = [];        % not applicable...but have to be populated (see below)
    detectionResultsStruct.spsds.longStepHeight = [];   % not applicable...but have to be populated (see below)
    detectionResultsStruct.spsds.longMADs = [];         % not applicable...but have to be populated (see below)
    detectionResultsStruct.spsds.shortCoefs = [];       % not applicable...but have to be populated (see below)
    detectionResultsStruct.spsds.shortStepHeight = [];  % not applicable...but have to be populated (see below)
    detectionResultsStruct.spsds.shortMADs = [];        % not applicable...but have to be populated (see below)
    
    %% if spsdBlobIn is empty, nothing to do. quit
    if (isempty(spsdBlobIn))
        detectionResultsStruct.clean.count = nValid;
        detectionResultsStruct.clean.index = validInd;
        detectionResultsStruct.clean.keplerId = obj.timeSeriesStruct.parameters.keplerId(detectionResultsStruct.clean.index);
        detectionResultsStruct.clean.keplerMag = obj.timeSeriesStruct.parameters.keplerMag(detectionResultsStruct.clean.index);    
        return;
    end
    
    %% populate the struct
    for i = validInd
       % if this target has an entry in spsdBlob, add the last SPSD of that array
       % (reverse order so that correction is from last SPSD backwards)
       idx = find( obj.timeSeriesStruct.parameters.keplerId(i) == [spsdBlobIn().keplerId]);
       if (isempty(idx))
           % no SPSD in this target
           detectionResultsStruct.clean.count = detectionResultsStruct.clean.count + 1;
           detectionResultsStruct.clean.index = [ detectionResultsStruct.clean.index i ];
           detectionResultsStruct.clean.keplerId = [ detectionResultsStruct.clean.keplerId obj.timeSeriesStruct.parameters.keplerId(i) ];
           detectionResultsStruct.clean.keplerMag = [ detectionResultsStruct.clean.keplerMag obj.timeSeriesStruct.parameters.keplerMag(i) ];
       else
           % at least one SPSD in this target. add it to the detectionResultsStruct
           detectionResultsStruct.spsds.count = detectionResultsStruct.spsds.count + 1;
           detectionResultsStruct.spsds.index = [ detectionResultsStruct.spsds.index i ];
           detectionResultsStruct.spsds.keplerId = [ detectionResultsStruct.spsds.keplerId obj.timeSeriesStruct.parameters.keplerId(i) ];
           detectionResultsStruct.spsds.keplerMag = [ detectionResultsStruct.spsds.keplerMag obj.timeSeriesStruct.parameters.keplerMag(i) ];
           if (length(spsdBlobIn(idx).scCadences)==1)
               % only one SPSD in this target
               % copy correction data into object
               nFound = nFound+1;
               obj.lcCorrectionRecovery(:,nFound) = spsdBlobIn(idx).correctionRecovery{1};
               obj.lcCorrectionPersistentStep(:,nFound) = spsdBlobIn(idx).correctionPersistentStep{1};
               % the value at the spsd cadence in LC has to be substituted for the interpolation
               tmp = spsdBlobIn(idx).lcCadences(end);
               obj.lcCorrectionRecovery(tmp,nFound) = obj.lcCorrectionRecovery(tmp+2,nFound);               
               % update detectionResultsStruct and spsdBlob
               detectionResultsStruct.spsds.spsdCadence = [ detectionResultsStruct.spsds.spsdCadence spsdBlobIn(idx).scCadences ];
           else
               % more than one SPSD in this target. take last one, and keep target in list.
               % copy correction data into object
               nFound = nFound+1;
               obj.lcCorrectionRecovery(:,nFound) = spsdBlobIn(idx).correctionRecovery{end};
               obj.lcCorrectionPersistentStep(:,nFound) = spsdBlobIn(idx).correctionPersistentStep{end};
               % the value at the spsd cadence in LC has to be substituted for the interpolation
               tmp = spsdBlobIn(idx).lcCadences(end);
               obj.lcCorrectionRecovery(tmp,nFound) = obj.lcCorrectionRecovery(tmp+2,nFound);               
               % update detectionResultsStruct and spsdBlob
               detectionResultsStruct.spsds.spsdCadence = [ detectionResultsStruct.spsds.spsdCadence spsdBlobIn(idx).scCadences(end) ];
               k = length(spsdBlobOut)+1;
               if (k==1)
                   % if it's still empty, we have to initialize the struct array properly first
                   spsdBlobOut = spsdBlobIn(idx);
               else
                   spsdBlobOut(k) = spsdBlobIn(idx);
               end
               spsdBlobOut(k).lcCadences = spsdBlobOut(k).lcCadences(1:end-1);
               spsdBlobOut(k).scCadences = spsdBlobOut(k).scCadences(1:end-1);
               spsdBlobOut(k).cadenceTimesStart = spsdBlobOut(k).cadenceTimesStart(1:end-1);
               spsdBlobOut(k).cadenceTimesEnd = spsdBlobOut(k).cadenceTimesEnd(1:end-1);
               spsdBlobOut(k).correctionRecovery = { spsdBlobOut(k).correctionRecovery{1:end-1} };
               spsdBlobOut(k).correctionPersistentStep = { spsdBlobOut(k).correctionPersistentStep{1:end-1} };
           end
       end       
    end
    
    %% need to fill the unused fields with nans, so that .correct() does not crash...    
    detectionResultsStruct.spsds.longCoefs = repmat(nan,detectionResultsStruct.spsds.count,10);
    detectionResultsStruct.spsds.longStepHeight = repmat(nan,detectionResultsStruct.spsds.count,1);
    detectionResultsStruct.spsds.longMADs = repmat(nan,detectionResultsStruct.spsds.count,2);
    detectionResultsStruct.spsds.shortCoefs = repmat(nan,detectionResultsStruct.spsds.count,7);
    detectionResultsStruct.spsds.shortStepHeight = repmat(nan,detectionResultsStruct.spsds.count,1);
    detectionResultsStruct.spsds.shortMADs = repmat(nan,detectionResultsStruct.spsds.count,2);
    
    %% update obj.preLoadedEvents
    obj.preLoadedEvents = spsdBlobOut;

end % function
