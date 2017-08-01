function  pmdOutputStruct = pmd_generate_output_time_series(pmdScienceObject, pmdOutputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function  pmdOutputStruct = pmd_generate_output_time_series(pmdScienceObject, pmdOutputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function calculates the time series metrics of background level, centroids
% mean row, centroids mean column, plate scale, CDPP measured, CDPP expected and
% CDPP ratio, which are stored in outputTsData struct of pmdOutputStruct.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

fprintf('\nPMD: Generate background level time series ...\n');
pmdOutputStruct.outputTsData.backgroundLevel     = pmd_calculate_background_level_metric(pmdScienceObject);

fprintf('\nPMD: Generate centroids mean row and column time series ...\n');
centroids = calculate_centroid_metric(pmdScienceObject);
pmdOutputStruct.outputTsData.centroidsMeanRow    = centroids.centroidsMeanRow; %pmdOutputTsData.centroidsMeanRow;
pmdOutputStruct.outputTsData.centroidsMeanColumn = centroids.centroidsMeanColumn; % pmdOutputTsData.centroidsMeanColumn;

fprintf('\nPMD: Generate plate scale time series ...\n');
pmdOutputStruct.outputTsData.plateScale = calculate_plate_scale_metric(pmdScienceObject); %/scalepmdOutputTsData.plateScale;

fprintf('\nPMD: Generate CDPP metrics ...\n');
cdppMetrics = calculate_cdpp_metric(pmdScienceObject); %pmdOutputTsData.cdppMetrics;

pmdOutputStruct.outputTsData.cdppMeasured = cdppMetrics.measured;
pmdOutputStruct.outputTsData.cdppExpected = cdppMetrics.expected;
pmdOutputStruct.outputTsData.cdppRatio    = cdppMetrics.ratio;
pmdOutputStruct.outputTsData.cdppMmrMetrics = cdppMetrics.mmrMetrics;

return

