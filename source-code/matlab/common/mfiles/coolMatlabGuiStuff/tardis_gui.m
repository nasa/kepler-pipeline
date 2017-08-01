function tardis_gui
%
% tardis_gui -- GUI which manages conversions between local time, UTC, DOY (both local and
% UTC), and MJD.
%
% Version date:  2009-March-10.
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
%    2009-July-17, PT:
%        adjust size of edit boxes for times in DD-MON-YYYY HH:MM:SS [Z] format -- the
%        boxes were adequately sized on Windoze, but somewhat too narrow on Linux.  Go
%        Figure.
%
%=========================================================================================

% start with the master GUI window -- doesn't have to be too big

  mainHandle = figure( 'units','pixels', 'position',[100 300 280 170], ...
      'numbertitle','off', 'name','TARDIS', 'resize','off', ...
       'integerhandle','off', 'menubar','none') ;
   
% put in uipanels for local, UTC, and MJD times

  localPanel = uipanel('parent',mainHandle, 'units','pixels', ...
      'position',[10 115 260 50], 'title','Local Time') ;
  utcPanel = uipanel('parent',mainHandle, 'units','pixels', ...
      'position',[10 60 260 50], 'title','UTC Time') ;
  mjdPanel = uipanel('parent',mainHandle, 'units','pixels', ...
      'position',[10 5 140 50], 'title','MJD') ;
  
% create the datestring and DOY edit boxes and fill them

  localTimestamp = uicontrol(mainHandle,'style', 'edit', ...
      'position', [20 125 155 20] , 'backgroundcolor', 'w', ...
      'callback',@set_local_time_callback);
  localDoyText = uicontrol(mainHandle, 'style','text', ...
      'string','DOY', 'position',[190 122 30 20]) ;
  localDoy = uicontrol(mainHandle,'style', 'edit', ...
      'position', [220 125 40 20] , 'backgroundcolor', 'w', ...
      'callback',@set_local_doy_callback);

  utcTimestamp = uicontrol(mainHandle,'style', 'edit', ...
      'position', [20 70 165 20] , 'backgroundcolor', 'w', ...
      'callback',@set_utc_callback);
  utcDoyText = uicontrol(mainHandle, 'style','text', ...
      'string','DOY', 'position',[190 67 30 20]) ;
  utcDoy = uicontrol(mainHandle,'style', 'edit', ...
      'position', [220 70 40 20] , 'backgroundcolor', 'w', ...
      'callback',@set_utc_doy_callback);

  
  mjdValue = uicontrol(mainHandle, 'style','edit', ...
      'position',[20 15 100 20], 'backgroundcolor','w', 'callback',@set_mjd_callback) ;
  
% add the button which resets to now

  nowButton = uicontrol(mainHandle, 'position',[170 5 100 43], ...
      'string','NOW!', 'fontweight','bold', 'callback', @now_button_callback) ;
  
% put the timestamp and DOY handles into a structure, and put that structure into appdata,
% so that it's easy to get at

  childHandleStruct.localTimestampHandle = localTimestamp ;
  childHandleStruct.localDoyHandle       = localDoy ;
  childHandleStruct.utcTimestampHandle   = utcTimestamp ;
  childHandleStruct.utcDoyHandle         = utcDoy ;
  childHandleStruct.mjdValueHandle       = mjdValue ;
  
  setappdata(mainHandle,'childHandleStruct',childHandleStruct) ;
  
% initialize the display to the current time, and while we are at it put the MJD into
% appdata

  now_button_callback( nowButton, [] ) ;
  
return
  
% and that's all there is to it!

%
%
%

%=========================================================================================

% subfunction which recalculates and redisplays all time values from the current value of
% the MJD stored in appdata

function recalc_and_redisplay( mainHandle )

% obtain the MJD and the display window handles

  mjd = getappdata(mainHandle,'mjd') ;
  childHandleStruct = getappdata(mainHandle,'childHandleStruct') ;
  
% redisplay the local time and DOY

  set(childHandleStruct.localTimestampHandle, 'string', ...
      mjd_to_local_time(mjd)) ;
  set(childHandleStruct.localDoyHandle, 'string', ...
      num2str( floor(datestr2doy(mjd_to_local_time(mjd))), '%03d') ) ;
  
% redisplay the UTC time and DOY

  set(childHandleStruct.utcTimestampHandle, 'string', ...
      mjd_to_utc(mjd)) ;
  set(childHandleStruct.utcDoyHandle, 'string', ...
      num2str( floor(datestr2doy(mjd_to_utc(mjd))), '%03d') ) ;

% redisplay the MJD

  set(childHandleStruct.mjdValueHandle, 'string', ...
      num2str(mjd,'%10.5f')) ;
  
return

% and that's it!

%
%
%

%=========================================================================================
%
% C A L L B A C K S
%
%=========================================================================================

% subfunction which manages the NOW! button callback

