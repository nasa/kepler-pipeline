function [prfArray, prfRow, prfColumn] = display_quality( prfCollectionObject, ...
    row, column, resolution, reverse )
%
% display_quality -- produce diagnostic displays of a prfCollectionClass object
%
% [prfArray, prfRow, prfColumn] = display_quality( prfCollectionObject, row, column )
%    produces displays of the pixel response function, its gradient, and cross-sections at
%    the row and column location specified using the prfCollectionClass object.  
%
% [...] = display_quality( ..., resolution, reverse ) allows the user to specify
%    resolution and reversal of the displays.
%
% Version date:  2008-September-30.
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

% Modification History:
%
%     2008-September-30, PT:
%         use native prfClass method if appropriate.
%
%=========================================================================================

% set defaults 

if nargin < 4
    resolution = 400;
end

if nargin < 5
    reverse = 1;
end

if ( ~prfCollectionObject.interpolateFlag )
    
    switch nargin
        case {1,2,3}
            [prfArray, prfRow, prfColumn] = display_quality(prfCollectionObject.prfCenterObject) ;
        case 4 % optional resolution argument
            [prfArray, prfRow, prfColumn] = display_quality(prfCollectionObject.prfCenterObject,...
                resolution) ;
        case 5 % optional reverse argument
            [prfArray, prfRow, prfColumn] = display_quality(prfCollectionObject.prfCenterObject,...
                resolution,reverse) ;
        otherwise
            error('prf:prfCollectionClass:display_quality:invalidArgs', ...
                'prfCollectionClass:display_quality:  invalid arguments') ;
            
    end
    
else

    [prfArray, prfRow, prfColumn] = make_array(prfCollectionObject, row, column, ...
        resolution, reverse);
    flux = sum(sum(prfArray));

    % draw the array
    figure;
    mesh(prfRow, prfColumn, prfArray);
    title('nomalized pixel response function');
    xlabel('row pixel');
    ylabel('column pixel');
    axis tight;

    % draw the gradient
    deltaRow = prfRow(2, 1) - prfRow(1, 1);
    deltaCol = prfColumn(1, 2) - prfColumn(1, 1);
    figure;
    mesh(prfRow(1:end-1, 1:end-1), prfColumn(1:end-1, 1:end-1), ...
        (prfArray(2:end,1:end-1) - prfArray(1:end-1,1:end-1))/deltaRow ...
        + (prfArray(1:end-1,2:end) - prfArray(1:end-1,1:end-1))/deltaCol);
    title('gradient of nomalized pixel response function');
    xlabel('row pixel');
    ylabel('column pixel');
    axis tight;

    % take 1-dimensional high-resolution slices
    [rowSectionValues, rowSectionLocation] = cross_section( prfCollectionObject, 1, row, column );
    [colSectionValues, colSectionLocation] = cross_section( prfCollectionObject, 2, row, column );

    figure
    plot(rowSectionLocation, rowSectionValues, colSectionLocation, colSectionValues);
    legend('row cross section', 'column cross section');

    figure
    plot(rowSectionLocation(1:end-1), diff(rowSectionValues)/flux, ...
        colSectionLocation(1:end-1), diff(colSectionValues)/flux);
    legend('row cross section difference', 'column cross section difference');

    % show relation between evaluated PRF and centroid
    baseRow = row;
    baseCol = column;
    rowOffset = baseRow + 1*randn(1000,1);
    colOffset = baseCol + 1*randn(1000,1);
    for i=1:length(rowOffset)
        [pixelArray rowArray, columnArray] = evaluate(prfCollectionObject, rowOffset(i), ...
            colOffset(i));
        pixelArray(pixelArray < 1e-3) = 0;
        rowCentroid(i) = sum(rowArray(:).*pixelArray(:))/sum(sum(pixelArray));
        colCentroid(i) = sum(columnArray(:).*pixelArray(:))/sum(sum(pixelArray));
    end
    figure
    subplot(2, 2, 1);
    plot(rowOffset, rowCentroid, 'x');
    title('target row vs. centroid row');
    subplot(2, 2, 2);
    plot(colOffset, colCentroid, 'x');
    title('target col vs. centroid col');

    rowFit = polyfit(rowOffset(:), rowCentroid(:), 1);
    disp(['rowFit = ' num2str(rowFit)]);
    rowResidual = rowCentroid(:) - polyval(rowFit, rowOffset(:));

    colFit = polyfit(colOffset(:), colCentroid(:), 1);
    disp(['colFit = ' num2str(colFit)]);
    colResidual = colCentroid(:) - polyval(colFit, colOffset(:));

    subplot(2, 2, 3);
    plot(rowOffset(:), rowResidual(:), 'x');
    title('centroid row residual');
    subplot(2, 2, 4);
    plot(colOffset(:), colResidual(:), 'x');
    title('centroid col residual');

end % interpolateFlag conditional
