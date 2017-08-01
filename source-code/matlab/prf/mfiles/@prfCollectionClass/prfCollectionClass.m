function prfCollectionObject = prfCollectionClass(prfCollectionData,fcConstants,prfSpecification)
% function prfCollectionObject = prfCollectionClass(prfCollectionData,fcConstants,prfSpecification)
%
% prfCollectionClass -- constructor for the prfCollectionClass
%
% prfCollectionObject = prfCollectionClass(prfCollectionData) constructs an object of the
%    prfCollectionClass.  The argument prfCollectionData can be any of the following:
%
%    ==> A vector of 5 prfClass objects.  The order of the objects must be as follows:
%        -> low-row, low-column corner
%        -> high-row, low-column corner
%        -> high-row, high-column corner
%        -> low-row, high-column corner
%        -> center.
%
%    ==> A single prfClass object.  In this case the single object is used as the PRF for
%        the entire module/output and no interpolation of PRFs is performed.
%
%   ==> A vector of 5 structures, each of which has as its field either "polyStruct" or
%       "coefficientMatrix".
%
%   ==> A vector of 5 structures, each of which has as its field "prfArray"
%       that contains a discrete PRF array
%
%   ==> A cell array of 1 or 5 file names, each of which points at a discrete
%       PRF file
%
%   ==> A single structure which has as its sole field either "polyStruct" or
%       "coefficientMatrix".
%
%    ==> A single data structure of the form produced by the prfCollectionClass get('*')
%        method.
%
%    ==> A prfCollectionClass object.
%
%    ==> A cell array of 5 strings containing the full pathnames of
%    discrete PRF files in the order given above
%
% prfSpecification = a structure specifying the properties of the PRF.
% This may be missing or empty, in which case the PRF_POLY_WITHOUT_UNCERTAINTIES
% is created.
% The fields of prfSpecification are:
% .type (char string): There are currently three types of PRF defined: 
%   PRF_POLY_WITHOUT_UNCERTAINTIES
%       a PRF that does not support the computation of
%       uncertainties in the evaluated PRF values.  This object has a much
%       smaller memory footprint than the PRF_POLY_WITH_UNCERTAINTIES
%       type
%   PRF_POLY_WITH_UNCERTAINTIES
%       a PRF containing the data that supports the computation of
%       uncertainties in the evaluated PRF values.  This object has a much
%       larger memory footprint than the PRF_POLY_WITHOUT_UNCERTAINTIES
%       type
%   PRF_DISCRETE
%       discrete PRF version of the data in prfCollectionData.  In this case
%       the prfSpecification structure must contain the field "oversample", 
%       which determines how many points are
%       sampled per pixel.  A prfDiscreteClass object is returned
%
% .oversample (float): the number of points sampled per pixel for the
%   PRF_DISCRETE type
%
% Version date:  2008-September-29.
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
%     2008-September-29, PT:
%         switch from using row and column limit arguments to use of fcConstants to derive
%         those limits.
%     2008-September-24, PT:
%         update to use a different structure -- the get method now returns the
%         coefficientMatrix of each regional PRF, since the polyStruct is no longer
%         stored.  Support use of a structure with coefficientMatrix / polyStruct field.
%         Add a flag which indicates whether there are really 5 prfClass objects or 5
%         copies of 1 prfClass object.
%     2008-September-10, PT:
%         check to make sure that all prfClass objects have the same size; if they do not,
%         throw an error.  Eliminate redundant members which would track the default range
%         of rows and columns to use for evaluation, since individual PRFs all use the
%         same default range if the PRF sizes are the same.
%
%=========================================================================================

if nargin < 3
    prfSpecification.type = 'PRF_POLY_WITHOUT_UNCERTAINTIES';
elseif isfield(prfSpecification, 'oversample')
    prfSpecification.type = 'PRF_DISCRETE';
end

% if the argument is already an prfCollectionClass object, we can just return it

  if (isa(prfCollectionData,'prfCollectionClass') && isempty(prfSpecification))
        prfCollectionObject = prfCollectionData ;      
  else
      
%     otherwise produce a structure which can be used for instantiation

      prfCollectionStruct = struct('prfCornerObject',[],'prfCenterObject',[], ...
          'vertexRow',[],'vertexColumn',[],'interpolateFlag',[]) ;
      
%     if the argument is a data structure from a prfCollectionClass get('*') operation, use it
%     to populate the prfCollectionStruct now

      if ( isstruct(prfCollectionData) && isscalar(prfCollectionData) && ...
              isfield(prfCollectionData,'prfCornerObject') ) 
          
          prfCollectionStruct = fill_prfCollectionStruct_from_prfCollectionData( ...
              prfCollectionStruct, prfCollectionData ) ;
          
