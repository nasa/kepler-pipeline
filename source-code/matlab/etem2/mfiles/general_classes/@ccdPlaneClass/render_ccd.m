function ccdImage = render_ccd(ccdPlaneObject, ccdObject, cadenceRange, imageType)
%
% function ccdImage = render_ccd(ccdPlaneObject, ccdObject, cadenceRange, imageType)
%
% render the ccd image in the provided cadence range.  
% cadenceRange is the range of cadences to include in this image indexed
%   from 1 = first cadence.
% imageType: controls whether the rendered image is before saturation spill
% of after:
%   imageType = 'prePixelEffects' or 'pixelPoly' use the pre-saturation spill
%       polynomial in ccdPixelPolyFilename
%   imageType = 'finalImage' or 'pixelEffectPoly' use the post-saturation
%       spill polynomial in ccdPixelEffectPolyFilename
%
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

if nargin == 3
    imageType = 'finalImage';
end

runParamsObject = ccdPlaneObject.runParamsClass;
numCcdRows = get(runParamsObject, 'numCcdRows');
numCcdCols = get(runParamsObject, 'numCcdCols');
integrationTime = get(runParamsObject, 'integrationTime');
dvaMeshOrder = get(runParamsObject, 'dvaMeshOrder');
nCoefs = get(runParamsObject, 'nCoefs');
planeNumber = ccdPlaneObject.planeNumber;
endian = get(runParamsObject, 'endian');

motionGridRow = get(ccdObject, 'motionGridRow');
motionGridCol = get(ccdObject, 'motionGridCol');

% make smeared motion basis
% this average is multiplied by the integration time, after which it
% approximates the integral over time
for i=1:size(ccdPlaneObject.motionBasis, 1)
    for j=1:size(ccdPlaneObject.motionBasis, 2)   
%         meanMotionBasis(i,j).designMatrix = mean(...
%             ccdPlaneObject.motionBasis(i,j).designMatrix(cadenceRange,:), 1) ...
%             * integrationTime;
        meanMotionBasis(i,j).designMatrix = mean(...
            ccdPlaneObject.motionBasis(i,j).designMatrix(cadenceRange,:), 1);
    end
end

interpA = make_binned_design_matrix(motionGridCol(:)/numCcdCols, ...
    motionGridRow(:)/numCcdRows,dvaMeshOrder);
interpSolutionMatrix = (interpA'*interpA)\interpA'; % Precompute for convenience

% make evaluation mesh for all pixels
[ccdMeshCol, ccdMeshRow] = ...
    meshgrid((1:numCcdCols)/numCcdCols,(1:numCcdRows)/numCcdRows);

switch(imageType)
    case {'finalImage', 'pixelEffectPoly'}
        fid = fopen(ccdPlaneObject.ccdPixelEffectPolyFilename, 'r', endian);
    case {'prePixelEffects', 'pixelPoly'}
        fid = fopen(ccdPlaneObject.ccdPixelPolyFilename, 'r', endian);
    otherwise
        error('ccdPlaneClass:render_ccd:bad imageType');
end
        
ccdImage = zeros(numCcdRows, numCcdCols);

h = waitbar(0, ['rendering CCD plane ' num2str(planeNumber)]);

% fseek(fid, 4*numCcdRows*numCcdCols*nCoefs, 'bof');
for k = 1:nCoefs
    % Pull out the ith coefficient from the Ajitm_Cell array
    meanMotionBasisCoeff = zeros(size(meanMotionBasis));
    for r = 1:size(meanMotionBasis,1)
        for c = 1:size(meanMotionBasis,2)
            meanMotionBasisCoeff(r,c) = meanMotionBasis(r,c).designMatrix(k);
        end
    end

    % fit polynomial to grid points in Ajit_Coeff_i
    ccdMotionBasisCoef = interpSolutionMatrix * meanMotionBasisCoeff(:);
    ccdMotionBasisTerm = eval2Dpoly(ccdMotionBasisCoef, ccdMeshCol, ccdMeshRow, dvaMeshOrder);

    % Add the product of the pixel coefficients multiplied by the jitter time series mean
    % to the running total mean image.
    coefficientPlane = fread(fid, [numCcdRows numCcdCols], 'float32');
    ccdImage = ccdImage ...
        + coefficientPlane .* ccdMotionBasisTerm;
%     figure; 
%     plot(ccdImage(61,:));
%     title(['coef ' num2str(k)]);
    waitbar(k/nCoefs);

end
fclose(fid);
close(h);

figure;
imagesc(ccdImage, [0,1e7]);
colormap hot(256);
colorbar;
title(['ccd plane ' num2str(planeNumber)]);

function val = eval2Dpoly(c, x, y, m)
% function val = eval2Dpoly(c, x, y, m)
%
% Evaluates the mth order 2-D polynomial specified by coefficient array c for offsets 
% in arrays x and y. The polynomial is assumed to be constructed as in makeA2D.
%


val = 0; %initialize

x_1         = x;
x_1(x_1==0) = 1;
x_1         = x_1.^-1;

% k indexes the column of Ajit that is a product of specified columns of X and Y
k = 0;
for i = 0:m
    xi = x.^(i+1);
    yj = ones(size(y));
    for j = 0:i

        % Next index
        k = k+1;

        % Product of X and Y
        %xiyj = x.^(i-j) .*y.^j;
        xi   = xi .* x_1;
        xiyj = xi .* yj;

        % Finally, evaluate the current polynomial term and add it to the
        % running sum
        val = val + c(k) * xiyj;
 
        yj = y .* yj; % increment for next pass

    end
end

