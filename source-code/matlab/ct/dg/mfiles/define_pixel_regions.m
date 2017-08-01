function [starRowStart, starRowEnd, starColStart,starColEnd,... 
    leadingBlackRowStart, leadingBlackRowEnd, leadingBlackColStart, leadingBlackColEnd,...
    trailingBlackRowStart, trailingBlackRowEnd, trailingBlackColStart, trailingBlackColEnd,...
    maskedSmearRowStart, maskedSmearRowEnd, maskedSmearColStart, maskedSmearColEnd...
    virtualSmearRowStart, virtualSmearRowEnd, virtualSmearColStart, virtualSmearColEnd] =...
    define_pixel_regions()
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

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [starRowStart, starRowEnd, starColStart,starColEnd,... 
%     leadingBlackRowStart, leadingBlackRowEnd, leadingBlackColStart, leadingBlackColEnd,...
%     trailingBlackRowStart, trailingBlackRowEnd, trailingBlackColStart, trailingBlackColEnd,...
%     maskedSmearRowStart, maskedSmearRowEnd, maskedSmearColStart, maskedSmearColEnd...
%     virtualSmearRowStart, virtualSmearRowEnd, virtualSmearColStart, virtualSmearColEnd] =...
%     define_pixel_regions()
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% define_pixel_regions obtains the start and end row and column
% indeces for each of the pixel regions defined in FcConstants.class
% 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

import gov.nasa.kepler.common.FcConstants;

starRowStart = FcConstants.nMaskedSmear + 1; 
starRowEnd = FcConstants.nRowsImaging  + FcConstants.nMaskedSmear;
starColStart = FcConstants.nLeadingBlack + 1;
starColEnd = FcConstants.nColsImaging + FcConstants.nLeadingBlack;

leadingBlackRowStart = FcConstants.LEADING_BLACK_START + 1;
leadingBlackRowEnd = FcConstants.CCD_ROWS;
leadingBlackColStart = FcConstants.LEADING_BLACK_START + 1;
leadingBlackColEnd = FcConstants.LEADING_BLACK_END + 1;

trailingBlackRowStart = FcConstants.LEADING_BLACK_START + 1;
trailingBlackRowEnd = FcConstants.CCD_ROWS;
trailingBlackColStart = FcConstants.TRAILING_BLACK_START + 1;
trailingBlackColEnd = FcConstants.TRAILING_BLACK_END + 1;

maskedSmearRowStart = FcConstants.MASKED_SMEAR_START + 1;
maskedSmearRowEnd = FcConstants.MASKED_SMEAR_END + 1;
maskedSmearColStart = FcConstants.nLeadingBlack + 1;
maskedSmearColEnd = FcConstants.nColsImaging + FcConstants.nLeadingBlack;


virtualSmearRowStart = FcConstants.VIRTUAL_SMEAR_START + 1;
virtualSmearRowEnd = FcConstants.VIRTUAL_SMEAR_END + 1;
virtualSmearColStart = FcConstants.nLeadingBlack + 1;
virtualSmearColEnd = FcConstants.nColsImaging + FcConstants.nLeadingBlack;

return