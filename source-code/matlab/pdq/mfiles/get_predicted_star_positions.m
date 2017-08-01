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
function [centRa, centDec, centroidUncertaintyStruct] = get_predicted_star_positions(raDec2PixObject, ccdModule, ccdOutput, centroidRows, centroidCols,...
    centroidUncertaintyStruct, cadenceTimeStamps, raPointing, decPointing, rollPointing, aberrateFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[nCentroids, nCadences]  = size(centroidRows);

ccdModule = repmat(ccdModule, nCentroids, 1);
ccdOutput = repmat(ccdOutput, nCentroids, 1);

centRa = -1*ones(size(centroidRows));
centDec = -1*ones(size(centroidRows));

% set up offsets in centroid row, columns

deltaRow    = 0.001; % 1/100th of a pixel (pixel occupies 3.98 arcsec, 1 arcsec = 1/3600)
deltaColumn = 0.001; % 1/100th of a pixel (pixel occupies 3.98 arcsec, 1 arcsec = 1/3600)

for jCadence = 1:nCadences

    % check with JJ as to which script should be called (I think it should
    % be pix_2_ra_dec_absolute_zero_based..)


    invalidRowIndex = find(centroidRows(:, jCadence) == -1);
    invalidColumnIndex = find(centroidCols(:, jCadence) == -1);

    validCentroidRows = centroidRows(:, jCadence);
    validCentroidColumns = centroidCols(:, jCadence);

    % make sure both centroid rows, centroid columns have -1 for the same
    % target
    if(~isempty(invalidColumnIndex))
        validCentroidRows(invalidColumnIndex) = -1;
    end

    validRowIndex = find(validCentroidRows ~= -1);

    if(~isempty(invalidRowIndex))
        validCentroidColumns(invalidRowIndex) = -1;
    end

    validColumnIndex = find(validCentroidColumns ~= -1);

    validCentroidIndex = unique([validColumnIndex;validRowIndex]);

    validCentroidRows = validCentroidRows(validRowIndex);
    validCentroidColumns = validCentroidColumns(validColumnIndex);

    if(~isempty(validCentroidIndex))

        [centroidRa centroidDec] = pix_2_ra_dec_absolute(raDec2PixObject, ccdModule(validCentroidIndex), ccdOutput(validCentroidIndex), validCentroidRows, validCentroidColumns, ...
            cadenceTimeStamps(jCadence), raPointing(jCadence), decPointing(jCadence), rollPointing(jCadence), aberrateFlag);

        % get positions for offsets in centroid row
        [centroidRaDeltaRow centroidDecDeltaRow] = pix_2_ra_dec_absolute(raDec2PixObject, ccdModule(validCentroidIndex), ccdOutput(validCentroidIndex), validCentroidRows+deltaRow, validCentroidColumns, ...
            cadenceTimeStamps(jCadence), raPointing(jCadence), decPointing(jCadence), rollPointing(jCadence), aberrateFlag);

        % get positions for offsets in centroid column
        [centroidRaDeltaColumn centroidDecDeltaColumn] = pix_2_ra_dec_absolute(raDec2PixObject, ccdModule(validCentroidIndex), ccdOutput(validCentroidIndex), validCentroidRows, validCentroidColumns+deltaColumn, ...
            cadenceTimeStamps(jCadence), raPointing(jCadence), decPointing(jCadence), rollPointing(jCadence), aberrateFlag);


        % terms in the row Jacobian
        dRaDeltaRow = (centroidRaDeltaRow - centroidRa)./deltaRow;
        dDecDeltaRow = (centroidDecDeltaRow - centroidDec)./deltaRow;

        % terms in the column Jacobian
        dRaDeltaColumn = (centroidRaDeltaColumn - centroidRa)./deltaColumn;
        dDecDeltaColumn = (centroidDecDeltaColumn - centroidDec)./deltaColumn;

        centroidUncertaintyStruct(jCadence).TrowColumnToRa = [diag(dRaDeltaRow) diag(dRaDeltaColumn)]; % ntargets x 2*ntargets
        centroidUncertaintyStruct(jCadence).TrowColumnToDec = [diag(dDecDeltaRow) diag(dDecDeltaColumn)];% ntargets x 2*ntargets

        centRa(validCentroidIndex, jCadence)  = centroidRa;
        centDec(validCentroidIndex, jCadence) = centroidDec;
    else

        centRa(:, jCadence)  = -1;
        centDec(:, jCadence) = -1;

        centroidUncertaintyStruct(jCadence).TrowColumnToRa = [];
        centroidUncertaintyStruct(jCadence).TrowColumnToDec = [];

    end

end
