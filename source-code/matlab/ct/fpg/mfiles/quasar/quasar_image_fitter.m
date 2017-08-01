function [status, fittedGeometry, geometryChangeStruct] = quasar_image_fitter( ...
    ccdNumber, ccdImage, kicData, raDec2PixModel, currentGeometry, mjd )
%
% quasar_image_fitter -- GUI tool for performing coarse focal-plane geometry fitting
%
% [status, fittedGeometry] = quasar_image_fitter( ccdNumber, ccdImage, kicData,
%    raDec2PixModel, currentGeometry ) takes as its arguments the following:
%
%    ccdNumber        (1 to 42)
%    ccdImage         (nRows x 2 * nColumns image)
%    kicData          (struct vector with fields:  keplerId, keplerMag, RA, Dec)
%    raDec2PixModel   (an raDec2Pix model)
%    currentGeometry  (current best guess of the focal plane geometry)
%    mjd              (modified Julian date for the operation)
%
% The GUI is launched, and the following are returned after GUI work:
%
%    status                0 == no geometry accepted, 1 == current geometry accepted, 2 ==
%                          fitted geometry accepted
%    fittedGeometry        geometry updated with fit results if desired, or 
%                          currentGeometry otherwise
%    geometryChangeStruct  Structure which contains information on the change in the 3-2-1
%                          angles and their uncertainties, change in row, column, and
%                          rotation and uncertainties, and chisq and ndof.
%
% quasar_image_fitter is intended to be called and managed by the quasar_matlab_gui
%    function, and is not intended for use on its own (other than in test).
%
% Version date:  2009-May-18.
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
%    2009-May-18, PT:
%        add pincushionScaleFactor for compatibility with updated FPG codebase.
%    2009-February-17, PT:
%        move compute_changed_geometry function to standalone file so that master GUI can
%        also use it.
%
%=========================================================================================

% hard-coded constants initialization:

  minMagnitudeInitial = 33 ;
  maxMagnitudeInitial = 33 ;

% compute the module and output number(s)

  highChannel = ccdNumber * 2 ;
  lowChannel  = highChannel - 1 ;
  [module,lowOutput]  = convert_to_module_output(lowChannel) ;
  [module,highOutput] = convert_to_module_output(highChannel) ;
  
% construct the GUI title string

  titleString = ['Quasar: Image Fitter, CCD ',num2str(ccdNumber), ...
      ' (Module ',num2str(module),', Outputs ',num2str(lowOutput), ...
      ' and ',num2str(highOutput),')'] ;
  
%=========================================================================================
%
% Initialize the GUI
%
%=========================================================================================

% Master figure construction

  mainHandle = figure( 'units','pixels', 'position',[100 100 1000 850], ...
      'tag','quasarImageFitter', 'numbertitle','off', 'name',titleString, ...
      'visible','off' ) ;
  
% initialize application data

  setappdata(mainHandle,'ccdImage',ccdImage) ;
  setappdata(mainHandle,'keplerIdImage',zeros(size(ccdImage))) ;
  setappdata(mainHandle,'raDec2PixModel',raDec2PixModel) ;
  setappdata(mainHandle,'currentGeometry',currentGeometry) ;
  setappdata(mainHandle,'fittedGeometry',[]) ;
  setappdata(mainHandle,'selectedGeometry','Current') ;
  setappdata(mainHandle,'mjd',mjd) ;
  setappdata(mainHandle,'kicData',kicData) ;
  setappdata(mainHandle,'kicCurrentPosition',[]) ;
  setappdata(mainHandle,'kicDesiredPosition',[]) ;
  setappdata(mainHandle,'fitStatus',0) ;
  setappdata(mainHandle,'ccdModule',module) ;
  setappdata(mainHandle,'ccdOutputLow',lowOutput) ;
  setappdata(mainHandle,'ccdOutputHigh',highOutput) ;
  setappdata(mainHandle,'ccdNumber',ccdNumber) ;
  setappdata(mainHandle,'incompleteConstraintPoint',[]) ;
  setappdata(mainHandle,'fpgFitObject',[]) ;
    
  setappdata(mainHandle,'minMagnitude',minMagnitudeInitial) ;
  setappdata(mainHandle,'maxMagnitude',maxMagnitudeInitial) ;
  
% initialize an raDec2PixClass object which is one-based and uses the current geometry

  rd2pm = getappdata(mainHandle,'raDec2PixModel') ;
  gm = getappdata(mainHandle,'currentGeometry') ;
  rd2pm.geometryModel = gm ;
  raDec2PixObject = raDec2PixClass(rd2pm,'one-based') ;
  setappdata(mainHandle,'raDec2PixObject',raDec2PixObject) ;
  
% axes component for the image -- the image includes leading black and masked smear, but
% not trailing black or virtual smear

  ax = axes('units', 'pixels', 'position', [ 70 375 900 450],'parent', mainHandle);

% magnitude entry panel -- I stupidly did this so that the fixed text strings are children
% of the uipanel, while the edit panels are children of the main figure.

  magHandle=uipanel('units','pixels','position',[50 225 160 100],'parent',mainHandle, ...
      'title','Magnitude Range') ;
  minTextHandle = uicontrol(magHandle,'style', 'text', 'string', 'Minimum',...
      'position', [ 20 52 70 20] );
  minValueHandle = uicontrol(mainHandle,'style', 'edit', 'string',num2str(minMagnitudeInitial),...
      'position', [ 150 275 50 20] , 'backgroundcolor', 'w','callback',@min_mag_callback);
  maxTextHandle = uicontrol(magHandle,'style', 'text', 'string', 'Maximum',...
      'position', [ 20 26 70 20] );
  maxValueHandle = uicontrol(mainHandle,'style', 'edit', 'string',num2str(maxMagnitudeInitial),...
      'position', [ 150 250 50 20] , 'backgroundcolor', 'w','callback',@max_mag_callback);
  
% geometry selection radio buttons -- this is disabled until such time as the fitted
% geometry has been constructed 

  geometryHandle = uibuttongroup('parent',mainHandle,'units','pixels',...
      'position',[50 120 160 100],'title','Geometry Model','visible','on') ;
  currentGeometryHandle = uicontrol('parent',geometryHandle,'Style','Radio',...
      'String','Current','pos',[40 52 100 20]) ;
  fittedGeometryHandle = uicontrol('parent',geometryHandle,'Style','Radio',...
      'String','Fitted','pos',[40 26 100 20],'enable','off') ;
  set(geometryHandle,'SelectionChangeFcn',@select_geometry_callback) ;

