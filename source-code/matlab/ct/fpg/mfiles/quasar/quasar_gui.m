function quasar_gui
%
% quasar_gui -- main gui for the Quasar focal plane geometry fitting tool
%
% Version date:  2009-February-20.
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
%    2009-February-20, PT:
%        bugfix:  import file writer should not continue to execute if the user hit
%        cancel.
%
%=========================================================================================

% start with a figure

  mainHandle = figure( 'units','pixels', 'position',[100 300 850 600], ...
      'numbertitle','off', 'name','Quasar', 'resize','off', ...
      'WindowButtonUpFcn', @dashboard_mouse_button_callback ) ;
  
% add the plot window for the dashboard plot

  ax=axes( 'units','pixels', 'position',[10 10 580 580], 'parent',mainHandle, ...
      'xtick',[], 'ytick',[] ) ;

% add information to the axes, specifically:  the status (whether the dashboard plot is
% ready to draw or not), the fit status of the CCDs (needed to plot their colors), corner
% coordinates of the 42 CCDs (needed to figure out the location of a mouse-click later)

  setappdata(ax,'drawStatus',false) ;
  setappdata(ax,'ccdFitStatus',zeros(42,1)) ;

  [mod,out] = convert_to_module_output(1:84) ;
  mod = [mod(:)' ; mod(:)'] ; out = [out(:)' ; out(:)'] ;
  mod = reshape(mod,4,42) ;
  out = reshape(out,4,42) ;
  row = repmat([0.5 ; 1044.5 ; 1044.5 ; 0.5],1,42) ;
  col = repmat([12.5 ; 12.5 ; 12.5 ; 12.5],1,42) ;
  [zp,yp] = morc_to_focal_plane_coords(mod(:),out(:),row(:),col(:),'one-based') ;
  zp = reshape(zp,4,42) ;
  yp = reshape(yp,4,42) ;
  
  setappdata(ax,'ccdCornerZPrimeCoords',zp) ;
  setappdata(ax,'ccdCornerYPrimeCoords',yp) ;
    
% filename, mjd, and utc information

  fitsPanelHandle = uipanel('parent',mainHandle, 'units','pixels', ...
      'position',[598 465 244 130], 'title','FITS File') ;
  fitsFilenameHandle = uicontrol(mainHandle, 'style','text', ...
      'string','', ...
      'position',[600 555 240 20]) ;
  fitsMjdHandle1 = uicontrol(mainHandle, 'style','text', ...
      'string', 'MJD mid-time: ', 'position',[600 535 90 20] ) ;
  fitsMjdHandle = uicontrol(mainHandle, 'style','text', ...
      'string', '', 'position',[690 535 150 20] ) ;
  fitsUtcHandle1 = uicontrol(mainHandle, 'style','text', ...
      'string', 'UTC mid-time: ', 'position',[600 515 90 20] ) ;
  fitsUtcHandle = uicontrol(mainHandle, 'style','text', ...
      'string', '', 'position',[690 515 150 20] ) ;  
  selectFitsHandle = uicontrol(mainHandle, 'position',[640 470 150 40], ...
      'string','Select FITS File', 'callback',@select_fits_file_callback) ;
 
% sample catalog file text -- until the FITS file is selected, the catalog can't be
% selected, since the catalog needs to check season and therefore MJD and raDec2PixModel
% are needed

  catalogPanelHandle = uipanel('parent',mainHandle, 'units','pixels', ...
      'position',[598 360 244 100], 'title','Catalog') ;
  catalogSourceHandle = uicontrol(mainHandle, 'style','text', ...
      'string', '', 'position',[600 410 240 20] ) ; 
  selectCatalogHandle = uicontrol(mainHandle, ...
      'position',[600 365 118 40], 'string','Select Catalog', 'enable','off', ...
      'callback',@select_catalog_callback) ;
  preStageCatalogHandle = uicontrol(mainHandle, ...
      'position',[720 365 118 40], 'string','Pre-stage catalog', ...
      'callback',@pre_stage_catalog_callback) ;

% sample raDec2Pix control panel

  raDec2PixPanelHandle = uipanel('parent',mainHandle, 'units','pixels', ...
      'position',[598 255 244 100], 'title','raDec2PixModel') ;
  raDec2PixSourceHandle = uicontrol(mainHandle, 'style','text', ...
      'string', '', 'position',[600 305 240 20] ) ; 
  selectRaDec2PixModelHandle = uicontrol(mainHandle, ...
      'position',[642 260 160 40], 'string',' Select raDec2Pix Model', ...
      'callback',@select_raDec2PixModel_callback) ;

