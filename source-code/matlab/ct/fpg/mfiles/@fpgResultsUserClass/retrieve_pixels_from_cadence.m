function fpgResultsUserObject = retrieve_pixels_from_cadence( fpgResultsUserObject, ...
    accessDataFlag, raDec2PixObject )
%
% retrieve_pixels_from_cadence -- use the time series API to get the target pixels from a
% long cadence into an fpgResultsUserClass object.
%
% fpgResultsUserObject = retrieve_pixels_from_cadence( fpgResultsUserObject ) uses the
%    time series API to retrieve the pixel data for the reference cadence and store them
%    in the pixelTimeSeries member of the fpgResultsUserClass object fpgResultsUserObject.
%
% fpgResultsUserObject = retrieve_pixels_from_cadence( fpgResultsUserObject,
%    accessDataFlag) uses a fake-data generator to mock up the pixel data when the value
%    of accessDataFlag is zero, and uses the time series API when accessDataFlag is 1.
%
% fpgResultsUserObject = retrieve_pixels_from_cadence( fpgResultsUserObject,
%    accessDataFlag, raDec2PixObject ) uses the user-supplied raDec2PixClass object to
%    convert the RA and Dec of star positions to pixel positions.  If the user does not
%    supply an raDec2PixClass object, the raDec2PixModel in the fpgResultsUserObject will
%    be used to instantiate one.
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
%     2008-December-12, PT:
%         replace hard-coded test path with one that uses initialize_soc_variables.
%     2008-October-01, PT:
%         bugfix to changes described below.
%     2008-September-23, PT:
%         update to use appropriate retriever function, and to match data structure
%         manipulation to the data structure it returns.
%
%=========================================================================================

% set the value of accessDataFlag if it is missing

  if (nargin == 1)
      accessDataFlag = 1 ;
  end
  
% determine whether any retrieval is required -- if there is data already present, then no
% retrieval is needed

  if (isempty(get(fpgResultsUserObject,'pixelTimeSeries')))
      
%     use the pixel data retrieval / mockup tool with the correct arguments

      if (accessDataFlag == 1)
          
          targetTimeSeriesStruct = fpg_retrieve_real_pixels( fpgResultsUserObject ) ;
          
      else
          if (nargin == 2)
              raDec2PixObject = raDec2PixClass(get(fpgResultsUserObject,'raDec2PixModel')) ;
          end
          targetTimeSeriesStruct = fpg_retrieve_fake_pixels( fpgResultsUserObject, ...
              raDec2PixObject ) ;
          
      end
      
%     convert the target time series structure to an FPG pixelTimeSeries format, in which
%     the pixelTimeSeriesStruct level of nesting is eliminated

      mjd = get(fpgResultsUserObject,'mjd') ; mjd = mjd(1) ;
%       pixelTimeSeries = convert_time_series_to_fpg_format( targetTimeSeriesStruct ) ;
%       validate_pixelTimeSeries( pixelTimeSeries, mjd, ...
%           get(fpgResultsUserObject,'fcConstants') ) ;
%       fpgResultsUserObject.pixelTimeSeries = pixelTimeSeries ;
       validate_pixelTimeSeries( targetTimeSeriesStruct, mjd, ...
           get(fpgResultsUserObject,'fcConstants') ) ;
       fpgResultsUserObject.pixelTimeSeries = targetTimeSeriesStruct ;
      
%     
            
  end % conditional on need to update the object
  
% and that's it!

%
%
%

%=========================================================================================

% function to perform the retrieval of real pixels via the time series extractor SBT

function targetTimeSeriesStruct = fpg_retrieve_real_pixels( fpgResultsUserObject )

% get the MJD and the information on the # of mod/outs

  mjd = get(fpgResultsUserObject,'mjd') ; mjd = mjd(1) ;
  fcConstants = get(fpgResultsUserObject,'fcConstants') ;
  nChannels = fcConstants.nModules * fcConstants.nOutputsPerModule ;
  [modList,outList] = convert_to_module_output( [1:nChannels]) ;
  
% perform the retrieval

  targetTimeSeriesStruct = retrieve_target_time_series_calibrated( modList, outList, ...
      mjd, mjd, 1 ) ;
    
% and that's it!

%
%
%

%=========================================================================================

% function to generate fake pixel data for plotting

function targetTimeSeriesStruct = fpg_retrieve_fake_pixels( fpgResultsUserObject, ...
    raDec2PixObject ) 

% set the path for retrieval of the cached data based on which computer is being used

  initialize_soc_variables ;
  testFileDir = [socTestDataRoot,'/fpg/unit-tests'] ;

  mjd = get(fpgResultsUserObject,'mjd') ; mjd = mjd(1) ;
  
