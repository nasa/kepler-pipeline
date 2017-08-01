function [mjd,vtcToMjdModel] = vtc_to_mjd( vtc, vtcToMjdModel )
%
% vtc_to_mjd -- convert from Vehicle Time Code (VTC) to Modified Julian Date (MJD)
%
% mjd = vtc_to_mjd( vtc ) converts a vector of Kepler vehicle time codes to a vector of
%    modified Julian dates using the appropriate Java method.  Datastore access is
%    required for this format.
%
% [mjd,vtcToMjdModel] = vtc_to_mjd( vtc ) returns the MJDs plus a vector of data
%    structures which contain the constants used for the conversion calculation.  The
%    structure vector will have the same length as the vtc and mjd vectors.
%
% mjd = vtc_to_mjd( vtc, vtcToMjdModel ) uses a user-supplied structure to replace the
%    coefficients obtained from the datastore; in this mode, no datastore access is
%    required.  The argument vtcToMjdModel must be either a scalar structure or a
%    structure vector with the same length as vector vtc.
%
% Version date:  2008-November-12.
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

% we definitely need the SclkCrud Java class for this purpose, so import it now

  import gov.nasa.kepler.hibernate.dr.SclkCrud ;
  sclkObject = SclkCrud() ;

% argument checks -- is vtc a vector?

  if (~isvector(vtc))
      error('common:vtcToMjd:vtcNotVector', ...
          'vtc_to_mjd:  vtc is not a vector') ;
  end

% argument checks -- are there 2 RHS arguments, or just one?  If there are 2, are the
% dimensions etc correct?

  if (nargin == 2)
      
      if ~isstruct(vtcToMjdModel)
          error('common:vtcToMjd:vtcToMjdModelInvalid', ...
              'vtc_to_mjd:  vtcToMjdModel is not a struct') ;
      end
      if isscalar(vtcToMjdModel)
          vtcToMjdModel = repmat(vtcToMjdModel,size(vtc)) ;
      end
      if ( ~isvector(vtcToMjdModel) || length(vtcToMjdModel) ~= length(vtc) )
          error('common:vtcToMjd:argumentDimensionMismatch', ...
              'vtc_to_mjd:  vtcToMjdModel must be a scalar or a vector equal to vtc in length') ;
      end
      if (~isfield(vtcToMjdModel,'secondsSinceEpoch') || ...
          ~isfield(vtcToMjdModel,'clockRate')         || ...
          ~isfield(vtcToMjdModel,'vtcEventTime')      || ...
          ~isfield(vtcToMjdModel,'j2000mjd')                 )
          error('common:vtcToMjd:vtcToMjdModelFieldsInvalid', ...
              'vtc_to_mjd: vtcToMjdModel has invalid field(s)') ;
      end
      
  else % no model, so get the model for each value in vtc
      
      vtcToMjdModel = get_vtc_to_mjd_model( vtc, sclkObject ) ;
      
  end
  
% allocate the return vector

  mjd = zeros(size(vtc)) ;
  
% loop over vtc values and compute the mjd for each one, using the correct model

  for iVtc = 1:length(vtc)
      
      mjd(iVtc) = sclkObject.convertVtcToMjd( vtc(iVtc), ...
          vtcToMjdModel(iVtc).secondsSinceEpoch, ...
          vtcToMjdModel(iVtc).clockRate, ...
          vtcToMjdModel(iVtc).vtcEventTime, ...
          vtcToMjdModel(iVtc).j2000mjd ) ;
      
  end
  
return

% and that's it!

%
%
%

%=========================================================================================

% function which performs database accesses to fill in the vtcToMjdModel structure vector
% for each value of vtc

function vtcToMjdModel = get_vtc_to_mjd_model( vtc, sclkObject )

% import the database-accessing methods needed for this process

  import gov.nasa.kepler.systest.sbt.SandboxTools ;
  import gov.nasa.kepler.common.FcConstants ;
  
% build an initial empty structure with the correct fields

  vtcToMjdModelTemplate = struct('secondsSinceEpoch', 0, ...
                                 'clockRate', 1, ...
                                 'vtcEventTime', 0, ...
                                 'j2000mjd', 0 ) ;
  vtcToMjdModel = repmat(vtcToMjdModelTemplate, size(vtc)) ;
  
% loop over vtc values and fill in the correct values for each member of the struct array

  for iVtc = 1:length(vtc)
      
      sclkCoeffsObject = sclkObject.retrieveSclkCoefficients( vtc(iVtc) ) ;
      vtcToMjdModel(iVtc).secondsSinceEpoch = sclkCoeffsObject.getSecondsSinceEpoch() ;
      vtcToMjdModel(iVtc).clockRate = sclkCoeffsObject.getClockRate() ;
      vtcToMjdModel(iVtc).vtcEventTime = sclkCoeffsObject.getVtcEventTime() ;
      vtcToMjdModel(iVtc).j2000mjd = FcConstants.J2000_MJD ;
      
  end
  
return  
  
% and that's it!

%
%
%
