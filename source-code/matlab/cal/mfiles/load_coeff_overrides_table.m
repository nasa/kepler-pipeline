function [overridesTable, logicalIdx, valueIdx, varianceIdx, channelIdx, seasonIdx] = load_coeff_overrides_table( )
%
% function [overridesTable, logicalIdx, valueIdx, varianceIdx, channelIdx, seasonIdx] = load_coeff_overrides_table( )
%
% This function returns the hard coded coefficient overrides table for the 1D black fit in CAL. Column indices
% into the table indicating logical, value, variance for all 1D black fit coefficients plus channel and season 
% are also optionally returned. 
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

% TABLE MAP:
% column 1 == channel
% column 2 == season
% column 3-20 == 3 entries for each coeff inorder --> flag (for whether to override coefficient, 0==false, 1==true), value, variance
%
% 2012/3/1 - 1D black model components by coeffiecient index
% See: CAL function initialize_1dblack_model.m
% 1 - const (row > maxMaskedSmearRow);
% 2 - linear (row > maxMaskedSmearRow);
% 3 - exprow_long_rowtc (row > maxMaskedSmearRow);
% 4 - exprow_short_rowtc (row > maxMaskedSmearRow);
% 5 - const (row <= maxMaskedSmearRow);
% 6 - linear (row <= maxMaskedSmearRow);


% hard coded constants
seasons = 0:3;
channels = 1:84;
numCoefficients = 6;

% derived constants
channelIdx  = 1;
seasonIdx   = 2;
logicalIdx  = (1:numCoefficients) .* 3;
valueIdx    = 1 + (1:numCoefficients) .* 3;
varianceIdx = 2 + (1:numCoefficients) .* 3;
numColumns  = 2 + 3 * numCoefficients;
numRows     = length(channels) * length(seasons);


% initialize table with zero coefficients and no-override condition
overridesTable = zeros(numRows,numColumns);

% seed channel numbers in first column
overridesTable(1:length(seasons):end,1) = colvec(channels);
overridesTable(2:length(seasons):end,1) = colvec(channels);
overridesTable(3:length(seasons):end,1) = colvec(channels);
overridesTable(4:length(seasons):end,1) = colvec(channels);

% seed season number in second column
overridesTable(1:end,2) = colvec(seasons(mod((1:numRows)-1,length(seasons))+1));


% specify any coefficient overrides here
% index = 4*(channel - 1) + (season + 1)
% use full row of table e.g. [channel, season, 6 x [boolean, value, variance] ]

% bright star in low row/high column corner of mod out rotated through 4 seasons
% ~~~~~~~~ deactivate short row time constant term and set masked smear bias and slope terms
overridesTable(261,:) = [66 0 0 0 0 0 0 0 0 0 0 1 0 0 1 -80 10 1 0 0.4];
% ~~~~~~~~ deactivate short row time constant term
overridesTable(102,:) = [26 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 ];
overridesTable(71,:)  = [18 2 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 ];
overridesTable(232,:) = [58 3 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 ];

% % ~~~~~~~~ deactivate long and short row time constant terms
% overridesTable(102,:) = [26 1 0 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 ];

