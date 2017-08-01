function cdqOutputStruct = cdq_matlab_controller(bartOutputDir, channelArray, chargeInjectionPixelRemoved)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function cdqOutputStruct = cdq_matlab_controller(bartOutputDir, channelArray, chargeInjectionPixelRemoved)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This function is the entry point into Collateral Data Quality (CDQ) tool,
% which invokes several other functions to meet following requirements of CDQ:
% 
% 53.CDQ.1
% CDQ shall accept the MATLAB output from the multiple mod/outs produced by BART runs as input.
%
% 53.CDQ.2
% CDQ shall calculate averages of RMS and thermal coefficient values produced by BART for each column of leading and trailing black and each row of 
% virtual and masked smear data for each mod/out.
%
% 53.CDQ.3
% CDQ shall display the averages it produces of RMS and thermal coefficient values produced by BART for each column of leading and trailing black and
% each row of virtual and masked smear data for each mod/out.
%
% 53.CDQ.4
% CDQ shall save the averages it produces of RMS and thermal coefficient values produced by BART for each column of leading and trailing black and
% each row of virtual and masked smear data for each mod/out.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%  Inputs:
%
%                        bartOutputDir [string]         A string defining the directory of bart outputs.  
%                         channelArray [double array]   Optional. Array of channels to be processed. Default value is [1:84].
%          chargeInjectionPixelRemoved [logical]        Optional. Flag indicating charge injection pixels are/aren't removed when it is true/false.
%                                                       Default value is false.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%  Output:
%
%    cdqOutputStruct is a structure containing following fields:
%
%                              meanRms [struct array]   Mean values of RMS of fit residuals. One struct for each module/output.
%           meanThermalModelLinearTerm [struct array]   Mean values of thermal model linear terms. One struct for each module/output.
%         meanThermalModelConstantTerm [struct array]   Mean values of thermal model constant terms. One struct for each module/output.
%
%    cdqOutputStruct.meanRms(1)
%    cdqOutputStruct.meanThermalModelLinearTerm(1)
%    cdqOutputStruct.meanThermalModelConstantTerm(1)  are structures containing the following fieds:
%
%                         leadingBlack [12x1 double]    Mean values of leading  balck columns.
%                        trailingBlack [20x1 double]    Mean values of trailing balck columns.
%                          maskedSmear [20x1 double]    Mean values of masked  smear rows.
%                         virtualSmear [26x1 double]    Mean values of virtual smear rows.
%
%    cdqOutputStruct is automatically saved in cdq_output_struct.mat under the directory where the user is running cdq_matlab-controller.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% Output plots:
% 
% The following tree of directories is also automatically generated under the directory
% where the user is running cdq_matlab_controller to the save the plots of each data type
% (RMS, thermal model linear/constant term) and collateral type (leading/trailing black,
% masked/virtual smear):
%
%       rms_plots
%                                           leading_black
%                                                           focal_plane
%                                                           one_mod_out
%                                           trailing_black
%                                                           focal_plane
%                                                           one_mod_out
%                                           masked_smear
%                                                           focal_plane
%                                                           one_mod_out
%                                           virtual_smear
%                                                           focal_plane
%                                                           one_mod_out
%       thermal_model_linear_term_plots
%                                           leading_black
%                                                           focal_plane
%                                                           one_mod_out
%                                           trailing_black
%                                                           focal_plane
%                                                           one_mod_out
%                                           masked_smear
%                                                           focal_plane
%                                                           one_mod_out
%                                           virtual_smear
%                                                           focal_plane
%                                                           one_mod_out
%       thermal_model_constant_term_plots
%                                           leading_black
%                                                           focal_plane
%                                                           one_mod_out
%                                           trailing_black
%                                                           focal_plane
%                                                           one_mod_out
%                                           masked_smear
%                                                           focal_plane
%                                                           one_mod_out
%                                           virtual_smear
%                                                           focal_plane
%                                                           one_mod_out
%
% The following plots are included in the 'focal_plane' directory of each data type and collateral type:
% 
%       3D plot of mean values
%           x axis - module/outputs
%           y axis - leading/trailing black columns or masked/virtual smear rows
%           z axis - mean values
%       2D plot of mean values (superposed with    offset)
%           x axis - module/outputs
%           y axis - mean values
%       2D plot of mean values (superposed without offset)
%           x axis - module/outputs
%           y axis - mean values
%       Histogram plots, one for each leading/trailing black column or masked/virtual smear row
%           x axis - module/outputs
%           y axis - scatter around mean values
%           z axis - pixel count
%
% The following plots are included in the 'one_mod_out' directory of each data type and collateral type:
% 
%       3D plot of mean values
%           x axis - leading/trailing black columns or masked/virtual smear rows
%           y axis - module/outputs
%           z axis - mean values
%       2D plot of mean values (superposed with    offset)
%           x axis - leading/trailing black columns or masked/virtual smear rows 
%           y axis - mean values
%       2D plot of mean values (superposed without offset)
%           x axis - leading/trailing black columns or masked/virtual smear rows
%           y axis - mean values
%       Histogram plots, one for each module/output
%           x axis - leading/trailing black columns or masked/virtual smear rows
%           y axis - scatter around mean values
%           z axis - pixel count
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Generate CDQ input structure
fprintf('\nCDQ: Generate CDQ input structure ...\n');

if ~( nargin==1 || nargin==2 || nargin==3 )
    error('CDQ:cdq_matlab_controller:wrongNumberOfInputs', 'cdq_matlab_controller must be called with 1, 2 or 3 input arguments.');
end

if ( ~ischar(bartOutputDir) || isempty(bartOutputDir) )
    error('CDQ:cdq_matlab_controller:invalidInput', 'bartOutputDir must be a non-empty string.');
end

if ( bartOutputDir(end)~='/' )
    bartOutputDir(end+1) = '/';
end

cdqInputStruct.bartOutputDir      = bartOutputDir;

cdqInputStruct.fcConstantsStruct  = convert_fc_constants_java_2_struct();

nModOut = cdqInputStruct.fcConstantsStruct.MODULE_OUTPUTS;
if ( ~exist('channelArray', 'var') )
    channelArray = 1:nModOut;
end

if ( ~exist('chargeInjectionPixelRemoved', 'var') )
    chargeInjectionPixelRemoved = false;
end

cdqInputStruct.channelArray                = channelArray;
cdqInputStruct.chargeInjectionPixelRemoved = chargeInjectionPixelRemoved;

% Check the availability of BART model and diagnostics files
cdqInputStruct = cdq_check_model_diagnostics_files(cdqInputStruct);

% Validate CDQ input struct
fprintf('\nCDQ: Validate CDQ input structure ...\n');
cdq_validate_input_struct(cdqInputStruct);

% Save CDQ input struct
inputFilename = 'cdq_input_struct.mat';
eval(['save ' inputFilename ' cdqInputStruct']);


% Calculate mean values and residuals and generate output struct and temporary struct
fprintf('\nCDQ: Calculate mean values and residuals ...\n');
[cdqOutputStruct, cdqTemporaryStruct] = cdq_calculate_averages(cdqInputStruct);

% Save CDQ output struct and temporary struct
outputFilename    = 'cdq_output_struct.mat';
temporaryFilename = 'cdq_temporary_struct.mat';
eval(['save ' outputFilename    ' cdqOutputStruct'   ]);
eval(['save ' temporaryFilename ' cdqTemporaryStruct']);


% Generate plots
fprintf('\nCDQ: Generate plots ...\n');
cdq_display_averages(cdqInputStruct, cdqOutputStruct, cdqTemporaryStruct);


end
