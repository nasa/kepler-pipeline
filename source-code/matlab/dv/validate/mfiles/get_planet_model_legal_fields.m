function legalFieldNames = get_planet_model_legal_fields( formatString )
%
% get_planet_model_legal_fields -- return the legal field names for a
% transitGeneratorClass object's planetModel member
%
% legalFieldNames = get_planet_model_legal_fields( formatString ) returns a cell array of
%    the legal fields for the planetModel member of the transitGeneratorClass:
%
%    formatString == 'physical', the physical parameter names are returned
%                     (used in DV v6.2)
%
%    formatString == 'observable', the observable parameter names are returned
%                     (used in DV v6.2)
%
%    formatString == 'tps-constructor', the parameters used to instantiate
%                     a transitGeneratorClass object starting from TPS TCE
%                     values are returned (used in DV v6.2)
%
%    formatString == 'geometric', the geometric-observable parameter names
%                     are returned (used in DV v7.0)
%
%    formatString == 'physical-observable', the complete list of parameter
%                     names (used in DV v6.2) are returned.
%
%    formatString == 'derived', the derived parameter names are returned.
%
%    formatString == 'all' or is missing or empty, the complete list of parameter
%                     names, including parameters which are used internally,
%                     are returned (used in DV v7.0)
%
% Version date:  2013-December-11.
%
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

% Modification History:
%
%    2013-December-11, JL:
%        add parameter 'effectiveStellarFlux'
%    2012-August-23, JL:
%        add parameters 'inclinationDegrees' and 'equilibriumTempKelvin'
%        add input option 'derived' for derived parameters
%    2010-Nov-2, EQ:
%        adding new set of geometric-observable parameters, changing
%        previous version of 'all' to 'physical-observable' in order to
%        include the new geometric-observable parameters in 'all' while
%        allowing all parameters for DV v6.2 to be accessible
%    2010-May-05, PT:
%        convert from transitEpochMjd to transitEpochBkjd.
%    2009-July-28, EQ:
%        include eccentricity and longitude of periastron
%    2009-July-27, PT:
%        change parameters used for TPS instantiation.
%    2009-July-22, PT:
%        change inclinationDegrees to minImpactParameter (which is dimensionless).
%    2009-June-12, PT:
%        adding a column for fields used to instantiate a transitGeneratorClass object
%        when it has epoch, star radius, duration, depth, and period (a mix of physical
%        and observable parameters)
%    2009-June-10, EQ:
%        replacing ingress time for star radius
%    2009-June-02, PT:
%        bugfix in use of exist function.
%=========================================================================================

% Build a struct which includes the parameters in the ultimately-desired order, via a cell
% array which is converted to a struct

%                   field name                     physical  observable  tps-constructor  geometric     trapezoidal     physical-observable   derived  
fieldArray = {  'transitEpochBkjd',                 true,       true,       true,           true,           true,           true,              false;   ...
                'eccentricity',                     true,       true,       true,           true,           false,          true,              false;   ...
                'longitudeOfPeriDegrees',           true,       true,       true,           true,           false,          true,              false;   ...
                'planetRadiusEarthRadii',           true,       false,      false,          false,          false,          true,              true;    ...
                'semiMajorAxisAu',                  true,       false,      false,          false,          false,          true,              true;    ...
                'minImpactParameter',               true,       false,      true,           true,           false,          true,              false;   ...
                'starRadiusSolarRadii',             true,       false,      true,           true,           false,          true,              false;   ...
                'transitDurationHours',             false,      true,       false,          false,          true,           true,              true;    ...
                'transitIngressTimeHours',          false,      true,       false,          false,          true,           true,              true;    ...
                'transitDepthPpm',                  false,      true,       true,           false,          true,           true,              true;    ...
                'orbitalPeriodDays',                false,      true,       true,           true,           true,           true,              false;   ...
                'ratioPlanetRadiusToStarRadius',    false,      false,      false,          true,           false,          false,             false;   ...
                'ratioSemiMajorAxisToStarRadius',   false,      false,      false,          true,           false,          false,             false;   ...
                'inclinationDegrees',               false,      false,      false,          false,          false,          false,             true;    ...
                'equilibriumTempKelvin',            false,      false,      false,          false,          false,          false,             true;    ...
                'effectiveStellarFlux',             false,      false,      false,          false,          false,          false,             true   };


% convert to a struct

fieldNameStruct = cell2struct(fieldArray, {'fieldName', 'isPhysical', 'isObservable', 'isTpsConstructor', 'isGeometric', 'isTrapezoidal', 'isPhysicalObservable', 'isDerived'}, 2) ;

% handle the various possible cases of the argument

if ( ~exist('formatString','var') || isempty(formatString) )
    formatString = 'all' ;
end

switch lower(formatString)
    
    case 'physical'
        
        fieldIndex = [fieldNameStruct.isPhysical];
        
    case 'observable'
        
        fieldIndex = [fieldNameStruct.isObservable];
        
    case 'tps-constructor'
        
        fieldIndex = [fieldNameStruct.isTpsConstructor];
        
    case 'geometric'
        
        fieldIndex = [fieldNameStruct.isGeometric];
        
    case 'trapezoidal'
        
        fieldIndex = [fieldNameStruct.isTrapezoidal];
    
    case 'physical-observable'
        
        fieldIndex = [fieldNameStruct.isPhysicalObservable];
        
    case 'derived'
        
        fieldIndex = [fieldNameStruct.isDerived];
       
    case 'all'
        
        fieldIndex = [fieldNameStruct.isGeometric] | [fieldNameStruct.isDerived];
        
    otherwise
        
        error('dv:getPlanetModelLegalFields:formatStringInvalid', ...
            'get_planet_model_legal_fields:  format string is invalid');
        
end % switch statement

selectedFieldNameStruct = fieldNameStruct(fieldIndex) ;
legalFieldNames = {selectedFieldNameStruct.fieldName} ;

return ;

% and that's it!

