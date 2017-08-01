function catalogData = assign_attributes(kicCatalogObject, ...
    catalogData, besanconCatalogFilename) %#ok
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

galaxy = [];

observingSeason = mod(catalogData.observingSeason,4);
moduleNumber = catalogData.moduleNumber;
% In this subroutine, the season number is used to index an array.  
% Hence, the need to use the season numbering 1-4 rather than 0-3.
% 1=fall, 2=winter, 3=spring, but 0 and/or 4 represent summer
if observingSeason == 0
    observingSeason = 4;
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
[r, c] = find(moduleNumber==moduleMap{observingSeason});

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

keplerMagnitude = catalogData.keplerMagnitude;
% Set up room for output variables
luminosityClass = zeros(size(keplerMagnitude));
spectralType = zeros(size(keplerMagnitude));
spectralSubType = zeros(size(keplerMagnitude));

% Bright stars in the KIC and in the Besancon model
kicIndexSet = find(keplerMagnitude < 10);
besanconIndexSet   = find(magnitude_b < 10);

% NOTE: The Besancon model has subtypes listed as 1-10 and so 1 must be
% subtracted to give 0-9 for subtype values below.

% Assign random draws from the Besancon model to the KIC for luminosityClass, spectralType, spectralSubType
luminosityClass(kicIndexSet) = ...
    lum_class_b( besanconIndexSet( ...
    round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) );
spectralType(kicIndexSet) = ...
    sp_type_b( besanconIndexSet( ...
    round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) );
spectralSubType(kicIndexSet) = ...
    sp_subtype_b( besanconIndexSet( ...
    round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) )-1; % 0-9

% Do the "medium" brightness stars in bins of 1 magnitude
for i = 10:15

    % Medium stars in the KIC and in the Besancon model
    kicIndexSet = find(i <= keplerMagnitude & keplerMagnitude  < i+1);
    besanconIndexSet = find(i <= magnitude_b & magnitude_b < i+1);

    % Assign random draws from the Besancon model to the KIC for luminosityClass, spectralType, spectralSubType
    luminosityClass(kicIndexSet) = lum_class_b( besanconIndexSet( ...
        round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) );
    spectralType(kicIndexSet) = sp_type_b( besanconIndexSet( ...
        round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) );
    spectralSubType(kicIndexSet) = sp_subtype_b( besanconIndexSet( ...
        round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) )-1; % 0-9

end

% Dim stars in the KIC and in the Besancon model
kicIndexSet = find(keplerMagnitude >= 16);
besanconIndexSet = find(magnitude_b >= 16);

% Assign random draws from the Besancon model to the KIC for luminosityClass, spectralType, spectralSubType
luminosityClass(kicIndexSet) = lum_class_b( besanconIndexSet( ...
    round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) );
spectralType(kicIndexSet) = sp_type_b( besanconIndexSet( ....
    round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) );
spectralSubType(kicIndexSet) = sp_subtype_b( besanconIndexSet( ....
    round(length(besanconIndexSet)*rand(size(kicIndexSet))+0.5)  ) )-1; % 0-9

% Deal with galaxies....and illegal magnitude objects
badObjectIndexSet = find(isnan(keplerMagnitude));
keplerMagnitude(badObjectIndexSet) = 30;

%Assign "illegal" luminosity class, spectral type, subtype
luminosityClass(badObjectIndexSet)  = -1;
spectralType(badObjectIndexSet)    = -1;
spectralSubType(badObjectIndexSet) = -1;

% now use the assigned data to generate effective temperatures, surface gravity and radii
% for the stars that don't have these set
needFixing = find(catalogData.logSurfaceGravity == -1);
effTemp = SpT2TeffBCL(spectralType(needFixing), spectralSubType(needFixing));
for i=1:length(needFixing)
	logG(i) = SpT2logg(spectralType(needFixing(i)), spectralSubType(needFixing(i)), ...
	    luminosityClass(needFixing(i)));
