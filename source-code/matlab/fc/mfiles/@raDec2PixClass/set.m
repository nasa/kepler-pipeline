function raDec2PixObject = set(raDec2PixObject, field, val) 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function output = set(raDec2PixObject, field, val)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Set various fields of the raDec2PixObject
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

% MOD:
%   2013-Nov-13, JT:
%       Updated checking of rollTimeModels and pointingModels to reflect
%       new model fields. Also fixed some syntax warnings and
%       inconsistencies with SOC coding conventions.
%   2008-Apr-04, PT:
%       add return of the modified object at end of modifications, since
%       Matlab always passes by value!  Type-check the values that the user
%       is attempting to set.  Prohibit setting of the spice file dir or
%       name.

    switch field
        case 'mjdStart' % should be a scalar double
            if ( isRealScalar(val) )
                raDec2PixObject.mjdStart = double(val);
            else
                error('Matlab:FC:raDec2PixClass:set',' mjdStart field of raDec2PixClass must be real scalar value') ;
            end
        case 'mjdEnd'
            if ( isRealScalar(val) )
                raDec2PixObject.mjdEnd = double(val);
            else
                error('Matlab:FC:raDec2PixClass:set',' mjdEnd field of raDec2PixClass must be real scalar value') ;
            end
        case 'pointingModel'
            if ( isPointingModelStructOK(val) )
                raDec2PixObject.pointingModel = val;
            else
                error('Matlab:FC:raDec2PixClass:set',' pointingModel fields ill-formed') ;
            end
        case 'geometryModel'
            if ( isGeometryModelStructOK(val) )
                raDec2PixObject.geometryModel = val;
            else
                error('Matlab:FC:raDec2PixClass:set',' geometryModel fields ill-formed') ;
            end
        case 'rollTimeModel'
            if ( isRollTimeModelOK(val) )
                raDec2PixObject.rollTimeModel = val;
            else
                error('Matlab:FC:raDec2PixClass:set',' rollTimeModel fields ill-formed') ;
            end

        case 'spiceFileDir'
            error('Matlab:FC:raDec2PixClass:set',' spiceFileDir is not a valid field to set in raDec2PixObject') ;
        case 'spiceFileName'
            error('Matlab:FC:raDec2PixClass:set',' spiceFileName is not a valid field to set in raDec2PixObject') ;
        case 'leapSecondFileName'
            error('Matlab:FC:raDec2PixClass:set',' leapSecondFileName is not a valid field to set in raDec2PixObject') ;
        case 'planetaryEphemerisFileName'
            error('Matlab:FC:raDec2PixClass:set',' planetaryEphemerisFileName is not a valid field to set in raDec2PixObject') ;

        case 'spiceSpacecraftEphemerisFilename' % convenience duplicate 
            error('Matlab:FC:raDec2PixClass:set',' spiceSpacecraftEphemerisFilename is not a valid field to set in raDec2PixObject') ;
        case 'leapSecondFilename' % convenience duplicate 
            error('Matlab:FC:raDec2PixClass:set',' leapSecondFilename is not a valid field to set in raDec2PixObject') ;
        case 'planetaryEphemerisFilename' % convenience duplicate 
            error('Matlab:FC:raDec2PixClass:set',' planetaryEphemerisFilename is not a valid field to set in raDec2PixObject') ;

        otherwise
            errmsg = sprintf(' %s is not a valid field of raDec2PixObject', field);
            error('Matlab:FC:raDec2PixClass:set', errmsg);
    end

return

%==========================================================================
%==========================================================================
%==========================================================================

function isItGood = isRealScalar( val )
%
% checks to see whether a value is a real (not complex) scalar, returns 1
% if so, 0 otherwise.
%
    if (  (isa(val,'numeric')) && (isreal(val)) && (isscalar(val)) )
        isItGood = 1 ;
    else
        isItGood = 0 ;
    end
    
return

%==========================================================================

function isItGood = isStructWellFormed( testStruct, fieldNameCellArray )
%
% tests to make sure that all of the field names in fieldNameCellArray are
% present in testStruct, returns 1 if so, zero otherwise.
%
    fieldsPresent = isfield( testStruct , fieldNameCellArray ) ;
    if ( isempty(find(fieldsPresent == 0)) )
        isItGood = 1 ;
    else
        isItGood = 0 ;
    end
    
return

%==========================================================================

function vectorLength = isRealVector( val )
%
% tests to make sure that the argument is a vector of reals, returns the
% length of the vector if so, zero otherwise.
%
    if (  (isa(val,'numeric')) && (isreal(val)) && (isvector(val)) )
        vectorLength = length(val) ;
    else
        vectorLength = 0 ;
    end
    
return

%==========================================================================

function isItGood = isPointingModelStructOK( pointingModelStruct )
%
% tests the pointingModelStruct to make sure that it has the correct
% fields ( mjds, ras, declinations, rolls, segmentStartMjds ) ; that all of
% the 5 fields are real vectors; and that the vectors are all equal in
% length.  Returns 1 if these conditions are met, 0 otherwise.
%

