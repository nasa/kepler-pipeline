function [padOutputStruct, nominalPointingStruct] = pad_attitude_solution(padScienceObject, attitudeSolutionStruct, padOutputStruct, raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [padOutputStruct, nominalPointingStruct] = pad_attitude_solution(padScienceObject, attitudeSolutionStruct, padOutputStruct, raDec2PixObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% This method, modified from attitude_solution in pdqScienceClass, determines
% reconstructed attitude solution. It saves reults in attitudeSolution field 
% of padOutputStruct.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Inputs:
%
%         padScienceObject: [object]  object of padScienceClass
%   attitudeSolutionStruct: [struct]  data structure of target stars
%          padOutputStruct: [struct]  PAD output struct with default values
%          raDec2PixObject: [object]  object of raDec2PixModel
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%    attitudeSolutionStruct is an array of structs with following fields:
%
%             raStars: [float array]  ra  of target stars
%            decStars: [float array]  dec of target stars
%             ccdModule: [int array]  ccd module number of measured target stars
%             ccdOutput: [int array]  ccd output number of measured target stars
%        centroidRows: [float array]  row    of centroids of measured target stars
%     centroidColumns: [float array]  column of centroids of measured target stars
%        CcentroidRow: [float array]  covariance matrix of row    of centroids of measured target stars
%      centroidColumn: [float array]  covariance matrix of column of centroids of measured target stars
%     nominalPointing: [float array]  nominal pointing data
%               cadenceTime: [float]  timestamp of the cadence
%       
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Outputs:
%
%          padOutputStruct: [struct]  PAD output struct with updated data in attitudeSolution field
%    nominalPointingStruct: [struct]  nominal pointing structure
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%     padOutputStruct is a struct with following fields:
%
%               attitudeSolution: [struct]  reconstructed attitude solution
%                         report: [struct]  report of delta attitude solution
%                 reportFilename: [String]  filename of report
%
%     padOutputStruct.attitudeSolution is a struct with following fields:
%
%                                 ra: [double array]  time series of ra
%                                dec: [double array]  time series of dec
%                               roll: [double array]  time series of roll
%                  covarianceMatrix11: [float array]  time series of covariance matrix element (1,1) 
%                  covarianceMatrix22: [float array]  time series of covariance matrix element (2,2) 
%                  covarianceMatrix33: [float array]  time series of covariance matrix element (3,3) 
%                  covarianceMatrix12: [float array]  time series of covariance matrix element (1,2) 
%                  covarianceMatrix13: [float array]  time series of covariance matrix element (1,3) 
%                  covarianceMatrix23: [float array]  time series of covariance matrix element (2,3) 
%       maxAttitudeFocalPlaneResidual: [float array]  time series of maximum attitude focal plane residual error
%                     gapIndicators: [logical array]  gap indicators of attitude solution time series 
%
%--------------------------------------------------------------------------
%     nominalPointingStruct is a struct with following fields:
%
%                                ra: [double array]  time series of ra
%                               dec: [double array]  time series of dec
%                              roll: [double array]  time series of roll
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


% Get number of cadences
numCadences      = length(attitudeSolutionStruct);

% Get debugLevel
debugLevel       = padScienceObject.padModuleParameters.debugLevel;

% allocate memory for nominalPointingRa, nominalPointingDec and nominalPointingRoll
nominalPointingStruct.ra   = -1*ones(numCadences, 1);
nominalPointingStruct.dec  = -1*ones(numCadences, 1);
nominalPointingStruct.roll = -1*ones(numCadences, 1);

% Loop over all cadences present in the data
for cadenceIndex = 1 : numCadences

    if( padScienceObject.cadenceTimes.gapIndicators(cadenceIndex) )
%         warning('PAD:attitudeSolution:notEnoughCentroids', ...
%             ['attitudeSolution is unavailable due to a gap in cadenceTimes for this cadence ' num2str(cadenceIndex)]);
        disp(['PAD:attitudeSolution: attitudeSolution is unavailable due to a gap in cadenceTimes for this cadence ' num2str(cadenceIndex)]);
        continue;
    end

    %----------------------------------------------------------------------
    % Step 1: Obtain attitude of nominal pointing 
    %----------------------------------------------------------------------
    fovCenter       = attitudeSolutionStruct(cadenceIndex).nominalPointing;
    boreSightRa     = fovCenter(1);
    boreSightDec    = fovCenter(2);
    boreSightRoll   = fovCenter(3);
    
    nominalPointingStruct.ra(cadenceIndex, 1)   = boreSightRa;
    nominalPointingStruct.dec(cadenceIndex, 1)  = boreSightDec;
    nominalPointingStruct.roll(cadenceIndex, 1) = boreSightRoll;
  
    %----------------------------------------------------------------------
    % Step 2: Collect the sky coordinates (Ra and Dec) and the measured 
    % centroidRows and centroidColumns for all fake target stars on all modouts
    %----------------------------------------------------------------------
    centroidRows    = attitudeSolutionStruct(cadenceIndex).centroidRows;
    centroidColumns = attitudeSolutionStruct(cadenceIndex).centroidColumns;


    if(length(centroidRows) <= 2)
%         warning('PAD:attitudeSolution:notEnoughCentroids', ...
%             ['attitudeSolution: only ' num2str(length(centroidRows)) ' targets available; not enough to compute attitude solution for this cadence ' num2str(cadenceIndex)]);
        disp(['PAD:attitudeSolution: only ' num2str(length(centroidRows)) ...
              ' targets available; not enough to compute attitude solution for this cadence ' num2str(cadenceIndex)]);
        continue;
    end

    raStars          = attitudeSolutionStruct(cadenceIndex).raStars;
    decStars         = attitudeSolutionStruct(cadenceIndex).decStars;
    cadenceTimeStamp = attitudeSolutionStruct(cadenceIndex).cadenceTime;

    %----------------------------------------------------------------------
    % Step 3: Abberate the real position of each fake target star to the apparent position
    %----------------------------------------------------------------------
    cadenceTimeStampInJulian    = cadenceTimeStamp + padScienceObject.raDec2PixModel.mjdOffset;
    [raStarsAber  decStarsAber] = aberrate_ra_dec(raDec2PixObject, raStars, decStars, cadenceTimeStampInJulian);
    raStarsAber  = raStarsAber(:);
    decStarsAber = decStarsAber(:);

    tic;

    %----------------------------------------------------------------------
    % Step 4: Run iterate_attitude_solution_using_robust_fit() to obtain attitude solution and also run
    % iterate_attitude_solution_using_nlinfit to obtain another solution; keep the better of the two.
    %----------------------------------------------------------------------

    CcentroidColumnBuf = attitudeSolutionStruct(cadenceIndex).CcentroidColumn;
    CcentroidRowBuf    = attitudeSolutionStruct(cadenceIndex).CcentroidRow;
    CcentroidColumn    = 0.5 * ( CcentroidColumnBuf + CcentroidColumnBuf' );
    CcentroidRow       = 0.5 * ( CcentroidRowBuf    + CcentroidRowBuf'    );
    dvaFlag            = 0;

    %     [boreSightRaNew, boreSightDecNew, boreSightRollNew, attitudeError, CdeltaAttitudes] = ...
    %         iterate_attitude_solution_using_chisquare_fit(raDec2PixObject,raStarsAber, decStarsAber ,centroidRows, centroidColumns,...
    %         CcentroidRow, CcentroidColumn,     boreSightRa, boreSightDec, boreSightRoll, cadenceTimeStamp, dvaFlag);

    [boreSightRaLinFit, boreSightDecLinFit, boreSightRollLinFit, attitudeErrorLinFit, CdeltaAttitudesLinFit] = ...
        iterate_attitude_solution_using_robust_fit(raDec2PixObject,raStarsAber, decStarsAber ,centroidRows, centroidColumns,...
        CcentroidRow, CcentroidColumn, boreSightRa, boreSightDec, boreSightRoll, cadenceTimeStamp, dvaFlag);

    boreSightRa   = boreSightRaLinFit;
    boreSightDec  = boreSightDecLinFit;
    boreSightRoll = boreSightRollLinFit;

    [boreSightRaNew, boreSightDecNew, boreSightRollNew, attitudeError, CdeltaAttitudes] = ...
        iterate_attitude_solution_using_nlinfit(raDec2PixObject,raStarsAber, decStarsAber, centroidRows, centroidColumns,...
        CcentroidRow, CcentroidColumn, boreSightRa, boreSightDec, boreSightRoll, cadenceTimeStamp, dvaFlag);

    if ( debugLevel>0 || round(0.01*cadenceIndex)==0.01*cadenceIndex )
        disp(sprintf(['Cadence: ' int2str(cadenceIndex) '  RA = %9.5f Dec = %9.5f Roll = %9.5f attitudeError = %9.5f'], ...
            boreSightRaNew, boreSightDecNew, boreSightRollNew, attitudeError));
    end
    
    %----------------------------------------------------------------------
    % Step 5: Copy results in padOutputStruct.attitudeSolution
    %----------------------------------------------------------------------

    padOutputStruct.attitudeSolution.ra(cadenceIndex)                   = boreSightRaNew;
    padOutputStruct.attitudeSolution.dec(cadenceIndex)                  = boreSightDecNew;
    padOutputStruct.attitudeSolution.roll(cadenceIndex)                 = boreSightRollNew;
    
    padOutputStruct.attitudeSolution.covarianceMatrix11(cadenceIndex)   = CdeltaAttitudes(1,1);
    padOutputStruct.attitudeSolution.covarianceMatrix22(cadenceIndex)   = CdeltaAttitudes(2,2);
    padOutputStruct.attitudeSolution.covarianceMatrix33(cadenceIndex)   = CdeltaAttitudes(3,3);
    padOutputStruct.attitudeSolution.covarianceMatrix12(cadenceIndex)   = CdeltaAttitudes(1,2);
    padOutputStruct.attitudeSolution.covarianceMatrix13(cadenceIndex)   = CdeltaAttitudes(1,3);
    padOutputStruct.attitudeSolution.covarianceMatrix23(cadenceIndex)   = CdeltaAttitudes(2,3);
  
    padOutputStruct.attitudeSolution.gapIndicators(cadenceIndex)        = false;
    
    padOutputStruct.attitudeSolution.attitudeErrorPixels(cadenceIndex)  = attitudeError;
   
    duration = toc;
    if (debugLevel > 0 )
        disp(sprintf('CPU time = %8.3f', duration));
    end
    
end

return

