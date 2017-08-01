function fpgResultsUserObject = retrieve_star_information_from_catalog( fpgResultsUserObject, ...
    minMagnitudePlot, maxMagnitudePlot, retrieveKicFlag )
%
% retrieve_star_information_from_catalog -- populate the star position information in an
% fpgResultsUserClass object from the KIC.
%
% fpgResultsUserObject = retrieve_star_information_from_catalog( fpgResultsUserObject,
%    minMagnitudePlot, maxMagnitudePlot ) populates the starSkyCoordinates member of
%    fpgResultsUserClass object fpgResultsUserObject from the KIC, obtaining information
%    on all of the stars between minMagnitudePlot and maxMagnitudePlot.  The data is
%    obtained for the MJD of the reference cadence.
%
% fpgResultsUserObject = retrieve_star_information_from_catalog(... , retrieveKicFlag)
%    indicates whether the user wants the data to be obtained from the KIC
%    (retrieveKicFlag == 1) or from a local cache of star data (retrieveKicFlag == 0).  If
%    retrieveKicFlag is omitted, a default of 1 (use the KIC) is inferred.
%
% Version date:  2008-December-12.
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
%    2008-December-12, PT:
%        replace hard-coded path with maintainable test path access.
%
%=========================================================================================

% if the retrieveKicFlag is missing, set it to 1

  if (nargin == 3)
      retrieveKicFlag = 1 ;
  end
  
% if minMagnitudePlot is greater than maxMagnitudePlot, throw an error

  if (minMagnitudePlot > maxMagnitudePlot)
      error('fpg:retrieveStarInformationFromCatalog:magnitudeRange', ...
          'retrieve_star_information_from_catalog:  min magnitude > max magnitude') ;
  end
  
% determine whether any retrieval is needed -- if the currently-stored magnitude range
% includes the requested range (and of course, this is in the case where there is star
% data currently stored)

  minMagnitudeStored = get(fpgResultsUserObject, 'minMagnitude') ;
  maxMagnitudeStored = get(fpgResultsUserObject, 'maxMagnitude') ;
  
  if ( (isempty(minMagnitudeStored)) || (minMagnitudeStored > minMagnitudePlot) || ...
          (maxMagnitudeStored < maxMagnitudeStored) )
      
%     If we got here, then we need to do the retrieval after all; so use either the
%     retrieve_kics method or the cached star information method, depending on the value
%     of the retrieveKicFlag
      
      if (retrieveKicFlag == 1)
          
          starSkyCoordinates = fpg_retrieve_real_kics( fpgResultsUserObject, ...
              minMagnitudePlot, maxMagnitudePlot ) ;
          
      else
          
          [starSkyCoordinates, minMagnitudePlot, maxMagnitudePlot] = fpg_retrieve_mat_kics( ...
              fpgResultsUserObject, minMagnitudePlot, maxMagnitudePlot ) ;
          
      end

%     validate the starSkyCoordinates data structure

      validate_starSkyCoordinates(starSkyCoordinates, minMagnitudePlot, maxMagnitudePlot, ...
          get(fpgResultsUserObject,'fcConstants') ) ;
      
%     put the starSkyCoordinates and the stellar magnitude information into the data
%     structure and re-instantiate the fpgResultsUserObject with it

      fpgResultsUserObject.starSkyCoordinates = starSkyCoordinates ;
      fpgResultsUserObject.minMagnitude = minMagnitudePlot ;
      fpgResultsUserObject.maxMagnitude = maxMagnitudePlot ;
            
  end % conditional on whether we need to perform the retrieve
  
% and that's it!

%
%
%

%=========================================================================================

% function fpg_retrieve_real_kics -- perform the retrieve_kics call to the datastore, and
% organize the resulting information in the correct format for fpgResultsUserClass objects

function starSkyCoordinates = fpg_retrieve_real_kics( fpgResultsUserObject, ...
    minMagnitudePlot, maxMagnitudePlot )

