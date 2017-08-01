function cdppMmrMetrics= calculate_cdpp_metric_additional(pmdScienceObject)
%
% cdppMmrMetrics= calculate_cdpp_metric_additional(pmdScienceObject)
%
% INPUTS:
%   pmdScienceObject
%
% OUTPUTS:
%    cdppMmrMetrics, a struct with fields:
%        .countOfStarsInMagnitude, The number of stars in each of the below magnitude bins. 
%             Note that the magnitude bins are 0.5 mag wide (e.g., 8.75-9.25) for the cdppMmrMetrics output.
%             .mag9
%             .mag10
%             .mag11
%             .mag12
%             .mag13
%             .mag14
%             .mag15
%        .medianCdpp, The median CDPP for stars in each of the magnitude bins.
%        .tenthPercentileCdpp, The 10th-percentile CDPP for stars in each of the magnitude bins.
%        .noiseModel, The CDPP noise model for each of the magnitude bins.
%        .percentBelowNoise, The percentage of stars with median CDPP less than the noise model. 
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

    % Factor to "convert" 6hr CDPP into 6.5hr CDPP:
    %
    sixHourFixFactor = sqrt(6.5/6.0);

    % Count up stars in each mag bin:
    %
    countOfStarsInMagnitude = get_star_counts(pmdScienceObject);

    % Bin the stars' CDPP values into hour/magnitude bins:
    %
    mmrCdppBinningStruct = get_mmr_binnings(pmdScienceObject);


    % Calculate:
    %     the median CDPP for the stars in each of the 21 bins:
    %     the 10th percentile CDPP for all stars
    %     noise model CDPP
    %     fraction of stars with median CDPP less than the noise model CDPP
    %
    [magCellArray magVector] = get_mag_cell_array();
    for imag = 1:length(magCellArray)
        magString = magCellArray{imag};
        magnitude = magVector(imag);

        mval = median(mmrCdppBinningStruct.(magString).sixHour);
        tval = prctile(mmrCdppBinningStruct.(magString).sixHour, 10);
        noise = get_noise_model(magnitude);

        medianCdpp.(magString) = mval / sixHourFixFactor;
        tenthPercentileCdpp.(magString) = tval / sixHourFixFactor;
        noiseModel.(magString) = noise;
        
        % Replace NaNs with -1s
        if isnan( medianCdpp.(magString) )
            medianCdpp.(magString) = -1;
        end
        if isnan( tenthPercentileCdpp.(magString) )
            tenthPercentileCdpp.(magString) = -1;
        end
        if isnan( noiseModel.(magString) )
            noiseModel.(magString) = -1;
        end
    end

    countBelowNoise = get_count_below_noise(pmdScienceObject, noiseModel, sixHourFixFactor);
    for imag = 1:length(magCellArray)
        
        magString = magCellArray{imag};
        percentBelowNoise.(magString) = 100.0 * countBelowNoise.(magString) ./ countOfStarsInMagnitude.(magString);
        
        % Replace NaNs with -1s
        if isnan( percentBelowNoise.(magString) )
            percentBelowNoise.(magString) = -1;
        end
       
    end

    cdppMmrMetrics.countOfStarsInMagnitude = countOfStarsInMagnitude;
    cdppMmrMetrics.medianCdpp = medianCdpp;
    cdppMmrMetrics.tenthPercentileCdpp = tenthPercentileCdpp;
    cdppMmrMetrics.noiseModel = noiseModel;
    cdppMmrMetrics.percentBelowNoise = percentBelowNoise;
return

function noiseModel = get_noise_model(magnitude)
    framesPerCadence = 270;
    readNoisePerFrame = 100;
    cadencesPerTransit = 13;
    effectiveNumberOfPixelsInAperture = 2.6;

    magOffset = (12 - magnitude);
    sourceChargePerCadence = 1625*2.1e5*2.512.^(magOffset);
    sourceCharge = sourceChargePerCadence * cadencesPerTransit;

    noiseModel = 1e6*sqrt(cadencesPerTransit * framesPerCadence * readNoisePerFrame^2 * effectiveNumberOfPixelsInAperture + sourceCharge) ./ sourceCharge;
return

function countOfStarsInMagnitude = get_star_counts(pmdScienceObject)
    countOfStarsInMagnitude = get_star_count_struct();
    nTargets = length(pmdScienceObject.cdppTsData);
    for itarg = 1:nTargets
        targCdpp = pmdScienceObject.cdppTsData(itarg);
        if ~is_good_target(targCdpp)
            continue;
        end
        
        targetRoundMag = get_mag_bin(targCdpp.keplerMag);
        if isempty(targetRoundMag)
            continue;
        end
        
        magString = sprintf('mag%d', targetRoundMag);

        countOfStarsInMagnitude.(magString) = countOfStarsInMagnitude.(magString) + 1;
    end
