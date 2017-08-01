function analyze_parameter_study()
% script to process and analyze PRF parameter study
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

% analyze_data('m14o1_z1f2F4');
analyze_data('m20o4_z5f5F1');
analyze_data('m20o4_z1f1F4');
analyze_data('m6o4_z1f1F4');
analyze_data('m6o4_z5f5F1');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function prfAnalysisStruct = analyze_data(prfIdString)

% load the source PRF
switch(prfIdString)
    case 'm14o1_z1f2F4'
        load /path/to/ETEM_PSFs/all_prf/prf_focus_4_z1_f2.mat
        sourcePrfPolyStruct = pixelPolyStruct;
        
    case 'm20o4_z5f5F1'
        load /path/to/ETEM_PSFs/all_prf/prf_focus_1_z5_f5.mat
        sourcePrfPolyStruct = pixelPolyStruct;
        
    case 'm20o4_z1f1F4'
        load /path/to/ETEM_PSFs/all_prf/prf_focus_4_z1_f1.mat
        sourcePrfPolyStruct = pixelPolyStruct;
        
    case 'm6o4_z1f1F4'
        load /path/to/ETEM_PSFs/all_prf/prf_focus_4_z1_f1.mat
        sourcePrfPolyStruct = pixelPolyStruct;
        
    case 'm6o4_z5f5F1'
        load /path/to/ETEM_PSFs/all_prf/prf_focus_1_z5_f5.mat
        sourcePrfPolyStruct = pixelPolyStruct;
        
    otherwise
        error('bad prfIdString');
end

arrayResolution = 400;

sourcePrfObject = prfClass(pixelPolyStruct);
sourceArray = make_array(sourcePrfObject, arrayResolution);
sourceArray = sourceArray/max(max(sourceArray));

load analysisParameters.mat magLimits crowdingLimits;
% compare with the result for the range of parameters
for maxM = 1:length(magLimits)
    for crowding = 1:length(crowdingLimits)
        filename = ['prfAnalysisData_' prfIdString '_m_12-' ...
            num2str(magLimits(maxM)) ...
            '_c_' ...
            num2str(crowdingLimits(crowding)) ...
            '.mat'];

        load(filename, 'pixelPolyStruct', 'numStars');
        disp(filename)
        
		if numStars(maxM, crowding) > 0
        	prfObject = prfClass(pixelPolyStruct);
        	prf(maxM, crowding).coefficientMatrix = get(prfObject, 'coefficientMatrix');

        	prfArray = make_array(prfObject, arrayResolution);
        	prfArray = prfArray/max(max(prfArray));
        	prf(maxM, crowding).prfArray = prfArray;

        	registeredPrfArray = register_centroids(sourceArray, prfArray);
        	registeredPrfArray = prfArray/max(max(registeredPrfArray));

        	prf(maxM, crowding).error = registeredPrfArray - sourceArray;

        	norm2Error(maxM, crowding) ...
            	= norm(prf(maxM, crowding).error(:))/norm(sourceArray(:));
        	maxError(maxM, crowding) ...
            	= abs(max(max(prf(maxM, crowding).error)));

        	clear prfData;
		else
			prf(maxM, crowding).prf = [];
			prf(maxM, crowding).prfArray = [];
			prf(maxM, crowding).error = [];
			norm2Error(maxM, crowding) = -1;
			maxError(maxM, crowding) = -1;
		end
    end
end

prfAnalysisStruct.sourceArray = sourceArray;
prfAnalysisStruct.prf = prf;
prfAnalysisStruct.magLimits = magLimits;
prfAnalysisStruct.crowdingLimits = crowdingLimits;
prfAnalysisStruct.numStars = numStars;
prfAnalysisStruct.norm2Error = norm2Error;
prfAnalysisStruct.maxError = maxError;

save(['prfAnalysisStruct_' prfIdString '.mat'], 'prfAnalysisStruct');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function registeredArray = register_centroids(sourceArray, movingArray)
nRows = size(sourceArray, 1);
nCols = size(sourceArray, 2);

if nRows ~= size(movingArray, 1) || nCols ~= size(movingArray, 2)
    error('arrays not same size');
end
[C,R] = meshgrid(1:nCols, 1:nRows);
movingFlux = sum(sum(movingArray));
movingCentroidRow = sum(R(:).*movingArray(:))/movingFlux;
movingCentroidCol = sum(C(:).*movingArray(:))/movingFlux;
sourceFlux = sum(sum(sourceArray));
sourceCentroidRow = sum(R(:).*sourceArray(:))/sourceFlux;
sourceCentroidCol = sum(C(:).*sourceArray(:))/sourceFlux;

deltaRow = movingCentroidRow - sourceCentroidRow;
deltaCol = movingCentroidCol - sourceCentroidCol;

registeredArray = interp2(C, R, movingArray, C + deltaCol, R + deltaRow, '*cubic', 0);

registeredFlux = sum(sum(registeredArray));
registeredCentroidRow = sum(R(:).*registeredArray(:))/registeredFlux;
registeredCentroidCol = sum(C(:).*registeredArray(:))/registeredFlux;

