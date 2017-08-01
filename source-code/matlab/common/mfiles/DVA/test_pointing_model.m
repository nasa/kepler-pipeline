function test_pointing_model
%
% test_pointing_model -- this is a prototype script for a more turnkey pointing model
% prototype that I intend to develop for ops use -- PT.
%
% Version date:  2013-November-13.
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
%    2009-April-03, PT:
%        use FOV center as indicator that pointing model is correct (I discovered that
%        raDec2Pix can return MORC for the center, even though there's no pixel there).
%
%    2009-May-15, JH:
%        - Replaced cached raDec2PixModel with call to retrieve_ra_dec_2_pix_model
%        - Replaced call to modify_raDec2PixModel with simple replacement of: 
%        spiceSpacecraftEphemerisFilename, pointingModel
%        - Make use of "uigetfile" so the user selects files, rather then coding 
%        them in.
%        - Modified the function parse_pointing_model(). It no longer takes
%        the directory and filename as input arguments. Now, it just takes
%        the FullFilename, which contains the full path. This is due to using
%        uigetfile.
%        - Changed masterDirectory to workingDirectory. Instead of copying
%        all pointing model files to the masterDirectory, now use the
%        workingDirectory as the figure output directory.
%        - Added a check (and copy) to ensure the new spacecraft ephemeris
%        is in the same directory as the planetary ephemeris and
%        leap-seconds
%    2013-November-14, JT:
%        updated to accommodate new segmentStartMjds field in pointing
%        model
%
%=========================================================================================

tic;

fprintf('\n Compare the new ephemris/pointing pair to the current ephemeris/pointing pair. \n');

% constant definition -- mainly paths and filenames  
%  workingDirectory=uigetdir('/','Select the working directory to store the output figures');
  disp('  Select the working directory to store the output figures')
  workingDirectory=uigetdir();

% Spacecraft Ephemeris filename
  [newSpacecraftEphemerisFilename, newEphemerisPathName, filterIndex] = ...
      uigetfile('*.bsp', 'Select the new spacecraft ephemeris file') ;
  newSpacecraftEphemerisFullFilename = fullfile(newEphemerisPathName, newSpacecraftEphemerisFilename) ;
  disp(['  User selected S/C ephemeris: ', newSpacecraftEphemerisFullFilename])

% Pointing model filenames
  [currentPointingModelFilename, currentDirectory, filterIndex] = ...
      uigetfile('*.txt', 'Select the Current Pointing Model file') ;
  currentPointingModelFullFilename=fullfile(currentDirectory, currentPointingModelFilename);
  disp(['  User selected Current pointing model: ', currentPointingModelFullFilename])

  [newPointingModelFilename, newDirectory, filterIndex] = ...
      uigetfile('*.txt', 'Select the New Pointing Model file') ;
  newPointingModelFullFilename = fullfile(newDirectory, newPointingModelFilename);
  disp(['  User selected New pointing model: ', newPointingModelFullFilename])
  
% approximate radius of the FOV, in pixels
  fovRadiusPixels = 5000 ;
  
% degree-radian conversion
  degreesPerRadian = 180 / pi ;

  
%=========================================================================================

% Move to the working directory  
  currentDir = pwd ;
  cd(workingDirectory) ;
  
% retrieve the current raDec2PixModel
  disp('  Retrieving the current raDec2PixModel')
  raDec2PixModel = retrieve_ra_dec_2_pix_model();

  
% Verify the new spacecraft ephemeris is in the same directory as the
% planetary and leap seconds directory. If not, then copy it there.
  if ~isequal(newEphemerisPathName, [raDec2PixModel.spiceFileDir filesep])
      disp('  The New spacecraft ephemeris file is not in the same directory as the planetary and leap second files.')
      disp(['  Copying file from: ' newEphemerisPathName]);
      disp(['  To: ' raDec2PixModel.spiceFileDir filesep]);
      eval(['!cp ' newSpacecraftEphemerisFullFilename ' ' [raDec2PixModel.spiceFileDir filesep]])
      if ~exist([raDec2PixModel.spiceFileDir filesep newSpacecraftEphemerisFilename],'file')
          disp('  Error copying file ... quitting')
          return
      end
  end

% degree-pixel conversion
  arcsecPerPixel = raDec2PixModel.geometryModel.constants(1).array(336) ;
  degreesPerPixel = arcsecPerPixel / 3600 ;  
  
%=========================================================================================

% TEST 1:  check that the new pointing + new ephemeris keeps the photometer centered on
% the nominal FOV while DVA acts upon it.  

% First step:  construct an raDec2PixClass object with the correct properties

  raDec2PixModelNew = raDec2PixModel ;

  pointingModelNew = parse_pointing_model( newPointingModelFullFilename ) ;

% replace the pointing model and spacecraft ephemeris filename

  raDec2PixModelNew.pointingModel = pointingModelNew ;
  raDec2PixModelNew.spiceSpacecraftEphemerisFilename = newSpacecraftEphemerisFilename ;


  raDec2PixObjectNew = raDec2PixClass(raDec2PixModelNew,'one-based') ;
  
  
% determine the start, end, and step values

  mjdStartNew = pointingModelNew.mjds(1) ;
  mjdEndNew   = pointingModelNew.mjds(end) ;
  mjdStepNew  = pointingModelNew.mjds(2) - pointingModelNew.mjds(1) ;


% use pix_2_ra_dec to determine the correct pixel to use henceforth; first
% get nominal FOV center at mjd start time

  rollTimeModel = get(raDec2PixObjectNew, 'rollTimeModel')  ;
  rollTimeObject = rollTimeClass(rollTimeModel) ;
  rollTime = get_roll_time(rollTimeObject, mjdStartNew);
  
  raFovStart = rollTime(4) ;
  decFovStart = rollTime(5) ;
  
  [mod, out, row, col] = ra_dec_2_pix( raDec2PixObjectNew, ...
      raFovStart, decFovStart, mjdStartNew ) ;
  
  
% Make sure the ra and dec are valid; ie. the center of the FOV is mapped to
% an actual pixel. If not, then make it so with the geometry model.
  
  if (mod == -1 || out == -1 || row == -1 || col == -1 )

    disp('  The center of the FOV is not mapped to physical pixels. Adjusting the geometry model to compensate.')
    
%   constants definition -- these are used for defining the CCDs in module 13 as having
%   nominal alignment, regardless of what's in the geometry model that comes with the
%   raDec2PixModel

    mod13Index321Transform = 61:66 ;
    mod13Value321Transform = [0 0 90 0 0 270] ;
    mod13IndexOffsets = 126+61:126+66 ;
    mod13ValueOffsets = [0 38.884 0  0 38.884 0] ;

%   replace the geometry values for module 13 in all of the geometry model constants arrays.
%   Since the arrays can be row- or column-vectors, we need to make sure the shape of the
%   values is correctly handled, which we do by taking out a sub-vector from the array and
%   using its shape to set the shape of the vector we insert

    geometryModel = raDec2PixModelNew.geometryModel ;
    for iArray = 1:length(geometryModel.constants)
        mod13Values = geometryModel.constants(iArray).array(mod13Index321Transform) ;
        geometryModel.constants(iArray).array(mod13Index321Transform) = ...
            reshape(mod13Value321Transform,size(mod13Values)) ;
        geometryModel.constants(iArray).array(mod13IndexOffsets) = ...
            reshape(mod13ValueOffsets,size(mod13Values)) ;
    end
    raDec2PixModelNew.geometryModel = geometryModel ;
    
  end

  
% determine the RA and Dec of this pixel throughout the validity period of the pointing
% model

  mjdVector = mjdStartNew:mjdStepNew:mjdEndNew ;
  [ra dec] = pix_2_ra_dec( raDec2PixObjectNew, mod, out, row, col, mjdVector ) ;
  
% compare the RA and Dec of the center-FOV with the nominal value

  rollTime = get_roll_time( rollTimeObject, mjdVector ) ;
  
  raFov = rollTime(:,4) ;
  decFov = rollTime(:,5) ;
  
  raMean = ra - raFov ; decMean = dec - decFov ;
  raMeanPixels =  raMean  / degreesPerPixel ;
  decMeanPixels = decMean / degreesPerPixel ;
  
  figure ; 
  plot(mjdVector-mjdStartNew,raMeanPixels,'b') ; 
  title(['Variation in Central Pointing -- ',newPointingModelFilename], ...
      'interpreter','none') ;
  hold on
  plot(mjdVector-mjdStartNew,decMeanPixels,'g') ;
  string = sprintf('Time [days];  UTC0 = %s',mjd_to_utc(mjdStartNew)) ;
  xlabel(string) ;
  ylabel('Pointing Change [pixels]') ;
  legend('RA','Dec','Location','Best') ;
  
% save the plot

  saveas(gcf, 'central-pointing-vs-time') ;
  
%=========================================================================================

% TEST 2:  Compare pointing models -- for this, we use 2 pointingClass objects

  pointingModelCurrent = parse_pointing_model( currentPointingModelFullFilename ) ;
  
  mjdStartCurrent = pointingModelCurrent.mjds(1) ;
  mjdEndCurrent   = pointingModelCurrent.mjds(end) ;
  
  pointingObjectCurrent = pointingClass(pointingModelCurrent) ;
  pointingObjectNew     = pointingClass(raDec2PixModelNew.pointingModel) ;
  
  mjdVector = max([mjdStartCurrent mjdStartNew]):min([mjdEndCurrent mjdEndNew]) ;
  
  pointingNew     = get_pointing(pointingObjectNew, mjdVector) ;
  pointingCurrent = get_pointing(pointingObjectCurrent, mjdVector) ;
  
  dPointing = pointingNew - pointingCurrent ;
  
  figure 
  subplot(3,1,1) ;
  plot(mjdVector-mjdVector(1),dPointing(:,1)/degreesPerPixel) ;
  ylabel('\Delta RA [Pixels]') ;
  title(['Diff between ',currentPointingModelFilename,' and ', ...
      newPointingModelFilename],'interpreter','none') ;
  subplot(3,1,2) ;
  plot(mjdVector-mjdVector(1),dPointing(:,2)/degreesPerPixel) ;
  ylabel('\Delta Dec [Pixels]') ;
  subplot(3,1,3) ;
  plot(mjdVector-mjdVector(1),dPointing(:,3)/degreesPerRadian * fovRadiusPixels ) ;
  string = sprintf('Time [Days];  UTC0 = %s',mjd_to_utc(mjdVector(1))) ;
  xlabel(string) ;
  ylabel('\Delta Roll [Pixels]') ; 
  
% save the plot

  saveas( gcf, 'pointing-new-minus-current' ) ;
  
% return to original directory

  cd(currentDir) ;

  toc
  
  return  

% and that's it!

%
%
%


%=========================================================================================
%=========================================================================================
%=========================================================================================

% subfunction which parses a pointing model text file and returns a pointing model

function pointingModel = parse_pointing_model( pointingModelFilename )

% read the file; pointing model file has four columns for Kepler-prime
% dates and five columns for K2 dates so it cannot be loaded as a matrix
% from a text file

  fid = fopen( pointingModelFilename, 'r' ) ;
  pointingModelCellArray = textscan( fid, '%f %f %f %f %f' ) ;
  fclose( fid ) ;
  
% split the cell array into mjds, ras, declinations, rolls,
% segmentStartMjds; for Kepler-prime dates the segmentStartMjd should be
% set to the first mjd timestamp in the pointing model file

  pointingModel.mjds             = pointingModelCellArray{1} ;
  pointingModel.ras              = pointingModelCellArray{2} ;
  pointingModel.declinations     = pointingModelCellArray{3} ;
  pointingModel.rolls            = pointingModelCellArray{4} ;
  
  segmentStartMjds = pointingModelCellArray{5} ;
  segmentStartMjds(isnan(segmentStartMjds)) = pointingModel.mjds(1) ;
  pointingModel.segmentStartMjds = segmentStartMjds ;
  
  pointingModel.fcModelMetadata = struct( ...
        'svnInfo', '', ...
        'ingestTime', '', ...
        'modelDescription', '', ...
        'databaseUrl', '', ...
        'databaseUsername', '') ;
    
return

% and that's it!

%
%
%
