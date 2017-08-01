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
function [predictedRows, predictedColumns, TpredRowsStruct, TpredColsStruct] = get_predicted_star_positions_II(raDec2PixObject, ccdModule, ccdOutput, raStars, decStars,...
    cadenceTimeStamps, raPointing, decPointing, rollPointing, aberrateFlag)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%
% Output:
%     predictedRows     An MxN matrix, where entry (m,n) denotes the
%                       predicted decimal row position of star m at cadence 
%                       n or -1 if input pointing args are -1. 
%     predictedColumns  An MxN matrix, where entry (m,n) denotes the
%                       predicted decimal column position of star m at  
%                       cadence n or -1 if input pointing args are -1. 
%     TpredRowsStruct   Row Jacobian for each cadence, approximated by
%                       differencing. Row differences are obtained by
%                       purturbing the RA, Dec, and Roll values by an
%                       amount delta = eps^(1/3) and computing the changes
%                       in predicted row position via ra_dec_2_pix_absolute(). 
%                       The Jacobian approximation is given by
%
%                           [ (deltaRaPredRows - predRows)./delta   ]
%                           [ (deltaDecPredRows - predRows)./delta  ]
%                           [ (deltaRollPredRows - predRows)./delta ]
%
%     TpredColsStruct   Column Jacobian for each cadence
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

nStars      = length(raStars);
nCadences   = length(cadenceTimeStamps);


% set up offsets in centroid row, columns

derivStep = eps^(1/3); % from statset('nlinfit'), used to compute numerical jacobian

deltaRa     = derivStep; % 1/100th of a pixel (pixel occupies 3.98 arcsec, 1 arcsec = 1/3600)
deltaDec    = derivStep; % 1/100th of a pixel (pixel occupies 3.98 arcsec, 1 arcsec = 1/3600)
deltaRoll   = derivStep;


predictedRows = zeros(nStars, nCadences);
predictedColumns = zeros(nStars, nCadences);
TpredRowsStruct = repmat(struct('TpointingToPredRows', zeros(nStars, 3)), nCadences, 1);
TpredColsStruct = repmat(struct('TpointingToPredCols', zeros(nStars, 3)), nCadences, 1);

for jCadence = 1:nCadences

    % check with JJ as to which script should be called (I think it should
    % be pix_2_ra_dec_absolute_zero_based..)

    % check for valid attitude solution for this cadence
    if(raPointing(jCadence) == -1)
        TpredRowsStruct(jCadence).TpointingToPredRows = [];
        TpredColsStruct(jCadence).TpointingToPredCols = [];


        predictedRows(:, jCadence)  = -1;
        predictedColumns(:, jCadence) = -1;
        continue;
    end


    [module output predRows predCols] = ra_dec_2_pix_absolute( raDec2PixObject, raStars, decStars, ...
        cadenceTimeStamps(jCadence), raPointing(jCadence), decPointing(jCadence), rollPointing(jCadence), aberrateFlag);


    if((unique(module) ~= ccdModule) || (unique(output) ~= ccdOutput))
        error('PDQ:centroidMetric:getPredictedStarPositionII', ...
            'mismatch between returned module and actual module (or returned ouput and actual module output)');

    end



    % get positions for offsets in centroid row
    [module output deltaRaPredRows deltaRaPredCols] = ra_dec_2_pix_absolute(raDec2PixObject, raStars, decStars, ...
        cadenceTimeStamps(jCadence), raPointing(jCadence)+deltaRa, decPointing(jCadence), rollPointing(jCadence), aberrateFlag);

    % get positions for offsets in centroid column
    [module output deltaDecPredRows deltaDecPredCols] = ra_dec_2_pix_absolute(raDec2PixObject, raStars, decStars, ...
        cadenceTimeStamps(jCadence), raPointing(jCadence), decPointing(jCadence)+deltaDec, rollPointing(jCadence), aberrateFlag);


    % get positions for offsets in centroid column
    [module output deltaRollPredRows deltaRollPredCols] = ra_dec_2_pix_absolute(raDec2PixObject, raStars, decStars, ...
        cadenceTimeStamps(jCadence), raPointing(jCadence), decPointing(jCadence), rollPointing(jCadence)+deltaRoll, aberrateFlag);

    % terms in the row Jacobian
    dRowDeltaRa = (deltaRaPredRows - predRows)./deltaRa;
    dRowDeltaDec = (deltaDecPredRows - predRows)./deltaDec;
    dRowDeltaRoll = (deltaRollPredRows - predRows)./deltaRoll;

    % terms in the column Jacobian
    dColDeltaRa = (deltaRaPredCols - predCols)./deltaRa;
    dColDeltaDec = (deltaDecPredCols - predCols)./deltaDec;
    dColDeltaRoll = (deltaRollPredCols - predCols)./deltaRoll;


    TpredRowsStruct(jCadence).TpointingToPredRows = [dRowDeltaRa dRowDeltaDec dRowDeltaRoll];
    TpredColsStruct(jCadence).TpointingToPredCols = [dColDeltaRa dColDeltaDec dColDeltaRoll];


    predictedRows(:, jCadence)  = predRows;
    predictedColumns(:, jCadence) = predCols;


end
