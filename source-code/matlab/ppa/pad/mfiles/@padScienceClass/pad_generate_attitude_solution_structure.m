function [attitudeSolutionStruct] = pad_generate_attitude_solution_structure(padScienceObject, raDec2PixObject, pointingObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [attitudeSolutionStruct] = pad_generate_attitude_solution_structure(padScienceObject, raDec2PixObject, pointingObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This method generates the attitudeSolutionStruct, which is the input  
% of PAD attitude reconstruction method 'pad_attitude_solution'.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Inputs:
%
%                padScienceObject: [object]  object of padScienceClass
%                 raDec2PixObject: [object]  object of raDec2PixModel
%                  pointingObject: [object]  object of pointing model
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Output:
%
%    attitudeSolutionStruct: [struct array]  data structure of target stars
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%    attitudeSolutionStruct is an array of structs with following fields:
%
%                    raStars: [float array]  ra  of target stars
%                   decStars: [float array]  dec of target stars
%                    ccdModule: [int array]  ccd module number of measured target stars
%                    ccdOutput: [int array]  ccd output number of measured target stars
%               centroidRows: [float array]  row    of centroids of measured target stars
%            centroidColumns: [float array]  column of centroids of measured target stars
%               CcentroidRow: [float array]  covariance matrix of row    of centroids of measured target stars
%             centroidColumn: [float array]  covariance matrix of column of centroids of measured target stars
%            nominalPointing: [float array]  nominal pointing data
%                      cadenceTime: [float]  timestamp of the cadence
%       
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Retrieve module/output number and cadence times from padScienceObject
nChannels     = padScienceObject.fcConstants.MODULE_OUTPUTS;
cadenceTimes  = padScienceObject.cadenceTimes.midTimestamps;
nCadences     = length(cadenceTimes);

% Clean cadence times
cadenceTimesCleaned = cadenceTimes(~padScienceObject.cadenceTimes.gapIndicators);
nCadencesCleaned    = length(cadenceTimesCleaned);
if ( nCadencesCleaned == 0 )
    error('PAD:padScienceClass:generateAttitudeSolutionStructure', 'No valid cadence time in padInputStruct.cadenceTimes');
end
midCadenceTime = cadenceTimesCleaned(floor((nCadencesCleaned+1)/2) );

% Retrieve nominal pointing model
midNominalPointing  = get_pointing( pointingObject, midCadenceTime );
midRaPointing       = midNominalPointing(1);
midDecPointing      = midNominalPointing(2);
midRollPointing     = midNominalPointing(3);

% Retrieve grid parameters from padScienceObject
gridRowStart     = padScienceObject.padModuleParameters.gridRowStart;
%gridRowStep      = padScienceObject.padModuleParameters.gridRowStep;
gridRowEnd       = padScienceObject.padModuleParameters.gridRowEnd;
gridRowMid       = round( 0.5*(gridRowStart + gridRowEnd) );

gridColStart     = padScienceObject.padModuleParameters.gridColStart;
%gridColStep      = padScienceObject.padModuleParameters.gridColStep;
gridColEnd       = padScienceObject.padModuleParameters.gridColEnd;
gridColMid       = round( 0.5*(gridColStart + gridColEnd) );

% Define a set of fake target stars on a 3x3 grid within each module/output
gridRowVector    = [gridRowStart gridRowMid gridRowEnd];
gridColVector    = [gridColStart gridColMid gridColEnd];
[rowRef, colRef] = ndgrid(gridRowVector, gridColVector);
rowRef           = rowRef(:);
colRef           = colRef(:);
ovec             = ones(size(rowRef));

% Allocate memory for raStars, decStars, ccdModule, ccdOutput
nStarModOut = length(rowRef);
nStars      = nStarModOut*nChannels;

raStars   = -1*ones(nStars, 1);
decStars  = -1*ones(nStars, 1);
ccdModule = -1*ones(nStars, 1);
ccdOutput = -1*ones(nStars, 1);

% Loop over each module/output and determine (ra, dec) pairs of each fake target star
aberrateFlag = 1;
for iChannel = 1 : nChannels
    
    % Get the pair (modRef, outRef) from the channel number
    [modRef, outRef] = convert_to_module_output(iChannel);

    % The pair (raRef, decRef)  star are determined with method pix_2_ra_dec_absolute()
    % from nominal pointing model
    [raRef, decRef] = pix_2_ra_dec_absolute(raDec2PixObject, modRef*ovec, outRef*ovec, rowRef, colRef, midCadenceTime, ...
        midRaPointing, midDecPointing, midRollPointing, aberrateFlag);

    % Copy modRef, outRef, raRef, decRef into raStars, decStars, ccdModule
    % and ccdOutput respectively
    index = (iChannel-1)*nStarModOut + (1:nStarModOut);
    raStars(index, 1)   = raRef(:);
    decStars(index, 1)  = decRef(:);
    ccdModule(index, 1) = modRef*ovec;
    ccdOutput(index, 1) = outRef*ovec;

end

% Allocate memory for output structure
s.raStars            = -1*ones(nStars, 1);
s.decStars           = -1*ones(nStars, 1);
s.ccdModule          = -1*ones(nStars, 1);
s.ccdOutput          = -1*ones(nStars, 1);
s.centroidRows       = -1*ones(nStars, 1);
s.centroidColumns    = -1*ones(nStars, 1);
s.CcentroidRow       = -1*ones(nStars, nStars);
s.CcentroidColumn    = -1*ones(nStars, nStars);
s.nominalPointing    = -1*ones(3, 1);
s.cadenceTime        = -1;

attitudeSolutionStruct = repmat(s, 1, nCadences);

% Loop over all cadences
for iCadence = 1:nCadences

    if( padScienceObject.cadenceTimes.gapIndicators(iCadence) )
        disp(['PAD:generateAttitudeSolutionStructure: attitudeSolutionStruct is unavailable due to a gap in cadenceTimes for this cadence ' num2str(iCadence)]);
        continue;
    end

    % Allocate memory for row, col, rowUncertainty, colUncertainty
    row  = -1*ones(nStars, 1);
    col  = -1*ones(nStars, 1);
    Crow = zeros(nStars, nStars);
    Ccol = zeros(nStars, nStars);

    for iChannel = 1:nChannels

        % Rows/columns are calculated only when statuses of rowPoly and colPoly are good
        if ( padScienceObject.motionPolyStruct(iChannel, iCadence).rowPolyStatus && ...
                padScienceObject.motionPolyStruct(iChannel, iCadence).colPolyStatus )

            % Determine minimum number of coefficients in motion polynomials of row and column
            rowPolyCovariance   = padScienceObject.motionPolyStruct(iChannel, iCadence).rowPoly.covariance;
            colPolyCovariance   = padScienceObject.motionPolyStruct(iChannel, iCadence).colPoly.covariance;
            minPolyCoefficients = min(length(rowPolyCovariance), length(colPolyCovariance));

            if ( minPolyCoefficients > 0 )

                % Fake target stars are selected from the 3x3 grid based on the orders of row/column motion polynomials
                if ( minPolyCoefficients < 3 )
                    index = (iChannel-1)*nStarModOut + 5;
                elseif ( minPolyCoefficients < 6 )
                    index = (iChannel-1)*nStarModOut + [2 5 6]';
                elseif ( minPolyCoefficients < 9 )
                    index = (iChannel-1)*nStarModOut + [1 2 3 4 7 9]';
                else
                    index = (iChannel-1)*nStarModOut + [1 2 3 4 5 6 7 8]';
                end


                % Rows/columns of centroids and corresponding uncertainties are determined by evaluating motion polynomials.
                [ rowBuf, rowUncertaintyIgnored, designMatrixRow ] = ...
                    weighted_polyval2d(raStars(index,1), decStars(index,1), padScienceObject.motionPolyStruct(iChannel, iCadence).rowPoly);
                [ colBuf, colUncertaintyIgnored, designMatrixCol ] = ...
                    weighted_polyval2d(raStars(index,1), decStars(index,1), padScienceObject.motionPolyStruct(iChannel, iCadence).colPoly);

                % Copy results to row, col, Crow, Ccol
                % Note:     row  = designMatrixRow * rowPoly.coeff
                %           Crow = designMatrixRow * rowPoly.covariance * designMatrixRow'
                %           col  = designMatrixCol * colPoly.coeff
                %           Ccol = designMatrixCol * colPoly.covariance * designMatrixCol'
                row(index, 1)      = rowBuf;
                col(index, 1)      = colBuf;
                Crow(index, index) = designMatrixRow * rowPolyCovariance * designMatrixRow';
                Ccol(index, index) = designMatrixCol * colPolyCovariance * designMatrixCol';

            end

        end

    end

    % Retrieve nominal pointing model at the specified cadence time
    if ~padScienceObject.cadenceTimes.gapIndicators(iCadence)
        nominalPointing  = get_pointing( pointingObject, cadenceTimes(iCadence));
    else
        nominalPointing = midNominalPointing;
    end

    indexValid = find( row~=-1 & col~=-1 );

    % Copy the data into the output structure array
    attitudeSolutionStruct(1, iCadence).raStars         = raStars(indexValid);
    attitudeSolutionStruct(1, iCadence).decStars        = decStars(indexValid);
    attitudeSolutionStruct(1, iCadence).ccdModule       = ccdModule(indexValid);
    attitudeSolutionStruct(1, iCadence).ccdOutput       = ccdOutput(indexValid);
    attitudeSolutionStruct(1, iCadence).centroidRows    = row(indexValid);
    attitudeSolutionStruct(1, iCadence).centroidColumns = col(indexValid);
%   attitudeSolutionStruct(1, iCadence).CcentroidRow    = Crow(indexValid, indexValid);
%   attitudeSolutionStruct(1, iCadence).CcentroidColumn = Ccol(indexValid, indexValid);

    % Set the covariance matrices diagonal. Changed on 07/17/2009
    diagCrow = diag( Crow(indexValid, indexValid) );
    diagCcol = diag( Ccol(indexValid, indexValid) );
    attitudeSolutionStruct(1, iCadence).CcentroidRow    = diag( diagCrow );
    attitudeSolutionStruct(1, iCadence).CcentroidColumn = diag( diagCcol );

    attitudeSolutionStruct(1, iCadence).nominalPointing = nominalPointing(:);
    attitudeSolutionStruct(1, iCadence).cadenceTime     = cadenceTimes(iCadence);

end

return