% get an raDec2PixClass object corresponding to the   
  
  fcConstants = get(fpgResultsUserObject,'fcConstants') ;
  
% get the seasonal roll for the MJD, and using that to retrieve the star information which
% is appropriate for that seasonal roll

  rollTimeObject = rollTimeClass( get(raDec2PixObject,'rollTimeModel') ) ;
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
  
% construct the row, column, and timeSeries which will be used for each star:

  rowValues = [-2 -1 0 1 2] ; colValues = rowValues ;
  [row,column] = ndgrid(rowValues, colValues) ;
  row = row(:)' ; column = column(:)' ;
  timeSeries = zeros(5,5) ;
  timeSeries(3,3) = 16 ;
  timeSeries(2,3) = 4 ;
  timeSeries(4,3) = 4 ;
  timeSeries(3,2) = 4 ;
  timeSeries(3,4) = 4 ;
  timeSeries(2,2) = 2 ;
  timeSeries(4,2) = 2 ;
  timeSeries(2,4) = 2 ;
  timeSeries(4,4) = 2 ;
  timeSeries = timeSeries(:)' ;
  
  
% construct the keplerIdTimeSeriesStruct which will be used for each star

  kTSS.keplerId = [] ;
  kTSS.row = row ;
  kTSS.column = column ;
  kTSS.isInOptimalAperture = ones(size(timeSeries)) ;
  kTSS.timeSeries = timeSeries ;
  kTSS.gapIndicators = zeros(size(timeSeries)) ;
  
% construct pixelTimeSeries as a structure

  pTS.module = [] ;
  pTS.output = [] ;
  pTS.mjdArray = [] ;
  pTS.keplerIdTimeSeriesStruct = kTSS ;
  
% dimension the return variable properly

  nModOut = length( starSkyCoordinates ) ;
  targetTimeSeriesStruct(nModOut) = pTS ;
  
% loop over mod/outs
  for iModOut = 1:nModOut
      
      targetTimeSeriesStruct(iModOut).module = starSkyCoordinates(iModOut).module ;
      targetTimeSeriesStruct(iModOut).output = starSkyCoordinates(iModOut).output ;
      targetTimeSeriesStruct(iModOut).mjdArray = mjd ;
            
%     get the pixel coordinates for all stars

      [m,o,r,c] = ra_dec_2_pix(raDec2PixObject, starSkyCoordinates(iModOut).ra*15, ...
          starSkyCoordinates(iModOut).dec, mjd) ;
      
%     eliminate any which fell off the mod/out

      badStars1 = find( (m~=starSkyCoordinates(iModOut).module) | ...
          (o~=starSkyCoordinates(iModOut).output) ) ;
      r = round(r) ; c = round(c) ;
      badStars2 = find( r<fcConstants.MASKED_SMEAR_END + 3 | r > fcConstants.VIRTUAL_SMEAR_START - 3 ) ;
      badStars3 = find( c< fcConstants.LEADING_BLACK_END + 3 | c > fcConstants.TRAILING_BLACK_START - 3 ) ;
      badStars = unique([badStars1(:) ; badStars2(:) ; badStars3(:)]) ;
      r(badStars) = [] ; c(badStars) = [] ;
      starSkyCoordinates(iModOut).keplerId(badStars) = [] ;
      
      nStar = length(starSkyCoordinates(iModOut).keplerId) ;
      targetTimeSeriesStruct(iModOut).keplerIdTimeSeriesStruct(1:nStar) = kTSS ;
      
      keplerIdCell = num2cell(starSkyCoordinates(iModOut).keplerId) ;
      [targetTimeSeriesStruct(iModOut).keplerIdTimeSeriesStruct.keplerId] = keplerIdCell{:} ;
      
%     loop over stars and set their row and column values
      
      for iStar = 1:nStar
          
%           rowStar = num2cell(row + r(iStar)) ; colStar = num2cell(column + c(iStar)) ;
%           [targetTimeSeriesStruct(iModOut).keplerIdTimeSeriesStruct(iStar).pixelTimeSeriesStruct.row] = ...
%               rowStar{:} ;
%           [targetTimeSeriesStruct(iModOut).keplerIdTimeSeriesStruct(iStar).pixelTimeSeriesStruct.column] = ...
%               colStar{:} ;

          rowStar = row + r(iStar) ; colStar = column + c(iStar) ;
          targetTimeSeriesStruct(iModOut).keplerIdTimeSeriesStruct(iStar).row = ...
              rowStar ;
          targetTimeSeriesStruct(iModOut).keplerIdTimeSeriesStruct(iStar).column = ...
              colStar ;


      end % loop over stars
      
  end % loop over mod/outs.
  
