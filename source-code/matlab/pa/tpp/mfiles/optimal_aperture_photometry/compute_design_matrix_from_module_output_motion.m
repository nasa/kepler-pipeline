function [designMatrixForModuleOutputMotion, ancillaryDataStruct] = ...
    compute_design_matrix_from_module_output_motion(ancillaryDataStruct, motionPolyStruct, parameters)
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



starCenterRow = parametersStruct.starCenterRow;
starCenterColumn = parametersStruct.starCenterColumn;

indexOfXjitter = parameters.indexOfXjitter;
indexOfYjitter = parameters.indexOfYjitter;
nCadences = parameters.nCadences;




modelOrderInDesignMatrix = ancillaryDataStruct(indexOfXjitter).modelOrderInDesignMatrix;
% number of columns will be n + n + n*n (cross terms) where n = modelOrderInDesignMatrix


%----------------------------------------------------------------------
% generate model term indicator matrix; refer to the description in
% x2fx.m - this can be turned into a function
%----------------------------------------------------------------------

modelTermIndicatorMatrix = generate_two_predictors_nth_order_model_matrix(modelOrderInDesignMatrix);

%----------------------------------------------------------------------
% to store the motion time series generated at every grid point in the
% ancillary data struct itself
%----------------------------------------------------------------------
dvaPlusJitterTimeSeriesX = zeros(nCadences, 1);
uncertaintiesInJitterX = zeros(nCadences, 1);
dvaPlusJitterTimeSeriesY = zeros(nCadences, 1);
uncertaintiesInJitterY = zeros(nCadences, 1);



for iCadence = 1:nCadences

    % start by creating a time series of motion at this row, column
    [dvaPlusJitterTimeSeriesX(iCadence)  uncertaintiesInJitterX(iCadence)] = ...
        weighted_polyval2d(starCenterRow, starCenterColumn, [motionPolyStruct(iCadence).rowCoeff]);
    [dvaPlusJitterTimeSeriesY(iCadence) uncertaintiesInJitterY(iCadence)]  =...
        weighted_polyval2d(starCenterRow, starCenterColumn, [motionPolyStruct(iCadence).columnCoeff]);
end

dvaPlusJitterTimeSeriesX = dvaPlusJitterTimeSeriesX - starCenterRow;
dvaPlusJitterTimeSeriesY = dvaPlusJitterTimeSeriesY(:) - starCenterColumn;


% now we have to keep track of {dx, dy} time series pair over a (say)
% 3x3 grid - should we add to the ancillary data struct or not?
% what to do with the uncertainties if we don't add to the ancillary
% data struct?
ancillaryDataStruct(indexOfXjitter).values = dvaPlusJitterTimeSeriesX(:);
ancillaryDataStruct(indexOfXjitter).uncertainties = uncertaintiesInJitterX(:);
ancillaryDataStruct(indexOfYjitter).values = dvaPlusJitterTimeSeriesY(:);
ancillaryDataStruct(indexOfYjitter).uncertainties = uncertaintiesInJitterY(:);
%---------------------------------------------------------------------

% before creating the design matrix, divide the ancillary values pointwise
% by the uncertainties


xTimeSeries = dvaPlusJitterTimeSeriesX(:)./uncertaintiesInJitterX(:);
yTimeSeries = dvaPlusJitterTimeSeriesY(:)./uncertaintiesInJitterY(:);

designMatrixForModuleOutputMotion = ...
    x2fx([xTimeSeries(:),yTimeSeries(:)],modelTermIndicatorMatrix);
return
