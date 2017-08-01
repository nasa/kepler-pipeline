function dgTrimmedImageObj = dgTrimmedImageClass...
    ( module, output, numCoadds, startMjd, endMjd, ffiImage)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function dgTrimmedImageObj = dgTrimmedImageClass 
% (module, output, numCoadds, startMjd, endMjd, ffiImage)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% class constructor for dgTrimmedImageClass
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS:
%
%           module: [int] CCD module number
%           output: [int] CCD output number
%        numCoadds: [int] number of coadds
%         startMjd: [double] start MJD time of data
%           endMjd: [double] end MJD time of data
%         ffiImage: [double] untrimmed image 1070 x 1132
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% OUTPUTS: an object, dgTrimmedImageObj with the fields
%
%           module: [int] CCD module number
%           output: [int] CCD output number
%        numCoadds: [int] number of coadds
%         startMjd: [double] start MJD time of data
%           endMjd: [double] end MJD time of data
%             star: [array double] normalized pixel values of the star region
%     leadingBlack: [array double] normalized pixel values of leading black region
%    trailingBlack: [array double] normalized pixel values of the trailing black region
%      maskedSmear: [array double] normalized pixel values of the masked smear region
%     virtualSmear: [array double] normalized pixel values of thevirtual
%     smear region
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

% initialize structure
trimFfiStruct = struct('module', module, 'output', output,...
    'numCoadds', numCoadds,'startMjd', startMjd, 'endMjd', endMjd,...
    'star', [], 'leadingBlack', [], 'trailingBlack', [],...
    'maskedSmear', [], 'virtualSmear', []);



% obtain row and col start for each of the pixel regions by calling
% define_pixel_regions() function
[starRowStart, starRowEnd, starColStart,starColEnd,... 
    leadingBlackRowStart, leadingBlackRowEnd, leadingBlackColStart, leadingBlackColEnd,...
    trailingBlackRowStart, trailingBlackRowEnd, trailingBlackColStart, trailingBlackColEnd,...
    maskedSmearRowStart, maskedSmearRowEnd, maskedSmearColStart, maskedSmearColEnd...
    virtualSmearRowStart, virtualSmearRowEnd, virtualSmearColStart, virtualSmearColEnd] =...
    define_pixel_regions();



% continue building the structure
trimFfiStruct.star = ffiImage(starRowStart:starRowEnd, starColStart:starColEnd)/numCoadds;
trimFfiStruct.leadingBlack = ffiImage(leadingBlackRowStart:leadingBlackRowEnd, leadingBlackColStart:leadingBlackColEnd)/numCoadds;
trimFfiStruct.trailingBlack = ffiImage(trailingBlackRowStart:trailingBlackRowEnd, trailingBlackColStart:trailingBlackColEnd)/numCoadds;
trimFfiStruct.maskedSmear = ffiImage(maskedSmearRowStart:maskedSmearRowEnd, maskedSmearColStart:maskedSmearColEnd)/numCoadds;
trimFfiStruct.virtualSmear =ffiImage(virtualSmearRowStart:virtualSmearRowEnd, virtualSmearColStart:virtualSmearColEnd)/numCoadds;



% class constructor
dgTrimmedImageObj = class(trimFfiStruct, 'dgTrimmedImageClass');



