function Cblack2D = get_Cblack2D(calObject, calIntermediateStruct, cadenceIndex, tStruct)
%function Cblack2D = get_Cblack2D(calObject, calIntermediateStruct, cadenceIndex, tStruct)
%
% This function computes the covariance matrix of uncertainties after 2D
% black correction.  The uncertainties associated with the 2D black model
% are neglected in the error propagation since they can essentially be
% treated as a bias term.  The raw black uncertainties have already been
% computed in the function compute_collateral_raw_black_uncertainties and
% saved in the blackUncertaintyStruct as 'deltaRawBlack' for all cadences
%
% transforms and covariance matrices may be saved for later analysis, but
% only Cblack2D is output here (and nothing else is currently being saved
% due to memory limitations)
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


% extract data flags
processLongCadence  = calObject.dataFlags.processLongCadence;
processShortCadence = calObject.dataFlags.processShortCadence;
pouEnabled = calObject.pouModuleParametersStruct.pouEnabled;

isAvailableBlackPix        = calObject.dataFlags.isAvailableBlackPix;
isAvailableMaskedBlackPix  = calObject.dataFlags.isAvailableMaskedBlackPix;
isAvailableVirtualBlackPix = calObject.dataFlags.isAvailableVirtualBlackPix;


%--------------------------------------------------------------------------
% extract raw pixel uncertainties associated with the measurement (in ADU)
% and gap indicators (used to set gaps in cov matrix equal to zero)
%--------------------------------------------------------------------------

if ~pouEnabled
    blackUncertaintyStruct = calIntermediateStruct.blackUncertaintyStruct;
end


if (processLongCadence)

    if (isAvailableBlackPix)
        
        blackGaps = calIntermediateStruct.blackGaps(:, cadenceIndex);        % nCcdRows x 1

        if ~pouEnabled
            deltaRawBlack  = blackUncertaintyStruct(cadenceIndex).deltaRawBlack; % nCcdRows x 1            
        else
            [~, Cblack] = get_primitive_data(tStruct,'residualBlack');
            deltaRawBlack = sqrt(Cblack);
        end

        % ensure data gaps are set to zero
        deltaRawBlack(blackGaps == 1) = 0;

        CblackRaw = deltaRawBlack.^2;

        % raw black to residual black transform (a scalar).  Note deltaRawBlack
        % is already in units of ADU/column/cadence, so we do not need the transform:
        % TrawBlackTo2Dcorrected = sqrt(numberOfExposures/numberOfBlackColumns)
        TrawBlackTo2Dcorrected = 1;

        % cov matrix after 2D black correction
        Cblack2D = TrawBlackTo2Dcorrected * CblackRaw * TrawBlackTo2Dcorrected';

        Cblack2D = diag(Cblack2D);  % nCcdRows x nCcdRows

        clear CblackRaw deltaRawBlackArray deltaRawBlack blackGaps
    else
        Cblack2D = [];
    end


