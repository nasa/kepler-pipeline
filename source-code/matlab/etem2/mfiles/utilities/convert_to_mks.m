function resultInMks = convert_to_mks(input, units)
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

kilograms = 1;
meters = 1;
kilometers = 1000;
year = 365*24*3600; % normal year, mks: s
julianYear = 365.25*24*3600; % julian year, mks: s
day = 24*3600; % mks: s
hour = 3600; % mks: s
minute = 60; % mks: s
second = 1;
   
switch(units)
    case {'solarMass', 'sunMass'}
        resultInMks = input*get_physical_constants_mks('solarMass');
    case 'earthMass'
        resultInMks = input*get_physical_constants_mks('earthMass');
    case 'jupiterMass'
        resultInMks = input*get_physical_constants_mks('jupiterMass');
    case 'kilograms'
        resultInMks = input*kilograms;
        
    case 'solarRadius'
        resultInMks = input*get_physical_constants_mks('solarRadius');
    case 'earthRadius'
        resultInMks = input*get_physical_constants_mks('earthRadius');
    case 'jupiterRadius'
        resultInMks = input*get_physical_constants_mks('jupiterRadius');
    case 'kilometers'
        resultInMks = input*kilometers;
    case 'meters'
        resultInMks = input*meters;
        
    case {'year', 'years'}
        resultInMks = input*year;
    case {'julianYear', 'julianYears'}
        resultInMks = input*julianYear;
    case {'day', 'days'}
        resultInMks = input*day;
    case {'hour', 'hours'}
        resultInMks = input*hour;
    case {'minute', 'minutes'}
        resultInMks = input*minute;
    case {'second', 'seconds'}
        resultInMks = input*second;
        
    otherwise
        error('unknown units in convert_to_mks');
end

        