%     if the argument is a structure with either polyStructs or coefficientMatrix'es, use
%     it to populate the prfCollectionStruct now

      elseif ( isstruct(prfCollectionData) && ...
              (isfield(prfCollectionData,'polyStruct') || ...
               isfield(prfCollectionData,'coefficientMatrix'))  )
           [rowRange, columnRange] = get_ranges_from_fcConstants(fcConstants) ;
           prfCollectionStruct = fill_prfCollectionStruct_from_prfClassData( ...
               prfCollectionStruct, prfCollectionData, rowRange, columnRange, prfSpecification  ) ;
          
%     if the argument is a structure with prfArray, use
%     it to populate the prfCollectionStruct now

      elseif ( isstruct(prfCollectionData) && isfield(prfCollectionData,'prfArray') )
           [rowRange, columnRange] = get_ranges_from_fcConstants(fcConstants) ;
           prfCollectionStruct = fill_prfCollectionStruct_from_prfArray( ...
               prfCollectionStruct, prfCollectionData, rowRange, columnRange, prfSpecification  ) ;
          
%     if the argument is a cell array of strings, use
%     it to fill the data structure up

      elseif ( iscellstr(prfCollectionData) && length(prfCollectionData) == 5 )
           [rowRange, columnRange] = get_ranges_from_fcConstants(fcConstants) ;
           prfCollectionStruct = fill_prfCollectionStruct_from_strings( ...
               prfCollectionStruct, prfCollectionData, rowRange, columnRange, prfSpecification  ) ;
          
%     if the argument is a single prfClass object, then use it to fill the
%     data structure up
          
      elseif (isa(prfCollectionData,'prfClass') && isscalar(prfCollectionData))
          
          [rowRange, columnRange] = get_ranges_from_fcConstants(fcConstants) ;
          prfCollectionStruct = fill_prfCollectionStruct_from_single_object( ...
              prfCollectionStruct, prfCollectionData, rowRange, columnRange ) ;
          
%     if the argument is a prfCollectionClass and prfSpecification is not empty 
%     and prfSpecification.type == PRF_DISCRETE
%     then we're supposed to make a discrete version of
%     prfCollectionClass
          
      elseif (isa(prfCollectionData,'prfCollectionClass') && ~isempty(prfSpecification)) ...
              && strcmp(prfSpecification.type, 'PRF_DISCRETE')
          prfCornerObjects = get(prfCollectionData, 'prfCornerObject');
          for i=1:4
              prfCornerData(i).polyStruct = get(prfCornerObjects(i), 'polyStruct');
          end
          prfCenterObject = get(prfCollectionData, 'prfCenterObject');
          prfCornerData(5).polyStruct = get(prfCenterObject, 'polyStruct');
          [rowRange, columnRange] = get_ranges_from_fcConstants(fcConstants) ;          
          prfCollectionStruct = fill_prfCollectionStruct_from_prfClassData( ...
              prfCollectionStruct, prfCornerData, rowRange, columnRange, prfSpecification ) ;
          
%     if the argument is a vector of prfClass objects, then use it to fill the
%     data structure up
          
      elseif (isa(prfCollectionData,'prfClass') && isvector(prfCollectionData))

          [rowRange, columnRange] = get_ranges_from_fcConstants(fcConstants) ;          
          prfCollectionStruct = fill_prfCollectionStruct_from_object_vector( ...
              prfCollectionStruct, prfCollectionData, rowRange, columnRange ) ;
          
      else % error case
          
          error('prf:prfCollectionClass:badInputs', ...
              'prfCollectionClass:  the input structure does not conform to the prfCollectionClass requirements') ;
          
      end % original if statement which started the set of if-elseif's above
      
%     at this point we can simply instantiate the prfCollectionClass object with the
%     fully-filled-in prfCollectionStruct

      prfCollectionObject = class(prfCollectionStruct,'prfCollectionClass') ;
      
%     pad out the coefficientMatrix members of the object's embedded prfClass objects
      if ~isa(prfCollectionStruct.prfCenterObject,'prfDiscreteClass')
            prfCollectionObject = expand_coefficient_matrices( prfCollectionObject ) ;
      end
          
  end % if-statement which split off a prfCollectionClass object from all other options
    
% and that's it!

%
%
%

%=========================================================================================
          
function prfCollectionStruct = fill_prfCollectionStruct_from_prfCollectionData( prfCollectionStruct, ....
    prfCollectionData ) 