end
% radius = effT2Radius(effTemp);
catalogData.logSurfaceGravity(needFixing) = logG;
catalogData.effectiveTemperature(needFixing) = effTemp;
% catalogData.radius(needFixing) = radius;
% now set the mass of all stars
% catalogData.mass = effT2Mass(catalogData.effectiveTemperature);
return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Teff, logTeff, CI, MV, BC, Mbol, L] = SpT2TeffBCL(Sp_Type, Sp_SubType)
%function [Teff, logTeff, CI, MV, BC, Mbol, L] = SpT2TeffBCL(Sp_Type, Sp_SubType)
%
% Sp_Type is the spectral type where O=1 B=2 A=3 F=4 G=5 K=6 M=7
% Sp_SubType is the spectral subtype number on a 0-9 scale
%
% Type and Subtype are converted to column vectors for processing.
%
% Table from p. 137 of "Astrophysical Data:  Planets and Stars" by K. R. Lang,
% Publisher: Springer-Verlag, 1992.
% 
% Teff is the effective temperature (K)
% logTeff is the log10 of the effective temperature (K)
% CI is the color index:
%   (U-B) for O and B stars 
%   (B-V) for A, F, G, and K stars
%   (R-I) for M stars
% MV is the absolute visual magnitude (at 10 parsecs(?))
% BC is the bolmetric correction
% Mbol is the bolometric magnitude and equals MV+BC
% L is the absolute luminosity in uints of the solare value L for main 
% sequence stars, or luminosity class LC = V (Scyhmidt-Kaler(1982))
%
% Note: logTeff is calculated by taking log(Teff)
% Note: CI doesn't work too well where color bands shift (B/A and K/M)
%       It would be better modeled as a piecewise polynomial (future work)
% Note: Computations of Mbol = MV + BC (both interpolations).
%
% As always, the ends of the interpolations are possibly odd, so early O and 
% late M values should be carefully checked.

Type = 10*Sp_Type(:) + Sp_SubType(:);

y = GetTableTCMBML;

% Interpolate on the effective temperature
if nargout > 0 
    warningState = warning('query', 'all');
    warning off
    p = polyfit(y(:,1),y(:,3),8);
    Teff = polyval(p,Type);
    Teff = Teff(:);
    warning(warningState);
end

% Calculate the log of the effective temperature
if nargout > 1
    logTeff = log10(Teff);
end

% Interpolate on the color index
if nargout > 2 
    p = polyfit(y(:,1),y(:,4),3);
    CI = polyval(p,Type);
    CI = CI(:);
end

% Interpolate on the absolute visual magnitude
if nargout > 3 
    p = polyfit(y(:,1),y(:,5),3);
    MV = polyval(p,Type);
    MV = MV(:);
end

% Interpolate on the Bolometric Correction
if nargout > 4
    p = polyfit(y(:,1),y(:,6),4);
    BC = polyval(p,Type);
    BC = BC(:);
end

% Interpolate on the bolometric magnitude
if nargout > 5 
    Mbol = MV + BC;
end

% Interpolate on the absolute luminosity
if nargout > 6 
    p = polyfit(y(:,1),log10(y(:,8)),4);
    L = polyval(p,Type);
    L = 10.^L(:);
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = GetTableTCMBML
%
% OBAFGKM
% 1234567
%
% 10*spectral type + spectral subtype is the "type" column
% So an O3 star is 13 and an M7 is 77