% dimension the return structure and do general setup
  
  mjd = get(fpgResultsUserObject,'mjd') ; mjd = mjd(1) ;
  fcConstants = get(fpgResultsUserObject,'fcConstants') ;
  nChannels = fcConstants.nModules * fcConstants.nOutputsPerModule ;
  [moduleList,outputList] = convert_to_module_output( [1:nChannels]) ;

  starSkyCoordinates( nChannels ).module = [] ; 
  starSkyCoordinates( nChannels ).output = [] ; 
  starSkyCoordinates( nChannels ).keplerId = [] ; 
  starSkyCoordinates( nChannels ).keplerMag = [] ; 
  starSkyCoordinates( nChannels ).ra = [] ; 
  starSkyCoordinates( nChannels ).dec = [] ; 
  
% loop over mod/outs and perform the KIC access

  for iModOut = 1:nChannels
      
      kics = retrieve_kics( moduleList(iModOut), outputList(iModOut), mjd, ...
          minMagnitudePlot, maxMagnitudePlot ) ;
      
%     dimension the vectors which go into the structure

      nStars = length(kics) ;
      keplerId = zeros(nStars,1) ;
      keplerMag = zeros(nStars,1) ;
      ra = zeros(nStars,1) ;
      dec = zeros(nStars,1) ;
      
%     loop over the stars and get their information

      for iStar = 1:nStars
          
          keplerId(iStar) = kics(iStar).getKeplerId() ;
          keplerMag(iStar) = kics(iStar).getKeplerMag() ;
          ra(iStar) = kics(iStar).getRa() ;
          dec(iStar) = kics(iStar).getDec() ;
          
      end % loop over stars
      
%     put it all together

      starSkyCoordinates(iModOut).module = moduleList(iModOut) ;
      starSkyCoordinates(iModOut).output = outputList(iModOut) ;
      starSkyCoordinates(iModOut).keplerId = keplerId ;
      starSkyCoordinates(iModOut).keplerMag = keplerMag ;
      starSkyCoordinates(iModOut).ra = ra ;
      starSkyCoordinates(iModOut).dec = dec ;
      
  end % loop over mod/outs
      
% and that's it!

%
%
%

%=========================================================================================

% function which performs the retrive via the stored mat-file version of the KIC

function [starSkyCoordinates, minMagnitudePlot, maxMagnitudePlot] = ...
              fpg_retrieve_mat_kics( fpgResultsUserObject, ...
              minMagnitudePlot, maxMagnitudePlot, mjd, raDec2PixModel )

% set the path for retrieval of the cached data based on which computer is being used

  initialize_soc_variables ;
  testFileDir = [socTestDataRoot,'/fpg/unit-tests'] ;

% get the MJD for the lookup
  
  mjd = get(fpgResultsUserObject,'mjd') ; mjd = mjd(1) ;
  
% if the magnitudes exceed the range of the cached data, throw a warning and change the
% values of minMagnitudePlot and maxMagnitudePlot

  minMagnitudeCached = 6.0 ; maxMagnitudeCached = 15.0 ;
  
  if ( (minMagnitudePlot < minMagnitudeCached) || (maxMagnitudePlot > maxMagnitudeCached) )
      warning('fpg:fpgRetrieveCachedKics:magnitudeRangeLimit', ...
          'fpg_retrieve_cached_kics:  requested ranges exceed cached ranges') ;
      minMagnitudePlot = max([minMagnitudePlot minMagnitudeCached]) ;
      maxMagnitudePlot = min([maxMagnitudePlot maxMagnitudeCached]) ;
  end
  
% determine the seasonal roll orientation of the date in question and retrieve the correct
% cached catalog
  
  raDec2PixModel = get(fpgResultsUserObject,'raDec2PixModel') ;
  rollTimeObject = rollTimeClass( raDec2PixModel.rollTimeModel ) ;
  rollTime = get_roll_time(rollTimeObject, mjd) ;
  season = rollTime(3) ; 
  
  switch season
      
      case 0
          
          load(fullfile(testFileDir,'starSkyCoordinatesSeason0')) ;
          
      case 1
          
          load(fullfile(testFileDir,'starSkyCoordinatesSeason1')) ;
          
      case 2
          
          load(fullfile(testFileDir,'starSkyCoordinatesSeason2')) ;
          
      case 3
          
          load(fullfile(testFileDir,'starSkyCoordinatesSeason3')) ;
          
  end % switch statement on season
  

