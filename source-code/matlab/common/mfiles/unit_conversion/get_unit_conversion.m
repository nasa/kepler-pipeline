function result = get_unit_conversion(conversionString)
%
% function to get the multiplicative scale factor for a unit conversion
% between the units designated in the input string.  For current list of
% conversions, input 'help'
%
% example: day2hour = get_unit_conversion('day2hour')
%          day2hour = 24
%
%          periodInHours = periodInDays * day2hour;
%
%
% example:  meter2solarRadius = get_unit_conversion('meter2solarRadius')
%           meter2solarRadius = 1.4368e-09
%
%          planetRadiusSolarUnits = planetRadiusMks * meter2solarRadius;
%
%
% Note: year is currently julian year = 365.25 !
%       if a 'normal' year of 365 days is desired, feel free to add below.
%
%--------------------------------------------------------------------------
%
% MKS is the system of units based on measuring lengths in meters, mass in
% kilograms, and time in seconds.
%
% Units generally used in Astronomical literature include au, solar masses,
% and light years, and anthropic units of earth masses, earth radii, etc.
%
% Units conversions needed for the SOC pipeline CSCIs vary, so please add
% conversions below if not available.
%
%--------------------------------------------------------------------------
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


% extract physical constants
astronomicalUnitMks  = get_physical_constants_mks('astronomicalUnit');
solarRadiusMks       = get_physical_constants_mks('solarRadius');
earthRadiusMks       = get_physical_constants_mks('earthRadius');
jupiterRadiusMks     = get_physical_constants_mks('jupiterRadius');

solarMassMks         = get_physical_constants_mks('solarMass');
earthMassMks         = get_physical_constants_mks('earthMass');
jupiterMassMks       = get_physical_constants_mks('jupiterMass');


switch(conversionString)

    %--------------------------------------------------------------------------
    % length/distance parameters (mks = meters)
    %--------------------------------------------------------------------------
    case{'cm2meter'}
        result = 1/100;
    case{'meter2cm'}
        result = 100;

    case{'au2meter'}
        result = astronomicalUnitMks;
    case{'meter2au'}
        result = 1/astronomicalUnitMks;

    case{'au2km'}
        result = astronomicalUnitMks/1000;
    case{'km2au'}
        result = 1/(astronomicalUnitMks/1000);

    case{'solarRadius2meter'}
        result = solarRadiusMks;
    case{'meter2solarRadius'}
        result = 1/solarRadiusMks;

    case{'earthRadius2meter'}
        result = earthRadiusMks;
    case{'meter2earthRadius'}
        result = 1/earthRadiusMks;

    case{'jupiterRadius2meter'}
        result = jupiterRadiusMks;
    case{'meter2jupiterRadius'}
        result = 1/jupiterRadiusMks;

        %--------------------------------------
        % include '___ 2mks' options
        %--------------------------------------
    case{'cm2mks'}
        result = 1/100;

    case{'au2mks'}
        result = astronomicalUnitMks;

    case{'solarRadius2mks'}
        result = solarRadiusMks;
        
    case{'earthRadius2mks'}
        result = earthRadiusMks;

    case{'jupiterRadius2mks'}
        result = jupiterRadiusMks;


    case{'rad2deg'}
        result = 180/pi;
    case{'deg2rad'}
        result = pi/180;


        %--------------------------------------------------------------------------
        % mass parameters (mks = kilograms)
        %--------------------------------------------------------------------------
    case{'solarMass2kgm'}
        result = solarMassMks;
    case{'kgm2solarMass'}
        result = 1/solarMassMks;

    case{'earthMass2kgm'}
        result = earthMassMks;
    case{'kgm2earthMass'}
        result = 1/earthMassMks;

    case{'jupiterMass2kgm'}
        result = jupiterMassMks;
    case{'kgm2jupiterMass'}
        result = 1/jupiterMassMks;

        %--------------------------------------
        % include '___ 2mks' options
        %--------------------------------------
    case{'solarMass2mks'}
        result = solarMassMks;

    case{'earthMass2mks'}
        result = earthMassMks;

    case{'jupiterMass2mks'}
        result = jupiterMassMks;


        %--------------------------------------------------------------------------
        % time parameters (mks = seconds)
        %--------------------------------------------------------------------------
    case {'min2sec'}
        result = 60;
    case {'sec2min'}
        result = 1/60;
        
        
    case {'hour2min'}
        result = 60;
    case {'min2hour'}
        result = 1/60;
        
    case{'hour2sec'}
        result = 3600;
    case{'sec2hour'}
        result = 1/3600;

    case{'day2sec'}
        result = 24 * 3600;
    case{'sec2day'}
        result = 1/(24*3600);

    case{'year2sec'}
        result = 365.25 * 24 * 3600;
    case{'sec2year'}
        result = 1/(365.25 * 24 * 3600);

    case{'day2min'}
        result = 24 * 60;
    case{'min2day'}
        result = 1/(24 * 60);

    case{'day2hour'}
        result = 24;
    case{'hour2day'}
        result = 1/24;

    case{'year2min'}
        result = 365.25 * 24 * 60;
    case{'min2year'}
        result = 1/(365.25 * 24 * 60);

        %--------------------------------------
        % include '___ 2mks' options
        %--------------------------------------
    case{'min2mks'}
        result = 60;

    case{'hour2mks'}
        result = 3600;

    case{'day2mks'}
        result = 24 * 3600;

    case{'year2mks'}
        result = 365.25 * 24 * 3600;


        %----------------------------------------------------------------------
        % Keep list of valid inputs
        %----------------------------------------------------------------------
    case{'help'}
        result = strvcat(...
            'cm2meter', ...
            'meter2cm', ...
            'au2meter', ...
            'meter2au', ...
            'au2km', ...
            'km2au', ...
            'solarRadius2meter', ...
            'meter2solarRadius', ...
            'earthRadius2meter', ...
            'meter2earthRadius', ...
            'jupiterRadius2meter', ...
            'meter2jupiterRadius', ...
            'cm2mks', ...
            'au2mks', ...
            'solarRadius2mks', ...
            'earthRadius2mks', ...
            'jupiterRadius2mks', ...
            'rad2deg', ...
            'deg2rad', ...
            'solarMass2kgm', ...
            'kgm2solarMass', ...
            'earthMass2kgm', ...
            'kgm2earthMass', ...
            'jupiterMass2kgm', ...
            'kgm2jupiterMass', ...
            'solarMass2mks', ...
            'earthMass2mks', ...
            'jupiterMass2mks', ...
            'min2sec', ...
            'sec2min', ...
            'hour2sec', ...
            'sec2hour', ...
            'day2sec', ...
            'sec2day', ...
            'year2sec', ...
            'sec2year', ...
            'day2min', ...
            'min2day', ...
            'day2hour', ...
            'hour2day', ...
            'year2min', ...
            'min2year', ...
            'min2mks', ...
            'hour2mks', ...
            'day2mks', ...
            'year2mks');  %#ok<VCAT>

    otherwise
        error(['undefined conversion ''',conversionString,'''']);
end

