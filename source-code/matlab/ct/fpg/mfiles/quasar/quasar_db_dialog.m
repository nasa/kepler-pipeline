function selection = quasar_db_dialog( title, selectionDefault )
%
% selection = quasar_db_dialog( title, selectionDefault ) -- select either live (0) or
% pre-staged (1) catalor or raDec2PixModel for Quasar use.  If the user selects cancel or
% closes the dialog box without making a selection, -1 is returned.
%
% Version date:  2009-February-17.
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
%    2009-February-17, PT:
%        add cancel -> -1 capability.
%
%=========================================================================================

% construct the dialog box

  mainHandle = figure( 'units','pixels', 'position',[500 500 280 150], ...
      'WindowStyle','modal', 'visible','off', 'resize','off', ...
      'numbertitle','off', 'name', title, ...
      'CloseRequestFcn',@close_callback ...
      ) ;
  
% constant definition

  catalogSelectionPreStaged = 1 ;
  catalogSelectionLive = 0 ;
  
  if (nargin==1)
      selectionDefault = catalogSelectionLive ;
  end

% define the radio buttons for the two options

  catalogHandle = uibuttongroup( 'parent', mainHandle, 'units','pixels', ...
      'position',[65 65 150 75] ) ;
  liveHandle = uicontrol( 'parent',catalogHandle, 'style','radio', ...
      'string','Database', 'pos', [20 45 100 20] ) ;
  preStagedHandle = uicontrol( 'parent',catalogHandle, 'style','radio', ...
      'string','Pre-Staged', 'pos', [20 15 100 20] ) ;
  if ( selectionDefault == catalogSelectionPreStaged)
      set(catalogHandle,'SelectedObject', preStagedHandle) ;
  else
      set(catalogHandle,'SelectedObject', liveHandle) ;
  end
  
% add the OK and Cancel buttons

  okButtonHandle = uicontrol(mainHandle, 'string','OK', 'callback',@ok_callback, ...
      'position',[20 20 100 35]) ;
  cancelButtonHandle = uicontrol(mainHandle, 'string','Cancel', ...
      'callback',@cancel_callback, ...
      'position',[160 20 100 35]) ;
 
% make the GUI visible and make it wait for the user  
  
  set(mainHandle, 'visible','on') ;
  uiwait(mainHandle) ;
  
% at this point, the user is done.  If the user clicked cancel or closed the window,
% indicate that to the user

  if (getappdata(mainHandle,'returnStatus')==false)
      selection = -1;
      
% otherwise, see which button is set

  else
      
      selectedButton = get(catalogHandle,'SelectedObject') ;
      if ( selectedButton == liveHandle )
          selection = catalogSelectionLive ;
      else
          selection = catalogSelectionPreStaged ;
      end
      
  end

% delete the GUI  
  
  delete(mainHandle) ;

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