% sample results control panel

  resultsPanelHandle = uipanel('parent',mainHandle, 'units','pixels', ...
      'position',[598 2 244 160], 'title','Results') ;
  writeGeometryHandle = uicontrol(mainHandle, 'position', [638 5 168 40], ...
      'string','Write Geometry Import File', 'enable','off',...
      'callback',@write_geometry_file_callback) ;
  writeResultsHandle = uicontrol(mainHandle, 'position', [638 50 168 40], ...
      'string','Write Results to File', 'enable','off',...
      'callback',@write_results_callback) ;
  displayResultsHandle = uicontrol(mainHandle, 'position', [638 95 168 40], ...
      'string','Display Results to Screen', 'enable','off',...
      'callback',@display_results_callback) ;
  
% add application data as required to the main GUI

  setappdata(mainHandle,'fitsFilename','') ;
  setappdata(mainHandle,'mjdMidTime',[]) ;
  setappdata(mainHandle,'raDec2PixModelFile','') ;
  setappdata(mainHandle,'raDec2PixModel',[]) ;
  setappdata(mainHandle,'catalogFile','') ;
  setappdata(mainHandle,'usePreStagedCatalog',true) ;
  setappdata(mainHandle,'currentGeometry',[]) ;
  setappdata(mainHandle,'fittedGeometry',[]) ;
  setappdata(mainHandle,'geometryChangeStructVector', ...
      repmat(compute_changed_geometry(0),42,1)) ;
  setappdata(mainHandle,'slowCallbackExecuting',false) ;

% add a struct which contains all the handles which need to be touched by the main GUI

  childHandleStruct = struct( ...
      'plotAxesHandle',        ax, ...
      'fitsFilenameHandle',    fitsFilenameHandle, ...
      'fitsMjdHandle',         fitsMjdHandle, ...
      'fitsUtcHandle',         fitsUtcHandle, ...
      'catalogSourceHandle',   catalogSourceHandle, ...
      'selectCatalogHandle',   selectCatalogHandle, ...
      'raDec2PixSourceHandle', raDec2PixSourceHandle, ...
      'writeGeometryHandle',   writeGeometryHandle, ...
      'writeResultsHandle',    writeResultsHandle, ...
      'displayResultsHandle',  displayResultsHandle ) ;
  setappdata(mainHandle,'childHandleStruct',childHandleStruct) ; 
  
return % end of main GUI function

%=========================================================================================

% subfunction to redraw the dashboard, including blue boxes for CCDs on which the current
% (database) model is accepted, and green boxes for CCDs on which the fitted model is
% accepted

function redraw_dashboard( axesHandle )

  cla ;
  axes(axesHandle) ;
  if ( getappdata(axesHandle,'drawStatus') )

%     draw the boxes of the CCDs
      
      draw_ccd(1:42) ;
      set(gca,'xtick',[], 'ytick',[]) ;

%     draw the legend information

      text(-5700,5700,'Accepted') ;
      text(-5700,5300,'Model:') ;
      rectangle('position',[-5700 4700 300 300],'facecolor','w') ;
      rectangle('position',[-5700 4300 300 300],'facecolor','b') ;
      rectangle('position',[-5700 3900 300 300],'facecolor','g') ;
      text(-5300,4850,'None') ;
      text(-5300,4450,'Current') ;
      text(-5300,4050,'Fitted') ;
  
%     loop over CCDs and color-code them according to their fit status

      zpCorner = getappdata(axesHandle,'ccdCornerZPrimeCoords') ;
      ypCorner = getappdata(axesHandle,'ccdCornerYPrimeCoords') ;
      ccdFitStatus = getappdata(axesHandle,'ccdFitStatus') ;
      acceptedCurrent = find(ccdFitStatus == 1) ;
      for iCcd = acceptedCurrent(:)'
          zpMin = min(zpCorner(:,iCcd)) ;
          zpMax = max(zpCorner(:,iCcd)) ;
          ypMin = min(ypCorner(:,iCcd)) ;
          ypMax = max(ypCorner(:,iCcd)) ;
          rectangle('position',[zpMin ypMin zpMax-zpMin ypMax-ypMin], ...
              'facecolor','b') ;
      end
      acceptedFitted = find(ccdFitStatus == 2) ;
      for iCcd = acceptedFitted(:)'
          zpMin = min(zpCorner(:,iCcd)) ;
          zpMax = max(zpCorner(:,iCcd)) ;
          ypMin = min(ypCorner(:,iCcd)) ;
          ypMax = max(ypCorner(:,iCcd)) ;
          rectangle('position',[zpMin ypMin zpMax-zpMin ypMax-ypMin], ...
              'facecolor','g') ;
      end
      
  end % conditional on drawStatus
      

