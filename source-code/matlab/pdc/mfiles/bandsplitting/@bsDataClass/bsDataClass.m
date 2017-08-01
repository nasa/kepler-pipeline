
% =======================================================================
% bsDataClass
% =======================================================================
%
% use with
% - bs_controller_split(...)
% - bs_controller_combine(...)
%
% or static method
% - bsDataClass.bandsplit_timeseries(...) for simple splitting of single time series
%
% See respective methods for further information
%
% bsConfigStruct:
%
%     numberOfBands                           [INT]        (default: 3)
%     splittingMethod                         [STRING]     'wavelet'
%     waveletFamily                           [STRING]     'daubechies'
%     numberOfWaveletTaps                     [INT]        (default: 12)
%     groupingMethod                          [STRING]     'manual' (default)
%                                                          'sumHigh'
%                                                          'sumLow'
%                                                          'groupHigh'
%                                                          'groupLow'
%     groupingManualBandBoundaries            [INT ARRAY]  (default: [1023 3])
%     edgeEffectMitigationMethod              [STRING]     'expointmirrortaper' (default)
%                                                          'none'
%     edgeEffectMitigationExtrapolationRange  [INT]        (default: 500)
%
%
%
% =======================================================================
% Explanation of combineMethod 'manual':
%   This groups together subbands as specified by the array groupingManualCadenceBoundaries
%   groupingManualCadenceBoundaries contains the cadence periods above which a new band should be created
%   For example:
%   [ 1024 256 32 8 ] generates:
%      band 1:  1024
%      band 2:  512 256
%      band 3:  128 64 32
%      band 4:  16 8
%      band 5:  4 2 1
% NOTE -- we now use a different method to specify the cadence at the band boundary, explained below: 
%   To avoid confusion at the boundaries, it might be more intuitive to specify
%   non-powers of two as boundary values. For instance, the above case is equivalent to
%   [ 1023 255 31 7 ]
%      (1023 splits between 1024/512,
%        255 splits between 256/128,
%         31 splits between32/16,
%          7 splits between 8/4)
%
% =======================================================================
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



classdef bsDataClass < handle
    
    

% ------------------------- Properties -------------------------------------------
    properties (GetAccess = 'public' , SetAccess = 'public')
	    configStruct = [];          % the config struct as input to the constructor
        diagnosticStruct = [];      % the diagnostic struct as input
        motherWavelet = [];         % generated in the Constructor
        diagnosticData = struct('hfigExtendedLightcurve' , 0 , ...
                                'hfigBands' , 0 );
        inputTargetDataStruct = []; % input data
        bandsTargetDataStruct = {}; % results
        waveletTargetDataStruct = {}; % results in wavelet domain
    end % properties
% ----------------- Private Properties -------------------------------------------
% NOTE: making these public for now, for easier debugging during development
    properties (GetAccess = 'public' , SetAccess = 'public')
        intermediateFlux = [];               % intermediate flux time series (pre...post) (values)
        intermediateFluxUncertainties = [];  % intermediate flux time series (pre...post) (uncertainties)
        allBands = [];                       % all bands of current target (before grouping) (values)
        allBandsUncertainties = [];          % all bands of current target (before grouping) (uncertainties)
        combinedBands = [];                  % combined band of current target (values)
        combinedBandsUncertainties = [];     % combined band of current target (uncertainties)
        conditioningStruct = [];             % data exchange between pre/post conditioning
        maxScale = 0;                        % maximum number of bands -1 (given by length of data and wavelet)
        nBands = 0;                          % requested number of bands (not more than maxScale+1)
        nTargets = 0;                        % for simpler access
        nCadences = 0;                       % for simpler access
        infoStruct = [];                     % contains diagnostic information of results, e.g. about the subband grouping
        waveletCoefficients = [];            % wavelet detail coefficients
        waveletCoefficientsUncertainties = [];            % wavelet detail coefficients uncertainties
        nScales = [];                       % Number of wavelet scales
        
    end
        

% ------------------------- Methods ----------------------------------------------
    methods (Access = 'public')