% default is failure

    isItGood = 0 ;

    fieldNames = {'mjds','ras','declinations','rolls','segmentStartMjds'} ;
    
    if (isStructWellFormed( pointingModelStruct, fieldNames )) ;
        
        vecLength = zeros(1,length(fieldNames)) ;
        for iField=1:length(fieldNames)
            vecLength(iField) = isRealVector(getfield(pointingModelStruct,fieldNames{iField})) ;
        end
        if ( (isempty(find(vecLength ~= vecLength(1)))) && (vecLength(1) ~= 0) )
            isItGood = 1 ;
        end
        
    end
    
return

%==========================================================================

function isItGood = isGeometryModelStructOK ( geomModelStruct )
%
% tests the geomModelStruct to make sure that it has the correct fields
% (mjds, constants, uncertainty) ; that all of them are vectors with the
% same length ; that constants and geometry are both structures with field
% name array; that all of constants(:).array and uncertainty(:).array are
% of real vectors of length 420; that mjds is a real vector.  Returns 1 if
% these conditions are met, 0 otherwise.
%

% initialize to bad status

    isItGood = 0 ;

    lenConstantsArray   = 420 ;
    lenUncertaintyArray = 420 ; 

    fieldNamesGeomModel = {'mjds','constants','uncertainty'} ;
    fieldNamesConstants = {'array'} ;
    fieldNamesUncertainty = {'array'} ;
    
% start with the names of the fields in geomModelStruct

    if (isStructWellFormed( geomModelStruct, fieldNamesGeomModel )  ) ;
        
% find out if mjds is a real vector

        lenMjd = isRealVector(geomModelStruct.mjds) ;
        if (lenMjd ~= 0)
            
% make sure that the other fields are vectors with equal length to mjd, and
% are structures with the correct field names

            if (  isvector(geomModelStruct.constants)            && ...
                  isvector(geomModelStruct.uncertainty)          && ...
                 (length(geomModelStruct.constants) == lenMjd)   && ...
                 (length(geomModelStruct.uncertainty) == lenMjd) && ...
                  isStructWellFormed(geomModelStruct.constants,fieldNamesConstants) && ...
                  isStructWellFormed(geomModelStruct.uncertainty,fieldNamesUncertainty)   )
             
% loop over the constants and uncertainty vectors, and make sure that each
% one's array field is a real vector of the correct length

                lenConstants = zeros(1,lenMjd) ;  lenUncertainty = lenConstants ;
                for iCount = 1:lenMjd
                    lenConstants(iCount) = isRealVector(geomModelStruct.constants(iCount).array) ;
                    lenUncertainty(iCount) = isRealVector(geomModelStruct.uncertainty(iCount).array) ;
                end
                if ( isempty(find(lenConstants   ~= lenConstantsArray)) && ...
                     isempty(find(lenUncertainty ~= lenUncertaintyArray))   )
                    isItGood = 1 ;
                end
                
            end
            
        end
        
    end
    
return    
                
%==========================================================================

function isItGood = isRollTimeModelOK( rollTimeModelStruct )
%
% tests the rollTimeModelStruct to make sure that it has the correct fields
% (mjds, rollOffsets, seasons, fovCenterRas, fovCenterDeclinations,
% fovCenterRolls), that they are all vectors with the same length, that all
% are real-valued except the seasons which is int32 class.  Returns 1 if
% all those conditions are satisfied, 0 otherwise.
%

% default status is bad

    isItGood = 0 ;
    
% field names

    fieldNames = {'mjds','rollOffsets','seasons', ...
        'fovCenterRas', 'fovCenterDeclinations', 'fovCenterRolls'} ;
    
% check the field names

    if ( isStructWellFormed(rollTimeModelStruct, fieldNames) )
        
% check the length and formation of the real valued fields

        lenMjd     = isRealVector(rollTimeModelStruct.mjds) ;
        lenOffsets = isRealVector(rollTimeModelStruct.rollOffsets) ;
        lenRas     = isRealVector(rollTimeModelStruct.fovCenterRas) ;
        lenDecs    = isRealVector(rollTimeModelStruct.fovCenterDeclinations) ;
        lenRolls   = isRealVector(rollTimeModelStruct.fovCenterRolls) ;
        
% get the length of the third field

        lenSeasons = length(rollTimeModelStruct.seasons) ;
        
% check that seasons is a vector of int32, and that all vector lengths are
% the same

        if ( isvector(rollTimeModelStruct.seasons) && ...
                isa(rollTimeModelStruct.seasons,'int32') && ...
                (lenMjd == lenOffsets) && (lenMjd == lenSeasons) && ...
                (lenMjd == lenRas) && (lenMjd == lenDecs) && ...
                (lenMjd == lenRolls) )
            isItGood = 1 ;
        end
        
    end
    
return    