% type logTeff Teff  CI    MV   BC   Mbol  L 
t = [13 4.720 52500 -1.22 -6.0 -4.75 -10.7 1.4e6;  % O stars
     14 4.680 48000 -1.20 -5.9 -4.45 -10.3 9.9e5;
     15 4.648 44500 -1.19 -5.7 -4.40 -10.1 7.9e5;
     16 4.613 41000 -1.17 -5.5 -3.93 -9.4  4.2e5;
     17 4.580 38000 -1.15 -5.2 -3.68 -8.9  2.6e5;
     18 4.555 35800 -1.14 -4.9 -3.54 -8.4  1.7e5;
     19 4.518 33000 -1.12 -4.5 -3.33 -7.8  9.7e4;
     20 4.486 30000 -1.08 -4.0 -3.16 -7.1  5.2e4;  % B stars
     21 4.405 25400 -0.95 -3.2 -2.70 -5.9  1.6e4;
     22 4.342 22000 -0.84 -2.4 -2.35 -4.7  5.7e3;
     23 4.271 18700 -0.71 -1.6 -1.94 -3.5  1.9e3;
     25 4.188 15400 -0.58 -1.2 -1.46 -2.7  830;
     26 4.146 14000 -0.50 -0.9 -1.21 -2.1  500;
     27 4.115 13000 -0.43 -0.6 -1.02 -1.6  320;
     28 4.077 11900 -0.34 -0.2 -0.80 -1.0  180;
     29 4.022 10500 -0.20  0.2 -0.51 -0.3   95;
     30 3.978 9520 -0.02 0.6 -0.30 0.3 54; % A stars
     31 3.965 9230 0.01 1.0 -0.23 0.8 35;
     32 3.953 8970 0.05 1.3 -0.20 1.1 26;
     33 3.940 8720 0.08 1.5 -0.17 1.3 21;
     35 3.914 8200 0.15 1.9 -0.15 1.7 14;
     37 3.895 7850 0.20 2.2 -0.12 2.1 10.5;
     38 3.880 7580 0.25 2.4 -0.10 2.3 8.6;
     40 3.857 7200 0.30 2.7 -0.09 2.6 6.5;  % F stars
     42 3.838 6890 0.35 3.6 -0.11 3.5 2.9;  % The 3.6 in this row looks suspect but matches the table....
     45 3.809 6440 0.44 3.5 -0.14 3.4 3.2;
     48 3.792 6200 0.52 4.0 -0.16 3.8 2.1;
     50 3.780 6030 0.58 4.4 -0.18 4.2 1.5;  % G stars
     52 3.768 5860 0.63 4.7 -0.20 4.5 1.1;
     55 3.760 5770 0.68 5.1 -0.21 4.9 0.79;
     58 3.746 5570 0.74 5.5 -0.40 5.1 0.66;
     60 3.720 5250 0.81 5.9 -0.31 5.6 0.42; % K stars
     61 3.706 5080 0.86 6.1 -0.37 5.7 0.37;
     62 3.690 4900 0.91 6.4 -0.42 6.0 0.29;
     63 3.675 4730 0.96 6.6 -0.50 6.1 0.26;
     64 3.662 4590 1.05 7.0 -0.55 6.4 0.19;
     65 3.638 4350 1.15 7.4 -0.72 6.7 0.15;
     67 3.609 4060 1.33 8.1 -1.01 7.1 0.10;
     70 3.585 3850 0.92 8.8 -1.38 7.4 7.7e-2;  % M stars
     71 3.570 3720 1.03 9.3 -1.62 7.7 6.1e-2;
     72 3.554 3580 1.17 9.9 -1.89 8.0 4.5e-2;
     73 3.540 3470 1.30 10.4 -2.15 8.2 3.6e-2;
     74 3.528 3370 1.43 11.3 -2.38 8.9 1.9e-2;
     75 3.510 3240 1.61 12.3 -2.73 9.6 1.1e-2;
     76 3.485 3050 1.93 13.5 -3.21 10.3 5.3e-3;
     77 3.468 2940 2.1  14.3 -3.46 10.8 3.4e-3;
     78 3.422 2640 2.4  16.0 -4.1  11.9 1.2e-3]; 
     
return