% replot button

  replotHandle = uicontrol('parent',mainHandle,'units','pixels','position',[50 15 160 100],...
      'string','Replot','callback',@replot_callback) ;

% buttons related to fitting -- do the fit, display the fit, clear the existing fit
% constraints

  doFitHandle = uicontrol('parent',mainHandle,'units','pixels',...
      'position',[230 145 160 60], 'string','Do Fit','callback',@do_fit_callback) ;

  displayFitHandle = uicontrol('parent',mainHandle,'units','pixels',...
      'position',[230 80 160 60],'string','Display Fit','callback',@display_fit_callback) ;

  clearConstraintsHandle = uicontrol('parent',mainHandle,'units','pixels',...
      'position',[230 15 160 60], ...
      'string','Clear Fit Constraints','callback',@clear_constraints_callback) ;

% buttons which are related to accepting or rejecting the fit

  acceptFitHandle = uicontrol('parent',mainHandle,'units','pixels',...
      'position',[410 145 160 60], ...
      'string','Accept Fitted Geometry','callback',@accept_fit_callback) ;
  
  acceptCurrentHandle = uicontrol('parent',mainHandle,'units','pixels',...
      'position',[410 80 160 60], ...
      'string','Accept Current Geometry','callback',@accept_current_callback) ;
  
  rejectAllHandle = uicontrol('parent',mainHandle,'units','pixels',...
      'position',[410 15 160 60], ...
      'string','Reject All Geometries','callback',@reject_all_callback) ;
  
% controls related to scaling information

  scalingBoxHandle = uipanel('units','pixels','parent',mainHandle, ...
      'position',[230 225 330 100],'title','Intensity Scaling') ;
  plotDataTextHandle = uicontrol(mainHandle,'style','text','string','Data Values:', ...
      'position',[235 285 100 20]) ;
  plotDataMinTextHandle = uicontrol(mainHandle,'style','text','string','Min = ', ...
      'position',[235 260 60 20]) ;
  plotDataMinValueHandle = uicontrol(mainHandle,'style','text','string','1234567', ...
      'position',[280 260 60 20]) ;
  plotDataMaxTextHandle = uicontrol(mainHandle,'style','text','string','Max = ', ...
      'position',[235 235 60 20]) ;
  plotDataMaxValueHandle = uicontrol(mainHandle,'style','text','string','1234567', ...
      'position',[280 235 60 20]) ;
  scalingTextHandle = uicontrol(mainHandle,'style','text','string','Intensity Scaling:', ...
      'position',[360 285 100 20]) ;
  scaleMinTextHandle = uicontrol(mainHandle,'style','text','string','Min = ', ...
      'position',[365 260 60 20]) ;
  scaleMinValueHandle = uicontrol(mainHandle,'style','edit','string','1234567', ...
      'position',[415 260 60 20],'backgroundcolor','w','enable','off', ...
      'callback',@replot_callback) ;
  scaleMaxTextHandle = uicontrol(mainHandle,'style','text','string','Max = ', ...
      'position',[365 235 60 20]) ;
  scaleMaxValueHandle = uicontrol(mainHandle,'style','edit','string','1234567', ...
      'position',[415 235 60 20],'backgroundcolor','w','enable','off', ...
      'callback',@replot_callback) ;
  autoScaleText1Handle = uicontrol(mainHandle,'style','text','string','Auto', ...
      'position',[480 285 60 20]) ;
  autoScaleText2Handle = uicontrol(mainHandle,'style','text','string','Scale', ...
      'position',[480 270 60 20]) ;
  autoScaleValueHandle = uicontrol(mainHandle,'style','checkbox', ...
      'position',[500 255 20 20],'tag','checkbox1','callback',@auto_scale_callback) ;
  set(autoScaleValueHandle,'value',get(autoScaleValueHandle,'Max')) ;
  
  
% Information box on cursor position

  pixelInfoHandle = uipanel('units','pixels','parent',mainHandle, ...
      'position',[580 15 170 200],...
      'title','Pixel Information','visible','on') ;
  pixelIntensityTextHandle = uicontrol(mainHandle,'style','text','string','Intensity', ...
      'position',[590 155 60 20]) ;
  pixelIntensityValueHandle = uicontrol(mainHandle,'style','text','string','', ...
      'position',[660 158 60 20],'backgroundcolor','w') ;
  pixelModuleTextHandle = uicontrol(mainHandle,'style','text','string','Module', ...
      'position',[590 125 60 20]) ;
  pixelModuleValueHandle = uicontrol(mainHandle,'style','text','string','', ...
      'position',[660 128 60 20],'backgroundcolor','w') ;
  pixelOutputTextHandle = uicontrol(mainHandle,'style','text','string','Output', ...
      'position',[590 95 60 20]) ;
  pixelOutputValueHandle = uicontrol(mainHandle,'style','text','string','', ...
      'position',[660 98 60 20],'backgroundcolor','w') ;
  pixelRowTextHandle = uicontrol(mainHandle,'style','text','string','Row', ...
      'position',[590 65 60 20]) ;
  pixelRowValueHandle = uicontrol(mainHandle,'style','text','string','', ...
      'position',[660 68 60 20],'backgroundcolor','w') ;
  pixelColTextHandle = uicontrol(mainHandle,'style','text','string','Column', ...
      'position',[590 35 60 20]) ;
  pixelColValueHandle = uicontrol(mainHandle,'style','text','string','', ...
      'position',[660 38 60 20],'backgroundcolor','w') ;

