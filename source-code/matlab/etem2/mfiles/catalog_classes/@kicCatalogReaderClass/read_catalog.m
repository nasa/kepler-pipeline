function catalogData = read_catalog(kicCatalogObject, ccdObject)
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

runParamsObject = kicCatalogObject.runParamsClass;

moduleNumber = get(runParamsObject, 'moduleNumber');
outputNumber = get(runParamsObject, 'outputNumber');
observingSeason = get(runParamsObject, 'observingSeason');
numVisibleRows = get(runParamsObject, 'numVisibleRows');
numVisibleCols = get(runParamsObject, 'numVisibleCols');
timeVector = get(runParamsObject, 'timeVector'); % in julian days
raDec2PixObject = get(runParamsObject, 'raDec2PixObject');
centerTimeIndex = get(raDec2PixObject, 'centerTimeIndex');

besanconCatalogFilename = kicCatalogObject.besanconCatalogFilename;

besanconFile = [kicCatalogObject.catalogFileLocation filesep besanconCatalogFilename];

% make the catalog data output self-documenting
catalogData.moduleNumber = moduleNumber;
catalogData.outputNumber = outputNumber;
catalogData.observingSeason = observingSeason;

%  set the time for the catalog load
catalogLoadTime = timeVector(centerTimeIndex); % convert to mjd

% load the catalog data for this module output and time
kicData = retrieve_kics(moduleNumber, outputNumber, catalogLoadTime);
%%
nStars = length(kicData);
ra = zeros(nStars, 1);
dec = zeros(nStars, 1);
kicId = zeros(nStars, 1);
keplerMagnitude = zeros(nStars, 1);
logSurfaceGravity = zeros(nStars, 1);
logMetallicity = zeros(nStars, 1);
effectiveTemperature = zeros(nStars, 1);
% radius = zeros(nStars, 1);
catalogCount = 1;
for i=1:nStars
    if ~isempty(kicData(i).keplerMag.value) &&  ~isnan(kicData(i).keplerMag.value)
        ra(catalogCount) = double(kicData(i).ra.value);
        dec(catalogCount) = double(kicData(i).dec.value);
        kicId(catalogCount) = double(kicData(i).keplerId);
        keplerMagnitude(catalogCount) = double(kicData(i).keplerMag.value);
        % if there is no Log10SurfaceGravity then there is no
        % Log10Metallicity, EffectiveTemp and Radius
        if ~isempty(kicData(i).log10SurfaceGravity.value) && ~isnan(kicData(i).log10SurfaceGravity.value)
            logSurfaceGravity(catalogCount) = double(kicData(i).log10SurfaceGravity.value);
            effectiveTemperature(catalogCount) = double(kicData(i).effectiveTemp.value);
%             radius(catalogCount) = double(kicData(i).radius.value);
            % but there may still be no metallicity
            if ~isempty(kicData(i).log10Metallicity.value) && ~isnan(kicData(i).log10Metallicity.value)
                logMetallicity(catalogCount) = double(kicData(i).log10Metallicity.value);
            else
                logMetallicity(catalogCount) = -1;
            end
        else
            logMetallicity(catalogCount) = -1;
            logSurfaceGravity(catalogCount) = -1;
            effectiveTemperature(catalogCount) = -1;
%             radius(catalogCount) = -1;
        end
        catalogCount = catalogCount + 1;
    end
end
%%
clear kicData;

% trim off bad entries
downsize1 = find(keplerMagnitude ~= 0);

% load this module and output from the 
% Actual limiting takes place here...
catalogData.ra  = 15*ra(downsize1); % convert to degrees from hours
clear ra;
catalogData.dec = dec(downsize1);
clear dec;
catalogData.kicId = kicId(downsize1);
clear kicId;
catalogData.keplerMagnitude = keplerMagnitude(downsize1);
clear keplerMagnitude;
catalogData.logSurfaceGravity = logSurfaceGravity(downsize1);
clear logSurfaceGravity;
catalogData.logMetallicity = logMetallicity(downsize1);
clear logMetallicity;
catalogData.effectiveTemperature = effectiveTemperature(downsize1);
clear effectiveTemperature;
% catalogData.radius = radius(downsize1);
% clear radius;

clear downsize1

% Make up a luminosity class, spectral type & spectral subtype for these stars
% All module info is the same, so send in only one element: module(1).
catalogData = assign_attributes(kicCatalogObject, ...
    catalogData, besanconFile);


