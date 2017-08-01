function varargout = get_physical_constants_mks( constantName )
%
% get_physical_constants_mks -- retrieve physical constants in MKS units.
%
% constantValue = get_physical_constants_mks( constantName ) returns the MKS value of the
%    requested physical constant.  To see a list of valid constantName values, use
%    get_physical_constants_mks('?') or get_physical_constants('help').
%
% constant_value = get_physical_constants_mks('*') or get_physical_constants_mks with no
%    argument returns a struct which contains values for all the defined MKS constants.
%
% Version date:  2009-April-29.
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
%    2009-April-29, PT:
%        add astronomicalUnit, plus value from wikipedia.
%
%=========================================================================================

% define the struct of physical constants:

  physicalConstantsStruct = struct( ...
        'gravitationalConstant',   6.67428e-11, ...
      'stefanBoltzmannConstant',   5.6704e-8, ...
                 'speedOfLight',   299792458, ...
                    'solarMass',   1.98892e30, ...
                    'earthMass',   5.9742e24, ...
                  'jupiterMass',   1.8986e27, ...
             'astronomicalUnit',   1.496e11, ...
                  'solarRadius',   6.960e8, ...
                  'earthRadius',   6378137, ...
                'jupiterRadius',   69911000 ...
      ) ;
  constantNamelist = fieldnames(physicalConstantsStruct) ;
  
% handle various input cases -- basically, they all boil down to help, or get the struct,
% or get one value out of the struct

  if ( ~exist('constantName', 'var') || isempty(constantName) )
      constantName = '*' ;
  end
  
  switch lower(constantName)
      
      case { '*' }
          varargout{1} = physicalConstantsStruct ;
          
      case{ '?', 'help' }
          disp('get_physical_constants_mks:  defined constants')
          for iConstant = 1:length(constantNamelist)
              disp(['    ',constantNamelist{iConstant}]) ;
          end
          
      otherwise % must be a specific constant is desired
          
          constantNameMatch = strcmp( constantName, constantNamelist ) ;
          if ( sum(constantNameMatch) ~= 0 )
              constantIndex = find(constantNameMatch) ;
              varargout{1} = physicalConstantsStruct.(constantNamelist{constantIndex}) ;
          else
              error( 'matlab:common:getPhysicalConstantsMks:undefinedConstant', ...
                  'get_physical_constants_mks:  undefined constant requested' ) ;
          end
          
  end % switch statement
  
return

% and that's it!

%
%
%
