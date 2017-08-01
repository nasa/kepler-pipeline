%% function uberDiagnosticStruct = pdc_populate_diagnosticinputstruct( uberDiagnosticStruct , nTargets )
% =========================================================================
% populates the uberDiagnosticStruct fields that don't exist with default values
% this function is intended as precursor for a pdcDebugClass or pdcDiagnosticClass constructor
% =========================================================================
%
% INPUTS:
%   uberDiagnosticStruct    -- [struct] passed in pdc_matlab_controller (can be empty)
%   nTargets                -- [int] total number of target in this PDC run.
%
% OUTPUTS:
%   uberDiagnosticStruct
%
%
% uberDiagnosticStruct has the following fields:
%
%   pdcDiagnosticStruct
%       targetsToMonitor            -- [int array] indices of targets to save intermediate time series for
%       keplerIdsToAnalyze          -- [int array] keplerIds of targets to perform post-MAP processing (i.e. gap filling) on. all if empty
%                                   
%   mapDiagnosticStruct             
%       doFigures                   -- [logical] flag whether to generate figures
%       doSaveFigures               -- [logical] flag whether figures should be saved
%       doCloseAfterSaveFigures     -- [logical] flag whether figures should be closed after saved
%       doSaveResultsStruct         -- [logical] If true then save mapResultsStruct
%       doQuickDiagnosticRun             -- [logical] if true then truncated diagnostic information should be output:  no figures and
%                                                      only some targets analyzied (see specificKeplerIdsToAnalyze)
%       debugRun                    -- [logcial] If true then this is a debug run, use debug parameters in pdc_controller
%                                                  (If you are not Jeff Smith then you should not use this, unless you know what you are doing!)
%       runLabel                    -- [string] string to prepend to warnings, saved figures and mapResultsStruct
%       specificKeplerIdsToAnalyze  -- [integer array] list of KeplerIDs to apply MAP to. This is only
%                                                   used if doQuickDiagnosticRun == true. If empty apply to all targets
%       saveAfterRobustFit          -- [logical] If true will save all data after the robust fit
%       loadThisRobustData          -- [string] if no empty then will load the data formthis file
%
%   spsdDiagnosticStruct
%       (nothing here yet)
%
%   bsDiagnosticStruct
%       verbose                  output text information, e.g. about grouping of sub-bands
%       plotFigures              flag whether figures should be shown
%       targetsToMonitor         indices of targets to monitor
%
%   dataStructSaving
%       saveBandSplittingObject
%       saveSpsdCorrectedFluxObject
%       saveTargetDataStructBeforeBandSplitting
%       saveTargetDataStructForBands
%       saveTargetDataStructAfterBsMap
%       saveTargetDataStructAfterMap
%       saveGoodnessMetricBsMap
%       saveGoodnessMetricMap
%       savePdcDebugStruct
%       
% =========================================================================
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

function uberDiagnosticStruct = pdc_populate_diagnosticinputstruct( uberDiagnosticStruct , nTargets )

% Don't be vocal about when to set a field
verbosity = false;

% =========================================================================
%%  PDC
    if (~isfield( uberDiagnosticStruct , 'pdcDiagnosticStruct' ))
        uberDiagnosticStruct.pdcDiagnosticStruct = struct();
    end
    
    if (~isfield( uberDiagnosticStruct.pdcDiagnosticStruct , 'targetsToMonitor' ))
        uberDiagnosticStruct.pdcDiagnosticStruct.targetsToMonitor = [];
    end
    
    if (~isfield( uberDiagnosticStruct.pdcDiagnosticStruct , 'keplerIdsToAnalyze' ))
        uberDiagnosticStruct.pdcDiagnosticStruct.keplerIdsToAnalyze = 1:nTargets;
        % FIX ME (to kepids)
    end

% =========================================================================