return

function countBelowNoise = get_count_below_noise(pmdScienceObject, noiseModel, sixHourFixFactor)
    nTargets = length(pmdScienceObject.cdppTsData);
    countBelowNoise = get_star_count_struct();

    [magCellArray magVector] = get_mag_cell_array();
    for imag = 1:length(magCellArray)
        magString = magCellArray{imag};
        magnitude = magVector(imag);

        noiseForThisMag = noiseModel.(magString);

        for itarg = 1:nTargets
            targCdpp = pmdScienceObject.cdppTsData(itarg);
            if ~is_good_target(targCdpp)
                continue;
            end
            
            targetRoundMag = get_mag_bin(targCdpp.keplerMag);
            if isempty(targetRoundMag)
                continue;
            end
            %targetRoundMag = round(targCdpp.keplerMag);
            magString = sprintf('mag%d', targetRoundMag);

            if targetRoundMag == magnitude
                starMedianCdppSixPointFive = median(targCdpp.cdpp6Hr) / sixHourFixFactor;

                if starMedianCdppSixPointFive < noiseForThisMag 
                    countBelowNoise.(magString) = countBelowNoise.(magString) + 1;
                end
            end
        end
    end

return

function allStarsInBinCdpp = get_mmr_binnings(pmdScienceObject)
    allStarsInBinCdpp = get_mmr_binning_struct();
    nTargets = length(pmdScienceObject.cdppTsData);

    [magCellArray magVector] = get_mag_cell_array();
    for imag = 1:length(magCellArray)
        magString = magCellArray{imag};
        magnitude = magVector(imag);
        data = [];

        for itarg = 1:nTargets
            targCdpp = pmdScienceObject.cdppTsData(itarg);
            if ~is_good_target(targCdpp)
                continue;
            end
            
            targetRoundMag = get_mag_bin(targCdpp.keplerMag);
            if isempty(targetRoundMag)
                continue;
            end

            if targetRoundMag == magnitude
                data = [data(:)' targCdpp.cdpp6Hr(:)'];
            end
        end

        allStarsInBinCdpp.(magString).sixHour = data;
    end
return

function isGoodTarget = is_good_target(targCdpp)
    isGoodTarget = true;

    % Skip giant stars (stars with log(g) <= 4.0):
    %
    if targCdpp.log10SurfaceGravity <= 4.0
       isGoodTarget = false;
    end

    % Skip this target if it has a NaN keplerMag:
    %
    if isnan(targCdpp.keplerMag)
       isGoodTarget = false; 
    end

    targetRoundMag = round(targCdpp.keplerMag);
    if targetRoundMag < 9 || targetRoundMag > 15
        isGoodTarget = false;
    end
return

function countOfStarsInMagnitude = get_star_count_struct();
    countOfStarsInMagnitude = struct( ...
        'mag9',  0, ...
        'mag10', 0, ...
        'mag11', 0, ...
        'mag12', 0, ...
        'mag13', 0, ...
        'mag14', 0, ...
        'mag15', 0);
return

function binningStruct = get_mmr_binning_struct()
    binningStruct = struct( ...
        'mag9',  struct('sixHour', []), ...
        'mag10', struct('sixHour', []), ...
        'mag11', struct('sixHour', []), ...
        'mag12', struct('sixHour', []), ...
        'mag13', struct('sixHour', []), ...
        'mag14', struct('sixHour', []), ...
        'mag15', struct('sixHour', []));
return

function [magCellArray magVector] = get_mag_cell_array()
    magCellArray = { 'mag9', 'mag10', 'mag11', 'mag12', 'mag13', 'mag14', 'mag15' };
    magVector = 9:15;
return

function magBin = get_mag_bin(keplerMag)
    magBin = [];
    if keplerMag >=  8.75 && keplerMag <  9.25, magBin =  9; end
    if keplerMag >=  9.75 && keplerMag < 10.25, magBin = 10; end
    if keplerMag >= 10.75 && keplerMag < 11.25, magBin = 11; end
    if keplerMag >= 11.75 && keplerMag < 12.25, magBin = 12; end
    if keplerMag >= 12.75 && keplerMag < 13.25, magBin = 13; end
    if keplerMag >= 13.75 && keplerMag < 14.25, magBin = 14; end
    if keplerMag >= 14.75 && keplerMag < 15.25, magBin = 15; end
return
