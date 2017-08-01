function [ rpFilePixelValues, pdqPixelValues] = double_check_read_eeis_data(is, fileNames)

% inputs: pdq-inputs-0.mat created by the java side and the names of the rp file that went into the
% creation of the rp files
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

% for example, fileNames could be a cell array of dimension 3x1

% fileNames = dir('*.rp');

if(~exist('fileNames', 'var'))
    fileNames = dir('*.rp');
    
    fileNames = {fileNames.name};
end

nStellarPixels = 0;

nStellarTargets = length(is.stellarPdqTargets);


for j = 1:nStellarTargets,
    nStellarPixels = nStellarPixels + length(is.stellarPdqTargets(j).referencePixels);
end

nBkgdTargets = length(is.backgroundPdqTargets);

nBkgdPixels = 0;

for j = 1:nBkgdTargets,
    nBkgdPixels = nBkgdPixels + length(is.backgroundPdqTargets(j).referencePixels);
end

nCollateralPixels = 0;
nCollateralTargets = length(is.collateralPdqTargets);
for j = 1:nCollateralTargets,
    nCollateralPixels = nCollateralPixels + length(is.collateralPdqTargets(j).referencePixels);
end

stellarPixelValues = [];
for j = 1:nStellarTargets,
    stellarPixelValues = [stellarPixelValues  cat(2, is.stellarPdqTargets(j).referencePixels.timeSeries)];
end

bkgdPixelValues = [];

for j = 1:nBkgdTargets,
    bkgdPixelValues = [bkgdPixelValues cat(2, is.backgroundPdqTargets(j).referencePixels.timeSeries)] ;
end

collateralPixelValues = [];
for j = 1:nCollateralTargets,
    collateralPixelValues = [collateralPixelValues cat(2, is.collateralPdqTargets(j).referencePixels.timeSeries)];
end

nCadences = length(is.cadenceTimes);

pdqPixelValues = ([stellarPixelValues bkgdPixelValues collateralPixelValues])';
pdqPixelValues = sort(pdqPixelValues);


for j = 1:nCadences

    rpFilePixelValues = read_reference_pixel_file(fileNames{j});
    rpFilePixelValues = sort(rpFilePixelValues);


    h1 = plot(rpFilePixelValues, 'b.-');
    hold on;
    h2 = plot( pdqPixelValues(:,j), 'r.:');
    legend([h1 h2], {'rp file', 'mat file'});

    title('pixel values read from mat file versus rp file');
    paperOrientationFlag = false;
    includeTimeFlag = false;
    printJpgFlag = false;
    fileNamestr = ['pixel values read from mat file versus rp file for cadence ' num2str(j)];
    plot_to_file(fileNamestr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    close all;


end

return;

% comments taken from RefPixelFileReader.java also from FS-GD ICD/SOC-MOC ICD
%   How to parse the Reference Pixel File sent by the MOC to the
%   SOC after an X-Band contact.
%
%   This file contains values for all reference pixels from the baseline image.
%   There is one reference pixel file per long cadence baseline (nominally one
%   per day, and 4 per x-band contact). The order of the pixels in the file is
%   the same as the order that the pixels are listed in the reference pixel
%   target table.
%
%   The file has the following format (from the FS-GS ICD, section 5.3.1.3.6):
%
%   <pre>
%   Byte
%   Offset   Content
%   ------------------------------------------
%    0-4     timestamp
%    0-3       seconds
%    4         fraction of seconds (LSB is 4.096 msec)
%    5-12      photometer config id
%    5           flags
%    6           long cadence target table id
%    7           short cadence target table id
%    8           background target table id
%    9           background aperture table id
%   10           science aperture table id
%   11           reference pixel target table id
%   12           compression table id
%   13-16    reference pixel #1
%   17-20    reference pixel #2
%   21+      ...continues for all reference pixels
%
%   This code assumes all values in the reference pixel file are BIG-ENDIAN.







