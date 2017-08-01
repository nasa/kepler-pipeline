function catalogData = assign_attributes(etem1CatalogObject, galaxy, ...
    catalogData, besanconCatalogFilename) %#ok

% In this subroutine, the season number is used to index an array.  
% Hence, the need to use the season numbering 1-4 rather than 0-3.
% 1=fall, 2=winter, 3=spring, but 0 and/or 4 represent summer
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
if catalogData.observingSeason == 0
    catalogData.observingSeason = 4;
end

% Summer = 4 (not 0), Fall = 1, Winter = 2, Spring = 3
moduleMap = cell(4,1);

% define winter (season 2)
moduleMap{2} = [ ...
     0  2  3  4  0
     6  7  8  9 10
    11 12 13 14 15
    16 17 18 19 20
     0 22 23 24  0];

% rotate to find fall
moduleMap{1} = rot90(moduleMap{2});

% rotate to find summer
moduleMap{4} = rot90(moduleMap{1});

% rotate to find spring
moduleMap{3} = rot90(moduleMap{4});

% Which row & column (which will tell you the correct module) needs to get loaded?
[r, c] = find(catalogData.moduleNumber==moduleMap{catalogData.observingSeason});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% don't want to mess with the variable names in the following lines since
% they are involved in an algorithmic construction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get ready to read in luminosityClass magnitude spectralSubType spectralType
[var_fields{1:4}] = deal('lum_class','magnitude','sp_subtype','sp_type');

for i = 1:length(var_fields)

    % Construct the variable name, e.g. "magnitude_8_1", "sp_subtype_23_1"
    % Note that we'll always use output 1 becasue all outputs are the same for the
    % Besancon catalog because it was generated on a MODULE basis.
    cat_str = [var_fields{i} '_' num2str(moduleMap{2}(r,c)) '_1'];

    % Now load "sp_type23_1" out of the catalog file
    eval(['load(besanconCatalogFilename,''' cat_str ''');'])

    % Now set "lum_class_b" to equal "lum_class_17_1" to standardize the rest of the routine
    eval([var_fields{i} '_b =' cat_str ';'])

    % Now clear the variable "magnitude_2_1" to free up space
    eval(['clear ' cat_str]);

end

% Set up room for output variables
catalogData.luminosityClass = zeros(size(catalogData.keplerMagnitude));
catalogData.spectralType = zeros(size(catalogData.keplerMagnitude));
catalogData.spectralSubType = zeros(size(catalogData.keplerMagnitude));

% Bright stars in the KIC and in the Besancon model
kicIndexSet = find(catalogData.keplerMagnitude < 10);
besanconIndexSet   = find(magnitude_b < 10);

% NOTE: The Besancon model has subtypes listed as 1-10 and so 1 must be
% subtracted to give 0-9 for subtype values below.

% Assign random draws from the Besancon model to the KIC for luminosityClass, spectralType, spectralSubType
catalogData.luminosityClass(kicIndexSet) = ...
    lum_class_b( besanconIndexSet( ...
    round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) );
catalogData.spectralType(kicIndexSet) = ...
    sp_type_b( besanconIndexSet( ...
    round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) );
catalogData.spectralSubType(kicIndexSet) = ...
    sp_subtype_b( besanconIndexSet( ...
    round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) )-1; % 0-9

% Do the "medium" brightness stars in bins of 1 magnitude
for i = 10:15

    % Medium stars in the KIC and in the Besancon model
    kicIndexSet = find(i <= catalogData.keplerMagnitude & catalogData.keplerMagnitude  < i+1);
    besanconIndexSet = find(i <= magnitude_b & magnitude_b < i+1);

    % Assign random draws from the Besancon model to the KIC for luminosityClass, spectralType, spectralSubType
    catalogData.luminosityClass(kicIndexSet) = lum_class_b( besanconIndexSet( ...
        round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) );
    catalogData.spectralType(kicIndexSet) = sp_type_b( besanconIndexSet( ...
        round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) );
    catalogData.spectralSubType(kicIndexSet) = sp_subtype_b( besanconIndexSet( ...
        round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) )-1; % 0-9

end

% Dim stars in the KIC and in the Besancon model
kicIndexSet = find(catalogData.keplerMagnitude >= 16);
besanconIndexSet = find(magnitude_b >= 16);

% Assign random draws from the Besancon model to the KIC for luminosityClass, spectralType, spectralSubType
catalogData.luminosityClass(kicIndexSet) = lum_class_b( besanconIndexSet( ...
    round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) );
catalogData.spectralType(kicIndexSet) = sp_type_b( besanconIndexSet( ....
    round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) );
catalogData.spectralSubType(kicIndexSet) = sp_subtype_b( besanconIndexSet( ....
    round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) )-1; % 0-9

% Deal with galaxies....and illegal magnitude objects
badObjectIndexSet = find(galaxy==1| isnan(galaxy) | isnan(catalogData.keplerMagnitude));
catalogData.keplerMagnitude(badObjectIndexSet) = 30;

%Assign "illegal" luminosity class, spectral type, subtype
catalogData.luminosityClass(badObjectIndexSet)  = -1;
catalogData.spectralType(badObjectIndexSet)    = -1;
catalogData.spectralSubType(badObjectIndexSet) = -1;