% instantiate the prfClass objects and copy over the other variables

  for iObject = 1:length(prfCollectionData.prfCornerObject)
      prfCollectionStruct.prfCornerObject = [prfCollectionStruct.prfCornerObject ;...
          prfClass(prfCollectionData.prfCornerObject(iObject).coefficientMatrix)] ;
  end
  prfCollectionStruct.prfCenterObject = ...
          prfClass(prfCollectionData.prfCenterObject.coefficientMatrix) ;
  prfCollectionStruct.vertexRow = prfCollectionData.vertexRow ;
  prfCollectionStruct.vertexColumn = prfCollectionData.vertexColumn ;
  prfCollectionStruct.interpolateFlag = prfCollectionData.interpolateFlag ;

% and that's it!

%
%
%

%=========================================================================================

function prfCollectionStruct = fill_prfCollectionStruct_from_single_object( ...
              prfCollectionStruct, prfCollectionData, rowRange, columnRange )
          
% instantiate the 5 prfCornerObjects and the 1 prfCenterObject from the single object

  for iCorner = 1:5
      prfCollectionStruct.prfCornerObject = [prfCollectionStruct.prfCornerObject ; prfCollectionData] ;
  end
  prfCollectionStruct.prfCenterObject = prfCollectionData ;
  
% fill in the vertex coordinates and the default rows and columns for evaluation

  prfCollectionStruct = fill_in_row_column_data( prfCollectionStruct, rowRange, columnRange ) ;
  
% only one object, so no interpolation needed

  prfCollectionStruct.interpolateFlag = false ;
  
% and that's it!

%
%
%

%=========================================================================================

function prfCollectionStruct = fill_prfCollectionStruct_from_object_vector( ...
              prfCollectionStruct, prfCollectionData, rowRange, columnRange )
          
% instantiate the 5 prfCornerObjects and the 1 prfCenterObject from the respective objects

  for iCorner = 1:4
      prfCollectionStruct.prfCornerObject = [prfCollectionStruct.prfCornerObject ; ...
          prfCollectionData(iCorner)] ;
  end
  prfCollectionStruct.prfCornerObject = [prfCollectionStruct.prfCornerObject ; ...
      prfCollectionStruct.prfCornerObject(1)] ;
  prfCollectionStruct.prfCenterObject = prfCollectionData(5) ;
  
% fill in the vertex coordinates and the default rows and columns for evaluation

  prfCollectionStruct = fill_in_row_column_data( prfCollectionStruct, rowRange, columnRange ) ;
  
% five distinct objects, so interpolation is needed

  prfCollectionStruct.interpolateFlag = true ;
  
% and that's it!

%
%
%

%=========================================================================================

function prfCollectionStruct = fill_in_row_column_data( prfCollectionStruct, rowRange, ...
    columnRange )

% get out the individual values of the row and column

  lowRow = min(rowRange) ; highRow = max(rowRange) ; 
  lowCol = min(columnRange) ; highCol = max(columnRange) ;
  
% find the middle of the mod/out, where the center PRF is valid

  centerRow = mean(rowRange) ; centerCol = mean(columnRange) ;
  
% put the vectors together

% corners        1        2          3        4          1     center
  vertexRow = [lowRow ; highRow ; highRow ; lowRow ;  lowRow ; centerRow] ;
  vertexCol = [lowCol ; lowCol  ; highCol ; highCol ; lowCol ; centerCol] ;
  
% fill in the default range of rows and columns to use for the evaluate function, based on
% the size of the prfCenterObject; while we are at it, make sure that all 5 PRFs have the
% same # of rows and columns

  nRowsDefault = get(prfCollectionStruct.prfCenterObject,'nPrfArrayRows') ;
  nPrfArray = get(prfCollectionStruct.prfCenterObject,'nPrfArray') ;
  nColsDefault = nPrfArray / nRowsDefault ;
  for iObject = 1:length(prfCollectionStruct.prfCornerObject)
      nRows = get(prfCollectionStruct.prfCornerObject(iObject),'nPrfArrayRows') ;
      nPrfArray = get(prfCollectionStruct.prfCornerObject(iObject),'nPrfArray') ;
      nCols = nPrfArray / nRows ;
      if ( nCols ~= nColsDefault && nRows ~= nRowsDefault )
          error('prf:prfCollectionClass:prfSizeMismatch', ...
              'prfCollectionClass: PRFs in the collection do not have identical sizes') ;
      end
  end
  nRowsDefaultOv2 = fix(nRowsDefault/2) ;
  nColsDefaultOv2 = fix(nColsDefault/2) ;

  prfCollectionStruct.vertexRow = vertexRow ;
  prfCollectionStruct.vertexColumn = vertexCol ;
  
