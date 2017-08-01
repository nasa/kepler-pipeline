function longCadenceImage = create_longCadence_image(dirLcFiles, module, output)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function longCadenceImage = create_longCadence_image(dirLcFiles, module, output)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% create_longCadence_image returns a sparse matrix of a 
% reconstructed FFI.  4 fits files are needed for this function to work:
%
%       (1) the target long cadence file,  *lcs-targ.fits file
%       (2) mapping of the target file, *lcm.fits file
%       (3) background pixel file, and, *lcs-bkg.fits file
%       (4) mapping of the background pixel file, *bgm.fits file
%
% LC image is constructed into an FFI using the the background and target
% files but not the collateral files as spatial information in these have
% been lost when summed on-board.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS:
%           
%           dirLcFiles: [string] directory of the long cadence files
%            module: [int] CCD module number
%            output: [int] CCD output number
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT:
%
%          longCadenceImage: [nRows x nCols double sparse] array of the
%          reconstructed long cadence image
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

% import Fc Constants
import gov.nasa.kepler.common.FcConstants;


% get the current location to be able to get back later
origLocation = pwd;
eval(['cd ' dirLcFiles])


% validate the directory with LC files...



% look for target's pmrf file
targetMapStruct = dir('*lcm.fits');
if isempty(targetMapStruct) 
    error('SBT:convert_from_lc_to_ffi', 'no pmrf file found')
end
if length(targetMapStruct) > 1
    error('SBT:convert_from_lc_to_ffi', 'multiple pmrfs found')
end
targetMapFile = targetMapStruct.name;

% look for the background pmrf file
bkgMapStruct = dir('*bgm.fits');
if isempty(bkgMapStruct) 
    error('SBT:convert_from_lc_to_ffi', 'no mapping file for backround pixels found')
end
if length(bkgMapStruct) > 1
    error('SBT:convert_from_lc_to_ffi', 'multiple mapping files for backround pixels found')
end
bkgMapFile = bkgMapStruct.name;

% look for the target file
targetStruct = dir('*lcs-targ.fits');
if isempty(targetStruct) 
    error('SBT:convert_from_lc_to_ffi', 'no target file found')
end
if length(targetStruct) > 1 
    error('SBT:convert_from_lc_to_ffi', 'multiple target files found')
end
targetFile = targetStruct.name;

% look for the backround file
bkgStruct = dir('*lcs-bkg.fits');
if isempty(bkgStruct) 
    error('SBT:convert_from_lc_to_ffi', 'no background file found')
end
if length(bkgStruct) > 1
    error('SBT:convert_from_lc_to_ffi', 'multiple background files found')
end
bkgFile = bkgStruct.name;



channel = convert_from_module_output(module, output);



% build target image
pmrfTargetTable = fitsread(targetMapFile,'bintable', channel);
targetRows = pmrfTargetTable{1};
targetCols = pmrfTargetTable{2};
targetPixels = cell2mat(fitsread(targetFile, 'bintable', channel));

% check that size of pmrf and target files map
if  length(targetRows) ~= length(targetPixels)
    error('SBT:convert_from_lc_to_ffi', 'length of target file and pmrf file do not match')
end

tempTargetImage = unique([targetRows+1, targetCols+1, targetPixels], 'rows');

targetImage = sparse(tempTargetImage(:,1), tempTargetImage(:,2), tempTargetImage(:,3),...
    FcConstants.CCD_ROWS, FcConstants.CCD_COLUMNS);



% build backgroud image
pmrfBkgTable = fitsread(bkgMapFile, 'bintable', channel);
bkgRows = pmrfBkgTable{1};
bkgCols = pmrfBkgTable{2};
bkgPixels = cell2mat(fitsread(bkgFile, 'bintable', channel));

% check that the size of mapping background file and backround file match
if  length(bkgRows) ~= length(bkgPixels)
    error('SBT:convert_from_lc_to_ffi', ...
        'length of background file and background mapping file do not match')
end

tempBkgImage = unique([bkgRows+1, bkgCols+1, bkgPixels], 'rows');

bkgImage = sparse(tempBkgImage(:,1), tempBkgImage(:,2), tempBkgImage(:,3),...
    FcConstants.CCD_ROWS, FcConstants.CCD_COLUMNS);



% add target and background image together
longCadenceImage = targetImage + bkgImage;

% find the pixels that intersected and got added together:
common  = intersect([tempTargetImage(:,1), tempTargetImage(:,2)], [tempBkgImage(:,1),  tempBkgImage(:,2)], 'rows');
commonIndx = sub2ind([FcConstants.CCD_ROWS FcConstants.CCD_COLUMNS], common(:,1), common(:,2));

% replace the common pixels with the target values
longCadenceImage(commonIndx) = targetImage(commonIndx);



% go back to original location
eval(['cd ' origLocation])
