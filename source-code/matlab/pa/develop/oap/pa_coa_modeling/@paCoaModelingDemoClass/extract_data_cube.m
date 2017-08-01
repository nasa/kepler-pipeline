function [dataCube, apertureMask, optimalApertureMask] = ...
    extract_data_cube( pixelDataStruct, dataField, cadences )
%************************************************************************** 
% [dataCube, apertureMask] = ...
%     extract_data_cube( pixelDataStruct, dataField, cadences )
%************************************************************************** 
% 
% INPUTS
%     pixelDataStruct : A pixel data struct of the form found in PA input
%                       structures.
%     dataField       : A valid field name (string) specifying a data
%                       field in pixelDataStruct (e.g., 'uncertainties').
%     cadences        : An array of cadence indices in the range 
%                       [1, nCadences]. (default: 1:nCadences)
%
% OUTPUTS
%     dataCube        : An nRows-by-nColumns-by-nCadences matrix containing
%                       the requested data.
%     apertureMask    : A binary matrix labeling pixels inside (1) and
%                       outside (0) the target aperture.
%     optimalApertureMask 
%                     : A binary matrix labeling pixels inside (1) and
%                       outside (0) the optimal aperture.
%************************************************************************** 
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

    rows = [pixelDataStruct.ccdRow]';            % nPixels-by-1
    cols = [pixelDataStruct.ccdColumn]';         % nPixels-by-1
    data = [pixelDataStruct.(dataField)]';       % nPixels-by-nCadences
    oa   = [pixelDataStruct.inOptimalAperture]'; % nPixels-by-1
    
    % Prune cadences.
    if ~exist('cadences', 'var')
        cadences = 1:size(data, 2);
    end
    data = data(:, cadences);
    
    nCadences = length(cadences);
    nPixels   = size(rows);
    
    % Shift CCD positions to matrix coordinates.
    rows = rows - min(rows(:)) + 1;
    cols = cols - min(cols(:)) + 1;
    
    % Initialize value cube.
    dataCube    = zeros( max(rows), max(cols), nCadences );
    onesVector = ones( nPixels );
    
    % Populate value cube.
    for j = 1:nCadences
        dataCube( sub2ind(size(dataCube), rows, cols, j*onesVector) ) ...
            = data(:, j);
    end
    
    % Create a logical mask identifying valid aperture pixels.
    apertureMask = false( max(rows), max(cols));
    apertureMask(sub2ind(size(apertureMask), rows, cols)) = true;
    
    % Create a logical mask identifying optimal aperture pixels.
    optimalApertureMask = false( max(rows), max(cols));
    optimalApertureMask(sub2ind(size(apertureMask), rows(oa), cols(oa))) = true;
    
end

