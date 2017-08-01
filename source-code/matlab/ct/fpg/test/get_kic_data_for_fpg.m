function starSkyCoordinates = get_kic_data_for_fpg( mod, out, mjd, magMin, magMax )
%
% get_kic_data_for_fpg -- perform KIC queries and format the data for FPG.
%
% starSkyCoordinates = get_kic_data_for_fpg( mod, out, mjd, magMin, magMax ) obtains the
%    set of stars which fall on the list of requested mod/outs on the requested mjd, and
%    fall within the requested magnitude range.  This data is reformatted for FPG and
%    returned in starSkyCoordinates.
%
% Version date:  2008-july-14.
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

% dimension the return structure

  nModOut = length(mod) ;
  starSkyCoordinates(nModOut).module = [] ;
  starSkyCoordinates(nModOut).output = [] ;
  starSkyCoordinates(nModOut).keplerId = [] ;
  starSkyCoordinates(nModOut).keplerMag = [] ;
  starSkyCoordinates(nModOut).ra = [] ;
  starSkyCoordinates(nModOut).dec = [] ;
  
% loop over mod/outs and perform the KIC query

  for iModOut = 1:nModOut
      
      kicsData = retrieve_kics( mod(iModOut), out(iModOut), mjd, magMin, magMax ) ;
      
%     loop over returned items and get their information out of the catalog

      starSkyCoordinates(iModOut).module = mod(iModOut) ;
      starSkyCoordinates(iModOut).output = out(iModOut) ;
      starSkyCoordinates(iModOut).keplerId = zeros(size(kicsData)) ;
      starSkyCoordinates(iModOut).keplerMag = zeros(size(kicsData)) ;
      starSkyCoordinates(iModOut).ra = zeros(size(kicsData)) ;
      starSkyCoordinates(iModOut).dec = zeros(size(kicsData)) ;
      
     for iStar = 1:length(kicsData)

         starSkyCoordinates(iModOut).keplerId(iStar) = kicsData(iStar).getKeplerId ;
         starSkyCoordinates(iModOut).keplerMag(iStar) = kicsData(iStar).getKeplerMag ;
         starSkyCoordinates(iModOut).ra(iStar) = kicsData(iStar).getRa ;
         starSkyCoordinates(iModOut).dec(iStar) = kicsData(iStar).getDec ;
         
     end
     
  end
  
% and that's it!

%
%
%
