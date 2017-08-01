function pdqTempStruct  = correct_for_smear_and_dark(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function pdqTempStruct  = correct_for_smear_and_dark(pdqTempStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Smear is a measure of the error introduced by transferring charge through
% an illuminated pixel in shutterless operation. It is equivalent to the
% ratio of the single-pixel transfer time to the exposure time.
% Subtracting the smear level from target and background pixel values
% corrects them for image streaks due to lack of a shutter
%
%  The algorithm consists of the following steps:
%  1. Since both virtual smear and masked smear are needed for smear
%     estimation, the following cases arise
%     case 1: No smear pixels available, hence smear correction is not
%             possible -  declare all target, bkgd pixels as data gaps
%     case 2: Only virtual smear pixels available
%     case 3: Only masked smear pixels available, dark current estimation
%             is not possible - so use dark currents from dark currents metric time
%             series in  pdqOutputStruct.outputPdqTsData.pdqModuleOutputTsData(currentModOut)
%     case 4: Both virtual and masked smear pixels available, dark current
%             estimation is possible
%     case 5: Both virtual and masked smear pixels available, but they
%             don't come from the same column (bit unrealistic), use only
%             the virtual smear
%  2. Correct target and background reference pixels for smear
%  3. Calculate the median smear level (suitable for tracking & trending)
%  4. Generate a bootstrap uncertainty estimate for the median smear level
%  5. Save the following:
%       1. In case the target gap and background gap indicators were changed because
%          of missing smear values for any of the columns for any of the cadences,
%          store the new gap indicators back in the pdqTempStruct
%       2. Smear corrected target and background reference pixels in pdqTempStruct
%       3. Append to the smear level metric time series (metric consisting of
%          median smear level for each cadence and associated uncertainty)the median
%          smear values and their uncertainties
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

% This function estimates the smear and performs smear correction on target
% and background pixels. The following scenarios are considered:
%
%
% case 1 : No smear available,hence no smear correction possible -  declare
% all target, bkgd pixels as data gaps.
%
% case 2 : Only virtual smear pixels available - use this as the estimated
% smear as the dark current is really small compared to other background flux sources.
%
% case 3 : Only masked smear pixels available - read in existing dark
% current level time series to compute estimated smear
%
% case 4 : both virtual and masked smear pixels available (treat the
% non-overlapping masked, virtual smear columns as data gaps - avoiding
% trouble later on....
%
% in case the target gap and background gap indicators were changed because
% of missing smear values for any of the columns for any of the cadences,
% store the values back in the object
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


%--------------------------------------------------------------------------
% Step 0: collect data from pdqTempStruct
%--------------------------------------------------------------------------

gains = pdqTempStruct.gainForAllCadencesAllModOuts(:,pdqTempStruct.currentModOut); % for all cadences in electrons per ADU

numberOfExposuresPerLongCadence = pdqTempStruct.configMapStruct.numberOfExposuresPerLongCadence; % for all cadences
ccdReadTime = pdqTempStruct.configMapStruct.ccdReadTime; % for all cadences
ccdExposureTime = pdqTempStruct.configMapStruct.ccdExposureTime; % for all cadences



nCcdColumns             = pdqTempStruct.nCcdColumns;

targetPixels            = pdqTempStruct.targetPixels;
targetPixelColumns      = pdqTempStruct.targetPixelColumns;
targetGapIndicators     = pdqTempStruct.targetGapIndicators;


bkgdPixels              = pdqTempStruct.bkgdPixels;
bkgdPixelColumns        = pdqTempStruct.bkgdPixelColumns;
bkgdGapIndicators       = pdqTempStruct.bkgdGapIndicators;

msmearPixels            = pdqTempStruct.binnedMsmearPixels;
msmearColumns           = pdqTempStruct.binnedMsmearColumns;
msmearGapIndicators     = pdqTempStruct.binnedMsmearGapIndicators;

vsmearPixels            = pdqTempStruct.binnedVsmearPixels;
vsmearColumns           = pdqTempStruct.binnedVsmearColumns;
vsmearGapIndicators     = pdqTempStruct.binnedVsmearGapIndicators;


numCadences              = pdqTempStruct.numCadences;

% RLM 2/17/11 -- 
% Preallocate to avoid errors due to variable dimensions. Previously,
% columns were added to these matrices dynamically. If a cadence was
% skipped due to gaps (see lines 390-490), the result was a reduced 
% column dimension, which led to dimension mismatch error in 
% collect_additional_bkgd_pixels_from_target_aperture.m, line 181.
pdqTempStruct.smearCorrectedBkgdPixels = -ones(size(bkgdPixels));
pdqTempStruct.darkCorrectedBkgdPixels = -ones(size(bkgdPixels));
pdqTempStruct.smearCorrectedTargetPixels = -ones(size(targetPixels));
pdqTempStruct.darkCorrectedTargetPixels = -ones(size(targetPixels));
% -- RLM


% JJ  - error propagation
% important to be able to reconstruct the transformation matrix on the fly
% - see notes


smear2 = zeros(nCcdColumns, numCadences);

smearUncertaintyStruct = repmat(struct('TgainCorrection', [], 'TrawMsmearTo2Dcorrected', [], ...
    'TrawVsmearTo2Dcorrected', [], ...
    'TcorrMsmearToEstSmear', [],  'TcorrVsmearToEstSmear', [], ...
    'validSmearColumns', [], 'darkCurrentsUncertainty', [], 'smear', []), numCadences, 1);

pdqTempStruct.smearUncertaintyStruct = smearUncertaintyStruct;


pdqTempStruct.darkCurrentsAvailable = true(numCadences,1);

darkCurrentInElectrons = zeros(nCcdColumns, numCadences);

darkCurrentUncertaintyStruct = repmat(struct('TmsmearCorrToDarkEst', [],  'TvsmearCorrToDarkEst', [], ...
    'validSmearColumns', [], 'darkCurrentLevels', []), numCadences, 1);

pdqTempStruct.darkCurrentUncertaintyStruct = darkCurrentUncertaintyStruct;


%--------------------------------------------------------------------------
% Step 1: apply smear correction for available cadences
%--------------------------------------------------------------------------

for cadenceIndex = 1 : numCadences


    % just in case the following quantities are time varying...

    pdqTempStruct.smearUncertaintyStruct(cadenceIndex).TgainCorrection = gains(cadenceIndex);
    pdqTempStruct.smearUncertaintyStruct(cadenceIndex).TrawMsmearTo2Dcorrected = sqrt(numberOfExposuresPerLongCadence(cadenceIndex));
    pdqTempStruct.smearUncertaintyStruct(cadenceIndex).TrawVsmearTo2Dcorrected = sqrt(numberOfExposuresPerLongCadence(cadenceIndex));

    pdqTempStruct.smearUncertaintyStruct(cadenceIndex).TcorrVsmearToEstSmear =  (1 + ccdReadTime(cadenceIndex)/ccdExposureTime(cadenceIndex));
    pdqTempStruct.smearUncertaintyStruct(cadenceIndex).TcorrMsmearToEstSmear =  -(ccdReadTime(cadenceIndex)/ccdExposureTime(cadenceIndex));

    pdqTempStruct.darkCurrentUncertaintyStruct(cadenceIndex).TmsmearCorrToDarkEst =  (1/ccdExposureTime(cadenceIndex));
    pdqTempStruct.darkCurrentUncertaintyStruct(cadenceIndex).TvsmearCorrToDarkEst =  -(1/ccdExposureTime(cadenceIndex));


    pdqTempStruct.smearUncertaintyStruct(cadenceIndex).validSmearColumns = [];

    pdqTempStruct.smearUncertaintyStruct(cadenceIndex).darkCurrentsUncertainty = [];

    pdqTempStruct.smearUncertaintyStruct(cadenceIndex).smear = [];

    validMsmearPixelIndices = find(~(msmearGapIndicators(:,cadenceIndex))); % valid msmear columns where data are present
    validVsmearPixelIndices = find(~(vsmearGapIndicators(:,cadenceIndex))); % valid vsmear columns where data are present


    %--------------------------------------------------------------------------
    % case 1 : No smear pixels available
    %--------------------------------------------------------------------------
    if(isempty(validMsmearPixelIndices) && isempty(validVsmearPixelIndices))

        % no smear available,hence no smear correction possible -  declare all target, bkgd pixels as data gaps
        targetGapIndicators(:, cadenceIndex) = true; % set all the gap indicators to true;

        bkgdGapIndicators(:, cadenceIndex) = true; % set all the gap indicators to true;

        warning('PDQ:correctSmear:MissingSmearValues', ...
            ['correct_smear: no smear levels available for ' ...
            num2str(cadenceIndex) ' cadence - declaring all target and background pixels as data gaps for this cadence' ]);

        continue;
    end;

    colMsmearValid = msmearColumns(~(msmearGapIndicators(:,cadenceIndex))); % valid msmear columns where data are present
    colVsmearValid = vsmearColumns(~(vsmearGapIndicators(:,cadenceIndex))); % valid vsmear columns where data are present

    % If we have only masked smear and no virtual smear at all for a
    % particular  cadenceIndex, is it still possible to do smear correction?
    %
    % JJ: Yes. The masked smear has all the smear and all the dark current
    % as a normal CCD pixel ('cause they are CCD pixels), so it would be
    % all right to use them. Yes. We probably could just use the trended
    % smear current value itself for each mod/out.
    % It would also not be a bad situation if only the virtual smear were
    % available as the dark current is really small compared to other
    % background flux sources.

    %--------------------------------------------------------------------------
    % case 2 : Only virtual smear pixels available
    %--------------------------------------------------------------------------
    if(isempty(validMsmearPixelIndices))

        smearColumns = colVsmearValid;

        darkCurrentLevels     = pdqTempStruct.pdqModuleOutputTsData.darkCurrentLevels;  % in e-/sec

        warning('PDQ:correctSmear:MissingMsmearValues', ...
            ['correct_smear: only virtual smear available; performing smear correction using virtual smear pixels only for cadence  = ' num2str(cadenceIndex) ]);


        if(~isempty(darkCurrentLevels))

            pdqTempStruct.darkCurrentUncertaintyStruct(cadenceIndex).validSmearColumns = smearColumns;

            % during PDQ requirements verification, Doug Caldwell suggested that
            % darkCurrentlevel shoud be in units of electrons/sec rather than the photoelectrons

            darkCurrentLevels     = pdqTempStruct.pdqModuleOutputTsData.darkCurrentLevels; % in e-/sec, per read

            smear = vsmearPixels(validVsmearPixelIndices) - (darkCurrentLevels(end))*ccdReadTime(cadenceIndex)*numberOfExposuresPerLongCadence(cadenceIndex);

        else
            smear = vsmearPixels(validVsmearPixelIndices);
        end

        pdqTempStruct.smearUncertaintyStruct(cadenceIndex).smear = smear;
        pdqTempStruct.smearUncertaintyStruct(cadenceIndex).validSmearColumns = smearColumns;

        pdqTempStruct.darkCurrentUncertaintyStruct(cadenceIndex).validSmearColumns = smearColumns; % does not exist for this cadence
        % Dark current array with all possible column values
        darkCurrentInElectrons(smearColumns, cadenceIndex)    =  darkCurrentLevels(end)*(ccdExposureTime(cadenceIndex) + ccdReadTime(cadenceIndex))*numberOfExposuresPerLongCadence(cadenceIndex);

        % metrics are unavailable

        %--------------------------------------------------------------------------
        % case 3 : Only masked smear pixels available
        %--------------------------------------------------------------------------
    elseif(isempty(validVsmearPixelIndices))

        % Read in existing dark current level time series
        darkCurrentsUncertainties  = pdqTempStruct.pdqModuleOutputTsData.darkCurrentsUncertainties;
        pdqTempStruct.darkCurrentUncertaintyStruct(cadenceIndex).validSmearColumns = smearColumns; % does not exist for this cadence
        darkCurrentLevels     = pdqTempStruct.pdqModuleOutputTsData.darkCurrentLevels;  % in e-/sec


        if(~isempty(darkCurrentLevels))


            smear = msmearPixels(validMsmearPixelIndices) - darkCurrentLevels(end)*numberOfExposuresPerLongCadence(cadenceIndex)*(ccdExposureTime(cadenceIndex) + ccdReadTime(cadenceIndex));
            smearColumns = colMsmearValid;  % modified after PDQ code review 1/2

            pdqTempStruct.smearUncertaintyStruct(cadenceIndex).smear = smear;
            pdqTempStruct.smearUncertaintyStruct(cadenceIndex).validSmearColumns = smearColumns;
            pdqTempStruct.smearUncertaintyStruct(cadenceIndex).darkCurrentsUncertainty = darkCurrentsUncertainties(end); % for propagation of error

            pdqTempStruct.darkCurrentUncertaintyStruct(cadenceIndex).validSmearColumns = smearColumns; % does not exist for this cadence

            % Dark current array with all possible column values
            darkCurrentInElectrons(smearColumns, cadenceIndex)    =  darkCurrentLevels(end)*numberOfExposuresPerLongCadence(cadenceIndex)*(ccdExposureTime(cadenceIndex) + ccdReadTime(cadenceIndex));
            % metrics are unavailable

        else
            % no smear available,hence no smear correction possible -  declare all target, bkgd pixels as data gaps
            targetGapIndicators(:, cadenceIndex) = true; % set all the gap indicators to true;

            bkgdGapIndicators(:, cadenceIndex) = true; % set all the gap indicators to true;


            warning('PDQ:correctSmear:MissingVsmearValues', ...
                ['correct_smear: only masked smear available; dark currents metric time series not available; no smear correction possible for ' ...
                num2str(cadenceIndex) ' cadence - declaring all target and background pixels as data gaps for this cadence' ]);


            % uncertainty struct stays empty
            continue;
        end
    else

        %--------------------------------------------------------------------------
        % case 4 : both virtual and masked smear pixels available
        %--------------------------------------------------------------------------

        % Masked and virtual smear pixels should come from the same column values
        % Take intersection to be sure

        commonSmearCols = intersect(colMsmearValid, colVsmearValid); % commonSmearCols is not expected to be []

        if(~isempty(commonSmearCols))
            % need to do two more intersects to be able to access smear pixels
            [commonCols,msmearIndices]  = intersect(msmearColumns(:,cadenceIndex), commonSmearCols);

            [commonCols,vsmearIndices]  = intersect(vsmearColumns(:,cadenceIndex), commonSmearCols);


            % Guarantee that the masked & virtual smear arrays are same length
            msmear = msmearPixels(msmearIndices, cadenceIndex);
            vsmear = vsmearPixels(vsmearIndices, cadenceIndex);

            %--------------------------------------------------------------------------
            % treat the non-overlapping masked, virtual smear columns as
            % data gaps - avoiding trouble later on....
            %--------------------------------------------------------------------------
            msmearIndexToBeSetToZero = setxor( (1:length(msmearPixels(:, cadenceIndex)))', msmearIndices);

            pdqTempStruct.binnedMsmearGapIndicators(msmearIndexToBeSetToZero,cadenceIndex) = true;

            vsmearIndexToBeSetToZero = setxor( (1:length(vsmearPixels(:, cadenceIndex)))', vsmearIndices);

            pdqTempStruct.binnedVsmearGapIndicators(vsmearIndexToBeSetToZero,cadenceIndex) = true;

            % Calculate dark current level from msmear and vsmear
            %darkCurrent  = (msmear - vsmear) * ((ccdExposureTime + ccdReadTime)/ccdExposureTime);  % another version

            % Calculate dark current level from msmear and vsmear
            % masked smear collects dark current during ccdExposureTime + ccdReadTime
            % virtual smear collects dark current during read time only
            darkCurrent  = (msmear - vsmear) ./(numberOfExposuresPerLongCadence(cadenceIndex)*ccdExposureTime(cadenceIndex));

            % If virtual & masked smear were not the same - use virtual smear values only
            smearColumns = vsmearColumns(vsmearIndices,cadenceIndex);


            % Here we are subtracting 2 numbers whose values are very close to
            % each other, and the dark current value is near zero. Adding in
            % read noise and the formula above can yield zero, or even negative
            % value.

            % Dark current array with all possible column values
            darkCurrentInElectrons(smearColumns, cadenceIndex) =  darkCurrent*numberOfExposuresPerLongCadence(cadenceIndex)*(ccdExposureTime(cadenceIndex) + ccdReadTime(cadenceIndex));


            % Calculate dark current level from msmear and vsmear
            % masked smear collects dark current during ccdExposureTime + ccdReadTime
            % virtual smear collects dark current during read time only
            % smear = 0.5*(msmear + vsmear - dark *(ccdExposureTime + 2*ccdReadTime))
            % simplification of above equation leads to
            smear  = 0.5*(msmear + vsmear - darkCurrent *numberOfExposuresPerLongCadence(cadenceIndex)*(ccdExposureTime(cadenceIndex) + 2*ccdReadTime(cadenceIndex)));


            % add in quadrature  read noise, quantization noise, and shot
            % noise (make sure these are in the same units; calculate the
            % shot noise as the sqrt(black corrected smear values)


            pdqTempStruct.smearUncertaintyStruct(cadenceIndex).smear = smear;
            pdqTempStruct.smearUncertaintyStruct(cadenceIndex).validSmearColumns = smearColumns;

            pdqTempStruct.darkCurrentUncertaintyStruct(cadenceIndex).validSmearColumns = smearColumns; % does not exist for this cadence
            pdqTempStruct.darkCurrentUncertaintyStruct(cadenceIndex).darkCurrentLevels = darkCurrent;


        else

            %--------------------------------------------------------------------------
            % case 5 : both virtual and masked smear pixels available, but they
            % don't come from the same column - bit unrealistic
            %--------------------------------------------------------------------------

            smear = vsmear;
            smearColumns = colVsmearValid;
            pdqTempStruct.smearUncertaintyStruct(cadenceIndex).smear = smear;
            pdqTempStruct.smearUncertaintyStruct(cadenceIndex).validSmearColumns = smearColumns;
            warning('PDQ:correctSmear:MsmearVsmearValues', ...
                ['correct_smear: both virtual and masked smear pixels available, but they don''t come from the same columns for  ' ...
                num2str(cadenceIndex) ' cadence - using only the virtual smear values for smear correction for this cadence' ]);


            pdqTempStruct.darkCurrentUncertaintyStruct(cadenceIndex).validSmearColumns = smearColumns; % does not exist for this cadence
            darkCurrentLevels     = pdqTempStruct.pdqModuleOutputTsData.darkCurrentLevels;

            pdqTempStruct.darkCurrentsAvailable(cadenceIndex) = false;

            % Dark current array with all possible column values
            darkCurrentInElectrons(smearColumns, cadenceIndex)  =  darkCurrentLevels(end)*numberOfExposuresPerLongCadence(cadenceIndex)*(ccdExposureTime(cadenceIndex) + ccdReadTime(cadenceIndex));


        end
    end

    % What happens if the smear corrections are available only for certain
    % columns and these columns do not cover all the columns of target
    % pixels (due  to data gaps occurring in different columns for target
    % and collateral pixels?)
    %
    % Is it all right to interpolate across columns (for a given cadenceIndex)
    % so every  column of target pixels will have a smear value?
    %
    % JJ: No.  The smear responds to motion along the row direction just as
    % stars do, although it is not that sensitive to motion of the image
    % along the column direction. In this case, we would have to abandon
    % the stellar targets in the affected columns. (I don't see an easy way
    % out of this unless we build a linear predictive model for each smear
    % column value based on the deltas in x and y (mostly x if this is
    % along the rows). This would be out of scope for PDQ, although
    % do-able.


    % Smear array with all possible column values
    smear2(smearColumns, cadenceIndex) = smear;

    % Correct target & background reference pixels for smear

    validTargetPixelIndices = find(~targetGapIndicators(:,cadenceIndex));

    if(~isempty(validTargetPixelIndices))

        targetColumns = targetPixelColumns(validTargetPixelIndices);

        % ideally validTargetColumns = smearColumns or may be
        % validTargetColumns is a subset of smearColumns
        % in rare instances, there might not be a smear value for each target
        % pixel column
        commonCols = intersect(targetColumns, smearColumns);
        targetColumnIndices = ismember(targetColumns, commonCols); % boolean array
        targetColumnIndices = find(targetColumnIndices); % array containing indices


        if(~isempty(targetColumnIndices))
            % redefine data gap indicators for this cadenceIndex
            validTargetPixelIndices2 = validTargetPixelIndices(targetColumnIndices);
            if(~isequal(validTargetPixelIndices, validTargetPixelIndices2))

                targetGapIndicators(:, cadenceIndex) = true; % reset all the gap indicators to true;
                targetGapIndicators(validTargetPixelIndices2, cadenceIndex) = false; % set the gap indicators to false where pixels have a corresponding smear value

                warning('PDQ:correctSmear:smearValues', ...
                    ['correct_smear: smear value does not exist for all target pixel columns for  ' ...
                    num2str(cadenceIndex) ' cadence - treating those targets pixles without a corresponding smear value as data gaps for this cadence' ]);

            end

            targetSmearCorrection  = smear2(targetColumns(targetColumnIndices), cadenceIndex); % targetColumnIndices contain many repeated column values
            targetPixels(validTargetPixelIndices2,cadenceIndex) = targetPixels(validTargetPixelIndices2,cadenceIndex) - targetSmearCorrection;

            pdqTempStruct.smearCorrectedTargetPixels(:,cadenceIndex)       = targetPixels(:,cadenceIndex);

            targetDCCorrection  = darkCurrentInElectrons(targetColumns(targetColumnIndices), cadenceIndex); % targetColumnIndices contain many repeated column values
            targetPixels(validTargetPixelIndices2,cadenceIndex) = targetPixels(validTargetPixelIndices2,cadenceIndex) - targetDCCorrection;

            pdqTempStruct.darkCorrectedTargetPixels(:,cadenceIndex)       = targetPixels(:,cadenceIndex);

            if(~isempty (find(targetPixels(:,cadenceIndex) <= 0, 1, 'first')))

                warning('PDQ:darkCurrentCorrection:NegativeTargetPixellvalues',...
                    'Subtracting darkCurrent level leads to negative target pixel values..')
            end
        end
    end

    % Correct background reference pixels for smear
    validBkgdPixelIndices = find(~bkgdGapIndicators(:,cadenceIndex));
    
    if(~isempty(validBkgdPixelIndices))

        bkgdColumns = bkgdPixelColumns(validBkgdPixelIndices);

        commonCols = intersect(bkgdColumns, smearColumns);
        bkgdColumnIndices = ismember(bkgdColumns, commonCols); % boolean array
        bkgdColumnIndices = find(bkgdColumnIndices); % array containing indices

        if(~isempty(bkgdColumnIndices))
            % redefine data gap indicators for this cadenceIndex
            validBkgdPixelIndices2 = validBkgdPixelIndices(bkgdColumnIndices);

            if(~isequal(validBkgdPixelIndices, validBkgdPixelIndices2))

                bkgdGapIndicators(:, cadenceIndex) = true; % rest all the gap indicators to true;
                bkgdGapIndicators(validBkgdPixelIndices2, cadenceIndex) = false; % set the gap indicators to false where pixels have a corresponding smear value
                warning('PDQ:correctSmear:smearValues', ...
                    ['correct_smear: smear value does not exist for all background pixel columns for  ' ...
                    num2str(cadenceIndex) ' cadence - treating those background pixles without a corresponding smear value as data gaps for this cadence' ]);
            end

            bkgdSmearCorrection  = smear2(bkgdColumns(bkgdColumnIndices), cadenceIndex);
            bkgdPixels(validBkgdPixelIndices2,cadenceIndex)    = bkgdPixels(validBkgdPixelIndices2,cadenceIndex) - bkgdSmearCorrection;

            pdqTempStruct.smearCorrectedBkgdPixels(:,cadenceIndex)        = bkgdPixels(:,cadenceIndex);

            if(any(bkgdPixels(:,cadenceIndex) < 0 ))
                nNegativeBkgdPixels = sum(bkgdPixels(:,cadenceIndex) < 0);
                warning('PDQ:correctSmear:smearCorrectedBkgdValues', ...
                    ['correct_smear: ' num2str(nNegativeBkgdPixels) ' smear corrected background pixel values < 0 for cadence ' ...
                    num2str(cadenceIndex) ]);
            end

            bkgdDCCorrection  = darkCurrentInElectrons(bkgdColumns(bkgdColumnIndices), cadenceIndex);
            bkgdPixels(validBkgdPixelIndices2,cadenceIndex)    = bkgdPixels(validBkgdPixelIndices2,cadenceIndex) - bkgdDCCorrection;
            pdqTempStruct.darkCorrectedBkgdPixels(:,cadenceIndex)  = bkgdPixels(:,cadenceIndex);


        end

    end
    if(~isempty (find(targetPixels(:,cadenceIndex) <= 0, 1, 'first')))

        warning('PDQ:smearDarkCorrection:NegativeTargetPixellvalues',...
            'Subtracting smear and dark level leads to negative target pixel values..')
    end

end


%--------------------------------------------------------------------------
% Step 3: save pixels corrected for smear back into pdqTempStruct
%--------------------------------------------------------------------------
% Save results in  pdqTempStruct
% These pixel data are now corrected for smear and dark
pdqTempStruct.targetPixels       = targetPixels;
pdqTempStruct.bkgdPixels         = bkgdPixels;

% in case the target gap and background gap indicators were changed because
% of missing smear values for any of the columns for any of the cadences,
% store the values back in the object
pdqTempStruct.targetGapIndicators = targetGapIndicators;
pdqTempStruct.bkgdGapIndicators   = bkgdGapIndicators;


return