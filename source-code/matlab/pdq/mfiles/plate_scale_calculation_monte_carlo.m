function plate_scale_calculation_monte_carlo(numCadences, nModOuts)
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




for currentModOut = 1 : nModOuts

    sFileName = ['pdqTempStruct_' num2str(currentModOut) '.mat'];

    % check to see the existence ofthe .mat file

    if(~exist(sFileName, 'file'))
        continue;
    end

    load(sFileName, 'pdqTempStruct');


    nRealizations = 100;


    % starting attitude - can be wrong (choose boreSightRa + 2 arc sec, boreSightDec
    % + 2 arc sec, boreSightRot + (2/7) arc sec)

    fovCenter   = pdqTempStruct.nominalPointing;




    raStars    = pdqTempStruct.raStars;
    decStars   = pdqTempStruct.decStars;


    for k = 1:nRealizations










        % generate artificial centroids
        % generate a new realization for each iteration



        %----------------------------------------------------------------------
        % Step 1: Abberate the real positions of each star to the apparent
        % position
        %----------------------------------------------------------------------
        [raStarsAber  decStarsAber ] = aberrate_ra_dec(raStars, decStars, cadenceTimeStamp); % computationally efficient do just once
        raStarsAber = raStarsAber(:);
        decStarsAber = decStarsAber(:);

        % First call - set all weoghts to 1
        % weights = ones(numTarget,1);

        tic;

        %----------------------------------------------------------------------
        % Step 5: Aberrate the attitude initial guess.
        %----------------------------------------------------------------------
        % transforming true ra and dec to aberrated ra and dec, no error prop, assume spacecraft velocity is known with perfect precision

        %----------------------------------------------------------------------
        % Step 6: Run iterate_quick_fit_attitude() to obtain attitude solution
        %----------------------------------------------------------------------
        aberrateFlag = 0;
        rot0 = fovCenter(3);

        [module, output, centroidRows, centroidColumns] = ...
            ra_dec_2_pix_absolute(raStarsAber, decStarsAber , cadenceTimeStamp, ra0,  dec0, rot0, aberrateFlag);


        for jCadence = 1: numCadences

            cadenceTimeStamp = pdqTempStruct.cadenceTimes(k);

            [ra0, dec0 ] = aberrate_ra_dec(fovCenter(1), fovCenter(2), cadenceTimeStamp); % computationally efficient do just once
            
            CcentroidRow = pdqTempStruct.centroidUncertaintyStruct(jCadence).CcentroidRow;
            CcentroidColumn = pdqTempStruct.centroidUncertaintyStruct(jCadence).CcentroidColumn;

            nStars = length(raStars);


            if( (nStars ~= size(CcentroidColumn,1))||(nStars ~= size(CcentroidRow,1)) )
                CcentroidColumn = CcentroidColumn(1:nStars,1:nStars);
                CcentroidRow = CcentroidRow(1:nStars,1:nStars);
            end

            pdqTempStruct.centroidRows(:, jCadence) = centroidRows + sqrt(diag(CcentroidRow)).*randn(nStars,1);
            pdqTempStruct.centroidColumns(:, jCadence) = centroidColumns + sqrt(diag(CcentroidColumn)).*randn(nStars,1);
        end


        pdqTempStruct = plate_scale_metric(pdqTempStruct, currentModOut);


        fprintf('');

    end
    fprintf('');
end
