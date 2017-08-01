function catalogData = read_catalog(etem1CatalogObject, ccdObject)
%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

runParamsObject = etem1CatalogObject.runParamsClass;

moduleNumber = get(runParamsObject, 'moduleNumber');
outputNumber = get(runParamsObject, 'outputNumber');
observingSeason = get(runParamsObject, 'observingSeason');
numVisibleRows = get(runParamsObject, 'numVisibleRows');
numVisibleCols = get(runParamsObject, 'numVisibleCols');
timeVector = get(runParamsObject, 'timeVector');
raDec2PixObject = get(runParamsObject, 'raDec2PixObject');
centerTimeIndex = get(raDec2PixObject, 'centerTimeIndex');

catalogFileLocation = etem1CatalogObject.catalogFileLocation;
besanconCatalogFilename = etem1CatalogObject.besanconCatalogFilename;

% Location of the catalog files this routine uses.
galaxyFile = [catalogFileLocation filesep 'KIC' filesep 'galaxy.mat'];
raFile = [catalogFileLocation filesep 'KIC' filesep 'ra.mat'];
dec_File = [catalogFileLocation filesep 'KIC' filesep 'dec.mat'];
kepmagFile = [catalogFileLocation filesep 'KIC' filesep 'kepmag.mat'];
kicidFile = [catalogFileLocation filesep 'KIC' filesep 'kicid.mat'];
besanconFile = [catalogFileLocation filesep besanconCatalogFilename];

% make the catalog data output self-documenting
catalogData.moduleNumber = moduleNumber;
catalogData.outputNumber = outputNumber;
catalogData.observingSeason = observingSeason;

% Load RA & Dec files (entire catalog)
eval(['load ' raFile]);
ra = 15*ra';  % convert from hours to degrees
eval(['load ' dec_File]);
dec = dec';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now get rid of catalog entries outside of the RA/Dec of interest range.
% Note that this is NOT the same as finding out what catalog objects are on the
% output for this simulation.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find the unaberrated RA/Dec of the four corners of the module/output/season
t = timeVector(centerTimeIndex);
[raCorners, decCorners] = pix_to_ra_dec(raDec2PixObject, ...
    moduleNumber*[1 1 1 1]', ...
    outputNumber*[1 1 1 1]', ...
    [1    1 numVisibleRows numVisibleRows]', ...
    [1 numVisibleCols    1 numVisibleCols]', timeVector(centerTimeIndex), 0);

% Limit what you have to the catalog entries within 0.01 degrees of the
% min/max RA & Dec of the output corners.  This gives enough "slop" so that any
% DVA will not cause stars to be either missed or included inappropriately.
downsize1 = find( min( raCorners)-0.01 <=  ra &  ra <= max( raCorners)+0.01 & ...
                  min(decCorners)-0.01 <= dec & dec <= max(decCorners)+0.01);
clear raCorners decCorners

% Actual limiting takes place here...
catalogData.ra  =  ra(downsize1);
clear ra;
catalogData.dec = dec(downsize1);
clear dec;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% in the following we violate the variable name coding standard to remain
% consistent with the variable names in the loaded mat files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the unique kepler input catalog ID variable & limit it to the objects of interest
eval(['load ' kicidFile]);
catalogData.kicId = kicid(downsize1)';
clear kicid;

% Load the magnitude variable & limit it to the objects of interest
eval(['load ' kepmagFile]);
catalogData.keplerMagnitude = kepmag(downsize1)';
clear kepmag;

% Load the galaxy variable & limit it to the objects of interest
% galaxy is not one of the output fields
eval(['load ' galaxyFile]);
galaxy = galaxy(downsize1)';

clear downsize1

% Make up a luminosity class, spectral type & spectral subtype for these stars
% All module info is the same, so send in only one element: module(1).
catalogData = assign_attributes(etem1CatalogObject, galaxy, ...
    catalogData, besanconFile);


