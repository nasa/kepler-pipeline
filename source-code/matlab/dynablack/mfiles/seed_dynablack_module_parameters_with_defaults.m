function inputsStruct = seed_dynablack_module_parameters_with_defaults( varargin )
% function inputsStruct = seed_dynablack_module_parameters_with_defaults( varargin )
%
% This function is the sole (MATLAB) source for the default parameter values during dynablack code development. It writes default module
% parameter values into dynablackModuleParameters and rbaFlagConfigurationStruct fields if called with dynablackInputsStruct as the
% argument. If called with empty argument it returns the dynablackModuleParameters struct and rbaFlagConfigurationStruct loaded with default
% values. 
%
% 9/15/2014
% BC - Update default values of nearTbMinpix, rbaStruct.testPulseDurations and
% a1NumPredictorRows to match default values in parameter database per KSOC-3850.
%
% 9/17/14
% BC - Verify all default values inthis fuction match those in
% the current parameter-library.xml (r6511)
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


if nargin > 0
    inputsStruct = varargin{1};
    s = inputsStruct.dynablackModuleParameters;
else
    s = struct;
end


s.dynablackBlobFilename         = 'dynablack_blob.mat';
s.cadenceGapThreshold           = 2;

% A1 fit quality check thresholds
s.blackResidualsThresholdDnPerRead          = 0.25;
s.blackResidualsStdDevThresholdDnPerRead    = 0.15;
s.numBlackPixelsAboveThreshold              = 10;

% logical flags
s.removeFixedOffset             = true;
s.removeStatic2DBlack           = true;
s.includeStepsInModel           = true;
s.a2SkipDiff                    = true;

% definine regions of interest (Rmin,Rma,Cmin,Cmax)
% The coadded regions must match the regions defined in the spacecraft config map
% e.g. black coadded columns = 1119:1132
s.leadingArp                    = [   7,1059,   3,  12];
s.trailingArp                   = [   7,1051,1115,1132];
s.trailingArpUs                 = [1052,1063,1113,1132];
s.trailingCollat                = [   7,1059,1119,1132];
s.neartrailingArp               = [1057,1063,1100,1112];
s.trailingFfi                   = [   7,1063,1113,1132];
s.rclcTarg                      = [   7,1058,   3,1130];
s.trailingMaskedSmear           = [   1,  20,1113,1132];
s.leadingMaskedSmear            = [   1,  20,   1,  12];

% fgs pixel clock states
s.parallelPixelSelect           = [565 566 1:29];
s.a2ParallelPixelSelect         = [565 566 1:29];
s.framePixelSelect              = 1:16;
s.a2FramePixelSelect            = 1:20;

% start of line ringing parameters
s.a2SolRange                    = 1:280;
s.a2SolStart                    = 13;

% nonlinear fit parameters
s.defaultRowTimeConstant        = 25;
s.nearTbMinpix                  = 1000;
s.thermalRowOffset              = 214;
s.minUndershootRow              = 1058;
s.maxUndershootRow              = 1063;
s.undershootSpan0               = -12;
s.undershootSpan                = -20;
s.scDPixThreshold               = 5000;
s.blurPix                       = 1;

% vertical (row) fit parameters
s.leadingColumnSelect           = [3:10 12];
s.maxA1CoeffCount               = 130;
s.a1NumPredictorRows            = 10;
s.a1NumNonlinearPredictorRows   = 4;
s.a1NumFfiPredictorRows         = 3;

% horizontal (column) fit parameters
s.a2LeadingColumnSelect         = 1:291;
s.a2LeadColumnPredictorCount    = 291;
s.a2ColumnPredictorCount        = 13;
s.maxA2CoeffCount               = 130;
s.a2SmearPredictorCount         = 6;

% smoothing over cadences fit parameters
s.numModelTypes                 = 4;
s.maxB1CoeffCount               = 9;
s.numB1PredictorCoeffs          = 2;


% moved to MATLAB inputsStruct root level per KSOC-2367
% rba flagging parameters
rbaStruct = struct;
rbaStruct.pixelNoiseThresholdAduPerRead   = 1.65;             % noise/read/pixel for 20 ppm of 12th mag. star
rbaStruct.pixelBiasThresholdAduPerRead    = 0.016;            % bias/read/pixel read for 20 ppm of 12th mag. star
rbaStruct.cleaningScale                   = 21;               % used for filtering spurious flags
rbaStruct.testPulseDurations              = 3:31;             % list of durations in lc for square wave transit model to test for rba
rbaStruct.numberOfFlagVariables           = 9;                % number of flag variables in suspect data flag
rbaStruct.severityQuantiles               = [0.977, 0.5];     % quantiles to report in severity parameters
rbaStruct.meanSigmaThreshold              = 1;                % bias threshold in sigma
rbaStruct.robustWeightThreshold           = 0.5;              % robust weight threshold
rbaStruct.transitDepthSigmaThreshold      = 0;                % transit depth threshold in sigma


% attach structs or return single struct (w/rbaFlagConfigurationStruct included)
if nargin > 0
    inputsStruct.dynablackModuleParameters = s;
    inputsStruct.rbaFlagConfigurationStruct = rbaStruct;
else
    s.rbaFlagConfigurationStruct = rbaStruct;
    inputsStruct = s;    
end



