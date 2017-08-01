%==========================================================================
% function resultsStruct = spsd_controller ( pdcInputObject, ...
%                                            targetDataStruct, ...
%                                            basisVectors, ...
%                                            preLoadedEvents)
%==========================================================================
% Detects Sudden Pixel Sensitivity Dropout (SPSD) events in flux time
% series and returns a summary of events detected along with additive
% corrections for each target.
%
% Let N = number of stellar targets in targetDataStruct.
%     C = the number of cadences in each light curve.
%     B = the number of basis vectors used in cotrending.
%
%
% INPUTS:
%
%     pdcInputObject      : A struct containing the following fields (see 
%                          spsdCorrectedFluxClass for details of what's used): 
%                              .pdcModuleParameters
%                              .spsdDetectorConfigurationStruct
%                              .spsdDetectionConfigurationStruct
%                              .spsdRemovalConfigurationStruct
%
%     targetDataStruct   : An N-length array of structs representing
%                          stellar targets. (see pdcInputStruct) 
%
%     basisVectors               : A B x C matrix of MAP basis vectors
%                          (or optionally empty matrix).
%
%     preLoadedEvents:   : [optional] An struct array containing events.
%                          See compile_spsd_blob().
%                          Intended mainly for SC processing (added in 8.2).
%                              
%
% OUTPUTS:
%
%     resultsStruct : 
%
%         A structure indicating clean targets and targets in which SPSD
%         events were identified. For each "dirty" target, a combined
%         additive correction is returned. Additive corrections are also
%         returned for each individual event within a target. See the
%         example structure below for details.
%
%         Assuming at least one SPSD was identified, a corrected light 
%         curve for the first SPSD can be created as follows:
%
%             >> idx1 = resultsStruct.spsd.index(1);
%             >> correctedFlux = targetDataStruct(idx1).values ...
%                    + resultsStruct.spsd.targets(1).cumulativeCorrection;
%
%         The cumulative correction is simply the sum of the individual
%         SPSD corrections:
%
%             cumulativeCorrection = sum([spsdEvents.correction],2)).
%
%         Example
%         -------
%         exampleResultsStruct
%           .clean [1x1 struct]         : Structure summarizing targets in
%                                         which SPSD events were NOT
%                                         identified.
%               .count: 4               : Number of "clean" targets.
%               .index: [2 3 4 5]       : targetDataStruct array indices of
%                                         clean targets.
%               .keplerId: [8077474 8077489 8077525 8733697]
%                                       : Kepler IDs corresponding to 
%                                         elements in 'index').
%           .spsds [1x1 struct]         : Structure summarizing targets in
%                                         which SPSD events WERE identified.
%               .count: 1               : Number of "dirty" targets.
%               .index: 1               : targetDataStruct array indices of
%                                         targets containing SPSD events. 
%               .keplerId: 8077476
%               .targets: [1x1 struct]  : SPSD event and correction summary 
%                                         for each target.
%                   .index: 1           : targetDataStruct array index of 
%                                         this target.
%                   .keplerId: 8077476  : Kepler ID of this target.
%                   .spsdCount: 1       : Number of SPSD events identified 
%                                         in this target.
%                   .cumulativeCorrection: [4634x1 double]
%                                       : Combined additive correction to  
%                                         target's light curve: correctedFlux =
%                                         this rawFlux + cumulativeCorrection, 
%                                         where cumulativeCorrection =
%                                         sum([spsdEvents.correction],2)).  
%                   .spsdEvents: [1x1 struct]
%                                       : Summary of individual SPSD events.
%                       .spsdCadence: 2516
%                                       : The index of the last non-gapped
%                                         cadence before the maximum positive
%                                         change in the corresponding
%                                         correction. (NOTE that this is
%                                         different than the meaning of 
%                                         spsdCadence in the internal
%                                         resultsStruct)
%
%                       .correction: [4634x1 double]
%                                       : Additive correction for this SPSD.
%
%
% KEY ASSUMPTIONS:
%
%     - Time series values must be in units of photoelectrons per cadence,
%       as output by PA. 
%     - Input values must constitute Piecewise Contiguous Photometric Data, 
%       as defined in the Kepler Project Glossary (KP-121).
% 
%==========================================================================
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
function [resultsStruct, spsdCorrectedFluxStruct] = spsd_controller ( ...
    pdcInputObject, targetDataStruct, basisVectors, preLoadedEvents)

    state = warning('query', 'all'); warning off
    pdcInputObject = struct(pdcInputObject);
    warning(state);

%     if nargin < 3 || (pdcInputObject.spsdRemovalConfigurationStruct.useMapBasisVectors == false)
%         basisVectors = [];
%     end
%   since 8.2: requiring basisVectors as input (or empty [])
    if (~isfield(pdcInputObject.spsdDetectionConfigurationStruct,'quickSpsdEnabled'))
        pdcInputObject.spsdDetectionConfigurationStruct.quickSpsdEnabled = false;
    end
    if nargin < 4 || (pdcInputObject.spsdDetectionConfigurationStruct.quickSpsdEnabled == false)
        preLoadedEvents = [];
    else
        preLoadedEvents.cadenceStartTimes = pdcInputObject.cadenceTimes.startTimestamps; % kinda redundant
        preLoadedEvents.cadenceEndTimes   = pdcInputObject.cadenceTimes.endTimestamps;   % kinda redundant
        preLoadedEvents.shortCadenceTimes = pdcInputObject.cadenceTimes;
    end
    
    paramStruct = struct;
    
    paramStruct.pdcModuleParameters              = pdcInputObject.pdcModuleParameters;
    paramStruct.spsdDetectorConfigurationStruct  = pdcInputObject.spsdDetectorConfigurationStruct;
    paramStruct.spsdDetectionConfigurationStruct = pdcInputObject.spsdDetectionConfigurationStruct;
    paramStruct.spsdRemovalConfigurationStruct   = pdcInputObject.spsdRemovalConfigurationStruct;
        
    spsdCorrectedFluxObject = spsdCorrectedFluxClass(...
        paramStruct, ...
        targetDataStruct, ...
        basisVectors, ...
        preLoadedEvents);
    
    resultsStruct = spsdCorrectedFluxObject.get_results();
    
    % Convert object to struct and return the struct
    spsdCorrectedFluxStruct = spsdCorrectedFluxObject.saveobj();
return
