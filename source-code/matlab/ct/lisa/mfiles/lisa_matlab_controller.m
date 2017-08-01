function [lisaOutputStructArray] = ...
lisa_matlab_controller(runDir, fitsFile, robustThreshold, plotsEnabled, ...
fcConstants)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [lisaOutputStructArray] = ...
% lisa_matlab_controller(runDir, fitsFile, reobustThreshold, plotsEnabled, ...
% fcConstants)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Compute the mean linear temperature coefficients (and uncertainties) for
% each type of FGS crosstalk pixel [Frame (16), Parallel (32), and
% Serial (1)] for each module output from BART output files in the runDir.
% Utilize FGS crosstalk pixels in the leading and trailing black only. Draw
% heavily from existing TCAT functions.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT: the lisa_matlab_controller takes the following arguments:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                         runDir: [string]  full path of directory
%                                           containing BART run
%                                           subdirectories
%                       fitsFile: [string]  full path of clock state mask
%                robustThreshold: [double]  threshold for outlier
%                                           identification
%                  plotsEnabled: [logical]  optional flag to enable plotting
%                                           (default = false)
%                    fcConstants: [struct]  optional fcConstants structure
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  OUTPUT:  A struct array (one per mod out) lisaOutputStructArray with the
%  following fields:
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   Top level
%
%                      ccdModule: [double]  CCD module number
%                      ccdOutput: [double]  CCD output number
% frameTransferPixelFamily: [struct array]  results for FGS frame transfer
%                                           pixels
%      parallelPixelFamily: [struct array]  results for FGS parallel
%                                           transfer pixels
%        serialPixelFamily: [struct array]  results for FGS serial
%                                           transfer pixels
%
%--------------------------------------------------------------------------
%   Second level
%
%     frameTransferPixelFamily, parallelPixelFamily and serialPixelFamily are
%     arrays of structs (one per family pixel type) with the following fields:
%
%                     rows: [double array]  row coordinates of pixels of
%                                           given type (LB/TB only)
%                  columns: [double array]  column coordinates of pixels of
%                                           given type (LB/TB only)
%  temperatureCoefficients: [double array]  linear temperature coefficients
%                                           from BART for given pixels
%                                           (DN/read/degC)
%  sigmaTemperatureCoefficients: [double array]
%                                           uncertainty in linear temperature
%                                           coefficients from BART for given
%                                           pixels (DN/read/degC)
%   effectiveRobustWeights: [double array]  robust weight values effectively
%                                           utilized for weighting of inverse
%                                           variances for LS fit
%     coefficientGapIndicators: [logical array]
%                                           flags to indicate valid linear
%                                           temperature coefficients for
%                                           computation of weighted mean
%     meanTemperatureCoefficient: [double]  weighted mean value of linear
%                                           temperature coefficients for
%                                           given pixels (DN/read/degC)
%     sigmaMeanTemperatureCoefficient: [double]
%                                           uncertainty in weighted mean value
%                                           of linear temperature coefficients
%                                           for given pixels (DN/read/degC)
%                    weightedMse: [double]  weighted mean squared error in fit
%                                           (dimensionless)
%
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

% Get the fcConstants if they were not provided.
if ~exist('fcConstants', 'var')
    fprintf('\n\nLISA: Getting fcConstants from the Java Class...\n\n');
    [fcConstants] = convert_fc_constants_java_2_struct();
end

% Disable plotting if it was not specified.
if ~exist('plotsEnabled', 'var')
    plotsEnabled = false;
end

% Set robust threshold if it was not specified.
DEFAULT_ROBUST_THRESHOLD = 0.10;

if ~exist('robustThreshold', 'var')
    robustThreshold = DEFAULT_ROBUST_THRESHOLD;
end

save robustThreshold.mat robustThreshold

% Prepare the lisaInputDataStruct. Include fcConstants and exclusion
% region.
lisaInputDataStruct.runDir = runDir;
[pathstr, fitsFileName, ext] = fileparts(fitsFile);
lisaInputDataStruct.xTalkFitsFileName = [fitsFileName, ext];

lisaInputDataStruct.fcConstantsStruct = fcConstants;
[lisaInputDataStruct] = set_region_of_interest(lisaInputDataStruct);

% Check for existence of directories and .mat file, and validate
% fcConstants structure.
fprintf('LISA: Checking for the existence of input directory, model/diagnostics .mat file...\n\n');
[lisaInputDataStruct] = validate_tcat_input_struct(lisaInputDataStruct);

% Read cross talk image (FITS format).
fprintf('LISA: Reading crosstalk fits file ...\n\n');
[xTalkOutputStruct] = ...
    read_crosstalk_fits_file(lisaInputDataStruct.xTalkFitsFileName);

% Extract parallel and frame transfer cross talk pixels in the visible CCD.
fprintf('LISA: Extracting parallel transfer and frame transfer crosstalk pixel co-ordinates ...\n\n');
[parallelXtalkPixelStruct, frameTransferXtalkPixelStruct, ...
    serialXtalkPixelStruct]  = ...
    extract_crosstalk_pixel_coordinates_for_lisa(lisaInputDataStruct, ...
    xTalkOutputStruct);

% Compute weighted means of (linear) temperature coefficients and
% uncertainties.
fprintf('LISA: Computing weighted means of temperature coefficients (and uncertainties) ...\n\n');
[lisaOutputStructArray]  = ...
    compute_mean_temperature_coefficients(fcConstants.MODULE_OUTPUTS, ...
    parallelXtalkPixelStruct, frameTransferXtalkPixelStruct, ...
    serialXtalkPixelStruct, robustThreshold, plotsEnabled);

% Save the array of output data structures.
save lisaOutputStructArray.mat lisaOutputStructArray

% Return.
return