% and that's it!

%
%
%

%=========================================================================================

% function which reorganizes the targetTimeSeriesStruct to eliminate the lowest level of
% structure nesting

% NOTE:  this function is now obsolete, since the time-series retriver has eliminated the
% lowest level of nesting (pixelTimeSeriesStruct) already.  I am leaving this routine in
% here for archival reasons but it is not thought to be needed or even useful any longer.

function pixelTimeSeries = convert_time_series_to_fpg_format( targetTimeSeriesStruct )

% start by duplicating the old structure, since there are some things we can simply copy
% over, but order the fields while we are at it; and remove fields we don't need
  
  pixelTimeSeries = orderfields(targetTimeSeriesStruct) ;
  if (isfield(pixelTimeSeries,'isLongCadence')) 
      pixelTimeSeries = rmfield(pixelTimeSeries,'isLongCadence') ;
  end
  if (isfield(pixelTimeSeries,'isOriginalData'))
      pixelTimeSeries = rmfield(pixelTimeSeries,'isOriginalData') ;
  end  
  
% loop over the top-level of the structure (which is by channel)

  nChannel = length(pixelTimeSeries) ;
  for iChannel = 1:nChannel
      
%     remove the pixelTimeSeriesStruct from the keplerIdTimeSeriesStruct

      pixelTimeSeries(iChannel).keplerIdTimeSeriesStruct = ...
          rmfield(pixelTimeSeries(iChannel).keplerIdTimeSeriesStruct,...
          'pixelTimeSeriesStruct') ;
      
%     Add the fields that we need onto the keplerIdTimeSeriesStruct

      pixelTimeSeries(iChannel).keplerIdTimeSeriesStruct(1).row = [] ;
      pixelTimeSeries(iChannel).keplerIdTimeSeriesStruct(1).column = [] ;
      pixelTimeSeries(iChannel).keplerIdTimeSeriesStruct(1).timeSeries = [] ;

%     loop over the keplerIdTimeSeriesStruct entities and construct the new data fields

      nTargets = length(targetTimeSeriesStruct(iChannel).keplerIdTimeSeriesStruct) ;
      
      for iTarget = 1:nTargets
          
          pTSS = targetTimeSeriesStruct(iChannel).keplerIdTimeSeriesStruct(iTarget).pixelTimeSeriesStruct ;
          row = [pTSS.row] ;
          row = row(:) ;
          pixelTimeSeries(iChannel).keplerIdTimeSeriesStruct(iTarget).row = row ;
          
          column = [pTSS.column] ;
          column = column(:) ;
          pixelTimeSeries(iChannel).keplerIdTimeSeriesStruct(iTarget).column = column ;
          
          timeSeries = [pTSS.timeSeries] ;
          nTimes = length(timeSeries) / length(column) ;
          pixelTimeSeries(iChannel).keplerIdTimeSeriesStruct(iTarget).timeSeries = ...
              reshape(timeSeries,nTimes,length(column)) ;
          
      end % target loop
      
  end % channel loop
  
% and that's it!

%
%
%

%=========================================================================================

% function validate_pixelTimeSeries -- performs validation (duh!) on the pixelTimeSeries
% structure.  This function is based on auto-generated validation code.

function validate_pixelTimeSeries( pixelTimeSeries, mjd, fcConstants )

% start with the top-level validation -- correct MJD, module and output values valid.  Due
% to roundoff issues, just validate the MJD to the level of 9 significant figures

