function coaObject = compute_dva_motion(coaObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function coaObject = compute_dva_motion(coaObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Computes the motion due to differential velocity aberration (DVA)   
% We compute the aberrated paths of points on a low-resolution (e.g. 5 x 5)
% mesh on the module output once for each day in the simulation period.
% Each resulting mesh of DVA data is fit by a 2D polynomialover the module output.  
% The DVA for any point on the module output can be estimated by evaluating
% that polynomial.
% 
% Fills in the following the following fields of coaObject:
%   .dvaCoeffStruct - struct containing the following fields
%       .abRowPoly() array of polynomial structs indexed by time
%           giving the fit to the aberrated mesh row positions
%       .abCalPoly() array of polynomial structs indexed by time
%           giving the fit to the aberrated mesh columns positions
%       .sampleInterval the time in days between samples
% 
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

% get some useful parameters
startTime = datestr2mjd(coaObject.startTime);
duration = coaObject.duration;
module = coaObject.module;
output = coaObject.output;
nRowPix = coaObject.moduleDescriptionStruct.nRowPix;
nColPix = coaObject.moduleDescriptionStruct.nColPix;
dvaMeshEdgeBuffer = coaObject.coaConfigurationStruct.dvaMeshEdgeBuffer;
dvaMeshOrder = coaObject.coaConfigurationStruct.dvaMeshOrder;
nDvaMeshRows = coaObject.coaConfigurationStruct.nDvaMeshRows;
nDvaMeshCols = coaObject.coaConfigurationStruct.nDvaMeshCols;
raOffset = coaObject.coaConfigurationStruct.raOffset;
decOffset = coaObject.coaConfigurationStruct.decOffset;
phiOffset = coaObject.coaConfigurationStruct.phiOffset;
motionPolynomialsEnabled = ...
    coaObject.coaConfigurationStruct.motionPolynomialsEnabled;
maskedSmear = coaObject.moduleDescriptionStruct.maskedSmear;
leadingBlack = coaObject.moduleDescriptionStruct.leadingBlack;

debugFlag = coaObject.debugFlag;

% if motion polynomials are enabled then there is not much to do here;
% determine the (median) sample interval and return
if motionPolynomialsEnabled
    
    motionPolyStruct = coaObject.motionPolyStruct;
    if isempty(motionPolyStruct)
        error('TAD:COA:compute_dva_motion:motionPolyStruct', ...
            'motion polynomial structure array is empty');
    end
    motionPolyGapIndicators = ~logical([motionPolyStruct.rowPolyStatus]');
    motionPolyStruct = motionPolyStruct(~motionPolyGapIndicators);
    if isempty(motionPolyStruct)
        error('TAD:COA:compute_dva_motion:motionPolyStruct', ...
            'all motion polynomials are invalid');
    end
    
    motionPolyTimestamps = [motionPolyStruct.mjdMidTime]';
    isInTimeRange = motionPolyTimestamps >= startTime & ...
        motionPolyTimestamps <= startTime + duration;
    if ~any(isInTimeRange)
        error('TAD:COA:compute_dva_motion:motionPolyStruct', ...
            'no valid motion polynomials in desired time range');
    end
    
    dvaCoeffStruct.sampleInterval = ...
        median(diff(motionPolyTimestamps(isInTimeRange)));
    dvaCoeffStruct.abRowPoly = [];
    dvaCoeffStruct.abColPoly = [];
    coaObject.dvaCoeffStruct = dvaCoeffStruct;
    
    return
    
end
    
% first construct grid on which to compute motion due to DVA. 
% construct the mesh with nDvaMeshRows and nDvaMeshCols points equally
% spaced across a CCD as defined in the moduleDataStruct.
[dvaInitMeshCol, dvaInitMeshRow] = meshgrid(...
    linspace(-dvaMeshEdgeBuffer, nColPix + dvaMeshEdgeBuffer, nDvaMeshCols), ...
    linspace(-dvaMeshEdgeBuffer, nRowPix + dvaMeshEdgeBuffer, nDvaMeshRows));
% find the initial unaberrated RA and dec of the dva mesh points
dvaMeshInitRA = zeros(size(dvaInitMeshRow));
dvaMeshInitDec = zeros(size(dvaInitMeshRow));
for meshRow = 1:nDvaMeshRows
    for meshCol = 1:nDvaMeshCols
%         [dvaMeshInitRA(meshRow, meshCol), dvaMeshInitDec(meshRow, meshCol)] ...
%             = pix_2_ra_dec_relative(coaObject.raDec2PixObject, ...
%             module, output, dvaInitMeshRow(meshRow, meshCol), ...
%             dvaInitMeshCol(meshRow, meshCol), startTime, ...
% 			raOffset, decOffset, phiOffset, 0);
        [dvaMeshInitRA(meshRow, meshCol), dvaMeshInitDec(meshRow, meshCol)] ...
            = pix_2_ra_dec_relative(coaObject.raDec2PixObject, ...
            module, output, dvaInitMeshRow(meshRow, meshCol) + maskedSmear, ...
            dvaInitMeshCol(meshRow, meshCol) + leadingBlack, startTime + duration/2, ...
			raOffset, decOffset, phiOffset, 1);
    end
end
% check for nan and inf
if any(any(~isfinite(dvaMeshInitRA)))
    error('TAD:compute_dva_motion:dvaMeshInitRA:not_finite',...
        'dvaMeshInitRA contains NAN or INF after pix_2_ra_dec.');
end
if any(any(~isfinite(dvaMeshInitDec)))
    error('TAD:compute_dva_motion:dvaMeshInitDec:not_finite',...
        'dvaMeshInitDec contains NAN or INF after pix_2_ra_dec.');
end
% compute the number of samples from the duration, taking one sample per
% day
nSamples = fix(duration) + 1;
% approximately compute the Julian time of each sample 
sampleTimes = linspace(startTime, startTime + duration, nSamples);
sampleInterval = sampleTimes(2) - sampleTimes(1);

% now compute the aberrated mesh positions 
aberratedRows = zeros(nSamples, nDvaMeshRows, nDvaMeshCols);
aberratedCols = zeros(nSamples, nDvaMeshRows, nDvaMeshCols);
aberratedWeights = ones(nSamples, nDvaMeshRows, nDvaMeshCols);
for meshRow = 1:nDvaMeshRows
    for meshCol = 1:nDvaMeshCols
        % compute the aberrated RA and dec of each dva mesh point at each
        % sample
        [aberratedModule, aberratedOutput, row, col] = ra_dec_2_pix_relative( ...
            coaObject.raDec2PixObject, ...
            dvaMeshInitRA(meshRow, meshCol), ...
            dvaMeshInitDec(meshRow, meshCol), ...
            sampleTimes, raOffset, decOffset, phiOffset);
        row = row - maskedSmear;
        col = col - leadingBlack;
		weights = ones(size(row));
        onWrongOutput = find(aberratedOutput ~= output);
		weights(onWrongOutput) = 0;

        aberratedRows(:, meshRow, meshCol) = row;
        aberratedCols(:, meshRow, meshCol) = col;
        aberratedWeights(:, meshRow, meshCol) = weights;
%         aberratedRows(:, meshRow, meshCol) = dvaInitMeshRow(meshRow, meshCol);
%         aberratedCols(:, meshRow, meshCol) = dvaInitMeshCol(meshRow, meshCol);
    end
end

if debugFlag % draw some picture of internal quantities
    
    figure;
    for i=1:nDvaMeshRows
        for j=1:nDvaMeshCols
            subplot(nDvaMeshRows, nDvaMeshCols, i+nDvaMeshRows*(j-1));
            scatter(aberratedRows(:,i,j), aberratedCols(:,i,j));
        end
    end    
    title('aberration motion');
end

% now fit a 2D polynomial of specified order to the aberrated data for each
% time sample
for t = 1:size(aberratedRows, 1)
    % pick out the data for this time
    abRow = squeeze(aberratedRows(t, :,:));
    abCol = squeeze(aberratedCols(t, :,:));
    abWeights = squeeze(aberratedWeights(t, :,:));
    % compute the polynomials, scaling the row, column coordinates to keep everything
    % nice
    dvaCoeffStruct.abRowPoly(t) = weighted_polyfit2d( ...
        dvaInitMeshRow(:)/nRowPix, dvaInitMeshCol(:)/nColPix, abRow(:), abWeights(:), dvaMeshOrder, 'standard');
    check_poly2d_struct(dvaCoeffStruct.abRowPoly(t), ...
        'TAD:compute_dva_motion:dvaCoeffStruct.abRowPoly:');
    dvaCoeffStruct.abColPoly(t) = weighted_polyfit2d( ...
        dvaInitMeshRow(:)/nRowPix, dvaInitMeshCol(:)/nColPix, abCol(:), abWeights(:), dvaMeshOrder, 'standard');
    check_poly2d_struct(dvaCoeffStruct.abColPoly(t), ...
        'TAD:compute_dva_motion:dvaCoeffStruct.abRowPoly:');
end
dvaCoeffStruct.sampleInterval = sampleInterval;

% fill in the result
coaObject.dvaCoeffStruct = dvaCoeffStruct;