% =========================================================================
%%   MAP
    if (~isfield( uberDiagnosticStruct , 'mapDiagnosticStruct' ))
        uberDiagnosticStruct.mapDiagnosticStruct = struct();
    end

    if (~isfield( uberDiagnosticStruct.mapDiagnosticStruct , 'runLabel' ))
        uberDiagnosticStruct.mapDiagnosticStruct.runLabel = 'Unlabled_run';
    end
    
    % This is for debugging PDC but not MAP specifically, turns off MAP figures
    if (~isfield( uberDiagnosticStruct.mapDiagnosticStruct , 'doQuickDiagnosticRun' ))
        uberDiagnosticStruct.mapDiagnosticStruct.doQuickDiagnosticRun = false;
    end

    % This is for debuggin MAP specifically
    if (~isfield( uberDiagnosticStruct.mapDiagnosticStruct , 'debugRun' ))
        uberDiagnosticStruct.mapDiagnosticStruct.debugRun = false;
    end

    if (~isfield( uberDiagnosticStruct.mapDiagnosticStruct , 'doFigures' ))
        uberDiagnosticStruct.mapDiagnosticStruct.doFigures = true;
    end

    if (~isfield( uberDiagnosticStruct.mapDiagnosticStruct , 'doSaveFigures' ))
        uberDiagnosticStruct.mapDiagnosticStruct.doSaveFigures = false;
    end

    if (~isfield( uberDiagnosticStruct.mapDiagnosticStruct , 'doCloseAfterSaveFigures' ))
        uberDiagnosticStruct.mapDiagnosticStruct.doCloseAfterSaveFigures = true;
    end

    if (~isfield( uberDiagnosticStruct.mapDiagnosticStruct , 'doSaveResultsStruct' ))
        uberDiagnosticStruct.mapDiagnosticStruct.doSaveResultsStruct = false;
    end

    if (~isfield( uberDiagnosticStruct.mapDiagnosticStruct , 'specificKeplerIdsToAnalyze' ))
        uberDiagnosticStruct.mapDiagnosticStruct.specificKeplerIdsToAnalyze = [];
    end

    uberDiagnosticStruct.mapDiagnosticStruct = assert_field(uberDiagnosticStruct.mapDiagnosticStruct, ...
                'saveAfterRobustFit', false, verbosity);
    uberDiagnosticStruct.mapDiagnosticStruct = assert_field(uberDiagnosticStruct.mapDiagnosticStruct, ...
                'loadThisRobustData', [], verbosity);
    
% =========================================================================



% =========================================================================
%%   SPSD
    if (~isfield( uberDiagnosticStruct , 'spsdDiagnosticStruct' ))
        uberDiagnosticStruct.spsdDiagnosticStruct = struct();
    end
% =========================================================================


% =========================================================================
%%  Band-Splitting
    if (~isfield( uberDiagnosticStruct , 'bsDiagnosticStruct' ))
        uberDiagnosticStruct.bsDiagnosticStruct = bsDataClass.create_default_diagnostic_struct();
    end
% =========================================================================


% =========================================================================
%% general: what diagnostic files to save
    if (~isfield( uberDiagnosticStruct , 'dataStructSaving' ))
        uberDiagnosticStruct.dataStructSaving = struct();
    end
    if (~isfield( uberDiagnosticStruct.dataStructSaving , 'saveSpsdCorrectedFluxObject' ))
        uberDiagnosticStruct.dataStructSaving.saveSpsdCorrectedFluxObject = true;
        % show be saved for SPSD diagnostics
    end
    if (~isfield( uberDiagnosticStruct.dataStructSaving , 'saveTargetDataStructBeforeBandSplitting' ))
        uberDiagnosticStruct.dataStructSaving.saveTargetDataStructBeforeBandSplitting = false;
    end
    if (~isfield( uberDiagnosticStruct.dataStructSaving , 'saveTargetDataStructForBands' ))
        uberDiagnosticStruct.dataStructSaving.saveTargetDataStructForBands = false;
        % values and uncertainties are also contained in mapResultsObject for each band
    end
    if (~isfield( uberDiagnosticStruct.dataStructSaving , 'saveTargetDataStructAfterBsMap' ))
        uberDiagnosticStruct.dataStructSaving.saveTargetDataStructAfterBsMap = false;
    end
    if (~isfield( uberDiagnosticStruct.dataStructSaving , 'saveTargetDataStructAfterMap' ))
        uberDiagnosticStruct.dataStructSaving.saveTargetDataStructAfterMap = false;
    end
    if (~isfield( uberDiagnosticStruct.dataStructSaving , 'saveGoodnessMetricForBands' ))
        uberDiagnosticStruct.dataStructSaving.saveGoodnessMetricForBands = false;
    end
    if (~isfield( uberDiagnosticStruct.dataStructSaving , 'saveGoodnessMetricBsMap' ))
        uberDiagnosticStruct.dataStructSaving.saveGoodnessMetricBsMap = true;
    end
    if (~isfield( uberDiagnosticStruct.dataStructSaving , 'saveGoodnessMetricMap' ))
        uberDiagnosticStruct.dataStructSaving.saveGoodnessMetricMap = true;
    end
    if (~isfield( uberDiagnosticStruct.dataStructSaving , 'savePdcDebugStruct' ))
        uberDiagnosticStruct.dataStructSaving.savePdcDebugStruct = true;
    end

% =========================================================================

end