% and that's it!

%
%

%=========================================================================================

function prfCollectionStruct = fill_prfCollectionStruct_from_prfClassData( ...
               prfCollectionStruct, prfCollectionData, rowRange, columnRange, ...
               prfSpecification  )

% Instantiate the prfClass object(s) from the prfCollectionData and use those, along with
% appropriate other subfunctions, to fill the prfCollectionStruct

  prfObjectVector = [] ;

  if (length(prfCollectionData) == 1)
      if (isfield(prfCollectionData,'coefficientMatrix'))
          prfObjectVector = prfClass(prfCollectionData.coefficientMatrix, prfSpecification) ;
      else
          prfObjectVector = prfClass(prfCollectionData.polyStruct, prfSpecification) ;
      end
      prfCollectionStruct = fill_prfCollectionStruct_from_single_object( ...
          prfCollectionStruct, prfObjectVector, rowRange, columnRange  ) ;
  else
      for iPrf = 1:5
          if (isfield(prfCollectionData,'coefficientMatrix'))
              prfObject = prfClass(prfCollectionData(iPrf).coefficientMatrix, prfSpecification) ;
          else
              prfObject = prfClass(prfCollectionData(iPrf).polyStruct, prfSpecification) ;
          end
          prfObjectVector = [prfObjectVector ; prfObject] ;
      end
      prfCollectionStruct = fill_prfCollectionStruct_from_object_vector( ...
          prfCollectionStruct, prfObjectVector, rowRange, columnRange  ) ;
  end
  
% and that's it!

%
%
%

%=========================================================================================

function prfCollectionStruct = fill_prfCollectionStruct_from_prfArray( ...
               prfCollectionStruct, prfCollectionData, rowRange, columnRange, ...
               prfSpecification  )

% Instantiate the prfClass object(s) from the prfCollectionData and use those, along with
% appropriate other subfunctions, to fill the prfCollectionStruct

  prfObjectVector = [] ;

  if (length(prfCollectionData) == 1)
      prfObjectVector = prfClass(prfCollectionData(1).prfArray, prfSpecification) ;
      prfCollectionStruct = fill_prfCollectionStruct_from_single_object( ...
          prfCollectionStruct, prfObjectVector, rowRange, columnRange  ) ;
  else
      for iPrf = 1:5
          prfObject = prfClass(prfCollectionData(iPrf).prfArray, prfSpecification) ;
          prfObjectVector = [prfObjectVector ; prfObject] ;
      end
      prfCollectionStruct = fill_prfCollectionStruct_from_object_vector( ...
          prfCollectionStruct, prfObjectVector, rowRange, columnRange  ) ;
  end
  
% and that's it!

%
%
%

%=========================================================================================

function prfCollectionStruct = fill_prfCollectionStruct_from_strings( ...
               prfCollectionStruct, prfCollectionData, rowRange, columnRange, ...
               prfSpecification  )

% Instantiate the prfClass object(s) from the prfCollectionData and use those, along with
% appropriate other subfunctions, to fill the prfCollectionStruct

  prfObjectVector = [] ;

  if (length(prfCollectionData) == 1)
      prfObjectVector = prfClass(prfCollectionData{1}, prfSpecification) ;
      prfCollectionStruct = fill_prfCollectionStruct_from_single_object( ...
          prfCollectionStruct, prfObjectVector, rowRange, columnRange  ) ;
  else
      for iPrf = 1:5
          prfObject = prfClass(prfCollectionData{iPrf}, prfSpecification) ;
          prfObjectVector = [prfObjectVector ; prfObject] ;
      end
      prfCollectionStruct = fill_prfCollectionStruct_from_object_vector( ...
          prfCollectionStruct, prfObjectVector, rowRange, columnRange  ) ;
  end
  
% and that's it!

%
%
%

%=========================================================================================

% function to convert fcConstants to row and column ranges

function [rowRange,columnRange] = get_ranges_from_fcConstants(fcConstants)

% unpack the 4 parameters which define the limits of the viewable area in pixel
% coordinates

  nRowsImaging  = fcConstants.nRowsImaging;
  nColsImaging  = fcConstants.nColsImaging;
  nLeadingBlack = fcConstants.nLeadingBlack;
  nMaskedSmear  = fcConstants.nMaskedSmear;
  
% define the ranges

  rowRange    = [nMaskedSmear+0.5  nMaskedSmear+nRowsImaging+0.5]  ;
  columnRange = [nLeadingBlack+0.5 nLeadingBlack+nColsImaging+0.5] ;
  
% and that's it!

%
%
%



