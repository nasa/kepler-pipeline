function outputStruct = get_results(obj)
%************************************************************************** 
% function outputStruct = get_results(obj)
%************************************************************************** 
% Format and return results.
%
% Although it is possible to access the 'resultsStruct' property directly,
% this function should always be used if possible since it hides
% implementation details and translates the contents of the internal
% structure. If you do access the internal resultsStruct, make sure you
% know what you are doing!
%
% Note that, while the detection algorithm designates the cadence
% corresponding to maximum filter response as the SPSD cadence, this
% function designates the cadence before the maximal (positive) change in
% the additive correction.
% 
%
% Outputs:
%
%     outputStruct
%     |-.clean [1x1 struct]         : Structure summarizing targets in
%     |  |                            which SPSD events were NOT
%     |  |                            identified.
%     |  |-.count: 4                : Number of "clean" targets.
%     |  |-.index: [2 3 4 5]        : targetDataStruct array indices of
%     |  |                            clean targets.
%     |   -.keplerId: [8077474 8077489 8077525 8733697]
%     |                             : Kepler IDs corresponding to 
%     |                               elements in 'index').
%      -.spsds [1x1 struct]         : Structure summarizing targets in
%        |                            which SPSD events WERE identified.
%        |-.count: 1                : Number of "dirty" targets.
%        |-.index: 1                : targetDataStruct array indices of
%        |                            targets containing SPSD events. 
%        |-.keplerId: 8077476
%         -.targets: [1x1 struct]   : SPSD event and correction summary 
%           |                         for each target.
%           |-.index: 1             : targetDataStruct array index of 
%           |                         this target.
%           |-.keplerId: 8077476    : Kepler ID of this target.
%           |-.spsdCount: 1         : Number of SPSD events identified 
%           |                         in this target.
%           |-.gapIndicators        : An array of gap indicators for this
%           |                         target.
%           |-.uncorrectedSuspectedDiscontinuity : A binary flag indicating
%           |                         that at least one SPSD was detected,
%           |                         but could not be sufficiently
%           |                         corrected. If true, then the
%           |                         correction vector for each SPSD in
%           |                         this target is set to zero, regardless
%           |                         whether it was successfully corrected.    
%           |-.cumulativeCorrection: [4634x1 double]
%           |                       : Combined additive correction to  
%           |                         target's light curve: correctedFlux =
%           |                         this rawFlux + cumulativeCorrection, 
%           |                         where cumulativeCorrection =
%           |                         sum([spsdEvents.correction],2)).  
%            -.spsdEvents: [1x1 struct]
%              |                    : Summary of individual SPSD events.
%              |-.spsdCadence: 2516
%              |                    : The index of the last non-gapped
%              |                      cadence before the maximum positive
%              |                      change in the corresponding
%              |                      correction. (NOTE that this is
%              |                      different than the meaning of 
%              |                      spsdCadence in the internal
%              |                      resultsStruct)
%              |
%               -.correction: [4634x1 double]
%                                   : Additive correction for this SPSD.
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
    SPSD_SEARCH_WINDOW_HALF_WIDTH = 2;
     
    % Notice we are forcing all vectors to be COLUMN vectors
    outputStruct = ...
        struct( ...
                'clean', struct ( ...
                                  'count', obj.resultsStruct.clean.count, ... 
                                  'index', obj.resultsStruct.clean.index(:)', ... 
                                  'keplerId', obj.resultsStruct.clean.keplerId(:)' ...
                                  ), ...
                'spsds', struct ( ...
                                  'count', obj.resultsStruct.spsds.count, ...
                                  'index', obj.resultsStruct.spsds.index(:)', ... 
                                  'keplerId', obj.resultsStruct.spsds.keplerId(:)', ...
                                  'targets', struct([]) ...
                                  ) ...
               );
    
    newTargetStruct = struct( ...
                             'index', [], ...
                             'keplerId', [], ...
                             'spsdCount', [], ...
                             'gapIndicators', [], ...
                             'uncorrectedSuspectedDiscontinuity', [], ...
                             'cumulativeCorrection', [], ...
                             'spsdEvents', struct([]) ...
                             );

    newSpsdStruct = struct( ...
                           'spsdCadence', [], ...
                           'correction', [] ...
                           );
                       
    if (outputStruct.spsds.count > 0)
        outputStruct.spsds.targets = newTargetStruct;
    end
    
    for i = 1:outputStruct.spsds.count
        
        ots = obj.resultsStruct.spsds.targets{i};
        nts = newTargetStruct;
        
        nts.index = ots.index;
        nts.keplerId = ots.keplerId;
        nts.spsdCount = ots.spsdCount;
        nts.gapIndicators = ots.gapIndicators;
        nts.uncorrectedSuspectedDiscontinuity = ots.uncorrectedSuspectedDiscontinuity;
        nts.spsdEvents = newSpsdStruct;

        cumulativeCorrection = zeros(size(ots.correctedTimeSeries))'; % note transposition
        for j = 1:nts.spsdCount
            ose = ots.spsd{j};
            nse = newSpsdStruct;
            
            nse.correction  = -(ose.persistentStep + ose.recoveryTerm)'; % We want an ADDITIVE correction (note transposition)
            nse.spsdCadence = ose.spsdCadence;
            
            % Define spsdCadence as the cadence before the maximal
            % (positive) change in the additive correction. Sign matters!
            dCorrection = diff(nse.correction);
            win = [max(1,nse.spsdCadence - SPSD_SEARCH_WINDOW_HALF_WIDTH) ...
                : min(length(dCorrection), nse.spsdCadence + SPSD_SEARCH_WINDOW_HALF_WIDTH)];
            [~, winInd] = max( dCorrection(win) );
            nse.spsdCadence = win( winInd );
                       
            % Handle the case in which the spsdCadence falls within a gap.
            % Move to the last valid cadence prior to the gap.
            gaps = nts.gapIndicators;
            ind = find(~gaps(1:nse.spsdCadence), 1, 'last');
            if ~isempty(ind) % If no valid cadences before gap, leave as is.
                nse.spsdCadence = ind;
            end
                        
            % If uncorrectedSuspectedDiscontinuity is set, zero the
            % correction for each SPSD in this target.
            if nts.uncorrectedSuspectedDiscontinuity
                nse.correction(:) = 0;
            end
            
            nts.spsdEvents(j) = nse;                           
            cumulativeCorrection = cumulativeCorrection + nse.correction;            
        end
        
        nts.cumulativeCorrection = cumulativeCorrection; 
        outputStruct.spsds.targets(i) = nts;
    end
    
    % Make sure empty arrays don't have non-zero dimensions.
    outputStruct = force_empty_arrays_to_0x0(outputStruct);
end


