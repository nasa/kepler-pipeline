function outputStruct = package_ee_pixel_data( iCadence, eeTempStruct )
%
% function outputStruct = package_ee_pixel_data( iCadence, eeTempStruct )
%
% Repackage data from eeTempStruct.targetStar into single arrays; pixFlux,
% Cpixflux, radius, row, col. startTarget and stopTarget are nTarget x 1
% arrays where entry i contains the index in pixFlux, Cpixflux, row and col
% where data for target i starts and stops. okTarget is the valid target
% count + 1. These arrays are packaged as fields of the outputStruct.
%
% INPUT:    iCadence     = cadence index; int
%           eeTempStruct = data structure as defined in encircledEnergy.m
% OUTPUT:   outputStruct = data structure with the following fields:
%               .pixFlux         = nx1 array, pixel data from all targets
%               .Cpixflux        = nx1 array, uncertainties of PixFlux or nxn covariance matix
%               .radius          = nx1 array, distance in pixels from corresponding target centroid for each pixel
%               .row             = nx1 array, pixel row coordinate
%               .col             = nx1 array, pixel column coordinate
%               .startTarget     = nTargetx1 array, starting index in nx1 arrays for target
%               .stopTarget      = nTargetx1 array, ending index in nx1 arrays for target
%               .expectedFlux    = nTargetsx1 array containing the expected flux for each target
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

numTarget = length(eeTempStruct.targetStar);

MAX_PIXELS = eeTempStruct.encircledEnergyStruct.MAX_PIXELS;

% pre allocate array space
pixFlux         = zeros(numTarget * MAX_PIXELS, 1);
radius          = zeros(numTarget * MAX_PIXELS, 1);
row             = zeros(numTarget * MAX_PIXELS, 1);
col             = zeros(numTarget * MAX_PIXELS, 1);
startTarget     = zeros(numTarget,1);
stopTarget      = zeros(numTarget,1);

expectedFlux    = [eeTempStruct.targetStar.expectedFlux];
expectedFlux    = expectedFlux(:);

% handle covariance as a special case of uncertainties
% if they are scalar uncertainties, allocate vector large enough for
% MAX values - use first target index as indicator
if(isvector(eeTempStruct.targetStar(1).cadence(iCadence).Cpixflux))
    Cpixflux    = zeros(numTarget * MAX_PIXELS, 1);
else
% they are covariance matrices, initialize stacked matrix as empty
    Cpixflux = spalloc(numTarget * MAX_PIXELS, numTarget * MAX_PIXELS, numTarget * MAX_PIXELS^2);
end

    
% get pixel, uncertainty, row, col and radius data for each target and stack in arrays
iStore = 1;
okTarget = 1;
iTarget = 1;
while(iTarget <= numTarget)

    % select only pixels without gaps at the pixel level
    ungappedPixels = find(eeTempStruct.targetStar(iTarget).cadence(iCadence).gapFlag == 0);
    
    % get length of pixel data
    nPixRow = length(ungappedPixels);

    % if not on gap list at the target level and there exists at least one ungapped pixel
    if( ~ismember(iCadence,eeTempStruct.targetStar(iTarget).gapList) && nPixRow > 0 ) 

        % mark target start and stop indices, store expected flux
        jStore                  = iStore+nPixRow-1;
        startTarget(okTarget)   = iStore;
        stopTarget(okTarget)    = jStore;
        expectedFlux(okTarget)  = eeTempStruct.targetStar(iTarget).expectedFlux;

        % store data and advance counter iStore            
        pixFlux(iStore:jStore)   = eeTempStruct.targetStar(iTarget).cadence(iCadence).pixFlux(ungappedPixels);
        radius(iStore:jStore)    = eeTempStruct.targetStar(iTarget).cadence(iCadence).radius(ungappedPixels);
        row(iStore:jStore)       = eeTempStruct.targetStar(iTarget).cadence(iCadence).row(ungappedPixels);
        col(iStore:jStore)       = eeTempStruct.targetStar(iTarget).cadence(iCadence).col(ungappedPixels); 

        % If Cpixflux are uncertainties, stack in vector
        if(isvector(eeTempStruct.targetStar(1).cadence(iCadence).Cpixflux)) 
            Cpixflux(iStore:jStore)  = ...
                eeTempStruct.targetStar(iTarget).cadence(iCadence).Cpixflux(ungappedPixels);
        else
        % If they are covariance matrices, stack in block diagonal matrix
            Cpixflux( iStore:jStore, iStore:jStore )= ...
                eeTempStruct.targetStar(iTarget).cadence(iCadence).Cpixflux(ungappedPixels,ungappedPixels);            
        end

        iStore      = jStore + 1;                    % increment current position
        okTarget    = okTarget + 1;                  % increment valid target count        
    end
    
    iTarget = iTarget+1;
end

% release unused pre allocated space and build output structure
outputStruct.pixFlux         = pixFlux(1:iStore-1);                  
outputStruct.radius          = radius(1:iStore-1);
outputStruct.row             = row(1:iStore-1);
outputStruct.col             = col(1:iStore-1);
outputStruct.startTarget     = startTarget(1:okTarget-1);
outputStruct.stopTarget      = stopTarget(1:okTarget-1);

outputStruct.expectedFlux    = expectedFlux;
outputStruct.okTarget        = okTarget-1;

if(isvector(Cpixflux))
    outputStruct.Cpixflux = Cpixflux(1:iStore-1);
else
    outputStruct.Cpixflux = Cpixflux(1:iStore-1, 1:iStore-1);
   
    % Check that the covaraince matrix is positive defintite by checking
    % that all eigenvalues are greater than zero. If any are negative,
    % reduce CpixFlux to a vector of uncertainties by taking the square 
    % root of the absolute value of the diagonal and throw warning.
    if( any(eig(outputStruct.Cpixflux) <= 0 ) )
        outputStruct.Cpixflux = sqrt( abs( diag(outputStruct.Cpixflux) ) );
        warning(['PA:',mfilename,':Covariance matrix is not positive definite. '], ...
        'Setting pixel flux variance to abs(diag(Cx))');
    end
end

 