% reduce the range of magnitudes to the ones specified by the user

  starSkyCoordinates = reduce_mag_range( starSkyCoordinates, minMagnitudePlot, ...
      maxMagnitudePlot ) ;
    
% and that's it!

%
%
%

%=========================================================================================

% perform validation of starSkyCoordinates information

function validate_starSkyCoordinates( starSkyCoordinates, minMagnitudePlot, ...
    maxMagnitudePlot, fcConstants )

% prepare information for keplerId validation
keplerIdMax = 15124609+1 ;
keplerMaxIdString = ['<',num2str(keplerIdMax,'%d')] ;

% get module and output valid values
  validModules = fcConstants.modulesList(:)' ;
  validOutputs = 1:fcConstants.nOutputsPerModule ;
  validModulesString = ['[',num2str(validModules),']'] ;
  validOutputsString = ['[',num2str(validOutputs),']'] ;
  
% setup strings for magnitude range
  minMagValidateString = ['>=',num2str(minMagnitudePlot),] ;
  maxMagValidateString = ['<=',num2str(maxMagnitudePlot),] ;

% This is an auto-generated script. Modify if needed.
%------------------------------------------------------------
fieldsAndBounds = cell(6,4);
fieldsAndBounds(1,:)  = { 'module'; []; []; validModulesString};
fieldsAndBounds(2,:)  = { 'output'; []; []; validOutputsString};
fieldsAndBounds(3,:)  = { 'keplerId'; '>=1' ; keplerMaxIdString ; []};
fieldsAndBounds(4,:)  = { 'keplerMag'; minMagValidateString; maxMagValidateString; []};
fieldsAndBounds(5,:)  = { 'ra'; []; []; []};
fieldsAndBounds(6,:)  = { 'dec'; []; []; []};

nStructures = length(starSkyCoordinates);

for j = 1:nStructures
    
    errString = ['starSkyCoordinates(',num2str(j),')'] ;
	validate_structure(starSkyCoordinates(j), fieldsAndBounds, errString);
    
%   additional validations:  module and output should be scalars;
%       keplerId should be integer-valued;
%       keplerId, keplerMag, ra, dec should be vectors of equal length.

    if (~isscalar(starSkyCoordinates(j).module) || ...
            ~isscalar(starSkyCoordinates(j).output)    )
        error('fpg:retrieveStarInformationFromCatalog:modOutNotScalar', ...
            ['retrieve_star_information_from_catalog:  module and output must be scalar in ',...
             errString]) ;
    end
    if (any(starSkyCoordinates(j).keplerId ~= round(starSkyCoordinates(j).keplerId)))
        error('fpg:retrieveStarInformationFromCatalog:keplerIdNotInteger', ...
            ['retrieve_star_information_from_catalog:  keplerId must be integer-valued in ',...
             errString]) ;
    end
    if ( (~isvector(starSkyCoordinates(j).keplerId)) || ...
            (~isvector(starSkyCoordinates(j).keplerMag)) || ...
            (~isvector(starSkyCoordinates(j).ra)) || ...
            (~isvector(starSkyCoordinates(j).dec)) )
        error('fpg:retrieveStarInformationFromCatalog:fieldsNotVectors', ...
            ['retrieve_star_information_from_catalog:  star data fields must be vectors in ',...
             errString]) ;
    end
    refLength = length(starSkyCoordinates(j).keplerId) ;
    if ( (length(starSkyCoordinates(j).keplerMag)~=refLength) || ...
            (length(starSkyCoordinates(j).ra)~=refLength) || ...
            (length(starSkyCoordinates(j).dec)~=refLength) )
        error('fpg:retrieveStarInformationFromCatalog:fieldsNotEqualLength', ...
            ['retrieve_star_information_from_catalog:  star data fields must have equal lengths in ',...
             errString]) ;
    end
    
end % loop over structures

clear fieldsAndBounds;
%------------------------------------------------------------
