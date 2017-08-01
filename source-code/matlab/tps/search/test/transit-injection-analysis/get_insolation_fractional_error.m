% estimate insolation errors for KOIs
% Use DV 9.3 v4 OPS run results -- KSOP-2537
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


% get dvOutputMatrix from task files directory
cd /path/to/mq-q1-q17/pipeline_results/dv-v4/
load dvOutputMatrix


% Useful columns
% planetKoiId -- column 190
% planetKoiCorrelation -- column 191
% allTransitsFit_ratioSemiMajorAxisToStarRadius_value --  99 
% allTransitsFit_ratioSemiMajorAxisToStarRadius_uncertainty --  100


% Identify known KOIs
idx = dvOutputMatrix(:,190) > 0 & dvOutputMatrix(:,100) >= 0;
fprintf('There are %d known KOIs with estimated errors on a/Rstar among the %d DR25 TCEs\n',sum(idx),length(idx))

% Fractional uncertainty in ratio of a/R for known KOIs
fracUncInSemiMajorAxisToRstarRatio = dvOutputMatrix(idx,100)./dvOutputMatrix(idx,99);
fprintf('The median fractional uncertainty in a/Rstar over all the KOIs is %7.2f\n',median(fracUncInSemiMajorAxisToRstarRatio));



% Fractional uncertainty in insolation, neglecting fractional uncertainty
% in effective temperature
% insolation is proportional to Teff^4 * (Rstar/a)^2
fracInsolationUnc = sqrt(2)*fracUncInSemiMajorAxisToRstarRatio;
fprintf('The median fractional insolation uncertainty over all the KOIs is %7.2f\n',median(fracInsolationUnc));
