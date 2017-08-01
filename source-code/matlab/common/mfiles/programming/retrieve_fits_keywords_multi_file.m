function [ffiKeywordStruct ffiKeywordTable keywordPresentStruct] = ...
    retrieve_fits_keywords_multi_file( directoryName, ffiType, varargin )
%
% retrieve_fits_keywords_multi_file -- retrieve FITS keywords from multiple files in a
% directory
%
% [ffiKeywordStruct ffiKeywordTable keywordPresentStruct] = 
%    retrieve_fits_keywords_multi_file( directoryName, ffiType, varargin ) searches for
%    all of the FITS files in directory == directoryName, of type == ffiType (e.g.,
%    'ffi-orig', 'lcs-targ', etc.), and retrieves all of the requested FITS keywords from
%    those files.  If ffiType is blank or '*', then all FITS types are searched.  The
%    returned ffiKeywordStruct is a struct array with the keyword values for each keyword
%    from each file, and includes the file names as a field.  The returned
%    keywordPresentStruct has the same structure, but all fields are logicals -- this
%    struct indicates whether the selected fields are present or missing for the located
%    FITS files.  The returned ffiKeywordTable is a struct array containing the file names
%    and a cell array of mnemonics, values, and descriptions.
%
%
% Version date:  2009-March-22.
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

% Modification history:
%
%=========================================================================================

% handle an empty ffiType

  if ( ~exist('ffiType') || isempty(ffiType) || strcmp(ffiType,'*') )
      ffiType = '' ;
  end
  
% get the directory listing -- if the directory doesn't even exist, error out

  if ( exist( directoryName ) ~= 7 )
      error('sbt:retrieveFitsKeywordsMultiFile:invalidDirectory', ...
          'retrieve_fits_keywords_multi_file:  requested directory is invalid') ;
  end
  
  directoryNameFull = [directoryName,filesep,'*',ffiType,'.fits'] ;
  
  dirListing = dir(directoryNameFull) ;
  
  ffiKeywordTable = struct('filename',[],'keywordTable',[]) ;
  ffiKeywordTable = repmat(ffiKeywordTable,1,length(dirListing)) ;
  
% convert the list of FITS header keywords to a char vector -- this is necessary because
% one can't directly pass a varargin from the input of one function to the input of
% another

  keywordString = '' ;
  for iKeyword = 1:length(varargin)
      keywordString = [keywordString,' ''',varargin{iKeyword},''''] ;
      if (iKeyword < length(varargin))
          keywordString = [keywordString,','] ;
      end
  end
  
% construct a command string which can be evaluated to perform the single-file call to
% retrieve_fits_primary_keywords

  cmdString = ['[ffiKeywordStruct(iFile), ffiKeywordTable(iFile).keywordTable] = '] ;
  cmdString = [cmdString,' retrieve_fits_primary_keywords('] ;
  cmdString = [cmdString,' fullfile( directoryName, dirListing(iFile).name ),'] ;
  cmdString = [cmdString, keywordString] ;
  cmdString = [cmdString,' ) ;'] ;
  
% loop over the files and extract their keyword values via the command constructed above

  for iFile = 1:length(dirListing)
            
      eval(cmdString) ;
      
%     produce the appropriate structure for ffiKeywordPresent

      keywordPresentStruct(iFile) = ffiKeywordStruct(iFile) ;
      fieldNames = fieldnames(keywordPresentStruct(iFile)) ;
      
%     for each keyword, determine whether the keyword was present or absent in the current
%     FITS file
      
      for iKeyword = 1:length(fieldNames)
          
          keywordValue = keywordPresentStruct(iFile).(fieldNames{iKeyword}) ;
          if ( ischar( keywordValue ) && ( length(keywordValue) > 9 ) && ...
                  ( strcmp(keywordValue(end-8:end),'not found') ) )
              keywordPresentStruct(iFile).(fieldNames{iKeyword}) = false ;
          else
              keywordPresentStruct(iFile).(fieldNames{iKeyword}) = true ;
          end
          
      end
      
  end
  
% add the file names to the ffiKeywordStruct and ffiKeywordTable structure arrays

  for iFile = 1:length(dirListing)
      ffiKeywordStruct(iFile).filename = dirListing(iFile).name ;
      ffiKeywordTable(iFile).filename = dirListing(iFile).name ;
  end
  
return

% and that's it!

%
%
%