function now_button_callback( handle, eventData )

% get to the main handle from the button handle

  mainHandle = get(handle,'parent') ;
  
% get the current time in MJD format, and put into the mainHandle's appdata 

  mjd = datestr2mjd(local_time_to_utc(now)) ;
  setappdata(mainHandle,'mjd',mjd) ;
  
% call the redisplay function

  recalc_and_redisplay( mainHandle ) ;
  
return
  
% end of now_button_callback function

%=========================================================================================

% subfunction which handles the MJD edit box callback

function set_mjd_callback( handle, eventData )

  mainHandle = get(handle,'parent') ;

% extract the value and convert to a number, if possible

  mjdFromUser = str2double(get(handle,'string')) ;
  if (~isempty(mjdFromUser) && ~isnan(mjdFromUser))
      setappdata(mainHandle,'mjd',mjdFromUser) ;
  end
  
% update the displays

  recalc_and_redisplay(mainHandle) ;
  
return
  
% end of set_mjd_callback function

%=========================================================================================

% subfunction which handles a new local-time datestring entry

function set_local_time_callback( handle, eventData )

  mainHandle = get(handle,'parent') ;

% convert the string to an MJD, if possible

  try
      mjd = datestr2mjd(local_time_to_utc(get(handle,'string'))) ;
  catch
      mjd = getappdata(mainHandle,'mjd') ;
  end

% put the new MJD into use and update the display

  setappdata(mainHandle,'mjd',mjd) ;
  recalc_and_redisplay(mainHandle) ;
  
return
  
% end of set_local_time_callback function

%=========================================================================================

% subfunction which converts a local-time DOY into an MJD and resets the displays -- note
% that the DOY can include fractions, but must be a valid DOY.  The current year of the
% currently-loaded MJD is assumed.

function set_local_doy_callback( handle, eventData )

  mainHandle = get(handle,'parent') ;
  mjd = getappdata(mainHandle,'mjd') ;
  localString = mjd_to_local_time(mjd) ; 
  year = str2double(localString(8:11)) ;
  
% convert the user-specified DOY to a number

  doy = str2double(get(handle,'string')) ;
  
% convert the new DOY and the old year to a new date string; if the value of the DOY
% string was not convertible to a number, datestr will error, so we can trap that here
% (since doy will contain NaN); if it does not error, check that the year has not lapped
% (indicated doy value < 1 or > max allowed for this year); if neither error condition has
% occurred, compute the new MJD

  try
      newLocalTimestamp = datestr(doy+datenum(year,0,0),0) ;
      newYear = str2double(newLocalTimestamp(8:11)) ;
      if (year == newYear)
          mjd = datestr2mjd(local_time_to_utc(newLocalTimestamp)) ;
      end
  catch
  end
  
% store the new (or old) MJD in the appdata, and redisplay dates

  setappdata(mainHandle,'mjd',mjd) ;
  recalc_and_redisplay(mainHandle) ;
  
return 

% end of set_local_doy_callback function

%=========================================================================================

% subfunction which handles a new UTC datestring entry

function set_utc_callback( handle, eventData )

  mainHandle = get(handle,'parent') ;

% convert the string to an MJD, if possible

  try
      mjd = datestr2mjd(get(handle,'string')) ;
  catch
      mjd = getappdata(mainHandle,'mjd') ;
  end

% put the new MJD into use and update the display

  setappdata(mainHandle,'mjd',mjd) ;
  recalc_and_redisplay(mainHandle) ;
  
return
  
% end of set_utc_callback function

%=========================================================================================

% subfunction which converts a UTC DOY into an MJD and resets the displays -- note
% that the DOY can include fractions, but must be a valid DOY.  The current year of the
% currently-loaded MJD is assumed.

function set_utc_doy_callback( handle, eventData )

  mainHandle = get(handle,'parent') ;
  mjd = getappdata(mainHandle,'mjd') ;
  utcString = mjd_to_utc(mjd) ; 
  year = str2double(utcString(8:11)) ;
  
% convert the user-specified DOY to a number

  doy = str2double(get(handle,'string')) ;
  
% convert the new DOY and the old year to a new date string; if the value of the DOY
% string was not convertible to a number, datestr will error, so we can trap that here
% (since doy will contain NaN); if it does not error, check that the year has not lapped
% (indicated doy value < 1 or > max allowed for this year); if neither error condition has
% occurred, compute the new MJD

  try
      newUtcTimestamp = datestr(doy+datenum(year,0,0),0) ;
      newYear = str2double(newUtcTimestamp(8:11)) ;
      if (year == newYear)
          mjd = datestr2mjd(newUtcTimestamp) ;
      end
  catch
  end
  
% store the new (or old) MJD in the appdata, and redisplay dates

  setappdata(mainHandle,'mjd',mjd) ;
  recalc_and_redisplay(mainHandle) ;
  
return 

% end of set_utc_doy_callback function

