function matFileStatus = dg_save_mat_file( fullMatFileName, dgStatistics)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function matFileStatus = dg_save_mat_file(fullMatFileName, dgStatistics)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% saves dgStatistics to a mat file specified by fullMatFileName
% if file is saved, matFileStatus returns 1, otherwise, 0
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS: 
%           dgStatistics is 1 x 84 struct with the following fields
%
%   FIRST LEVEL- 
%
%               module : [int] CCD module number
%                output: [int] CCD output number
%             numCoadds: [int] number of cocadds
%              startMjd: [double] start MJD time of data
%                endMjd: [double] end MJD time of data
%                  star: [struct] statistics of the star region
%          leadingBlack: [struct] statistics of the leading black region
%         trailingBlack: [struct] statistics of the trailing black region
%           maskedSmear: [struct] statistics of the masked smear region
%          virtualSmear: [struct] statistics of the virtual smear region
%
%    SECOND LEVEL-
%
%           star, leadingBlack, trailingBlack, maskedSmear, virtualSmear
%           are structs having the following fields:
%
%                   min: [double] the minimum value for the normalized 
%                                 pixel region
%                   max: [double] the maximum  value for the normalized
%                                 pixel region
%                  mean: [double] the mean value for the normalized
%                                 pixel region 
%                median: [double] the median value for the normalized
%                                 pixel region
%                  mode: [double] the most frequent value for the 
%                                 normalized pixel region
%                 stdev: [double] the standard diviation for the normalized
%                                 pixel region
%    expectedPixelCount: [int] the expected number of pixels (and data
%                              points) for the pixel region
%  percentPixelComplete: [double] percent of pixels that had data
%                                 transmission
%      highGuardBandVal: [double] defined as 0.95 x (2^14-1) for all
%                                 module outputs
%     countPixHighGuard: [int] number of pixels above the highGuardBandBand for
%                              the pixel region
%       lowGuardBandVal: [double] this is defined as 0.95 x mean black of
%                                 the module output
%      countPixLowGuard: [int] number of pixels below lowGuardBandVal for the
%                                 pixel region
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT:
%          
%               mat file with the dg statistics for each modout
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


try
  
    string = ['save ' fullMatFileName ' ' inputname(2)];
    string2 = [inputname(2) '= dgStatistics'];
    eval(string2);
    eval(string);
    matFileStatus = 1;
    fprintf('successfully saved dg statistics mat file ''%s''\n ', fullMatFileName)

catch
    
    matFileStatus = 0;
    fprintf('Unable to save dg statistics mat file ''%s''\n ', fullMatFileName)
    
end

return