function logg = SpT2logg(Sp_Type, Sp_SubType, Lum_Class)
%function logg = SpT2logg(Sp_Type, Sp_SubType, {Lum_Class})
%
% Sp_Type is the spectral type where O=1 B=2 A=3 F=4 G=5 K=6 M=7
% Sp_SubType is the spectral subtype number on a 0-9 scale
% Lum_Class is the luminosity class; default luminosity class is 5 (V)
% Only works for luminosity class V (5) III (3) and I (1)
%
% Spectral Type and Subtype are converted to column vectors for processing.
%
% Table from p. 134 of "Astrophysical Data:  Planets and Stars" by K. R. Lang,
% Publisher: Springer-Verlag, 1992.
%
% logg tables are relative and so the logg of the sun is added to the result.

if nargin==2
    Lum_Class = 5;
end

loggSun = log10(2.7398e4); %cm/s^2

Type = 10*Sp_Type(:) + Sp_SubType(:);

y = GetTableLogg(Lum_Class);

p = polyfit(y(:,1)/10,y(:,2),5);
logg = polyval(p,Type/10);
logg = logg(:) + loggSun;

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = GetTableLogg(Lum_Class)

% Table has log(g/g_sun)
switch Lum_Class

    case {1, 2}
        y=[15 -1.1
            16 -1.2
            18 -1.2
            20 -1.6
            25 -2.0
            30 -2.3
            35 -2.4
            40 -2.7
            45 -3.0
            50 -3.1
            55 -3.3
            60 -3.5
            65 -4.1
            70 -4.3
            72 -4.5];

    case {3, 4}
        y=[20 -1.1
            25 -0.95
            50 -1.5
            55 -1.9
            60 -2.3
            65 -2.7
            70 -3.1];

    case {5, 6}
        y=[13 -0.3
            15 -0.4
            16 -0.45
            18 -0.5
            20 -0.5
            23 -0.5
            25 -0.4
            28 -0.4
            30 -0.3
            35 -0.15
            40 -0.1
            45 -0.1
            50 -0.05
            55  0.05
            60  0.05
            65  0.1
            70  0.15
            72  0.2
            75  0.5
            78  0.5];

    otherwise
        error('Unsupported Luminosity Class')
end

return


% function mass = effT2Mass(effectiveTemp)
% %function logg = effT2Mass(effectiveTemp)
% %
% %
% % Table from p. 389 of "Astrophysical Quantities" Cox, ed 4th ed.,
% % Publisher: AOP press.
% %
% 
% solarMassKg = 1.989e30;  % kg
% 
% % y = [effectiveTemperature mass (solar masses)];
% y=[36000 23
%     31500 17.5
%     19000 7.6
%     15400 5.9
%     11800 3.8
%     9480 2.9
%     8160 2.0
%     7020 1.6
%     6530 1.4
%     5930 1.05
%     5700 0.92
%     5240 0.79
%     4340 0.67
%     3680 0.51
%     3530 0.40
%     3030 0.21
%     2500 0.06];
% 
% p = polyfit(y(:,1),y(:,2),5);
% mass = solarMassKg*polyval(p,effectiveTemp);
% 
% return
% 
% function radius = effT2Radius(effectiveTemp)
% % function radius = effT2Radius(effectiveTemp)%
% %
% % Table from p. 389 of "Astrophysical Quantities" Cox, ed 4th ed.,
% % Publisher: AOP press.
% %
% 
% solarRadiusM = 6.9599e8; %meters
% 
% % y = [effectiveTemperature radius (solar masses)];
% y=[36000 8.5
%     31500 7.4
%     19000 4.8
%     15400 3.9
%     11800 3.0
%     9480 2.4
%     8160 1.7
%     7020 1.5
%     6530 1.3
%     5930 1.1
%     5700 0.92
%     5240 0.85
%     4340 0.72
%     3680 0.60
%     3530 0.50
%     3030 0.27
%     2500 0.10];
% 
% p = polyfit(y(:,1),y(:,2),5);
% radius = polyval(p,effectiveTemp);
% 
% return

