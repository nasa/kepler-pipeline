function mjd = quasar_mjd_dialog( mjdDefault )
%
% mjd = quasar_mjd_dialog( mjdDefault) -- acquire an MJD via a modal dialog box,
% positioned based on the position and size of the parent GUI.
%
% Version date:  2009-February-15.
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
%=========================================================================================

% construct the dialog box

  mainHandle = figure( 'units','pixels', 'position',[500 500 250 150], ...
      'WindowStyle','modal', 'visible','off', 'resize','off', ...
      'numbertitle','off', 'name', 'Select MJD', 'CloseRequestFcn',@close_callback ) ;
  
% add a text string and the default MJD value (if left out, default to today's MJD)

  if (nargin == 0)
      mjdDefault = floor(datestr2mjd(local_time_to_utc(now))) ;
  end
  mjdTextHandle = uicontrol(mainHandle,'style','text', 'string','Enter the MJD:', ...
      'position',[75 120 100 20]) ;
  mjdValueHandle = uicontrol(mainHandle,'style','edit',...
      'string',num2str(mjdDefault), ...
      'position',[75 70 100 40], 'backgroundcolor','w') ;
  
% add the OK and Cancel buttons

  okButtonHandle = uicontrol(mainHandle, 'string','OK', 'callback',@ok_callback, ...
      'position',[20 20 100 35]) ;
  cancelButtonHandle = uicontrol(mainHandle, 'string','Cancel', ...
      'callback',@cancel_callback, ...
      'position',[130 20 100 35]) ;
  
% make the GUI visible and lock execution  
  
  set(mainHandle,'visible','on') ;
  uiwait(mainHandle) ;
  
% set the return value

  returnStatus = getappdata(mainHandle,'returnStatus') ;
  if (returnStatus)
      mjdString = get(mjdValueHandle,'string') ;
      mjd = str2num(mjdString) ;
  else
      mjd = mjdDefault ;
  end
  
% discard the window

  delete(mainHandle) ;
  
return  

%=========================================================================================
%
% C A L L B A C K S
%
%=========================================================================================

% handle the OK button press

function ok_callback( handle, eventData )

% set the return status in the main GUI to true

  setappdata(get(handle,'parent'),'returnStatus',true) ;
  
% resume execution

  uiresume
  
return

%

%=========================================================================================

% handle the cancel button press

function cancel_callback( handle, eventData )

% set the return status in the main GUI to false

  if (get(handle,'parent')~=0)
      handle = get(handle,'parent') ;
  end
  setappdata(handle,'returnStatus',false) ;
  
% resume execution

  uiresume
  
return

%

%=========================================================================================

% handle the close request

function close_callback( handle, eventData )

  cancel_callback( handle, eventData ) ;
  
return