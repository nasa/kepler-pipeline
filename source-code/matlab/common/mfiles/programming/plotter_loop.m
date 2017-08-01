function plotter_loop( loopCommand, nLoops )
%
% plotter_loop -- execute a user-specified MATLAB command in a loop, with a pop-up menu
% allowing stepping or jumping through the loop
%
% plotter_loop( loopCommand, nLoops ) will use the command line fragment in loop command
%    to iteratively execute a MATLAB command.  Usually this is done in the context of
%    plotting.  The plotting command must take an iteration number as its last argument,
%    and that argument must be omitted from the loopCommand string.  For example, to
%    iteratively execute the command
%
%       do_my_plot( struct1, struct2, struct3, iLoop ) ;
%
%    the correct syntax is as follows:
%
%       plotter_loop( 'do_my_plot( struct1, struct2, struct3, ', nLoops ) ;
%
%    where nLoops is the total number of iterations to be performed.  The plotter_loop
%    function will perform the iterations and also provides a pop-up menu:  the menu
%    allows the user to step forward, step back, jump to an arbitrary loop value, or exit.
%
% Version date:  2010-November-08.
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

  iLoop = 1 ;
  while iLoop > 0 && iLoop <= nLoops 
      
      thisCommand = [loopCommand,num2str(iLoop),');'] ;
      evalin('caller',thisCommand) ;
      action = menu( 'Choose an Action', 'Forward', 'Back', 'Jump', 'Exit' ) ;
      switch action
          case 1
              iLoop = iLoop + 1 ;
              continue
          case 2
              iLoop = iLoop - 1 ;
              continue
          case 3
              iLoop = input('Enter desired loop value: ') ;
              continue 
          case 4
              iLoop = nan ;
              continue 
      end
      
  end
  
return