% --------------------------------------------------------------------------------
        % Constructor
        function obj = bsDataClass(inTargetDataStruct,bsConfigStruct,bsDiagnosticStruct)
            % some general init
            obj.nTargets = length(inTargetDataStruct);
            obj.nCadences = length(inTargetDataStruct(1).values);
            % assuming that input validation has been done already (via static method) when validating PDC inputs                        
            % == bsConfigStruct ==
            obj.configStruct = bsConfigStruct;
            % make sure some fields in bsConfigStruct are in correct row/column format
            if (size(obj.configStruct.groupingManualBandBoundaries,1) > size(obj.configStruct.groupingManualBandBoundaries,2))
                obj.configStruct.groupingManualBandBoundaries = obj.configStruct.groupingManualBandBoundaries';
            end
            % ====================
            if (~isempty(bsDiagnosticStruct))
                obj.diagnosticStruct = bsDiagnosticStruct;
            else
                obj.diagnosticStruct = obj.create_default_diagnostic_struct();
            end
            obj.inputTargetDataStruct = inTargetDataStruct;
            obj.intermediateFlux = [];
            obj.intermediateFluxUncertainties = [];
            % create figures handles
            if (obj.diagnosticStruct.plotFigures)
                obj.diagnosticData.hfigExtendedLightCurve = figure;
                set(obj.diagnosticData.hfigExtendedLightCurve,'Name','BS DIAGNOSTIC: Extended Lightcurve');
                obj.diagnosticData.hfigBands = figure;
                set(obj.diagnosticData.hfigBands,'Name','BS DIAGNOSTIC: Bands');
            else
                obj.diagnosticData.hfigExtendedLightCurve = 0;
                obj.diagnosticData.hfigBands = 0;
            end
            % create mother wavelet
            obj.create_mother_wavelet();
            % calculate maximum number of bands
            lenSignal = length(inTargetDataStruct(1).values);
            lenWavelet = length(obj.motherWavelet);
            % maxScale can be increased in the preconditioning, depending on the light curve extension length
            % maxScale is increased by one to account for lengthening of time series by expointmirrortaper etc
            obj.maxScale = ceil(log(lenSignal/lenWavelet) / log(2)) +1; % original setting
            % Compute the maximum scale, using the rule of thumb formula
            % from Percival&Walden Wavelet Methods for Time Series Analysis, p. 200
            % According to this formula, one should *not* increase the scale by one
            % obj.maxScale = ceil( log2(lenSignal/(lenWavelet-1) + 1) );
            
            % Number of wavelet scales is maxScale + 1 
            obj.nScales = obj.maxScale+1;
            obj.nBands = min(bsConfigStruct.numberOfBands,obj.maxScale+1);
            
            %==============================================================
            % Initialize obj.bandsTargetDataStruct -- fields 
            % contained in obj.bandsTargetDataStruct{1}(1) -- and their
            % order -- *should* be the same as those in inputTargetDataStruc
            % TODO: We should not be intializing a targetDataStruct like this.
            % What we really should be doing is defining targetDataClass so that initialization
            % is only done in one set of code. Some day, some day...
            initStructBands = struct();
            initStructBands.attitudeTweakIndicators  = [];
            initStructBands.crowdingMetric = 0;
            initStructBands.excludeBasedOnLabels = false;
            initStructBands.fluxFractionInAperture = 0;
            initStructBands.gapIndicators = false(obj.nCadences,1);
            initStructBands.keplerId = 0;
            initStructBands.keplerMag = 0;
            % initStructBands.kic is a complex struct,
            % with dozens of fields that are themselves structs;
            % For now, initialize to a blank struct
            initStructBands.kic = struct(); 
            initStructBands.labels = {};
            initStructBands.transits = [];
            initStructBands.uncertainties = zeros(obj.nCadences,1);
            initStructBands.values = zeros(obj.nCadences,1);
            initStructBands.optimalAperture = [];
            initStructBands = orderfields(initStructBands);
            initStructBands = repmat(initStructBands,obj.nTargets,1);
            initCellBands{1} = initStructBands;
            obj.bandsTargetDataStruct = repmat(initCellBands,1,obj.nBands);
            
            % Initialize obj.waveletTargetDataStruct
            initStructScales = struct();
            initStructScales.values = zeros(obj.nCadences,1);
            initStructScales.uncertainties = zeros(obj.nCadences,1);
            initStructScales = repmat(initStructScales,obj.nTargets,1);
            initCellScales{1} = initStructScales;
            obj.waveletTargetDataStruct = repmat(initCellScales,1,obj.nScales);
            
            % Initialize obj.waveletCoefficients
            initCell{1} = 0;
            obj.waveletCoefficients = repmat(initCell,1,obj.nTargets);
            % Initialize obj.waveletCoefficientsUncertainties
            obj.waveletCoefficientsUncertainties = repmat(initCell,1,obj.nTargets);
            % Initialize obj.allBands
            obj.allBands = repmat(initCell,1,obj.nTargets);
            % Initialize obj.allBandsUncertainties
            obj.allBandsUncertainties = repmat(initCell,1,obj.nTargets);
           
            
        end % bsDataClass (Constructor)
% --------------------------------------------------------------------------------
% further methods: (defined in individual m-files)
        create_mother_wavelet(obj);
        pre_transform_conditioning(obj,targetIndex);
        post_transform_conditioning(obj,targetIndex);
        split_into_bands(obj,targetIndex);
        combine_bands(obj,targetIndex);
        process_single_target(obj,targetIndex);
        process_all_targets(obj);
    end % methods

% ------------------------- Static Methods ---------------------------------------
    methods (Static)
        % split targets in targetDataStruct (standard call in PDC)
%         [ bsTargetResultsStructs , bsDataObject ] = bs_controller_split( bsTargetInputStruct , bsConfigStruct , bsDiagnosticInputStruct );
%         (currently not a class member)
        % combine targets in targetDataStruct (standard call in PDC)
%         [ bsTargetResultsStruct ] = bs_controller_combine( mapResultsObjectBands , bsDataObject );
%         (currently not a class member)
        % simple splitting of a single vector of values
        [ bands bsInfoStruct ] = bandsplit_timeseries( timeSeries , varargin )
        % generate default bsConfigStruct
        bsConfigStruct = create_default_config_struct();
        % generate default bsDiagnosticStruct
        bsDiagnosticStruct = create_default_diagnostic_struct(varargin);
        % Check inputs
        [ isValid , validStrings ] = validate_inputs(bsConfigStruct);
        % 
    end % static methods
    
end % classdef

