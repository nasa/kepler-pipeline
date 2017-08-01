function quasar_pointing_gui
%
% quasar_pointing_gui -- main gui for the Quasar pointing determination tool
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

%=========================================================================================

% start with a figure

  mainHandle = figure( 'units','pixels', 'position',[100 300 850 600], ...
      'numbertitle','off', 'name','Quasar Pointing', 'resize','off', ...
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
    
% mjd and utc information

  fitsMjdHandle1 = uicontrol(mainHandle, 'style','text', ...
      'string', 'MJD mid-time: ', 'position',[600 575 90 20] ) ;
  fitsMjdHandle = uicontrol(mainHandle, 'style','text', ...
      'string', '', 'position',[690 575 150 20] ) ;
  fitsUtcHandle1 = uicontrol(mainHandle, 'style','text', ...
      'string', 'UTC mid-time: ', 'position',[600 555 90 20] ) ;
  fitsUtcHandle = uicontrol(mainHandle, 'style','text', ...
      'string', '', 'position',[690 555 150 20] ) ;  
  
% FITS filename information

  fitsPanelHandle = uipanel('parent',mainHandle, 'units','pixels', ...
      'position',[598 465 244 90], 'title','FITS File') ;
  fitsFilenameHandle = uicontrol(mainHandle, 'style','text', ...
      'string','', ...
      'position',[600 515 240 20]) ;
  selectFitsHandle = uicontrol(mainHandle, 'position',[640 470 150 40], ...
      'string','Select FITS File', 'callback',@select_fits_file_callback) ;
  
% PDQ MAT-file information

  pdqPanelHandle = uipanel('parent',mainHandle,'units','pixels', ...
      'position',[598 365 244 100],'title','PDQ MAT-File') ;
  pdqFilenameHandle = uicontrol(mainHandle,'style','text', ...
      'string','', 'position',[600 425 240 20]) ;
  selectPdqHandle = uicontrol(mainHandle,'position',[640 370 150 40], ...
      'string','Select PDQ File', 'callback',@select_pdq_file_callback) ;
 
% sample catalog file text -- until the FITS file is selected, the catalog can't be
% selected, since the catalog needs to check season and therefore MJD and raDec2PixModel
% are needed

  catalogPanelHandle = uipanel('parent',mainHandle, 'units','pixels', ...
      'position',[598 260 244 100], 'title','Catalog') ;
  catalogSourceHandle = uicontrol(mainHandle, 'style','text', ...
      'string', '', 'position',[600 310 240 20] ) ; 
  selectCatalogHandle = uicontrol(mainHandle, ...
      'position',[600 265 118 40], 'string','Select Catalog', 'enable','off', ...
      'callback',@select_catalog_callback) ;
  preStageCatalogHandle = uicontrol(mainHandle, ...
      'position',[720 265 118 40], 'string','Pre-stage catalog', ...
      'callback',@pre_stage_catalog_callback) ;

% sample raDec2Pix control panel

  raDec2PixPanelHandle = uipanel('parent',mainHandle, 'units','pixels', ...
      'position',[598 155 244 100], 'title','raDec2PixModel') ;
  raDec2PixSourceHandle = uicontrol(mainHandle, 'style','text', ...
      'string', '', 'position',[600 205 240 20] ) ; 
  selectRaDec2PixModelHandle = uicontrol(mainHandle, ...
      'position',[642 160 160 40], 'string',' Select raDec2Pix Model', ...
      'callback',@select_raDec2PixModel_callback) ;

% sample results control panel

  resultsPanelHandle = uipanel('parent',mainHandle, 'units','pixels', ...
      'position',[598 2 244 148], 'title','Fitting and Results') ;
  doFitHandle = uicontrol(mainHandle,'position',[638 106 168 30], ...
      'string','Do Fit','enable','off', ...
      'callback',@do_fit_callback) ;
  displayFitHandle = uicontrol(mainHandle,'position',[638 74 168 30], ...
      'string','Display Fit','enable','off', ...
      'callback',@display_fit_callback) ;
  exportFitHandle = uicontrol(mainHandle,'position',[638 42 168 30], ...
      'string','Export Fit','enable','off', ...
      'callback',@export_fit_callback) ;
  clearConstraintsHandle = uicontrol(mainHandle,'position',[638 10 168 30], ...
      'string','Clear Fit Constraints','enable','off', ...
      'callback',@clear_constraints_callback) ;
  
% add application data as required to the main GUI

  setappdata(mainHandle,'fitsFilename','') ;
  setappdata(mainHandle,'pdqFilename','') ;
  setappdata(mainHandle,'mjdMidTime',[]) ;
  setappdata(mainHandle,'raDec2PixModelFile','') ;
  setappdata(mainHandle,'raDec2PixModel',[]) ;
  setappdata(mainHandle,'catalogFile','') ;
  setappdata(mainHandle,'usePreStagedCatalog',true) ;
  setappdata(mainHandle,'initialPointingStruct',[]) ;
  setappdata(mainHandle,'fittedPointingStruct',[]) ;
  setappdata(mainHandle,'fitConstraintsStruct',[]) ;
  setappdata(mainHandle,'slowCallbackExecuting',false) ;
  setappdata(mainHandle,'pdqStruct',[]) ;

% add a struct which contains all the handles which need to be touched by the main GUI

  childHandleStruct = struct( ...
      'plotAxesHandle',         ax, ...
      'fitsFilenameHandle',     fitsFilenameHandle, ...
      'pdqFilenameHandle',      pdqFilenameHandle, ...
      'fitsMjdHandle',          fitsMjdHandle, ...
      'fitsUtcHandle',          fitsUtcHandle, ...
      'catalogSourceHandle',    catalogSourceHandle, ...
      'selectCatalogHandle',    selectCatalogHandle, ...
      'raDec2PixSourceHandle',  raDec2PixSourceHandle, ...
      'doFitHandle',            doFitHandle, ...
      'displayFitHandle',       displayFitHandle, ...
      'exportFitHandle',        exportFitHandle, ...
      'clearConstraintsHandle', clearConstraintsHandle ...
 ) ;
  setappdata(mainHandle,'childHandleStruct',childHandleStruct) ; 
  
return % end of main GUI function

%=========================================================================================

% subfunction to redraw the dashboard, including blue boxes for CCDs on which fit
% constraints are selected

function redraw_dashboard( axesHandle )

  cla ;
  axes(axesHandle) ;
  mainHandle = get( axesHandle, 'parent' ) ;
  if ( getappdata(axesHandle,'drawStatus') )

%     draw the boxes of the CCDs
      
      draw_ccd(1:42) ;
      set(gca,'xtick',[], 'ytick',[]) ;

%     draw the legend information

      text(-5700,5700,'Constraints') ;
      text(-5700,5300,'Set:') ;
      rectangle('position',[-5700 4700 300 300],'facecolor','w') ;
      rectangle('position',[-5700 4300 300 300],'facecolor','g') ;
      text(-5300,4850,'No') ;
      text(-5300,4450,'Yes') ;
  
%     loop over CCDs and color-code them according to their constraint status

      zpCorner = getappdata(axesHandle,'ccdCornerZPrimeCoords') ;
      ypCorner = getappdata(axesHandle,'ccdCornerYPrimeCoords') ;
      ccdConstraintStatus = get_ccd_fit_constraint_status( mainHandle ) ;
      constraintPresent = find(ccdConstraintStatus == 1) ;
      for iCcd = constraintPresent(:)'
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

  if ~isempty( getappdata( mainHandle,'fitsFilename' ) )

      disp('   Loading FITS image files') ;
      ccdImage1 = fitsread(getappdata(mainHandle,'fitsFilename'), 'image', lowChannel,  'raw' ) ;
      ccdImage2 = fitsread(getappdata(mainHandle,'fitsFilename'), 'image', highChannel, 'raw' ) ;
      
  else % PDQ use-case
      
      disp('   Loading PDQ reference pixels') ;
      pdqStruct = getappdata(mainHandle,'pdqStruct') ;
      ccdImage1 = get_pdq_image( pdqStruct, ccdModule, lowOutput ) ;
      ccdImage2 = get_pdq_image( pdqStruct, ccdModule, highOutput ) ;
      
  end
  
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
  
  oldConstraintsStruct = [] ;
  fitConstraintsStruct = getappdata(mainHandle,'fitConstraintsStruct') ;
  if ~isempty(fitConstraintsStruct)
      channel = convert_from_module_output( [fitConstraintsStruct.ccdModule], ...
          [fitConstraintsStruct.ccdOutputDesired] ) ;
      constraintsCcdNumber = floor( channel / 2 + 0.5 ) ;
      thisCcdConstraints   = constraintsCcdNumber == ccdNumber ;
      if any(thisCcdConstraints)
          oldConstraintsStruct = fitConstraintsStruct(thisCcdConstraints) ;
          fitConstraintsStruct(thisCcdConstraints) = [] ;
      end
  end
  
% launch the fitter!

  newConstraintsStruct = quasar_pointing_image_fitter( ccdNumber, ...
      ccdImage, kicsData, getappdata(mainHandle,'raDec2PixModel'), ...
      getappdata(mainHandle,'initialPointingStruct'), ...
      getappdata(mainHandle, 'fittedPointingStruct'), ...
      getappdata(mainHandle,'mjdMidTime'), oldConstraintsStruct ) ;
  
% incorporate the new constraints back into the struct

  fitConstraintsStruct = [fitConstraintsStruct(:) ; newConstraintsStruct(:)] ;
  setappdata( mainHandle, 'fitConstraintsStruct', fitConstraintsStruct ) ;
  
  childHandleStruct = getappdata( mainHandle, 'childHandleStruct' ) ;
  
% redraw the plot

  redraw_dashboard( childHandleStruct.plotAxesHandle ) ;
  
% are there now enough constraints for the fit?  If so, enable the fit button to work

  if length(fitConstraintsStruct) >= 3
      set( childHandleStruct.doFitHandle, 'enable', 'on' ) ;
  else
      set( childHandleStruct.doFitHandle, 'enable', 'off' ) ;
  end
  
% also, allow the user to clear all constraints at this point if so desired

  if length(fitConstraintsStruct) > 0
      set( childHandleStruct.clearConstraintsHandle, 'enable', 'on' ) ;
  else
      set( childHandleStruct.clearConstraintsHandle, 'enable', 'off' ) ;
  end
  
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
      setappdata(mainHandle,'pdqFilename','') ;
      setappdata(mainHandle,'pdqStruct',[]) ;
      
%     if there's an raDec2PixModel already, populate the initial pointing

      raDec2PixModel = getappdata(mainHandle,'raDec2PixModel') ;
      if ~isempty(raDec2PixModel)
          pointingObject = pointingClass( raDec2PixModel.pointingModel ) ;
          initialPointing = get_pointing( pointingObject, ...
              mjdMidTime ) ;
          initialPointingStruct = initialize_pointing_struct ;
          initialPointingStruct.raDegrees.value = initialPointing(1) ;
          initialPointingStruct.decDegrees.value = initialPointing(2) ;
          initialPointingStruct.rollDegrees.value = initialPointing(3) ;
          setappdata(mainHandle,'initialPointingStruct',initialPointingStruct) ;
      end
     
%     populate the appropriate slots on the GUI with information

      childHandleStruct = getappdata(mainHandle,'childHandleStruct') ;
      set(childHandleStruct.fitsFilenameHandle,'string',filename) ;
      set(childHandleStruct.pdqFilenameHandle,'string','') ;
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

% subfunction for selecting a PDQ file

function select_pdq_file_callback( handle, eventData )

% get the main GUI handle

  mainHandle = get(handle,'parent') ;
  
% bring up a file GUI and have the user select the file
  
  [filename,pathname] = uigetfile( ...
      {'*.mat','MAT Files' ; '*','All Files'}, ...
      'Select PDQ MAT-File' ) ;
  
% if the user didn't hit "cancel", carry on:

  if ( ~isnumeric(filename) )
      
      pdqFilename = fullfile(pathname,filename) ;
      load(pdqFilename) ;
      
%     store the filename and MJD mid-time -- for now, use a dummy MJD
      
      setappdata(mainHandle,'mjdMidTime',inputsStruct.pdqTimestampSeries.startTimes(end)) ;
      setappdata(mainHandle,'fitsFilename','') ;
      setappdata(mainHandle,'pdqFilename',pdqFilename) ;
      setappdata(mainHandle,'pdqStruct',inputsStruct) ;
      
%     populate the appropriate slots on the GUI with information

      childHandleStruct = getappdata(mainHandle,'childHandleStruct') ;
      set(childHandleStruct.fitsFilenameHandle,'string','') ;
      set(childHandleStruct.pdqFilenameHandle,'string',filename) ;
      set(childHandleStruct.fitsMjdHandle,'string',...
          num2str(getappdata(mainHandle,'mjdMidTime'))) ;
      set(childHandleStruct.fitsUtcHandle,'string',mjd_to_utc( ...
          getappdata(mainHandle,'mjdMidTime'))) ;
      
%     if there's an raDec2PixModel already, populate the initial pointing

      raDec2PixModel = getappdata(mainHandle,'raDec2PixModel') ;
      if ~isempty(raDec2PixModel)
          pointingObject = pointingClass( raDec2PixModel.pointingModel ) ;
          initialPointing = get_pointing( pointingObject, ...
              mjdMidTime ) ;
          initialPointingStruct = initialize_pointing_struct ;
          initialPointingStruct.raDegrees.value = initialPointing(1) ;
          initialPointingStruct.decDegrees.value = initialPointing(2) ;
          initialPointingStruct.rollDegrees.value = initialPointing(3) ;
          setappdata(mainHandle,'initialPointingStruct',initialPointingStruct) ;
      end
     
%     enable the catalog if there's also an raDec2PixModel lurking about

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
%                   if (rollTime(1,3) == rollTime(2,3))
                      set(childHandleStruct.catalogSourceHandle, ...
                          'string',filename) ;
                      setappdata(mainHandle,'catalogFile',fullFilename) ;
                      setappdata(mainHandle,'usePreStagedCatalog',true) ;
%                   else
%                       beep ; pause(0.35) ; beep
%                       disp('Seasonal roll mismatch between FITS file and catalog file') ;
%                   end
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
% repository and extract the model pointing; also, if we have an raDec2PixModel
% and a FITS file we can enable catalog selection

  if exist('raDec2PixModel','var')
      setappdata(mainHandle,'raDec2PixModel',raDec2PixModel) ;
      mjdMidTime = getappdata(mainHandle,'mjdMidTime') ;
      if ~isempty(mjdMidTime)
          pointingObject = pointingClass( raDec2PixModel.pointingModel ) ;
          initialPointing = get_pointing( pointingObject, ...
              mjdMidTime ) ;
          initialPointingStruct = initialize_pointing_struct ;
          initialPointingStruct.raDegrees.value = initialPointing(1) ;
          initialPointingStruct.decDegrees.value = initialPointing(2) ;
          initialPointingStruct.rollDegrees.value = initialPointing(3) ;
          setappdata(mainHandle,'initialPointingStruct',initialPointingStruct) ;
      end
      fitsFilename = getappdata(mainHandle,'fitsFilename') ;
      pdqFilename  = getappdata(mainHandle,'pdqFilename') ;
      if (~isempty(fitsFilename) || ~isempty(pdqFilename))
          set(childHandleStruct.selectCatalogHandle,'enable','on') ;
      end
  end
      
      
return


%=========================================================================================

% subfunction which handles clearing the user-selected constraints from the table

function clear_constraints_callback( handle, eventData )

% get the main handle

  mainHandle = get( handle, 'parent' ) ;
 
% perform the clear 

  setappdata( mainHandle, 'fitConstraintsStruct', [] ) ;
  
% redraw the dashboard and disable the fitting option since no constraints are set

  childHandleStruct = getappdata( mainHandle, 'childHandleStruct' ) ;
  redraw_dashboard( childHandleStruct.plotAxesHandle ) ;
  set( childHandleStruct.doFitHandle, 'enable','off' ) ;
  set( childHandleStruct.clearConstraintsHandle, 'enable', 'off' ) ;
  
return


%=========================================================================================

% subfunction which produces an initialized pointing struct

function pointingStruct = initialize_pointing_struct

% substruct definition

  coordinateStruct = struct( 'value', 0, 'uncertainty', 0 ) ;
  
% main struct definition

  pointingStruct = struct( 'raDegrees', coordinateStruct, 'decDegrees', coordinateStruct, ...
      'rollDegrees', coordinateStruct, 'chisq', 0, 'ndof', 0 ) ;
  
return 

%=========================================================================================

% subfunction which determines whether fit constraints are present on given CCDs

function ccdConstraintStatus = get_ccd_fit_constraint_status( mainHandle )

  ccdConstraintStatus = zeros(1,42) ;
  
  fitConstraintsStruct = getappdata( mainHandle,'fitConstraintsStruct' ) ;
  
  if ~isempty( fitConstraintsStruct )
      channel = convert_from_module_output( [fitConstraintsStruct.ccdModule], ...
          [fitConstraintsStruct.ccdOutputDesired] ) ;
      constraintCcdNumber = floor( channel / 2 + 0.5 ) ;
      ccdConstraintStatus(constraintCcdNumber) = 1 ;
  end
  
return

%=========================================================================================

% function which performs the fit -- an fpgFitClass object is populated, and its
% do_fpg_fit method is invoked.

function do_fit_callback( handle, eventData )

% start by getting the main handle for the GUI

  mainHandle = get(handle,'parent') ;
  
% get the constraining star data; if there isn't any, or if there isn't enough, complain
% to the user and do nothing else

  kicDesiredPosition = getappdata(mainHandle,'fitConstraintsStruct') ;
  if (length(kicDesiredPosition) < 2)
      beep ; pause(0.35) ; beep
      warning('quasar:doFitCallback:notEnoughConstraintPoints', ...
          'do_fit_callback:  not enough constraint stars specified') ;
      
  else % otherwise, we should attempt to do the fit!
  
%     start constructing the data structure which initializes the object

      fpgFitStruct.raDec2PixObject = raDec2PixClass( ...
          getappdata(mainHandle,'raDec2PixModel'), 'one-based' ) ;
      fpgFitStruct.mjd = getappdata(mainHandle,'mjd') ;
      fpgFitStruct.geometryParMap = zeros(126,1) ;
      fpgFitStruct.plateScaleParMap = 0 ;
      fpgFitStruct.cadenceRAMap = 1 ;
      fpgFitStruct.cadenceDecMap = 2 ;
      fpgFitStruct.cadenceRollMap = 3 ;
      fpgFitStruct.nConstraintPoints = 2*length(kicDesiredPosition) ;
      rowConstraints = [kicDesiredPosition.rowDesired] ;
      colConstraints = [kicDesiredPosition.columnDesired] ;
      fpgFitStruct.constraintPoints = [rowConstraints(:) ; colConstraints(:)] ;
      fpgFitStruct.constraintPointCovariance = ...
          0.25 * eye(fpgFitStruct.nConstraintPoints) ;
      
      initialPointing = getappdata( mainHandle, 'initialPointingStruct' ) ;
      fpgFitStruct.initialParValues   = [0 ; 0 ; 0] ;
      fpgFitStruct.pointingRefCadence = [initialPointing.raDegrees.value ; ...
          initialPointing.decDegrees.value ; initialPointing.rollDegrees.value] ;
      fpgFitStruct.mjd = getappdata( mainHandle, 'mjdMidTime' ) ;
      
%     need to get RA, dec and output for all the constraint stars      

      RA = [kicDesiredPosition.RA] ;
      Dec = [kicDesiredPosition.dec] ;
%      [RA, Dec] = get_kicDesiredPosition_ra_dec( kicDesiredPosition, mainHandle ) ;
      ccdOutput = [kicDesiredPosition.ccdOutputDesired] ;
      ccdModule = [kicDesiredPosition.ccdModule] ;
      fpgFitStruct.raDecModOut(1).matrix = [RA(:) Dec(:) ccdModule(:) ccdOutput(:)] ;
      fpgFitStruct.fitterOptions = kepler_set_soc('TolX',1e-8,'TolFun',2e-2,...
          'FunValCheck','Off','Display','Off') ;
      fpgFitStruct.ccdsForPointingConstraint = [] ;
      fpgFitStruct.pincushionScaleFactor = 1 ;
      
%     instantiate the fit object and perform the fit

      fpgFitObject = fpgFitClass(fpgFitStruct) ;
      fpgFitObject = do_fpg_fit(fpgFitObject) ;
      
%     extract the updated pointing and put it into the GUI's appdata repository

      fittedPointing = initialPointing ;
      fittedValues = get( fpgFitObject, 'finalParValues' ) ;
      covariance   = get( fpgFitObject, 'parValueCovariance' ) ;
      fittedPointing.chisq = get( fpgFitObject, 'chisq' ) ;
      fittedPointing.ndof  = get( fpgFitObject, 'ndof' ) ;
      
      fittedPointing.raDegrees.value         = fittedValues(1) + fpgFitStruct.pointingRefCadence(1) ;
      fittedPointing.raDegrees.uncertainty   = sqrt(covariance(1,1)) ;
      fittedPointing.decDegrees.value        = fittedValues(2) + fpgFitStruct.pointingRefCadence(2) ;
      fittedPointing.decDegrees.uncertainty  = sqrt(covariance(2,2)) ;
      fittedPointing.rollDegrees.value       = fittedValues(3) + fpgFitStruct.pointingRefCadence(3) ;
      fittedPointing.rollDegrees.uncertainty = sqrt(covariance(3,3)) ;
      
      setappdata( mainHandle, 'fittedPointingStruct', fittedPointing ) ;
      childHandleStruct = getappdata( mainHandle, 'childHandleStruct' ) ;
      set( childHandleStruct.displayFitHandle, 'enable', 'on' ) ;
      if ~isempty( getappdata(mainHandle,'pdqFilename') )
          set( childHandleStruct.exportFitHandle, 'enable', 'on' ) ;
      end
      
  end % conditional on sufficient data being present
      
return

%=========================================================================================

% display the fit!

function display_fit_callback( handle, eventData )

% get the main handle

  mainHandle = get(handle,'parent') ;
  
% get the initial and fitted values

  initialPointing = getappdata( mainHandle, 'initialPointingStruct' ) ;
  fittedPointing  = getappdata( mainHandle, 'fittedPointingStruct' ) ;
  
% display each coordinate in turn

  display_pointing( 'RA',   initialPointing.raDegrees,   fittedPointing.raDegrees ) ;
  display_pointing( 'Dec',  initialPointing.decDegrees,  fittedPointing.decDegrees ) ;
  display_pointing( 'Roll', initialPointing.rollDegrees, fittedPointing.rollDegrees ) ;
  
% convert to pixel offsets

  decCosine = abs( cos( fittedPointing.decDegrees.value * pi/180 ) ) ;
  deltaRaDegreesOfArc = (fittedPointing.raDegrees.value - initialPointing.raDegrees.value) * ...
      decCosine ;
  sigmaRaDegreesOfArc = fittedPointing.raDegrees.uncertainty * decCosine ;
  deltaDecDegreesOfArc = fittedPointing.decDegrees.value - initialPointing.decDegrees.value ;
  sigmaDecDegreesOfArc = fittedPointing.decDegrees.uncertainty ;
  deltaRollDegrees = fittedPointing.rollDegrees.value - initialPointing.rollDegrees.value ;
  sigmaRollDegrees = fittedPointing.rollDegrees.uncertainty ;
  
  degreesOfArcToPixels = 3600 / 3.98 ;
  
  deltaRaPixels  = deltaRaDegreesOfArc  * degreesOfArcToPixels ;
  sigmaRaPixels  = sigmaRaDegreesOfArc  * degreesOfArcToPixels ;
  deltaDecPixels = deltaDecDegreesOfArc * degreesOfArcToPixels ;
  sigmaDecPixels = sigmaDecDegreesOfArc * degreesOfArcToPixels ;
  
% determine the focal plane coordinates of the pixel which is furthest from the center of
% the focal plane, thence distance to same

  [zp,yp] = morc_to_focal_plane_coords( 2, 4, 21, 13, 'one-based' ) ;
  radiusPixels = sqrt( zp^2 + yp^2 ) ;
  
  deltaRollPixels = deltaRollDegrees * pi/180 * radiusPixels ;
  sigmaRollPixels = sigmaRollDegrees * pi/180 * radiusPixels ;
  
  display_offset( 'RA',   deltaRaPixels,   sigmaRaPixels ) ;
  display_offset( 'Dec',  deltaDecPixels,  sigmaDecPixels ) ;
  display_offset( 'Roll', deltaRollPixels, sigmaRollPixels ) ;
  
% chi-square and ndof of the fit

  disp(['Chi-square == ', num2str( fittedPointing.chisq ), ', ndof == ', ...
      num2str( fittedPointing.ndof )]) ;
  
return

%=========================================================================================

function export_fit_callback( handle, eventData )

% get the main handle

  mainHandle = get(handle,'parent') ;
  
% get the fitted pointing and the PDQ struct

  fittedPointing = getappdata( mainHandle, 'fittedPointingStruct' ) ;
  inputsStruct   = getappdata( mainHandle, 'pdqStruct' ) ;
  pdqFilename    = getappdata( mainHandle, 'pdqFilename' ) ;
  mjd            = getappdata( mainHandle, 'mjdMidTime' ) ;
  
% construct a filename for writing

  pdqOutputFilename = [pdqFilename(1:end-4),'-',datestr(now,30),'.mat'] ;
  
% construct the attitude solution

  preliminaryAttitudeSolutionStruct = struct( 'mjd', mjd,'raDegrees', ...
      fittedPointing.raDegrees.value, 'decDegrees', fittedPointing.decDegrees.value, ...
      'rollDegrees', fittedPointing.rollDegrees.value ) ;
  inputsStruct.preliminaryAttitudeSolutionStruct = preliminaryAttitudeSolutionStruct ;
  
% perform the save

  save(pdqOutputFilename,'inputsStruct') ;
  
return
  

%=========================================================================================

% function to display the pointing fit for one coordinate

function display_pointing( coordName, initialStruct, fittedStruct )

% display the coordinate name

  disp( [coordName,':'] ) ;
  
% determine the # of decimal places needed

  decimalPlaces = abs( log10(fittedStruct.uncertainty) ) ;
  width = decimalPlaces + 5 ;
  
  disp(['Initial value:  ',num2str(initialStruct.value,width)]) ;
  disp(['Fitted value:   ',num2str(fittedStruct.value,width)]) ;
  disp(['Delta = ',num2str(fittedStruct.value-initialStruct.value,decimalPlaces), ...
      '+/- ',num2str(fittedStruct.uncertainty,decimalPlaces)]) ;
  
return

%=========================================================================================

% function to display the change in pixel coordinates

function display_offset( coordName, delta, sigma )

% determine width

  decimalPlaces = abs(log10(sigma)) + 2 ;
  
  disp([coordName,':']) ;
  disp(['Delta == ',num2str(delta,decimalPlaces),' +/- ', num2str(sigma,decimalPlaces),' pixels']) ;
  
return

%=========================================================================================

% function to construct a "sparse" PDQ-based image

function ccdImage = get_pdq_image( pdqStruct, ccdModule, ccdOutput )

% define the empty image

  ccdImage = zeros(1044,1112) ;
  
% find the stellar targets which have valid reference pixels for this mod out

  stellarTargets = pdqStruct.stellarPdqTargets ;
  module = [stellarTargets.ccdModule] ;
  output = [stellarTargets.ccdOutput] ;
  
  thisModOut = module == ccdModule & output == ccdOutput ;
  stellarTargets = stellarTargets(thisModOut) ;
  
  referencePixels = [stellarTargets.referencePixels] ;
  row = zeros(size(referencePixels)) ;
  col = zeros(size(referencePixels)) ;
  val = zeros(size(referencePixels)) ;
  
% put pixel values into the image

  for iPixel = 1:length(referencePixels)
      
      thisPixel = referencePixels(iPixel) ;
      row(iPixel) = thisPixel.row+1 ;
      col(iPixel) = thisPixel.column+1 ;
      val(iPixel) = thisPixel.timeSeries(end) * double(~thisPixel.gapIndicators(end)) ;
      ccdImage(thisPixel.row+1, thisPixel.column+1) = thisPixel.timeSeries(end) * ...
          double(~thisPixel.gapIndicators(end)) ;
      
  end
  
return

  