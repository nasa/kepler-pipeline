function [reconstructedRowMotionPolynomial, reconstructedColumnMotionPolynomial, ancillaryDataStruct] = ...
    extract_polynomial_from_reconstructed_motion(ancillaryDataStruct, parameters)
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


gridRows = parameters.gridRows;
gridColumns = parameters.gridColumns;
gridSize = parameters.gridSize;
nCadences = parameters.nCadences;

cadenceTimes = parameters.cadenceTimesJD;



ccdModule = parameters.ccdModule;
ccdOutput = parameters.ccdOutput;
indexOfBoresightAttitude = parameters.indexOfBoresightAttitude;




boresightRaTimeSeries = ancillaryDataStruct(indexOfBoresightAttitude).values(:,1);
boresightDecTimeSeries = ancillaryDataStruct(indexOfBoresightAttitude).values(:,2);
boresightRollTimeSeries = ancillaryDataStruct(indexOfBoresightAttitude).values(:,3);

attitudeCovMatrix = ancillaryDataStruct(indexOfBoresightAttitude).uncertainties;

%----------------------------------------------------------------------
% to store the motion time series generated at every grid point in the
% ancillary data struct itself
%----------------------------------------------------------------------
aberratedGridRows = zeros(nCadences, gridSize*gridSize);
aberratedGridColumns = zeros(nCadences, gridSize*gridSize);



[meshGridRows, meshGridColumns] = meshgrid(gridRows, gridColumns);
meshGridRows = meshGridRows(:);
meshGridColumns = meshGridColumns(:);
lengthOfMeshGrid = length(meshGridRows);
ccdModules = repmat(ccdModule,lengthOfMeshGrid,1); % Pix2RaDec requires that this be a vector.
ccdOutputs = repmat(ccdOutput,lengthOfMeshGrid,1);






doDva = 0; % not a boolean
% just one invocation of Pix2RaDec
[gridPixelsUnaberratedRa, gridPixelsUnaberratedDec] = ...
    Pix2RaDec(ccdModules, ccdOutputs, meshGridRows, meshGridColumns, cadenceTimes(1), doDva);







doDva = 1; % aberrate RA, Dec of each grid point

for jGridPoint = 1:lengthOfMeshGrid

    fprintf('reconstructing motion for row = %d, col = %d\n', meshGridRows(jGridPoint), meshGridColumns(jGridPoint));

    [sameModules, sameOutputs, aberratedRowPositions, aberratedColumnPositions] = ...
        RaDec2Pix(gridPixelsUnaberratedRa(jGridPoint), gridPixelsUnaberratedDec(jGridPoint), cadenceTimes, ...
        boresightRaTimeSeries, boresightDecTimeSeries,  boresightRollTimeSeries, doDva);

    aberratedGridRows(:,jGridPoint) = aberratedRowPositions;

    aberratedGridColumns(:,jGridPoint) = aberratedColumnPositions;

end
% 
% now fit a 2D polynomial of specified order to the aberrated data for each
% time sample

%load temp.mat


polyOrder = parameters.reconstructMotionPolynomialOrder;
%-----------------------------------------------------------------------

doDvaFlag = 1;