elseif (processShortCadence)

    if (isAvailableBlackPix)

        blackGaps = calIntermediateStruct.blackGaps(:, cadenceIndex);        % nCcdRows x 1
        
        if ~pouEnabled
            deltaRawBlack  = blackUncertaintyStruct(cadenceIndex).deltaRawBlack; % nCcdRows x 1            
        else
            [~, Cblack] = get_primitive_data(tStruct,'residualBlack');
            deltaRawBlack = sqrt(Cblack);
        end
        

        % ensure data gaps are set to zero
        deltaRawBlack(blackGaps == 1) = 0;  % nCcdRows x 1

        % raw black to residual black transform (a scalar). Note deltaRawBlack
        % is already in units of ADU/column/cadence, so we do not need the transform:
        % TrawBlackTo2Dcorrected = sqrt(numberOfExposures/numberOfBlackColumns)
        TrawBlackTo2Dcorrected = 1;

        %--------------------------------------------------------------------------
        % check for masked and/virtual black pixel values, and include in
        % delta raw black array and compute raw-to-2D black transforms

        if (isAvailableMaskedBlackPix)

            % get smear rows that were summed onboard spacecraft to find the mean
            % value, which will be the 'row' of the masked black pixel value
            mSmearRowStart   = calIntermediateStruct.mSmearRowStart;
            mSmearRowEnd     = calIntermediateStruct.mSmearRowEnd;


            if numel(mSmearRowStart) > 1 && numel(mSmearRowEnd) > 1
                mSmearRows = mSmearRowStart(cadenceIndex):mSmearRowEnd(cadenceIndex);
            else
                mSmearRows = mSmearRowStart:mSmearRowEnd;
            end

            maskedBlackRow  = round(mean(mSmearRows));
            mBlackGaps      = calIntermediateStruct.mBlackGaps(cadenceIndex);       % scalar
            
            if ~pouEnabled
                deltaRawMblack  = blackUncertaintyStruct(cadenceIndex).deltaRawMblack;  % scalar
            else
                [~, Cblack] = get_primitive_data(tStruct,'mBlackEstimate');
                deltaRawMblack =sqrt(Cblack);
            end
            

            % raw black to residual black transform (a scalar). Note deltaRawBlack
            % is already in units of ADU/column/cadence, so we do not need the transform:
            % TrawBlackTo2Dcorrected = sqrt(numberOfExposures/numberOfBlackColumns)
            TrawBlackTo2DcorrectedMblack = 1;

            if (~mBlackGaps)

                % include raw masked black value in deltaRawBlack
                deltaRawBlack(maskedBlackRow) = deltaRawMblack;

                % multiply raw-to-2D transforms
                TrawBlackTo2Dcorrected = TrawBlackTo2Dcorrected*TrawBlackTo2DcorrectedMblack;
            end

        end


        if (isAvailableVirtualBlackPix)

            % get smear rows that were summed onboard spacecraft to find the mean
            % value, which will be the 'row' of the masked black pixel value
            vSmearRowStart   = calIntermediateStruct.vSmearRowStart;
            vSmearRowEnd     = calIntermediateStruct.vSmearRowEnd;


            if numel(vSmearRowStart) > 1 && numel(vSmearRowEnd) > 1
                vSmearRows = vSmearRowStart(cadenceIndex):vSmearRowEnd(cadenceIndex);
            else
                vSmearRows = vSmearRowStart:vSmearRowEnd;
            end

            virtualBlackRow = round(mean(vSmearRows));
            
            vBlackGaps      = calIntermediateStruct.vBlackGaps(cadenceIndex);       % scalar

            if ~pouEnabled
                deltaRawVblack  = blackUncertaintyStruct(cadenceIndex).deltaRawVblack;  % scalar
            else
                [~, Cblack] = get_primitive_data(tStruct,'vBlackEstimate');
                deltaRawVblack = sqrt(Cblack);
            end
            

            % raw black to residual black transform (a scalar). Note deltaRawBlack
            % is already in units of ADU/column/cadence, so we do not need the transform:
            % TrawBlackTo2Dcorrected = sqrt(numberOfExposures/numberOfBlackColumns)
            TrawBlackTo2DcorrectedVblack = 1;

            if (~vBlackGaps)

                % include raw virtual black value in deltaRawBlack
                deltaRawBlack(virtualBlackRow) = deltaRawVblack;

                % multiply raw-to-2D transforms
                TrawBlackTo2Dcorrected = TrawBlackTo2Dcorrected*TrawBlackTo2DcorrectedVblack;
            end
        end
    end


    % construct black raw uncertainties cov matrix
    CblackRaw = diag(deltaRawBlack.^2);         % nCcdRows x nCcdRows

    %--------------------------------------------------------------------------
    % covariance matrix of uncertainties after 2D black subtraction
    %--------------------------------------------------------------------------
    Cblack2D = TrawBlackTo2Dcorrected * CblackRaw * TrawBlackTo2Dcorrected';

    clear CblackRaw deltaRawBlackArray deltaRawBlack blackGaps
else
    Cblack2D = [];
end


return;