% information box on stars which are moused over

  starInfoHandle = uipanel('units','pixels','parent',mainHandle,...
      'position',[760 15 220 310], ...
      'title','Star Information','visible','on') ;
  keplerIdTextHandle = uicontrol(mainHandle,'style', 'text', 'string', 'Kepler ID',...
      'position', [ 770 275 70 20] );
  keplerIdValueHandle = uicontrol(mainHandle,'style', 'text', 'string', '',...
      'position', [ 845 278 100 20],'backgroundcolor','w' );
  raTextHandle = uicontrol(mainHandle,'style', 'text', 'string', 'RA',...
      'position', [ 770 245 70 20] );
  raValueHandle = uicontrol(mainHandle,'style', 'text', 'string', '',...
      'position', [ 845 248 100 20],'backgroundcolor','w' );
  decTextHandle = uicontrol(mainHandle,'style', 'text', 'string', 'Dec',...
      'position', [ 770 215 70 20] );
  decValueHandle = uicontrol(mainHandle,'style', 'text', 'string', '',...
      'position', [ 845 218 100 20],'backgroundcolor','w' );
  magTextHandle = uicontrol(mainHandle,'style', 'text', 'string', 'Kepler Mag',...
      'position', [ 770 185 70 20] );
  magValueHandle = uicontrol(mainHandle,'style', 'text', 'string', '',...
      'position', [ 845 188 100 20],'backgroundcolor','w' );
  modTextHandle = uicontrol(mainHandle,'style', 'text', 'string', 'Module',...
      'position', [ 770 125 70 20] );
  modValueHandle = uicontrol(mainHandle,'style', 'text', 'string', '',...
      'position', [ 845 128 100 20],'backgroundcolor','w' );
  outTextHandle = uicontrol(mainHandle,'style', 'text', 'string', 'Output',...
      'position', [ 770 95 70 20] );
  outValueHandle = uicontrol(mainHandle,'style', 'text', 'string', '',...
      'position', [ 845 98 100 20],'backgroundcolor','w' );
  rowTextHandle = uicontrol(mainHandle,'style', 'text', 'string', 'Row',...
      'position', [ 770 65 70 20] );
  rowValueHandle = uicontrol(mainHandle,'style', 'text', 'string', '',...
      'position', [ 845 68 100 20],'backgroundcolor','w' );
  colTextHandle = uicontrol(mainHandle,'style', 'text', 'string', 'Column',...
      'position', [ 770 35 70 20] );
  colValueHandle = uicontrol(mainHandle,'style', 'text', 'string', '',...
      'position', [ 845 38 100 20],'backgroundcolor','w' );
  
% build a structure which contains the handles of the uicontrols for which access is
% required, and put that as appdata into the main GUI.  This is in some sense superfluous,
% as all of those uicontrols are children of the main GUI, but it simplifies the
% management of the data.

  childHandleStruct = struct( ...
      'minMagnitudeHandle',         minValueHandle, ...
      'maxMagnitudeHandle',         maxValueHandle, ...
      'geometryHandle',             geometryHandle, ...
      'fittedGeometryHandle',       fittedGeometryHandle, ...
      'plotDataMinValueHandle',     plotDataMinValueHandle, ...
      'plotDataMaxValueHandle',     plotDataMaxValueHandle, ...
      'scaleMinValueHandle',        scaleMinValueHandle, ...
      'scaleMaxValueHandle',        scaleMaxValueHandle, ...
      'autoScaleValueHandle',       autoScaleValueHandle, ...
      'pixelIntensityValueHandle',  pixelIntensityValueHandle, ...
      'pixelModuleValueHandle',     pixelModuleValueHandle, ...
      'pixelOutputValueHandle',     pixelOutputValueHandle, ...
      'pixelRowValueHandle',        pixelRowValueHandle, ...
      'pixelColValueHandle',        pixelColValueHandle, ...
      'keplerIdValueHandle',        keplerIdValueHandle, ...
      'raValueHandle',              raValueHandle, ...
      'decValueHandle',             decValueHandle, ...
      'magValueHandle',             magValueHandle, ...
      'modValueHandle',             modValueHandle, ...
      'outValueHandle',             outValueHandle, ...
      'rowValueHandle',             rowValueHandle, ...
      'colValueHandle',             colValueHandle        ) ;
  
  setappdata(mainHandle,'childHandleStruct',childHandleStruct) ;

% set some parameters  
  
  set(mainHandle,'Interruptible','on','WindowButtonMotionFcn', @move_mouse_callback, ...
      'WindowButtonUpFcn', @click_mouse_callback, ...
      'CloseRequestFcn',@close_request_callback) ;
  set(mainHandle,'Toolbar','figure')
  
% plot the CCD image

%  do_plot(mainHandle) ;
  auto_scale_callback(autoScaleValueHandle,[]) ;
  
% normalize all components so that resizing figure still looks good

  list = allchild(mainHandle);
  foundlist = findall(list, 'units', 'pixels');
  for n = 1:length(foundlist)
    set(foundlist(n), 'units', 'normalized')
  end
    
% make the GUI visible

  set(mainHandle,'visible','on') ;
  
% make the GUI blocking -- don't want additional image-fitter GUIs brought up while we are
% messing with this one

  uiwait(mainHandle) ;
  
% set return values

  status = getappdata(mainHandle,'fitStatus') ;
  if (status == 0 || status == 1)
      fittedGeometry = getappdata(mainHandle,'currentGeometry') ;
      geometryChangeStruct = compute_changed_geometry(0) ;
  else
      fittedGeometry = getappdata(mainHandle,'fittedGeometry') ;
      geometryChangeStruct = compute_changed_geometry(mainHandle) ;
  end
  
  delete(mainHandle) ;
  
return

% end of main function

%
%
%

%=========================================================================================

% subfunction to handle the main plotting chores

function do_plot( mainHandle )

% get the ccd image

  ccdImage = getappdata(mainHandle,'ccdImage') ;
  imageSize = size(ccdImage) ;
  
% get the relevant children via their struct

  childHandleStruct = getappdata(mainHandle,'childHandleStruct') ;
  
% fill in the min and max image values, neglecting -1 and 2^32-1 values

  ccdImageVector = ccdImage(:) ;
  validCcdImageVector = ccdImageVector( ccdImageVector>0 & ccdImageVector<2^32-1 ) ;
  minPixel = min(validCcdImageVector) ;
  maxPixel = max(validCcdImageVector) ;
  
  set(childHandleStruct.plotDataMinValueHandle,'string', ...
      num2str(round(minPixel))) ;
  set(childHandleStruct.plotDataMaxValueHandle,'string', ...
      num2str(round(maxPixel))) ;
  
% get the scaling limits 

  minImageValue = str2num(get(childHandleStruct.scaleMinValueHandle,'string')) ;
  maxImageValue = str2num(get(childHandleStruct.scaleMaxValueHandle,'string')) ;
  
% clear things up
  
  cla ;
  
% do the plot (1-based indexing!)

  imagesc(ccdImage,[minImageValue maxImageValue]) ;
  set(gca,'YDir','normal') ;
  xlabel(gca,'\bf Column')
  ylabel(gca,'\bf Row')
  colormap hot ;
  
% draw the cyan line between the two mod/outs

  hold on 
  centerColumn = imageSize(2) / 2 ;
  plot([centerColumn+0.5 centerColumn+0.5],[0.5 imageSize(1)+0.5],'c') ;
  