for iCadence = 1:nCadences

    fprintf(' cadence %d\n', iCadence);

    % pick out the data for this time
    abRow = aberratedGridRows(iCadence,:);
    abCol = aberratedGridColumns(iCadence,:);
    % compute the polynomials, scaling the row, column coordinates to keep everything
    % nice
    ra0 = boresightRaTimeSeries(iCadence);
    dec0 = boresightDecTimeSeries(iCadence);
    phi0 = boresightRollTimeSeries(iCadence);

    [Trow, Tcol] = get_jacobian_of_rowcol_wrt_spacecraft_attitude(meshGridRows, meshGridColumns, gridPixelsUnaberratedRa, gridPixelsUnaberratedDec,...
        doDvaFlag, ra0, dec0, phi0, cadenceTimes(iCadence));

    if(iCadence ==1 )
        
        % row
        [polyFitOutputStruct, designMatrix] = weighted_polyfit2d( meshGridRows, meshGridColumns, abRow(:), 1, polyOrder, 'standard');

        reconstructedRowMotionPolynomial = repmat(polyFitOutputStruct, nCadences, 1);

        reconstructedRowMotionPolynomial(iCadence) = polyFitOutputStruct;

        check_poly2d_struct(reconstructedRowMotionPolynomial(iCadence),'PA:OAP:extract_polynomial_from_reconstructed_motion:RowPoly:');

        % replace covariance matrix of uncertainties
        Cpoly2d = reconstructedRowMotionPolynomial(iCadence).covariance;
        Tpoly2d = Cpoly2d*designMatrix';
        
        
        reconstructedRowMotionPolynomial(iCadence).covariance  = Tpoly2d * Trow * attitudeCovMatrix(:,:,iCadence)* Trow' * Tpoly2d';
        
        % column 
        polyFitOutputStruct = weighted_polyfit2d( meshGridRows, meshGridColumns, abCol(:), 1, polyOrder, 'standard');
        
        reconstructedColumnMotionPolynomial = repmat(polyFitOutputStruct,nCadences,1);
        
        reconstructedColumnMotionPolynomial(iCadence) = polyFitOutputStruct;

        check_poly2d_struct(reconstructedColumnMotionPolynomial(iCadence),'PA:OAP:extract_polynomial_from_reconstructed_motion:ColumnPoly:');
        
        reconstructedColumnMotionPolynomial(iCadence).covariance  = Tpoly2d * Tcol * attitudeCovMatrix(:,:,iCadence)* Tcol' * Tpoly2d';
        

    else

        [reconstructedRowMotionPolynomial(iCadence), designMatrix] = weighted_polyfit2d( meshGridRows, meshGridColumns, abRow(:), 1, polyOrder, 'standard');

        check_poly2d_struct(reconstructedRowMotionPolynomial(iCadence),'PA:OAP:extract_polynomial_from_reconstructed_motion:RowPoly:');

        Cpoly2d = reconstructedRowMotionPolynomial(iCadence).covariance;
        Tpoly2d = Cpoly2d*designMatrix';
        
        reconstructedRowMotionPolynomial(iCadence).covariance  = Tpoly2d * Trow * attitudeCovMatrix(:,:,iCadence)* Trow' * Tpoly2d';


        
        reconstructedColumnMotionPolynomial(iCadence) = weighted_polyfit2d( meshGridRows, meshGridColumns, abCol(:), 1, polyOrder, 'standard');
        
        check_poly2d_struct(reconstructedColumnMotionPolynomial(iCadence),'PA:OAP:extract_polynomial_from_reconstructed_motion:ColumnPoly:');

        reconstructedColumnMotionPolynomial(iCadence).covariance  = Tpoly2d * Tcol * attitudeCovMatrix(:,:,iCadence)* Tcol' * Tpoly2d';

    end
end


return





% row position of any target star on the ccd is a function of ra,dec (sky
% coordinates), time (spacecraft velocity)
% same is true of column position as well.


function [Trow, Tcol] = get_jacobian_of_rowcol_wrt_spacecraft_attitude(meshGridRows, meshGridColumns, gridPixelsUnaberratedRa, gridPixelsUnaberratedDec, doDvaFlag, ra0, dec0, phi0, julianTime)

% set up offsets in ra, dec and phi
deltaRa = 1/3600; % 1 arcsec
deltaDec = 1/3600; 
deltaPhi = 1/3600;

% get initial pixel positions of stars in this frame
%[mm,oo,row,col] = RaDec2Pix(aberRa,aberDec,season,ra0,dec0,phi0);

row = meshGridRows;
col = meshGridColumns;


% get positions for offsets in each attitude element
[mm,oo,rowdRa,coldRa] = RaDec2Pix(gridPixelsUnaberratedRa, gridPixelsUnaberratedDec,julianTime, ra0+deltaRa, dec0, phi0, doDvaFlag);

[mm,oo,rowdDec,coldDec] = RaDec2Pix(gridPixelsUnaberratedRa, gridPixelsUnaberratedDec,julianTime, ra0, dec0+deltaDec, phi0, doDvaFlag);

[mm,oo,rowdPhi,coldPhi] = RaDec2Pix(gridPixelsUnaberratedRa, gridPixelsUnaberratedDec,julianTime, ra0, dec0, phi0+deltaPhi, doDvaFlag);

% form coefficients of linearized attitude

% terms in the Jacobian

rRa = (rowdRa-row)/deltaRa;
rDec = (rowdDec-row)/deltaDec;
rPhi = (rowdPhi-row)/deltaPhi;

cRa = (coldRa-col)/deltaRa;
cDec = (coldDec-col)/deltaDec;
cPhi = (coldPhi-col)/deltaPhi;


% set up design matrix A, and residual data array b
Trow = [rRa,rDec,rPhi];
Tcol = [cRa,cDec,cPhi]; % 50 x 3 matrix for a grid size of 5 x 5

return
