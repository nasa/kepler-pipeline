function [mjd, ra, dec, roll, filename] = compute_pointing_model_from_attitude_history( ...
    attitudeHistoryFilename, raDec2PixModel, mjdTimestep, finalMjd, dMjd  )
%
% compute_pointing_model_from_attitude_history -- generate a pointing model using a file
% of historical attitude information
%
% [mjd, ra, dec, roll] = compute_pointing_model_from_attitude_history( attitudeHistoryFilename, 
%    raDec2PixModel, mjdTimestep, finalMjd, dMjd ) returns the historical and future
%    spacecraft attitude based on a sparse set of known attitudes which are read from the
%    file specified by attitudeHistoryFilename.  All other arguments are optional, and are
%    defined as follows:
%
%    attitudeHistoryFilename:  name of a file containing a list of MJDs, RAs, Decs, and
%       Rolls.  Attitudes can be apparent attitudes (indicated by the keyword "apparent"
%       or the keyword "optical" following the numeric values), or intertial attitudes
%       (indicated by the keyword "inertial" or the keyword "absolute" following the
%       numeric values).
%    raDec2PixModel:  an instantiation struct for an raDec2PixClass object.  Default is to
%       retrieve the current model from the datastore.
%    mjdTimestep:  desired interval for computing the pointing model.  Default value is
%       0.5 days.
%    finalMjd:  end-date for calculation.  Default value is 58000, which is September 3,
%       2017.
%    dMjd:  time interval between the last calculation from one historical attitude to the
%       start of the next attitude.  Default value is 1e-6 days.
%
% The compute_pointing_model_from_attitude_history computes the pointing as a number of
%    segments, each of which starts at a value and a time specified by a line in the
%    attitude history, and ends at a time dMjd prior to the next entry in the history, or
%    at the finalMjd for the last segment.  These segments are concatenated together and
%    returned.
%
% [..., filename] = compute_pointing_model_from_attitude_history( ... ) saves the computed
%    pointing to a filename which uses the format specified in the SO-SOC ICD (KADN 26176)
%    and returns the filename along with the RA, Dec and Roll.
%
% Version date:  2009-April-24.
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

% Start by managing the optional inputs

  if (nargin < 2) || isempty(raDec2PixModel)
      raDec2PixModel = retrieve_ra_dec_2_pix_model() ;
  end
  if (nargin < 3) || isempty(mjdTimestep) 
      mjdTimestep = 0.5 ;
  end
  if (nargin < 4) || isempty(finalMjd)
      finalMjd = 58000 ;
  end
  if (nargin < 5) || isempty(dMjd) 
      dMjd = 1e-6 ;
  end
  
% parse the attitude history file and return an attitude history struct

  attitudeHistoryStruct = parse_attitude_history( attitudeHistoryFilename ) ;
  nHistory = length(attitudeHistoryStruct) ;
  
% if the finalMjd is prior to the last MJD in the history struct, issue a warning

  if ( finalMjd < attitudeHistoryStruct(nHistory).mjd )
      warning('matlab:computePointingModelFromAttitudeHistory:finalMjdTooEarly', ...
          'compute_pointing_model_from_attitude_history:  finalMjd is before last attitude in file') ;
  end
  
% prepare outputs

  ra = [] ; dec = [] ; roll = [] ; mjd = [] ;
  
% construct an raDec2PixClass object (needed for use if some of the pointings are
% absolute)

  raDec2PixObject = raDec2PixClass( raDec2PixModel, 'one-based' ) ;
  
% loop over attitude segments

  for iHistory = 1:nHistory
      
%     if the pointing is absolute, convert to apparent, since the underlying
%     compute_pointing_model function expects that

      mjd0 = attitudeHistoryStruct(iHistory).mjd ;
      if (iHistory == nHistory)
          mjd1 = finalMjd ;
      else
          mjd1 = attitudeHistoryStruct(iHistory+1).mjd - dMjd ;
      end
      if (attitudeHistoryStruct(iHistory).isAbsolutePointing)
          [ra0, dec0] = unaberrate_ra_dec( raDec2PixObject, ...
              attitudeHistoryStruct(iHistory).ra, ...
              attitudeHistoryStruct(iHistory).dec, ...
              mjd0 + raDec2PixModel.mjdOffset ) ;
      else
          ra0 = attitudeHistoryStruct(iHistory).ra ;
          dec0 = attitudeHistoryStruct(iHistory).dec ;
      end
      roll0 = attitudeHistoryStruct(iHistory).roll ;
      
%     generate the vector of MJDs

      mjdVector = mjd0:mjdTimestep:mjd1 ;
      if (mjdVector(end) < mjd1)
          mjdVector = [mjdVector mjd1] ;
      end
      mjdVector = mjdVector(:) ;
      
%     compute the pointings in this segment
      
      [raVector, decVector, rollVector] = compute_pointing_model( raDec2PixModel, ...
          mjdVector, [ra0 ; dec0 ; roll0] ) ;
      
%     add the current results to the overall pointing information

      ra   = [ra   ; raVector(:)] ;
      dec  = [dec  ; decVector(:)] ;
      roll = [roll ; rollVector(:)] ;
      mjd  = [mjd  ; mjdVector(:)] ;
      
  end % loop over history values
  
% if file output was requested, perform that now

  if (nargout == 5)
      filename = write_pointing_model_file( mjd, ra, dec, roll ) ;
  end
  
return
  
% and that's it!

%
%
%

%=========================================================================================

% subfunction to parse the attitude history file

function attitudeHistoryStruct = parse_attitude_history( attitudeHistoryFilename )

% parse the file -- percent-delimited comments are allowed, including inline

  attitudeValues = load(attitudeHistoryFilename) ;
  
% if the MJDs are not in order, error out

  mjdList = attitudeValues(:,1) ;
  if ( ~issorted(mjdList) )
      error('matlab:computePointingModelFromAttitudeHistory:attitudesNotInTimeOrder', ...
          'compute_pointing_model_from_attitude_history:  attitudes in history file not time-ordered') ;
  end
  
% convert the values to a struct

  attitudeValues = num2cell(attitudeValues) ;
  attitudeHistoryStruct = cell2struct( attitudeValues, ...
      {'mjd', 'ra', 'dec', 'roll', 'isAbsolutePointing'}, 2 ) ; 
    
return

% and that's it!

%
%
%

%=========================================================================================
