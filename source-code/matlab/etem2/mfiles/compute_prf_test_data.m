function compute_prf_test_data(r)
% function to be called from c wrapper
% script to run etem2 to create PRF test data for a single module output
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

% load the dither pattern
offsetPattern = '/path/to/PRF/prfOffsetDeliveries/final/v1/prfOffsetPattern.mat';

load(offsetPattern, 'prfRelativeRaOffset', 'prfRelativeDecOffset', 'startDate');

etem2InputStruct = ETEM2_inputs_1channel_prf();

% set the ra and dec offsets for the dither pattern
etem2InputStruct.runParamsData.keplerData.raOffset = prfRelativeRaOffset(r);
etem2InputStruct.runParamsData.keplerData.decOffset = prfRelativeDecOffset(r);
etem2InputStruct.runParamsData.keplerData.phiOffset = 0;

etem2InputStruct.runParamsData.simulationData.moduleNumber = 14; % which CCD module, ouput and season, legal values: 2-4, 6-20, 22-24
etem2InputStruct.runParamsData.simulationData.outputNumber = 4; % legal values: 1-4

% offset the time of the cadence assuming each data take uses 2 15 minute
% cadences
orignalStartTime = datestr2julian(startDate);
% add 30 minutes for each run number
startTime = orignalStartTime + (r-1)/48;
etem2InputStruct.runParamsData.simulationData.runStartDate = julian2datestr(startTime);

outputDir = ['output/prf_noise_study/prf_data_m' ...
    num2str(etem2InputStruct.runParamsData.simulationData.moduleNumber) ...
    'o' num2str(etem2InputStruct.runParamsData.simulationData.outputNumber) ...
	'_rb_xt/'];
etem2InputStruct.runParamsData.etemInformation.etem2OutputLocation = ...
    [outputDir 'run' num2str(r)];

etem2(etem2InputStruct);

copyfile(offsetPattern, outputDir);


