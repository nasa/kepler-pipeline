function cbdObj = retrieve_FFIs(cbdObj, dirOfFFIs, fileOfFFIs, channelIndex)
% function cbdObj = retrieve_FFIs(cbdObj, dirOfFFIs, fileOfFFIs)
% Fetch image data of specified channel from FFIs of given directory and file name array.
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

constants;

numOfFitsFiles = length( fileOfFFIs );

if ( numOfFitsFiles == 0 )
    error('Number of FFIs is zero?!');
end

k = 1;
fitsFileName = fullfile(dirOfFFIs, fileOfFFIs{k});
FILE_EXIST = 2;
if ~( exist(fitsFileName, 'file') == FILE_EXIST )
    error( ['FITS file not found: ' fitsFileName] );
end

try
    fitsInfo = fitsinfo(fitsFileName);
    fitsWidth = fitsInfo.Image(1).Size(1);
    fitsHeight =fitsInfo.Image(1).Size(2);
    fitsNum = length(fitsInfo.Image);
catch
    error('');
end
if ~( fitsNum == 84 )
    error( 'Number of FFIs retrieved in FITS file not equal to 84!' );
end

cbdObj.originalFFIs = zeros(fitsHeight, fitsWidth, numOfFitsFiles);
    
% loop through each of the input files
for k=1:numOfFitsFiles
    fitsFileName = fullfile(dirOfFFIs, fileOfFFIs{k});
    
    FILE_EXIST = 2;
    if ( exist(fitsFileName, 'file') ~= FILE_EXIST )
        error( strcat('FITS file not found: ', fitsFileName) );
    end

    ccdImage = fitsread(fitsFileName, 'image', channelIndex);
    ccdImage = ccdImage / cbdObj.numOfCoAdds; % ccdImageCR

    cbdObj.originalFFIs(:, :, k) = ccdImage;
end


if ( cbdObj.debugStatus )
        fprintf(' Totally retrieved %2d FFIs\n', numOfFitsFiles);
end

return