% If there are any stars in the KIC current position, plot them (remember to convert
% mod/out based column values to CCD-based ones)

  kicCurrentPosition = getappdata(mainHandle,'kicCurrentPosition') ;
  if (~isempty(kicCurrentPosition))
      row = [kicCurrentPosition.row] ;
      out = [kicCurrentPosition.ccdOutput] ;
      col = [kicCurrentPosition.column] ;
      col = convert_to_ccd_column(out,col,'one-based') ;
      plot(col,row,'go') ;
  end
  
% if there are any stars in the KIC constraints data structure, plot them (remember to
% convert mod/out based column values to CCD-based ones)

  kicDesiredPosition = getappdata(mainHandle,'kicDesiredPosition') ;
  plot_kicDesiredPosition( kicDesiredPosition, true, true ) ;
  
return

% end of plotting function

%
%
%

%=========================================================================================

% subfunction to handle plotting of one or more kicDesiredPosition stars -- a blue circle
% at the modeled star location, blue dot at the desired location, and a blue line
% in-between.  Caller can select to plot only the circle, or only the line and dot, or
% both.

function plot_kicDesiredPosition( kicDesiredPosition, plotCircle, plotDotAndLine )

  if (~isempty(kicDesiredPosition))
      
%     unpack the needed variables from the kicDesiredPosition structure
      
      outModel = [kicDesiredPosition.ccdOutputModel] ;
      rowModel = [kicDesiredPosition.rowModel] ;
      columnModel = [kicDesiredPosition.columnModel] ;
      columnModel = convert_to_ccd_column(outModel,columnModel,'one-based') ;
      
%     do the plots 
      
      if (plotCircle)
          plot(columnModel,rowModel,'bo') ;
      end
      if (plotDotAndLine)
          outDesired = [kicDesiredPosition.ccdOutputDesired] ;
          rowDesired = [kicDesiredPosition.rowDesired] ;
          columnDesired = [kicDesiredPosition.columnDesired] ;
          columnDesired = convert_to_ccd_column(outDesired,columnDesired,'one-based') ;
          plot(columnDesired,rowDesired,'b.') ;
          for iPoint = 1:length(columnModel)
              plot([columnModel(iPoint) columnDesired(iPoint)], ...
                   [rowModel(iPoint) rowDesired(iPoint)], 'b') ;
          end
      end
      
  end

return

% end of kicDesiredPosition plotting function

%=========================================================================================


% function which returns the RA and Dec of stars in the kicDesiredPosition structure (or
% the incompleteConstraintPoint function) based on the KIC

function [RA Dec] = get_kicDesiredPosition_ra_dec( kicDesiredPosition, mainHandle )

% get the kicData struct out of the main GUI

  kicData = getappdata( mainHandle, 'kicData' ) ;
  RA = [kicData.RA] ;
  Dec = [kicData.Dec] ;
  keplerId = [kicData.keplerId] ;
  keplerIdConstraintStars = [kicDesiredPosition.keplerId] ;

% because neither the KIC nor the constraint stars are guaranteed to be sorted by Kepler
% ID number, and because we want to keep the current order in the constraint star
% structure the same, we use a heinous for-loop to identify the KIC stars which are
% pointed to by the constraint stars.  Fortunately there aren't too many of these, so
% performance is not an issue.

  keplerIdIndex = zeros(size(keplerIdConstraintStars)) ;
  for iStar = 1:length(keplerIdIndex)
      keplerIdIndex(iStar) = find(keplerId == keplerIdConstraintStars(iStar)) ;
  end

  RA = RA(keplerIdIndex) ;
  Dec = Dec(keplerIdIndex) ;
  
return

% end of get_kicDesiredPosition_ra_dec function

%
%
%

%=========================================================================================

% function which fills in the model row, column, and output values for kicDesiredPosition
% or incompleteConstraintPoint functions

function kicDesiredPosition = fill_kicDesiredPosition_model_values( kicDesiredPosition, ...
    mainHandle )

% get the RA and Dec values

  [RA, Dec] = get_kicDesiredPosition_ra_dec( kicDesiredPosition, mainHandle ) ;
  
% use raDec2Pix to get the output, row and column

  raDec2PixObject = getappdata( mainHandle, 'raDec2PixObject' ) ;
  mjd             = getappdata( mainHandle, 'mjd' ) ;
  [mod,out,row,col] = ra_dec_2_pix(raDec2PixObject,RA,Dec,mjd) ;

% extract the desired row, column, and ccd output numbers from the structure
  
  rowDesired = [kicDesiredPosition.rowDesired] ;
  colDesired = [kicDesiredPosition.columnDesired] ;
  outDesired = [kicDesiredPosition.ccdOutputDesired] ;
  
