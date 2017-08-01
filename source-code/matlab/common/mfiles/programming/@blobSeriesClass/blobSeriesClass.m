function blobSeriesObject = blobSeriesClass( blobSeries )
%
% blobSeriesClass -- class constructor for an object to manage blobSeries
%
% blobSeriesObject = blobSeriesClass( blobSeries ) takes as an argument a blobSeries
%    structure from the Java-side and encapsulates that structure and its associated blob
%    data in an object which provides access methods to the user.
%
% Class members include:
% 
%    blobIndices:   1 x nCadences vector of indices into the data structures.
%    gapIndicators: 1 x nCadences vector of logicals indicating gaps.
%    blobStruct:    1 x nBlobs vector of deblobbed Matlab structures.
%    startCadence:  scalar, value of first cadence associated with the series.
%    endCadence:    scalar, value of the last cadence associated with the series.
%
% See also:  struct_to_blob single_blob_to_struct.
%
% Version date:  2008-September-19.
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
%     2008-September-19, PT:
%         support for startCadence and endCadence members.  Sort fields in the structure
%         before calling the class function.
%     2008-September-07, PT:
%         support for blobIndices as any real numeric class, not just int32.  
%     2008-September-05, PT:
%         Per recent discussions with SOC team, blobSeries will always be a blobNameSeries
%         and use a cell array to transport the filenames.  Modify code to handle that new
%         conception of the blobSeriesClass.
%
%=========================================================================================

% validate the blobSeries structure

  fieldsAndBounds = cell(5,4) ;
  fieldsAndBounds(1,:) = { 'blobIndices' ; [] ; [] ; [] } ;
  fieldsAndBounds(2,:) = { 'gapIndicators' ; [] ; [] ; [] } ;
  fieldsAndBounds(3,:) = { 'blobFilenames' ; [] ; [] ; [] } ; 
  fieldsAndBounds(4,:) = { 'startCadence' ; [] ; [] ; [] } ;
  fieldsAndBounds(5,:) = { 'endCadence' ; [] ; [] ; [] } ;
  validate_structure( blobSeries, fieldsAndBounds, 'blobStruct' ) ;
  clear fieldsAndBounds ;

% gapIndicators and blobIndices should have equal length and be vectors; blobStruct should
% also be a vector; blobIndices should be integer-valued, of a numeric type, and real

  if (~isvector(blobSeries.blobIndices) || ~isvector(blobSeries.gapIndicators) ||...
          length(blobSeries.blobIndices) ~= length(blobSeries.gapIndicators) )
      error('programming:blobSeriesClass:cadenceVectorsInvalid', ...
          'blobSeriesClass:  blobIndices and gapIndicators must be equal-length vectors') ;
  end
  if (~isnumeric(blobSeries.blobIndices))
      error('programming:blobSeriesClass:blobIndicesNotNumeric', ...
          'blobSeriesClass: blobIndices vector is not a numeric class') ;
  end
  if (~isreal(blobSeries.blobIndices))
      error('programming:blobSeriesClass:blobIndicesNotReal', ...
          'blobSeriesClass: blobIndices vector is not real') ;
  end
  if (any(round(blobSeries.blobIndices)~=blobSeries.blobIndices))
      error('programming:blobSeriesClass:blobIndicesNotIntegerValued', ...
          'blobSeriesClass: blobIndices vector is not integer-valued') ;
  end
  
  if (~strcmp(class(blobSeries.gapIndicators),'logical'))
      error('programming:blobSeriesClass:gapIndicatorsIllogical', ...
          'blobSeriesClass: gapIndicators are not logical') ;
  end
  
% startCadence and endCadence should be scalars, and integer-valued, and endCadence cannot
% be smaller than startCadence

  if (~isscalar(blobSeries.startCadence))
      error('programming:blobSeriesClass:startCadenceNotScalar', ...
          'blobSeriesClass: startCadence is not a scalar') ;
  end
  if (~isscalar(blobSeries.endCadence))
      error('programming:blobSeriesClass:endCadenceNotScalar', ...
          'blobSeriesClass: endCadence is not a scalar') ;
  end
  if ( round(blobSeries.startCadence) ~= blobSeries.startCadence )
      error('programming:blobSeriesClass:startCadenceNotIntegerValued', ...
          'blobSeriesClass: startCadence is not integer-valued') ;
  end
  if ( round(blobSeries.endCadence) ~= blobSeries.endCadence )
      error('programming:blobSeriesClass:endCadenceNotIntegerValued', ...
          'blobSeriesClass: endCadence is not integer-valued') ;
  end
  if ( blobSeries.endCadence < blobSeries.startCadence )
      error('programming:blobSeriesClass:endCadenceLessThanStartCadence', ...
          'blobSeriesClass:  endCadence is less than startCadence') ;
  end

% blobFilenames is a vector cell array, and each cell is a string
  
  if (~isvector(blobSeries.blobFilenames) | ~iscell(blobSeries.blobFilenames) )
      error('programming:blobSeriesClass:blobFilenamesNotVectorCellArray',...
          'blobSeriesClass: the blobFilenames field must be a vector cell array') ;
  end
  
  nBlobs = length(blobSeries.blobFilenames) ;
  for iBlob = 1:nBlobs
      if ( ~ischar(blobSeries.blobFilenames{iBlob}) | ...
           ~isvector(blobSeries.blobFilenames{iBlob}) )
          error('programming:blobSeriesClass:blobFilenamesNotCharVectors', ...
              'blobSeriesClass:  the cells in blobFilenames field must all be char arrays') ;
      end
  end

% all of the cadences which are not gapped must point at one of the blobs
  
  validIndices = 0:nBlobs-1 ;
  blobIndicesValidCadences = blobSeries.blobIndices( find(~blobSeries.gapIndicators) ) ;
  if (any(~ismember(blobIndicesValidCadences,validIndices)))
      error('programming:blobSeriesClass:cadenceNumbersInvalid', ...
          'blobSeriesClass:  invalid cadence numbers detected in blobIndices') ;
  end
  
% remove the blobFilenames from the blobSeries structure

  blobFilenames = blobSeries.blobFilenames ;
  blobSeries = rmfield(blobSeries,'blobFilenames') ;
  
% deblob the last blob so that the size of the array is properly dimensioned.  

  if (nBlobs > 0)
  
      blobSeries.blobStruct(nBlobs).struct = ...
          single_blob_to_struct(blobFilenames{nBlobs}) ;
  
%     now loop over the rest of the array and deblob

      for iBlob = 1:nBlobs-1
          blobSeries.blobStruct(iBlob).struct = ...
              single_blob_to_struct(blobFilenames{iBlob}) ;
      end
      
  end
    
% increment the blobIndices to be one-based (it's Matlab, after all!)

  blobSeries.blobIndices = blobSeries.blobIndices + 1 ;
  
% sort the fields into alphabetical order

  blobSeries = orderfields(blobSeries) ;
  
% instantiate the object, return it, and exit

  blobSeriesObject = class( blobSeries, 'blobSeriesClass' ) ;
  
% and that's it!

%
%
%
