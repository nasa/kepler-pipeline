function [mod out row col] = compute_position_stars_of_concern( starDataFile, ...
    raDec2PixModel, mjd, outputTableFile )
%
% [mod out row col] = compute_position_stars_of_concern( starDataFile, raDec2PixModel,
%    mjd, outputTableFile ) -- load the positions of "stars of concern" from a data file,
%    compute their mod/out/row/column ("MORC" coordinates), and return them and save to a
%    file.  If any argument is missing or empty, it will be appropriately obtained.
%
% Version date:  2009-April-03.
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

  row = [] ; col = [] ; out = [] ; mod = [] ;
  
% identify missing or blank arguments

  if (nargin < 4 || isempty(outputTableFile))
      outputTableFileEmpty = true ; 
  else
      outputTableFileEmpty = false ;
  end
  if (nargin < 3 || isempty(mjd))
      mjdEmpty = true ; 
  else
      mjdEmpty = false ;
  end
  if (nargin < 2 || isempty(raDec2PixModel))
      raDec2PixModelEmpty = true ; 
  else
      raDec2PixModelEmpty = false ;
  end
  if (nargin < 1 || isempty(starDataFile))
      starDataFileEmpty = true ; 
  else
      starDataFileEmpty = false ;
  end
  
% if the star data file is empty, get it from the user via uigetfile

  if (starDataFileEmpty)
      [starDataFilename, starDataFilePath] = uigetfile('*.txt','Select Star Data File') ;
      if ( isnumeric(starDataFilename) && starDataFilename == 0 ) 
          return ; 
      end
      starDataFile = fullfile(starDataFilePath,starDataFilename) ;
  end
  
% read the star data file via load operation -- requires that the first line in the file
% have the Matlab comment indicator (% sign) if it is a header

  starData = load(starDataFile) ;
  
% extract the RA, Dec, Kepmag, and KepID from the data.  Note that, regardless of what the
% comment says, RA is in hours, not degrees

  raHours    = starData(:,1) ;
  decDegrees = starData(:,2) ;
  keplerMag  = starData(:,3) ;
  keplerId   = starData(:,4) ;
  
% if there's no MJD, use $NOW as the timestamp 

  if (mjdEmpty)
      mjd = datestr2mjd(local_time_to_utc(now)) ;
  end
  
% if there's no raDec2PixModel, retrieve it

  if (raDec2PixModelEmpty)
      raDec2PixModel = retrieve_ra_dec_2_pix_model() ;
  end
  
% instantiate the raDec2PixClass object

  raDec2PixObject = raDec2PixClass(raDec2PixModel,'zero-based') ;
  
% Compute the pixel coordinates of each star of concern

  [mod, out, row, col] = ra_dec_2_pix( raDec2PixObject, raHours*15, decDegrees, mjd ) ;
  
% write the table -- if no output file has been selected, select one now

  if (outputTableFileEmpty)
      [outputTableFilename, outputTableFilePath] = uiputfile('*.txt', ...
          'Select Output Table File') ;
      if ( isnumeric(outputTableFilename) && outputTableFilename == 0 ) 
          return ; 
      end
      outputTableFile = fullfile(outputTableFilePath,outputTableFilename) ;
  end
  
% write the table out

  fileId = fopen(outputTableFile,'wt') ;
  fprintf(fileId,'%%   RA hrs   Dec deg   Kepmag    Kep_ID   chn    row       coln\n') ;
  for iStar = 1:length(raHours)
      fprintf(fileId,'%f  %f  %f  %8d  %02d  %8.3f  %8.3f \n', ...
          raHours(iStar), decDegrees(iStar), keplerMag(iStar), keplerId(iStar), ...
          convert_from_module_output(mod(iStar), out(iStar)), row(iStar), col(iStar) ) ;
  end
  fclose(fileId) ;
  
return
  