% build an array of values and use cell2struct to pour them back into the structure, along
% with the re-computed values

  keplerIdConstraintStars = [kicDesiredPosition.keplerId] ;
  kicDesiredPositionArray = [keplerIdConstraintStars(:)' ; ...
      row(:)' ; col(:)' ; out(:)' ; ...
      rowDesired(:)' ; colDesired(:)' ; outDesired(:)'] ;
  kicDesiredPositionCellArray = num2cell(kicDesiredPositionArray) ;
  
% note that there are 2 use-cases for this function, and in one of them the desired values
% are empty and kicDesiredPosition is a scalar struct.  Handle that dichotomy now
  
  if ( isempty(rowDesired) )
      kicDesiredPosition = cell2struct(kicDesiredPositionCellArray, ...
          {'keplerId','rowModel','columnModel','ccdOutputModel'}, 1) ;
      kicDesiredPosition.rowDesired = [] ;
      kicDesiredPosition.columnDesired = [] ;
      kicDesiredPosition.ccdOutputDesired = [] ;
  else
      kicDesiredPosition = cell2struct(kicDesiredPositionCellArray, ...
          {'keplerId','rowModel','columnModel','ccdOutputModel', ...
           'rowDesired','columnDesired','ccdOutputDesired'}, 1) ;
  end
   
 return

% end of fill_kicDesiredPosition_model_values function
 
%

%
%
%

%=========================================================================================
%
% Callback Functions
%
%=========================================================================================

% function which handles the enable/disable of auto scaling

function auto_scale_callback( handle, eventData )

% get the value of the check box

  autoScale = (get(handle,'value') == get(handle,'max')) ;
  
% get the parent handle and its associated set of useful child handles

  mainHandle = get(handle,'parent') ;
  childHandleStruct = getappdata(mainHandle,'childHandleStruct') ;
  
% if the auto scale is set, compute the auto scaling, fill it in, and disable the input
% windows, and replot; otherwise, enable the input windows and do nothing else

  if (autoScale)
      
      ccdImage = getappdata(mainHandle,'ccdImage') ;  
      ccdImageVector = ccdImage(:) ;
      validCcdImageVector = ccdImageVector( ccdImageVector>0 & ccdImageVector<2^31-1 ) ;
      minImageValue = min(validCcdImageVector) ;
      maxImageValue = median(validCcdImageVector)+ 35*mad(validCcdImageVector); 
      set(childHandleStruct.scaleMinValueHandle,'string',...
          num2str(round(minImageValue))) ;
      set(childHandleStruct.scaleMaxValueHandle,'string',...
          num2str(round(maxImageValue))) ;
      set(childHandleStruct.scaleMinValueHandle,'enable','off') ;
      set(childHandleStruct.scaleMaxValueHandle,'enable','off') ;
      do_plot(mainHandle) ;
      
  else
      
      set(childHandleStruct.scaleMinValueHandle,'enable','on') ;
      set(childHandleStruct.scaleMaxValueHandle,'enable','on') ;
      
  end
  
return

%=========================================================================================

% function which accepts a new value for the minimum magnitude range

function min_mag_callback( handle, eventData )

% get the value of the selected minimum magnitude and put it into the main figure's app
% data in the appropriate slot

  newMinMagnitude = str2num(get(handle,'string')) ;
  mainHandle = get(handle,'parent') ;
  setappdata(mainHandle,'minMagnitude',newMinMagnitude) ;
  
return

%=========================================================================================

% function which accepts a new value for the maximum magnitude range

function max_mag_callback( handle, eventData )

% get the value of the selected maximum magnitude and put it into the main figure's app
% data in the appropriate slot

  newMaxMagnitude = str2num(get(handle,'string')) ;
  mainHandle = get(handle,'parent') ;
  setappdata(mainHandle,'maxMagnitude',newMaxMagnitude) ;
  
return

%=========================================================================================

% function which accepts a selection of the geometry model to use

function select_geometry_callback( handle, eventData )

% get the selected geometry and put it into the main figure's app data

  mainHandle = get(handle,'parent') ;
  newGeometry = get(get(handle,'SelectedObject'),'String') ;
  setappdata(mainHandle,'selectedGeometry',newGeometry) ;
  
% automatically perform a replot

  replot_callback( handle, [] ) ;
  
return

%=========================================================================================

% function which performs the replot -- plots the starfield overlaid with stars in the
% selected magnitude range and stars which have been selected as fit constraints

function replot_callback( handle, eventData )

% get the main figure handle

  mainHandle = get(handle,'parent') ;
  
% step 1:  set up the raDec2PixClass object with the correct geometry

  raDec2PixModel   = getappdata(mainHandle,'raDec2PixModel') ;
  selectedGeometry = getappdata(mainHandle,'selectedGeometry') ;
  if (strcmp(selectedGeometry,'Current'))
      geometryModel = getappdata(mainHandle,'currentGeometry') ;
  else
      geometryModel = getappdata(mainHandle,'fittedGeometry') ;
  end
  raDec2PixModel.geometryModel = geometryModel;
  raDec2PixObject = raDec2PixClass(raDec2PixModel,'one-based') ;
  setappdata(mainHandle,'raDec2PixObject',raDec2PixObject) ;
  
% Step 2:  repopulate the list of stars from the KIC which are to be plotted based on the
% current values of the magnitude ranges

  kicData      = getappdata(mainHandle,'kicData') ;
  minMagnitude = getappdata(mainHandle,'minMagnitude') ;
  maxMagnitude = getappdata(mainHandle,'maxMagnitude') ;
  mjd          = getappdata(mainHandle,'mjd') ;
  
  kicMagnitudes = [kicData.keplerMag] ;
  RA = [kicData.RA] ;
  Dec = [kicData.Dec] ;
  keplerId = [kicData.keplerId] ;
  selectedStars = find( kicMagnitudes >= minMagnitude & kicMagnitudes <= maxMagnitude ) ;
  if (~isempty(selectedStars))
      RA = RA(selectedStars) ; RA = RA(:)' ;
      Dec = Dec(selectedStars) ; Dec = Dec(:)' ;
      keplerId = keplerId(selectedStars) ; keplerId = keplerId(:)' ;

      [mod,out,row,col] = ra_dec_2_pix(raDec2PixObject,RA,Dec,mjd) ;
      out = out(:)' ;
      row = row(:)' ;
      col = col(:)' ;

      kicCurrentPositionArray = [keplerId ; out ; row ; col] ;
      kicCurrentPositionCellArray = num2cell(kicCurrentPositionArray) ;
      kicCurrentPosition = cell2struct(kicCurrentPositionCellArray, ...
          {'keplerId','ccdOutput','row','column'},1) ;
      setappdata(mainHandle,'kicCurrentPosition',kicCurrentPosition) ;
  else
      setappdata(mainHandle,'kicCurrentPosition',[]) ;
  end % conditional on existence of selected stars
  
% step 3:  recompute the model positions of the stars which are used as fit constraints,
% if any are selected (the desired positions do not change)

  kicDesiredPosition = getappdata(mainHandle,'kicDesiredPosition') ;
  if (~isempty(kicDesiredPosition))
      kicDesiredPosition = fill_kicDesiredPosition_model_values( kicDesiredPosition, ...
          mainHandle ) ;
      setappdata(mainHandle,'kicDesiredPosition',kicDesiredPosition) ;
  end 
  
% step 4:  clear and repopulate the keplerIdImage table, which is used by the mouseover
% tool to know when something needs to be displayed

  keplerIdImage = getappdata(mainHandle,'keplerIdImage') ;
  keplerIdImage = zeros(size(keplerIdImage)) ;
  keplerId1 = [] ; row1 = [] ; col1 = [] ; out1 = [] ;
  keplerId2 = [] ; row2 = [] ; col2 = [] ; out2 = [] ;
  if (exist('kicCurrentPosition'))
      keplerId1 = [kicCurrentPosition.keplerId] ;
      row1 = [kicCurrentPosition.row] ;
      col1 = [kicCurrentPosition.column] ;
      out1 = [kicCurrentPosition.ccdOutput] ;
  end
  if (~isempty(kicDesiredPosition))
      keplerId2 = -[kicDesiredPosition.keplerId] ;
      row2 = [kicDesiredPosition.rowModel] ;
      col2 = [kicDesiredPosition.columnModel] ;
      out2 = [kicDesiredPosition.ccdOutputModel] ;
  end
  keplerId = [keplerId1(:) ; keplerId2(:)] ;
  row      = round([row1(:)      ; row2(:)]) ;
  col      = [col1(:)      ; col2(:)] ;
  out      = [out1(:)      ; out2(:)] ;
  col = round(convert_to_ccd_column(out,col,'one-based')) ;
  
% Now:  this has given a vector of pixel positions, but we want to include neighboring
% pixels as well, so that the mouse-over function isn't too fussy.  There is a rather
% complicated but effective way to do this:

% decide the range over which we want the mouseover to work, in total pixels

  nRowMouseover = 3 ; 
  nColMouseover = 3 ;
  
% expand the vectors of row, column, and kepler ID to be nID x nRowMouseover x
% nColMouseover
  
  nStars = length(keplerId) ;
  keplerId = repmat( reshape( keplerId,[1,1,nStars] ), [nRowMouseover,nColMouseover,1] ) ;
  row = repmat( reshape( row,[1,1,nStars] ), [nRowMouseover,nColMouseover,1] ) ;
  col = repmat( reshape( col,[1,1,nStars] ), [nRowMouseover,nColMouseover,1] ) ;
  
% construct an identically-shaped set of offsets in row and column

  [dRow,dCol] = meshgrid( [-floor(nRowMouseover/2):floor(nRowMouseover/2)], ...
                          [-floor(nColMouseover/2):floor(nColMouseover/2)] ) ;
  dRow = repmat( reshape( dRow, [nRowMouseover,nColMouseover,1] ), [1,1,nStars] ) ;
  dCol = repmat( reshape( dCol, [nRowMouseover,nColMouseover,1] ), [1,1,nStars] ) ;
  
% add the row and column offsets to the initial row and column matrices

  row = row + dRow ;
  col = col + dCol ;
  
% convert row, col, and keplerId back to vectors

  row = row(:) ;
  col = col(:) ;
  keplerId = keplerId(:) ;
  
% find the pixel values which are on the grid and keep them
  
  goodPixels = (row >= 1 & row <= size(keplerIdImage,1) & ...
                col >= 1 & col <= size(keplerIdImage,2)) ;
  imageIndex = sub2ind(size(keplerIdImage),row(goodPixels),col(goodPixels)) ;
  keplerIdImage(imageIndex) = keplerId(goodPixels) ;
  setappdata(mainHandle,'keplerIdImage',keplerIdImage) ;

% now that all of the application data has been updated, do the plot

  do_plot(mainHandle) ;
  
return

% end of replot_callback

%=========================================================================================

% function which performs the fit -- an fpgFitClass object is populated, and its
% do_fpg_fit method is invoked.

function do_fit_callback( handle, eventData )

% start by getting the main handle for the GUI

  mainHandle = get(handle,'parent') ;
  
% get the constraining star data; if there isn't any, or if there isn't enough, complain
% to the user and do nothing else

  kicDesiredPosition = getappdata(mainHandle,'kicDesiredPosition') ;
  if (length(kicDesiredPosition) < 2)
      beep ; pause(0.35) ; beep
      warning('quasar:doFitCallback:notEnoughConstraintPoints', ...
          'do_fit_callback:  not enough constraint stars specified') ;
      
  else % otherwise, we should attempt to do the fit!
  
%     start constructing the data structure which initializes the object

      fpgFitStruct.raDec2PixObject = getappdata(mainHandle,'raDec2PixObject') ;
      fpgFitStruct.mjd = getappdata(mainHandle,'mjd') ;
      fpgFitStruct.geometryParMap = zeros(126,1) ;
      ccdNumber = getappdata(mainHandle,'ccdNumber') ;
      angle1Index = ccdNumber * 3 ;
      fpgFitStruct.geometryParMap(angle1Index-2:angle1Index) = [1 ; 2 ; 3] ;
      fpgFitStruct.plateScaleParMap = 0 ;
      fpgFitStruct.cadenceRAMap = 0 ;
      fpgFitStruct.cadenceDecMap = 0 ;
      fpgFitStruct.cadenceRollMap = 0 ;
      fpgFitStruct.nConstraintPoints = 2*length(kicDesiredPosition) ;
      rowConstraints = [kicDesiredPosition.rowDesired] ;
      colConstraints = [kicDesiredPosition.columnDesired] ;
      fpgFitStruct.constraintPoints = [rowConstraints(:) ; colConstraints(:)] ;
      fpgFitStruct.constraintPointCovariance = ...
          0.25 * eye(fpgFitStruct.nConstraintPoints) ;
      gm = get(fpgFitStruct.raDec2PixObject,'geometryModel') ;
      fpgFitStruct.initialParValues = ...
          gm.constants(1).array(angle1Index-2:angle1Index) ;
      fpgFitStruct.initialParValues = fpgFitStruct.initialParValues(:) ;
      
%     need to get RA, dec and output for all the constraint stars      

      [RA, Dec] = get_kicDesiredPosition_ra_dec( kicDesiredPosition, mainHandle ) ;
      ccdOutput = [kicDesiredPosition.ccdOutputDesired] ;
      module = getappdata(mainHandle,'ccdModule') ;
      fpgFitStruct.raDecModOut(1).matrix = ...
          [RA(:) Dec(:) module*ones(length(kicDesiredPosition),1) ccdOutput(:)] ;
      fpgFitStruct.fitterOptions = kepler_set_soc('TolX',1e-8,'TolFun',2e-2,...
          'FunValCheck','Off','Display','Off') ;
      fpgFitStruct.pointingRefCadence = get_pointing(pointingClass(get( ...
          fpgFitStruct.raDec2PixObject,'pointingModel')),fpgFitStruct.mjd) ;
      fpgFitStruct.ccdsForPointingConstraint = [] ;
      fpgFitStruct.pincushionScaleFactor = 1 ;
      
%     instantiate the fit object and perform the fit

      fpgFitObject = fpgFitClass(fpgFitStruct) ;
      fpgFitObject = do_fpg_fit(fpgFitObject) ;
      
%     extract the updated geometry and put it into the GUI's appdata repository

      fpgFitObject = set_raDec2Pix_geometry( fpgFitObject, 1 ) ;
      setappdata(mainHandle,'fittedGeometry',get(get(fpgFitObject,'raDec2PixObject'), ...
          'geometryModel')) ;
      
%     put the fit object into the appdata repository as well

      setappdata(mainHandle,'fpgFitObject',fpgFitObject) ;
      
%     enable the fitted geometry

      childHandleStruct = getappdata(mainHandle,'childHandleStruct') ;
      set(childHandleStruct.fittedGeometryHandle,'enable','on') ;
      
  end % conditional on sufficient data being present
      
return

%=========================================================================================

% function which displays the fit 

function display_fit_callback( handle, eventData )

% get the main GUI handle

  mainHandle = get(handle,'parent') ;
  ccdNumber = getappdata(mainHandle,'ccdNumber') ;
  
% if the fit has been performed, continue to get the deltas, otherwise complain

  fpgFitObject = getappdata(mainHandle,'fpgFitObject') ;
  if ( ~isempty(fpgFitObject) )

      currentGeometry = getappdata(mainHandle,'currentGeometry') ;
      fittedGeometry = getappdata(mainHandle,'fittedGeometry') ;
      geometryChangeStruct = compute_changed_geometry( mainHandle ) ;
      display_geometry_fits( ccdNumber, currentGeometry, fittedGeometry, ...
          geometryChangeStruct )
      
  else % if no fit has been performed, complain
      
      beep ; pause(0.35) ; beep
      warning('quasar:displayFitCallback:noFitPerformed', ...
          'display_fit_callback: No fit has yet been performed') ;

  end
            
return

%=========================================================================================

% function which clears the fit constraints (aka "erases the blue stars")

function clear_constraints_callback( handle, eventData )

% get the main GUI handle

  mainHandle = get(handle,'parent') ;
  
% clear out the kicDesiredPosition structure

  setappdata(mainHandle,'kicDesiredPosition',[]) ;
  
% clear out the incomplete constraint point structure 

  setappdata(mainHandle,'incompleteConstraintPoint',[]) ;
  
% replot

  replot_callback(handle,[]) ;
  
return

%=========================================================================================

% function which handles the "Accept Fitted Geometry" button press

function accept_fit_callback( handle, eventData )

% get the main handle, and from it inspect the fitted geometry structure; if it's present,
% then we can set the status in the main GUI and resume execution; otherwise, raise a
% warning and do nothing

  mainHandle = get(handle,'parent') ;
  fittedGeometry = getappdata(mainHandle,'fittedGeometry') ;
  if (~isempty(fittedGeometry))
      setappdata(mainHandle,'fitStatus',2) ;
      uiresume ;
  else 
      beep ; pause(0.35) ; beep
      warning('quasar:acceptFitCallback:noFittedGeometryPresent', ...
          'accept_fit_callback: Cannot accept fitted geometry -- no fitted geometry present') ;
  end
  
return

%=========================================================================================

% function which handles the "Accept Current Geometry" button push

function accept_current_callback( handle, eventData )

% set the desired state for the fitStatus and resume execution

  mainHandle = get(handle,'parent') ;
  setappdata(mainHandle,'fitStatus',1) ;
  uiresume ;
  
return

%=========================================================================================

% function which handles the "Reject All Geometries" button push

function reject_all_callback( handle, eventData )

% set the desired state for the fitStatus and resume execution

  mainHandle = get(handle,'parent') ;
  setappdata(mainHandle,'fitStatus',0) ;
  uiresume ;
  
return

%=========================================================================================

% function which handles the close-request -- for the Quasar image fitter, this is the
% same as clicking "Reject All Geometries".

function close_request_callback( handle, eventData )

  mainHandle = get(handle,'parent') ;
  setappdata(mainHandle,'fitStatus',0) ;
  uiresume ;
  
return

%=========================================================================================

% function which handles mouse-over -- if a star is present, its information is displayed
% in the star information box.  Thanks to Hayley for figuring out a convenient way to do
% this

function move_mouse_callback( mainHandle, eventData )
    

% find the position of the cursor in the image

  cp = round(get(gca,'currentpoint')) ;
  currentRow = cp(1,2) ; currentCol = cp(1,1) ;
  
% find the star, if any, on the pixel of interest; don't forget that constraint point
% stars are stored as negative Kepler ID values, so keep both the image ID value and the
% abs of that value
  
  keplerIdImage = getappdata(mainHandle,'keplerIdImage') ;
  if (currentRow >=1 && currentRow <= size(keplerIdImage,1) && ...
      currentCol >=1 && currentCol <= size(keplerIdImage,2) )
      currentKeplerId = keplerIdImage(currentRow,currentCol) ;
  else
      currentKeplerId = 0 ;
  end
  currentKeplerIdAbs = abs(currentKeplerId) ;
  
% we need only to get data for the fields if the currentKeplerId value is nonzero

  if (currentKeplerId ~= 0)
      
%     get magnitude, RA, and Dec from the catalog

      kicData = getappdata(mainHandle,'kicData') ;
      keplerId = [kicData.keplerId] ;
      kicDataIndex = find(keplerId == currentKeplerIdAbs) ;
      RA = kicData(kicDataIndex).RA ;
      Dec = kicData(kicDataIndex).Dec ;
      keplerMag = kicData(kicDataIndex).keplerMag ;
      
%     get module from the application data
 
      module = getappdata(mainHandle,'ccdModule') ;
      
%     get row, col, and output from either the kicCurrentPosition or kicDesiredPosition
%     structs

      if ( currentKeplerId > 0 ) % kicCurrentPosition
          
          kicCurrentPosition = getappdata(mainHandle,'kicCurrentPosition') ;
          keplerId = [kicCurrentPosition.keplerId] ;
          positionIndex = find(currentKeplerId == keplerId) ;
          out = kicCurrentPosition(positionIndex).ccdOutput ;
          row = kicCurrentPosition(positionIndex).row ;
          col = kicCurrentPosition(positionIndex).column ;
          
      else % kicDesiredPosition
          
          kicDesiredPosition = getappdata(mainHandle,'kicDesiredPosition') ;
          keplerId = [kicDesiredPosition.keplerId] ;
          positionIndex = find(currentKeplerIdAbs == keplerId) ;
          out = kicDesiredPosition(positionIndex).ccdOutputModel ;
          row = kicDesiredPosition(positionIndex).rowModel ;
          col = kicDesiredPosition(positionIndex).columnModel ;
          
      end % conditional on sign of currentKeplerId
      
%     build strings with the correct values in them

      keplerIdString = num2str(currentKeplerIdAbs) ;
      keplerMagString = num2str(keplerMag) ;
      raString = num2str(RA) ;
      decString = num2str(Dec) ;
      
      modString = num2str(module) ;
      outString = num2str(out) ;
      rowString = num2str(row) ;
      colString = num2str(col) ;
      
  else % if there is no star on the pixel, set the strings to be blanks
      
      keplerIdString = '' ;
      keplerMagString = '' ;
      raString = '' ;
      decString = '' ;
      
      modString = '' ;
      outString = '' ;
      rowString = '' ;
      colString = '' ;
      
  end % conditional on nonzero value of currentKeplerId

% get the pixel information if the mouse is on the image 

  if (currentRow >=1 && currentRow <= size(keplerIdImage,1) && ...
      currentCol >=1 && currentCol <= size(keplerIdImage,2) )
      
      ccdNumber = getappdata(mainHandle,'ccdNumber') ;
      [out,col] = convert_from_ccd_column(ccdNumber,currentCol,'one-based') ;
      ccdImage = getappdata(mainHandle,'ccdImage') ;
      intensity = round(ccdImage(currentRow,currentCol)) ;

      modString2 = getappdata(mainHandle,'ccdModule') ;
      outString2 = num2str(out) ;
      rowString2 = num2str(currentRow) ;
      colString2 = num2str(col) ;
      intensityString = num2str(intensity) ;
      
  else
      
      modString2 = '' ;
      outString2 = '' ;
      rowString2 = '' ;
      colString2 = '' ;
      intensityString = '' ;
      
  end
        
% now:  set the strings into their appropriate slots in the display

  childHandleStruct = getappdata(mainHandle,'childHandleStruct') ;

  set(childHandleStruct.keplerIdValueHandle,'string',keplerIdString) ;
  set(childHandleStruct.raValueHandle,'string',raString) ;
  set(childHandleStruct.decValueHandle,'string',decString) ;
  set(childHandleStruct.magValueHandle,'string',keplerMagString) ;
  set(childHandleStruct.modValueHandle','string',modString) ;
  set(childHandleStruct.outValueHandle,'string',outString) ;
  set(childHandleStruct.rowValueHandle,'string',rowString) ;
  set(childHandleStruct.colValueHandle,'string',colString) ;
  
  set(childHandleStruct.pixelIntensityValueHandle,'string',intensityString) ;
  set(childHandleStruct.pixelModuleValueHandle,'string',modString2) ;
  set(childHandleStruct.pixelOutputValueHandle,'string',outString2) ;
  set(childHandleStruct.pixelRowValueHandle,'string',rowString2) ;
  set(childHandleStruct.pixelColValueHandle,'string',colString2) ;
  
return

%=========================================================================================

% function which handles the mouse clicks on the figure plot -- first click is to select a
% target star (green circle), second click establishes the desired pixel location of the
% star.

%function click_mouse_callback( mainHandle, eventData )
%
%return

function click_mouse_callback( mainHandle, eventData )

% find the position of the cursor in the image

  cp = round(get(gca,'currentpoint')) ;
  currentRow = cp(1,2) ; currentCol = cp(1,1) ;
  keplerIdImage = getappdata(mainHandle,'keplerIdImage') ;

% keep going only if we are on the image plot  
  
  if (currentRow >=1 && currentRow <= size(keplerIdImage,1) && ...
      currentCol >=1 && currentCol <= size(keplerIdImage,2) )
  
%     Are we on the first mouse click?  This is indicated by the presence or absence of a
%     struct in the incompleteConstraintPoint appdata slot

      incompleteConstraintPoint = getappdata(mainHandle,'incompleteConstraintPoint') ;
      
      if (isempty(incompleteConstraintPoint)) % first mouse click
          
%         is there a star where we clicked which is not already a constraint point?

          keplerId = keplerIdImage(currentRow,currentCol) ;
          if (keplerId > 0)
              
%             construct a constraint point structure and fill it in

              incompleteConstraintPoint = struct('keplerId', keplerId, ...
                  'rowDesired', [], 'columnDesired', [], 'ccdOutputDesired', [] ) ;

              incompleteConstraintPoint = fill_kicDesiredPosition_model_values( ...
                  incompleteConstraintPoint, mainHandle ) ;
              setappdata(mainHandle,'incompleteConstraintPoint',incompleteConstraintPoint) ;
              
%             plot the star image with a blue circle

              plot_kicDesiredPosition( incompleteConstraintPoint, true, false ) ;
              
          else % no star or already a constraint point
              
              beep ;
              pause(0.35) ;
              beep
              warning('quasar:clickMouseCallback:noSuitableConstraintStarPresent', ...
                'click_mouse_callback: No suitable constraint star present at mouse location') ;
            
          end % keplerId > 0 condition
          
      else % what do we do if it's the second mouse click?
          
%         get the incomplete constraint point data and fill it in with the current pixel
%         location as the desired position

          incompleteConstraintPoint = getappdata(mainHandle,'incompleteConstraintPoint') ;
          incompleteConstraintPoint.rowDesired = currentRow ;
          ccdNumber = getappdata(mainHandle,'ccdNumber') ;
          [o,c] = convert_from_ccd_column( ccdNumber, currentCol, 'one-based') ;
          incompleteConstraintPoint.columnDesired = c ;
          incompleteConstraintPoint.ccdOutputDesired = o ;
          
%         add it to the list of constraint points

          kicDesiredPosition = getappdata(mainHandle,'kicDesiredPosition') ;
          kicDesiredPosition = [kicDesiredPosition ; ...
              incompleteConstraintPoint] ;
          setappdata(mainHandle,'kicDesiredPosition',kicDesiredPosition) ;
          
%         clear out the existing incomplete constraint point from the figure

          setappdata(mainHandle,'incompleteConstraintPoint',[]) ;
          
%         plot the blue line and point

          plot_kicDesiredPosition( incompleteConstraintPoint, false, true ) ;
          
%         convert the keplerIdImage values to negative, indicating that this is a
%         constraint point now

          keplerIdImage = getappdata(mainHandle,'keplerIdImage') ;
          keplerId = incompleteConstraintPoint.keplerId ;
          keplerIdImage( keplerIdImage(:) == keplerId ) = ...
              -keplerIdImage( keplerIdImage(:) == keplerId ) ;
          setappdata(mainHandle,'keplerIdImage',keplerIdImage) ;
              
      end % which-mouse-click conditional
      
  end % within the plot range conditional 
              
return