return

%=========================================================================================

% subfunction which handles the actual passing of information to and from the fitter gui

function launch_image_fitter( mainHandle, ccdNumber )

% determine the two mod/outs on the CCD, and their channel numbers

  highChannel = 2*ccdNumber ;
  lowChannel  = highChannel - 1 ;
  [ccdModule,ccdOutput] = convert_to_module_output([lowChannel, highChannel]) ;
  lowOutput = ccdOutput(1) ; highOutput = ccdOutput(2) ; ccdModule = ccdModule(1) ;
  
% get the two images from the FITS file and combine them.  In this case this means
% stripping off their trailing black and virtual smear regions, and flipping the
% even-numbered image left-to-right

  disp('   Loading FITS image files') ;
  ccdImage1 = fitsread(getappdata(mainHandle,'fitsFilename'), 'image', lowChannel,  'raw' ) ;
  ccdImage2 = fitsread(getappdata(mainHandle,'fitsFilename'), 'image', highChannel, 'raw' ) ;
  ccdImage = double([ccdImage1(1:1044,1:1112) fliplr(ccdImage2(1:1044,1:1112))]) ;
  
% get the catalog data -- this requires either a call to retrieve_kics, in the event of
% live catalog, or extraction from the cached catalog, if that method is used

  disp('   Loading catalog information') ;
  if ( getappdata(mainHandle,'usePreStagedCatalog') )
      
      lowChannelVarName = ['kicsDataMod',num2str(ccdModule,'%02d'),...
          'Out',num2str(lowOutput)] ;
      highChannelVarName = ['kicsDataMod',num2str(ccdModule,'%02d'),...
          'Out',num2str(highOutput)] ;
      cmd1 = ['load(''',getappdata(mainHandle,'catalogFile'),''', ''', ...
          lowChannelVarName,''', ''',highChannelVarName,''')'] ;
      eval(cmd1) ;
      cmd2 = ['kicsData = [',lowChannelVarName,'(:) ; ', ...
          highChannelVarName,'(:)] ;'] ;
      eval(cmd2) ;
      
  else % live catalog case
      
      kicsData1 = quasar_retrieve_kics( ccdModule, lowOutput, ...
          getappdata(mainHandle,'mjdMidTime') ) ;
      kicsData2 = quasar_retrieve_kics( ccdModule, highOutput, ...
          getappdata(mainHandle,'mjdMidTime') ) ;
      kicsData = [kicsData1(:) ; kicsData2(:)] ;
      
  end % pre-staged catalog conditional
  
% launch the fitter!

  [status, fittedGeometry1, geometryChangeStruct] = quasar_image_fitter( ccdNumber, ...
      ccdImage, kicsData, getappdata(mainHandle,'raDec2PixModel'), ...
      getappdata(mainHandle,'currentGeometry'), ...
      getappdata(mainHandle,'mjdMidTime') ) ;
  
% if the status is not zero, then we should respond to it -- set the value of the fit
% status for this CCD, put the geometryChangeStruct into the geometryChangeStructVector,
% copy the changed geometry parameters from the returned struct to the main fitted
% geometry storehouse, and enable the output displayers.

  childHandleStruct = getappdata(mainHandle,'childHandleStruct') ;
  if (status ~= 0)
      
      ccdFitStatus = getappdata(childHandleStruct.plotAxesHandle,'ccdFitStatus') ;
      ccdFitStatus(ccdNumber) = status ;
      setappdata(childHandleStruct.plotAxesHandle,'ccdFitStatus',ccdFitStatus) ;
      geometryChangeStructVector = getappdata(mainHandle,'geometryChangeStructVector') ;
      geometryChangeStructVector(ccdNumber) = geometryChangeStruct ;
      setappdata(mainHandle,'geometryChangeStructVector',geometryChangeStructVector) ;
      fittedGeometry = getappdata(mainHandle,'fittedGeometry') ;
      angle1Index = 3*ccdNumber ;
      for iGeom = 1:length(fittedGeometry.constants)
          fittedGeometry.constants(iGeom).array(angle1Index-2:angle1Index) = ...
              fittedGeometry1.constants(iGeom).array(angle1Index-2:angle1Index) ;
      end
      setappdata(mainHandle,'fittedGeometry',fittedGeometry) ;
      set(childHandleStruct.writeGeometryHandle,'enable','on') ;
      set(childHandleStruct.writeResultsHandle,'enable','on') ;
      set(childHandleStruct.displayResultsHandle,'enable','on') ;
      
  end
  
% redraw the plot

  redraw_dashboard( childHandleStruct.plotAxesHandle ) ;
  
return

%

%=========================================================================================

% subfunction which performs the KIC retrieval and repackages the resulting information
% into the format required by Quasar

function kicsData = quasar_retrieve_kics( ccdModule, ccdOutput, mjd ) 

% start with the retriever call

  kicJavaObjectVector = retrieve_kics( ccdModule, ccdOutput, mjd, -inf, 15 ) ;
  
% construct an array to put numeric values into

  kicArray = zeros(4,length(kicJavaObjectVector)) ;
  
% loop over objects and execute their getters

  kicArray(1,:) = [kicJavaObjectVector.keplerId] ;
  temp = [kicJavaObjectVector.keplerMag] ;
  kicArray(2,:) = [temp.value] ;
  temp = [kicJavaObjectVector.ra] ;
  kicArray(3,:) = [temp.value] ;
  temp = [kicJavaObjectVector.dec] ;
  kicArray(4,:) = [temp.value] ;
  
%   wb = waitbar(0,['Processing Star # 1 out of ',num2str(length(kicJavaObjectVector))]) ;
%   set(wb,'name',['KIC Processing:  Module ',num2str(ccdModule),' Output ', ...
%       num2str(ccdOutput)]) ;
%   for iStar = 1:length(kicJavaObjectVector)
%       
%       kicArray(1,iStar) = kicJavaObjectVector(iStar).getKeplerId ;
%       temp = kicJavaObjectVector(iStar).getKeplerMag ;
%       if (~isempty(temp))
%           kicArray(2,iStar) = temp ;
%       end
%       kicArray(3,iStar) = kicJavaObjectVector(iStar).getRa ;
%       kicArray(4,iStar) = kicJavaObjectVector(iStar).getDec ;
%       if (iStar < length(kicJavaObjectVector) && floor(iStar/100)==iStar/100)
%           waitbar(iStar/length(kicJavaObjectVector),wb, ...
%               ['Processing Star # ',num2str(iStar),...
%               ' out of ',num2str(length(kicJavaObjectVector))]) ;
%       end
%       
%   end
%   close(wb)
  pause(1.0) ; % allows it to clear the waitbar
  
% filter out the ones which have no magnitude information, and convert RA to degrees

  badStars = find(kicArray(2,:)==0) ;
  kicArray(:,badStars) = [] ;
  kicArray(3,:) = kicArray(3,:) * 15 ;
  
% convert to a structure (this requires that we first convert to a cell array)

  kicCellArray = num2cell(kicArray) ;
  kicsData = cell2struct(kicCellArray,{'keplerId','keplerMag','RA','Dec'},1) ;
  
% I shouldn't need to clear the kicJavaObjectVector at the end of function execution, and
% it probably won't do me any good to do so, but I'm going to anyway on the theory that
% Matlab may do something strange with Java objects in memory

  clear kicJavaObjectVector ;
  
return

%=========================================================================================
% 
% C A L L B A C K S
%
%=========================================================================================

% function which processes a mouse-click on the dashboard -- if the dashboard is drawn, it
% launches 

function dashboard_mouse_button_callback( mainHandle, eventData ) 

% get the axes handle from the main gui

  childHandleStruct = getappdata(mainHandle,'childHandleStruct') ;
  handle = childHandleStruct.plotAxesHandle ;

% if the image isn't drawn, then we don't need to do anything

  if( getappdata(handle,'drawStatus') )
      
%     check to see if there is already a slow callback trying to execute, if so don't
%     launch this one

      if getappdata(gcbf,'slowCallbackExecuting')
          return 
      end
  
%     set the slow callback flag

      setappdata(gcbf,'slowCallbackExecuting',true) ;

%     get the current position of the pointing device and see if it's on the plot axes; if
%     not, no need to do anything...

      cp = get(gca,'currentpoint') ;
      currentY = cp(1,2) ; currentZ = cp(1,1) ;
      zpLim = get(handle,'XLim') ;
      ypLim = get(handle,'YLim') ;
      
      if ( currentY >= ypLim(1) && currentY <= ypLim(2) && ...
           currentZ >= zpLim(1) && currentZ <= zpLim(2) )

%         get the corner positions of each CCD

          zpCorner = getappdata(handle,'ccdCornerZPrimeCoords') ;
          ypCorner = getappdata(handle,'ccdCornerYPrimeCoords') ;
      
%         use inpolygon to figure out whether the pointer is inside any of the CCDs

          inCcd = 0 ;
          for iCcd = 1:size(zpCorner,2) 
              if (inpolygon(currentZ,currentY,zpCorner(:,iCcd),ypCorner(:,iCcd)))
                  inCcd = iCcd ; 
                  break ;
              end
          end
      
%     if the inCcd value is not zero, then go to the routine which calls the fitter and
%     processes its results

          if (inCcd ~= 0)
              disp(['Preparing to fit CCD ',num2str(inCcd)]) ;
              launch_image_fitter( mainHandle, inCcd ) ;
          end
      
      end % in bounds of axes conditional
      
%     set the slow callback flag to false again

      setappdata(gcbf,'slowCallbackExecuting',false) ;

  end % drawStatus conditional

return

%=========================================================================================

% subfunction which selects a FITS file and reads its header to get the mid-time MJD

function select_fits_file_callback( handle, eventData )

% get the main GUI handle

  mainHandle = get(handle,'parent') ;
  
% bring up a file GUI and have the user select the file
  
  [filename,pathname] = uigetfile( ...
      {'*.fits','FITS Files' ; '*','All Files'}, ...
      'Select FFI FITS File' ) ;
  
% if the user didn't hit "cancel", carry on:

  if ( ~isnumeric(filename) )
      
%     construct the full filename with path

      fitsFilename = fullfile(pathname,filename) ;
      
%     read the header with fitsinfo and get the mid-time MJD.  Unfortunately, the mid-time
%     on fakedata FFIs is often incorrect, so use the mean of the STARTIME and END_TIME.

      fitsHeader = fitsinfo(fitsFilename) ;
      fitsKeywords = fitsHeader.PrimaryData.Keywords(:,1) ;
%      midTimeIndex = find(strcmp(fitsKeywords,'MID_TIME')) ;
      startTimeIndex = find(strcmp(fitsKeywords,'STARTIME')) ;
      endTimeIndex = find(strcmp(fitsKeywords,'END_TIME')) ;
      if (startTimeIndex == 0 || endTimeIndex == 0)
          error('quasar:selectFitsFileCallback:mjdTimeKeywordAbsent', ...
              'select_fits_file_callback:  selected FITS file has missing timestamp keywords') ;
      end
      
%     store the filename and MJD mid-time
      
      mjdMidTime = (fitsHeader.PrimaryData.Keywords{startTimeIndex,2} + ...
          fitsHeader.PrimaryData.Keywords{endTimeIndex,2}) / 2 ;
      setappdata(mainHandle,'mjdMidTime',mjdMidTime) ;
      setappdata(mainHandle,'fitsFilename',fitsFilename) ;
     
%     populate the appropriate slots on the GUI with information

      childHandleStruct = getappdata(mainHandle,'childHandleStruct') ;
      set(childHandleStruct.fitsFilenameHandle,'string',filename) ;
      set(childHandleStruct.fitsMjdHandle,'string',...
          num2str(getappdata(mainHandle,'mjdMidTime'))) ;
      set(childHandleStruct.fitsUtcHandle,'string',mjd_to_utc( ...
          getappdata(mainHandle,'mjdMidTime'))) ;
      
%     enable the catalog if there's also an raDec2PixModel lurking about

      raDec2PixModel = getappdata(mainHandle,'raDec2PixModel') ;
      if ( ~isempty(raDec2PixModel) )
          set(childHandleStruct.selectCatalogHandle,'enable','on') ;
      end
      
  end % conditional on non-numeric filename return

return

%=========================================================================================

% subfunction which allows the user to select a catalog -- either get the catalog from the
% database as needed, or go to a pre-staged catalog.  In the latter case, the timestamp in
% the pre-staged catalog is checked against the timestamp in the FITS file to make sure
% they are in the same seasonal roll.

function select_catalog_callback( handle, eventData )

% get the main handle

  mainHandle = get(handle,'parent') ;
  childHandleStruct = getappdata(mainHandle,'childHandleStruct') ;
  
% launch the modal dialog box which determines whether the datastore or cached model is
% desired

  catalogFilename = getappdata(mainHandle,'catalogFile') ;
  if ( isempty(catalogFilename) || strcmp(catalogFilename,'database') )
      defaultSource = 0 ;
  else
      defaultSource = 1 ;
  end
  catalogSource = quasar_db_dialog( 'Select Catalog Source', defaultSource ) ;

% proceed only if the user did not select Cancel

  switch catalogSource
            
      case 0 % live model -- set the source string to "database" 
             % and throw away the old filename
             
          set(childHandleStruct.catalogSourceHandle,'string','database') ;
          setappdata(mainHandle,'catalogFile','') ;
          setappdata(mainHandle,'usePreStagedCatalog',false) ;
          
      case 1 % pre-staged model -- launch a GUI to get the file; if the user doesn't hit
             % cancel, go into the file for the MJD and check its season against the
             % season of the FITS file
          
          [filename,pathname] = uigetfile( ...
              {'*.mat','MAT-files' ; '*','All Files'}, ...
              'Select a KIC MAT-file' ) ;
          if (~isnumeric(filename))
              fullFilename = fullfile(pathname,filename) ;
              loadMjdString = ['load(''',fullFilename,''', ''mjd'')'] ;
              eval(loadMjdString) ;
              if (exist('mjd')~=1)
                  beep ; pause(0.35) ; beep
                  disp('No MJD in pre-staged catalog') ;
              else
                  mjdFits = getappdata(mainHandle,'mjdMidTime') ;
                  raDec2PixModel = getappdata(mainHandle,'raDec2PixModel') ;
                  rollTimeObject = rollTimeClass(raDec2PixModel.rollTimeModel) ;
                  rollTime = get_roll_time(rollTimeObject,[mjd ; mjdFits]) ;
                  if (rollTime(1,3) == rollTime(2,3))
                      set(childHandleStruct.catalogSourceHandle, ...
                          'string',filename) ;
                      setappdata(mainHandle,'catalogFile',fullFilename) ;
                      setappdata(mainHandle,'usePreStagedCatalog',true) ;
                  else
                      beep ; pause(0.35) ; beep
                      disp('Seasonal roll mismatch between FITS file and catalog file') ;
                  end
              end
          end
          
  end % switch statement
  
% if the selection process was successful, then the catalog source display has been
% filled.  In this case, we can trigger a redraw of the dashboard, since this indicates
% that the FITS file, the raDec2PixModel, and the catalog are all ready

  if ( ~isempty(get(childHandleStruct.catalogSourceHandle,'string')) )
      setappdata(childHandleStruct.plotAxesHandle,'drawStatus',true) ;
      redraw_dashboard( childHandleStruct.plotAxesHandle ) ;
  end
  
return

%=========================================================================================

% subfunction which does the work of pre-fetching the catalog and storing it to local
% storage

function pre_stage_catalog_callback( handle, eventData )

% if there's already a slow callback executing, don't execute this one

  if getappdata(gcbf,'slowCallbackExecuting')
      return 
  end
  
% set the slow callback flag

  setappdata(gcbf,'slowCallbackExecuting',true) ;

% get the mjd from the main GUI appdata; if not present, pick today

  mainHandle = get(handle,'parent') ;
  mjd = getappdata(mainHandle,'mjdMidTime') ;
  if (isempty(mjd))
      mjd = datestr2mjd(local_time_to_utc(now)) ;
  end
  
% make sure this is what the user wants  
  
  mjd = quasar_mjd_dialog(mjd) ;
  
% start by prompting the user for a filename and destination to save the catalog to

  [filename,pathname,filter] = uiputfile({'*.mat', 'MAT-files' ; '*','All Files'},...
      'Save Quasar Catalog As') ;
  
% if a valid file was selected, we can continue  
  
  if ( ~isnumeric(filename) && ~isnumeric(pathname) )
      
      if ( length(filename) >= 4 && ( strcmp(filename(end-3:end),'.mat') ) )
          filenameHasMatSuffix = true ;
      else
          filenameHasMatSuffix = false ;
      end
      if ( (filter == 1) && (~filenameHasMatSuffix) )
          filename = [filename,'.mat'] ;
      end
      fullFilename = fullfile(pathname,filename) ;
      
      if (exist(fullFilename)==2)
          save(fullFilename,'mjd','-append') ;
      else
          save(fullFilename,'mjd') ;
      end
      
      timeStart = clock ;
      
%     loop over mod/outs and use the quasar retriever to do the main work

      for iChannel = 1:84
          
          timeModStart = clock ;
          
          [module,output] = convert_to_module_output(iChannel) ;
          disp(['Retrieving catalog for module ',num2str(module),...
              ' output ',num2str(output),' on MJD ',num2str(mjd)]) ;
          kicsData = quasar_retrieve_kics(module,output,mjd) ;
          
%         rename the data to kicsDataMod##Out#

          kicsName = ['kicsDataMod',num2str(module,'%02d'), ...
              'Out',num2str(output)] ;
          renameCommand = [kicsName,' = kicsData ;'] ;
          eval(renameCommand) ;
          
%         save the acquired information to the file requested

          saveCommand = ['save(fullFilename,''',kicsName,''',''-append'') ;'] ;
          eval(saveCommand) ;
          
%         clear the kicsData and kicsDataMod##Out# to save memory space
          clearCommand = ['clear kicsData ',kicsName] ;
          eval(clearCommand) ;
          
          disp(['Completed processing for module ',num2str(module),...
              ' output ',num2str(output),' in ',num2str(etime(clock,timeModStart)), ...
              ' seconds']) ;
          
      end % loop over mod/outs
      
      disp(['Pre-fetched catalog save completed in ',num2str(etime(clock,timeStart)), ...
          ' seconds.']) ;
      
  end % valid filename received conditional

% set the slow callback flag to false again

  setappdata(gcbf,'slowCallbackExecuting',false) ;
  
  
return

%=========================================================================================

% subfunction which selects either a cached raDec2Pix model or the one from the datastore

function select_raDec2PixModel_callback( handle, eventData )

% get the main handle

  mainHandle = get(handle,'parent') ;
  childHandleStruct = getappdata(mainHandle,'childHandleStruct') ;
  
% launch the modal dialog box which determines whether the datastore or cached model is
% desired

  raDec2PixFilename = getappdata(mainHandle,'raDec2PixModelFile') ;
  if ( isempty(raDec2PixFilename) || strcmp(raDec2PixFilename,'database') )
      defaultSource = 0 ;
  else
      defaultSource = 1 ;
  end
  modelSource = quasar_db_dialog( 'Select raDec2PixModel', defaultSource ) ;
  
% proceed only if the user did not select Cancel

  switch modelSource
            
      case 0 % live model -- if successfully loaded, set the source string to "database" 
             % and throw away the old filename
             
          try
              oldSource = get(childHandleStruct.raDec2PixSourceHandle,'string') ;
              oldFile = getappdata(mainHandle,'raDec2PixModelFile') ;
              set(childHandleStruct.raDec2PixSourceHandle,'string','database') ;
              setappdata(mainHandle,'raDec2PixModelFile','') ;
              raDec2PixModel = retrieve_ra_dec_2_pix_model() ;
          catch
              beep ; pause(0.35) ; beep
              disp('Unable to retrieve raDec2Pix model from datastore') ;
              set(childHandleStruct.raDec2PixSourceHandle,'string',oldSource) ;
              setappdata(mainHandle,'raDec2PixModelFile',oldFile) ;
          end
          
      case 1 % cached model -- bring up a dialog box to select the file.  If successfully
             % loaded, set the source file in the display and the fullfile in the app data
             % repository
          
          [filename,pathname] = uigetfile( ...
              {'*.mat','MAT-files' ; '*','All Files'}, ...
              'Select an raDec2PixModel MAT-file' ) ;
          if (~isnumeric(filename))
              load(fullfile(pathname,filename)) ;
              if (exist('raDec2PixModel') == 1)
                  set(childHandleStruct.raDec2PixSourceHandle,'string',filename) ;
                  setappdata(mainHandle,'raDec2PixModelFile', ...
                      fullfile(pathname,filename)) ;
              else
                  beep ; pause(0.35) ; beep
                  disp('Unable to retrieve raDec2PixModel from file') ;
              end
          end
      
  end % switch statement
  
% if there's an raDec2PixModel in the local workspace, then we can put it into the appdata
% repository and extract its geometry model as well; also, if we have an raDec2PixModel
% and a FITS file we can enable catalog selection

  if (exist('raDec2PixModel') == 1)
      setappdata(mainHandle,'raDec2PixModel',raDec2PixModel) ;
      setappdata(mainHandle,'currentGeometry',raDec2PixModel.geometryModel) ;
      setappdata(mainHandle,'fittedGeometry',raDec2PixModel.geometryModel) ;
      fitsFilename = getappdata(mainHandle,'fitsFilename') ;
      if (~isempty(fitsFilename))
          set(childHandleStruct.selectCatalogHandle,'enable','on') ;
      end
  end
      
      
return

%=========================================================================================

% subfunction which writes the geometry file in the correct format for ingestion into the
% SOC datastore.

function write_geometry_file_callback( handle, eventData )

% get the handle to the main GUI

  mainHandle = get(handle,'parent') ;
  
% get the MJD of the file and the fitted geometry model

  mjd = getappdata(mainHandle,'mjdMidTime') ;
  fittedGeometry = getappdata(mainHandle,'fittedGeometry') ;
  gmConstants = fittedGeometry.constants(1).array ;
  
% make the filename with the appropriately formatted datestring

  dateString = datestr(now,30) ;
  dateString = [dateString(1:8) dateString(10:11)] ;

  filename = ['kplr',dateString,'_geometry.txt'] ;

% bring up the save file dialog, with the default filename as the one we want

  [filename,pathname] = uiputfile('*.txt','Save Geometry Text File As',filename) ;
  
% open the file for writing if the user did not hit cancel

  if ( ~isnumeric(filename) && ~isnumeric(pathname) )

      fullFilename = fullfile(pathname,filename) ;
      filePointer = fopen(fullFilename,'wt') ;
  
% write the MJD in the top of the file

      fprintf(filePointer,'%8.2f\n',mjd) ;

% write the first 252 parameters out in 3-column format
  
      fprintf(filePointer,'%-16.14f %-16.13f %-16.11f\n',gmConstants(1:126)) ;
      fprintf(filePointer,'%-16.14f %-16.13f %-16.13f\n',gmConstants(127:252)) ;
  
% write the last 84 parameters out in 1-column format

      fprintf(filePointer,'%-16.14f\n',gmConstants(253:336)) ;

      fclose(filePointer) ;
  
  end % conditional on good filespec returned

return

%=========================================================================================

function write_results_callback( handle, eventData )

% get the main handle for the gui

  mainHandle = get(handle,'parent') ;
  
% use the standard GUI tools to produce a save-as dialog box

  [filename,pathname,filter] = uiputfile({'*.txt','Text file' ; '*','All files'}, ...
      'Save Fit Summary As') ;
  
% if a valid file was selected, we can continue  
  
  if ( ~isnumeric(filename) && ~isnumeric(pathname) )
      
      if ( length(filename) >= 4 && ( strcmp(filename(end-3:end),'.txt') ) )
          filenameHasTextSuffix = true ;
      else
          filenameHasTextSuffix = false ;
      end
      if ( (filter == 1) && (~filenameHasTextSuffix) )
          filename = [filename,'.txt'] ;
      end
      fullFilename = fullfile(pathname,filename) ;
      filePointer = fopen(fullFilename,'wt') ;
      
%     call the display tool

      display_geometry_fits( 1:42, getappdata(mainHandle,'currentGeometry'), ...
          getappdata(mainHandle,'fittedGeometry'), ...
          getappdata(mainHandle,'geometryChangeStructVector'), filePointer ) ;
      
      fclose(filePointer) ;
      
  end
            
return

%=========================================================================================

% subfunction which displays the results of the fit to the screen

function display_results_callback( handle, eventData )

% get the main handle for the gui

  mainHandle = get(handle,'parent') ;
  
% call the display tool

  display_geometry_fits( 1:42, getappdata(mainHandle,'currentGeometry'), ...
      getappdata(mainHandle,'fittedGeometry'), ...
      getappdata(mainHandle,'geometryChangeStructVector'), 1 ) ;

return