mjdTruncation = 9 ;
validMjdString = ['[',num2str(mjd,mjdTruncation),']'] ;
validModuleString = ['[',num2str(fcConstants.modulesList(:)'),']'] ;
validOutputString = ['[',num2str([1:fcConstants.nOutputsPerModule]),']'] ;

fieldsAndBounds = cell(4,4);
fieldsAndBounds(1,:)  = { 'keplerIdTimeSeriesStruct'; []; []; []};
fieldsAndBounds(2,:)  = { 'mjdArray'; []; []; validMjdString};
fieldsAndBounds(3,:)  = { 'module'; []; []; validModuleString};
fieldsAndBounds(4,:)  = { 'output'; []; []; validOutputString};

nStructures = length(pixelTimeSeries);

for j = 1:nStructures
    
    mjdUntruncated = pixelTimeSeries(j).mjdArray ;
    pixelTimeSeries(j).mjdArray = str2num(num2str(pixelTimeSeries(j).mjdArray,mjdTruncation)) ;
	validate_structure(pixelTimeSeries(j), fieldsAndBounds,'pixelTimeSeries');
    pixelTimeSeries(j).mjdArray = mjdUntruncated ;
end

clear fieldsAndBounds;

% next-level validation -- fields of keplerIdTimeSeriesStruct:  keplerId, row, column,
% time series, gapIndicators.  

keplerIdMax = 15124609+1 ;
keplerMaxIdString = ['<',num2str(keplerIdMax,'%d')] ;
rowMinString = ['>',num2str(fcConstants.MASKED_SMEAR_END)] ;
rowMaxString = ['<',num2str(fcConstants.VIRTUAL_SMEAR_START)] ;
colMinString = ['>',num2str(fcConstants.LEADING_BLACK_END)] ;
colMaxString = ['<',num2str(fcConstants.TRAILING_BLACK_START)] ;

fieldsAndBounds = cell(5,4);
fieldsAndBounds(1,:)  = { 'keplerId'; '>=1'; keplerMaxIdString; []};
fieldsAndBounds(2,:)  = { 'row'; rowMinString ; rowMaxString ; []};
fieldsAndBounds(3,:)  = { 'column'; colMinString ; colMaxString ; []};
fieldsAndBounds(4,:)  = { 'timeSeries'; []; []; []};
fieldsAndBounds(4,:)  = { 'gapIndicators'; []; []; []};

kStructs = length(pixelTimeSeries);
for i = 1:kStructs
    nStructures = length(pixelTimeSeries(i).keplerIdTimeSeriesStruct);
    nMjd = length(pixelTimeSeries(i).mjdArray) ;
    
%   within a given mod/out, concatenate the rows, columns, and keplerIds and valdiate the
%   fields via validate_field (saves time compared to use of validate_structure).
    
    keplerId = [pixelTimeSeries(i).keplerIdTimeSeriesStruct.keplerId] ;
    row = [pixelTimeSeries(i).keplerIdTimeSeriesStruct.row] ;
    column = [pixelTimeSeries(i).keplerIdTimeSeriesStruct.column] ;
    errString = ['pixelTimeSeries(',num2str(i),')'] ;
    validate_field(keplerId,fieldsAndBounds(1,:),[errString,' keplerId']) ;
    validate_field(row,fieldsAndBounds(2,:),[errString,' row']) ;
    validate_field(column,fieldsAndBounds(3,:),[errString,' column']) ;

    for j = 1:nStructures
        
%       validate the time series (can't concatenate them because the # of pixels becomes #
%       of rows, which means that different targets can have different # of rows and thus
%       can't be concatenated)
        
        errString = ['pixelTimeSeries(',num2str(i),').keplerIdTimeSeriesStruct(', ...
            num2str(j),')'] ;
        validate_field(pixelTimeSeries(i).keplerIdTimeSeriesStruct(j).timeSeries,...
            fieldsAndBounds(4,:),errString) ;
        
%       additional validation -- the row, column and keplerId should be integer-valued; 
%                                keplerId is a scalar ;
%                                row and column are vectors
%                                sizeof(timeSeries) = length(row) by length (mjdArray)

        kTSS = pixelTimeSeries(i).keplerIdTimeSeriesStruct(j) ;

        if (~isscalar(kTSS.keplerId))
            error('fpg:retrievePixelsFromCadence:keplerIdNotScalar',...
                ['retrieve_pixels_from_cadence:  keplerId must be a scalar in ',...
                errString]) ;
        end
        if (~isvector(kTSS.row) || (~isvector(kTSS.column)))
            error('fpg:retrievePixelsFromCadence:rowColumnNotVector', ...
                ['retrieve_pixels_from_cadence:  row and column must be vectors in ',...
                errString]) ;
        end
        if ( (any(kTSS.row~=round(kTSS.row))) || (any(kTSS.column~=round(kTSS.column))) || ...
             (kTSS.keplerId ~= round(kTSS.keplerId)) )
           error('fpg:retrievePixelsFromCadence:notInteger', ...
               ['retrieve_pixels_from_cadence:  row, column, or keplerId not integer in ',...
               errString]) ;
        end
        if ( (any(size(kTSS.timeSeries) ~= [nMjd length(kTSS.row)])) )
            error('fpg:retrievePixelsFromCadence:timeSeriesDimensions',...
                ['retrieve_pixels_from_cadence: timeSeries has wrong dimensions in ',...
                errString]) ;
        end
    
    end
    

end

% just in case it is needed, here is the validate_structure call which I removed in order
% to speed up the validation using validate_field.

%		validate_structure(pixelTimeSeries(i).keplerIdTimeSeriesStruct(j), ...
%            fieldsAndBounds,errString);
