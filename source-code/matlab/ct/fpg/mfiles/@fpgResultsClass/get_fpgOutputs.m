function fpgOutputs = get_fpgOutputs( fpgResultsObject, mjdLongCadence, reportFileName )
%
% get_fpgOutputs -- generate the data structure which FPG provides as output to the
% pipeline during operation in support of PRF.
%
% fpgOutputs = get_fpgOutputs( fpgResultsObject, mjdLongCadence, reportFileName ) 
%  generates the outputs which are required from FPG during operation in support of PRF.
%  As defined by the PRF SDD, the fields of fpgOutputs are:
%
%    geometryBlobFileName:  string, name of the local file containing the geometry model
%       converted to a blob.
%    reportFileName:  string, name of the local file containing the FPG fit report.
%    fpgImportFileName:  string, name of the local file containing the geometry model as a
%       flat text file, suitable for import into FC.
%    resultBlobFileName:  string, name of the local file containing the fpgResultsObject
%       converted to a struct and then to a blob.
%    spacecraftAttitudeStruct:  structure containing the fitted spacecraft attitude for
%       each cadence.
%
% The spacecraftAttitudeStruct is a structure with the following fields:
%
%     ra:  Right ascension of the spacecraft in degrees.
%     dec:  Declination of the spacecraft in degrees.
%     roll:  roll angle of the spacecraft in degrees.
%
% Note that right ascension is in degrees, not hours.  Note further that the zero of roll
%  is the nominal rotation of the spacecraft, which is rotated 13 degrees wrt the axes
%  defined by the local RA and Dec at the boresight.
%
% The ra, dec, and roll fields all have the following sub-fields:
%
%     values:  vector of data values for each cadence.
%     uncertainties:  vector of uncertainties of the data values for each cadence.
%     gapIndices:  vector of gap indicators for each cadence, with gapIndices(i) == true
%         indicating that the cadence is gapped, false indicating good data.
%
% Version date:  2008-October-31.
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

% Modficiation History:
%
%     2008-October-31, PT:
%         delete redundant assignment of reportFileName to fpgOutputs.
%     2008-October-13, PT:
%         add fpgImportFileName and resultBlobFileName to returned struct.  
%     2008-September-22, PT:
%         return geometryBlobFileName as filename.ext, not absolute.
%     2008-September-07, PT:
%         add reportFileName field to outputs for pipeline.  Eliminate obsolete
%         requirement for the gapIndicators to be 1 x 0 rather than empty.  Change method
%         for saving geometry model blob.
%     2008-August-04, PT:
%         put the returned attitudes into the same order in which they were passed by the
%         caller.
%
%=========================================================================================


%=========================================================================================
%
% Geometry Model
%
%=========================================================================================

% Set the fitted geometry model into the raDec2PixObject in the fpgResultsObject

  fpgResultsObject = set_raDec2Pix_geometry( fpgResultsObject, 1 ) ;
  raDec2PixObject = get(fpgResultsObject,'raDec2PixObject') ;
  
% extract the geometry model and save to a blob

  geometryModel = get(raDec2PixObject,'geometryModel') ;
  
  localDir = pwd ; 
  fileTimestamp = datestr(now,30) ;
  fileName = ['geometryModelBlob_fpgOutput_',fileTimestamp,'.mat'] ;
  struct_to_blob(geometryModel,fileName) ;
%  geometryBlobFileName = fullfile(localDir,fileName) ;
  geometryBlobFileName = fileName ;

%=========================================================================================
%
% Attitude Solution
%
%=========================================================================================
  
% Attitude solution:  get the attitude being used as the nominal attitude of the
% spacecraft on the reference cadence

  pointingRefCadence = get(fpgResultsObject,'pointingRefCadence') ;
  
  raRefCadence = pointingRefCadence(1) ;
  decRefCadence = pointingRefCadence(2) ;
  rollRefCadence = pointingRefCadence(3) ;
  
% get the maps which tell which parameter in the fit corresponds to which pointing
% parameter on which cadence

  cadenceRAMap = get( fpgResultsObject,'cadenceRAMap') ;
  cadenceDecMap = get( fpgResultsObject,'cadenceDecMap') ;
  cadenceRollMap = get( fpgResultsObject,'cadenceRollMap') ;
  mjd = get(fpgResultsObject,'mjd') ;
  
% get the fit parameters and the uncertainties

  finalParValues = get( fpgResultsObject, 'finalParValues' ) ;
  parValueCovariance = get( fpgResultsObject, 'parValueCovariance' ) ;
  sigma = sqrt(diag(parValueCovariance)) ;
  
% construct the vectors for return -- note that if any cadences were left out of the fit,
% they don't appear in the fpgResultsClass object at all, so use the mjdLongCadence vector
% passed by the caller

  raValues = zeros(size(mjdLongCadence)) ;
  decValues = zeros(size(mjdLongCadence)) ;
  rollValues = zeros(size(mjdLongCadence)) ;
  raUncertainties = zeros(size(mjdLongCadence)) ;
  decUncertainties = zeros(size(mjdLongCadence)) ;
  rollUncertainties = zeros(size(mjdLongCadence)) ;
  
% put the fitted pointings and their uncertainties in the correct slots in the data
% vectors.  This is terribly inelegant and brute force, but it works so I'm gonna stick
% with it:

  for iCadence = 1:length(mjdLongCadence)
      
%     see whether the current cadence is one that was preserved in the fit, and one which
%     got its pointing fitted
      
      mjdIndex = find(mjd==mjdLongCadence(iCadence)) ;
      if ( ~isempty(mjdIndex) && ~isempty(cadenceRAMap) && ...
              cadenceRAMap(mjdIndex)~=0 )
          
%         if so, put the fitted values into appropriate slots in the return vectors
          
          raValues(iCadence) = finalParValues(cadenceRAMap(mjdIndex)) ;
          decValues(iCadence) = finalParValues(cadenceDecMap(mjdIndex)) ;
          rollValues(iCadence) = finalParValues(cadenceRollMap(mjdIndex)) ;
          raUncertainties(iCadence) = sigma(cadenceRAMap(mjdIndex)) ;
          decUncertainties(iCadence) = sigma(cadenceDecMap(mjdIndex)) ;
          rollUncertainties(iCadence) = sigma(cadenceRollMap(mjdIndex)) ;
      end
  end
  
% detect gapped cadences -- these will be indicated by zero uncertainty values

  gapIndices = find(raUncertainties == 0) ;
  gapIndices = gapIndices(:) ;
  
% Note that if the caller did not fit the pointing of the reference cadence, then that
% does not count as a gap!  But first we have to find the re-sorted location of the
% reference cadence.  Note that the sign that the reference cadence pointing was fitted is
% that the ccdsForPointingConstraint member of fpgResultsObject isn't empty.

  refCadence = find(mjdLongCadence == mjd(1)) ;
  refCadenceGapIndex = find(gapIndices == refCadence) ;
  ccdsForPointingConstraint = get( fpgResultsObject, 'ccdsForPointingConstraint' ) ;
  if ( ~isempty(refCadenceGapIndex) && isempty(ccdsForPointingConstraint) )
      gapIndices(refCadenceGapIndex) = [] ;
  end
  
% zero-base the gap indices

  if (~isempty(gapIndices))
      gapIndices = gapIndices - 1 ;
  else
      gapIndices = [] ;
  end
  gapIndices = int32(gapIndices) ;
  
% add the reference cadence pointing to the fits, since what we fit is actually the
% deviation of the cadence pointing from the expected reference cadence pointing

  raValues = raValues + raRefCadence ;
  decValues = decValues + decRefCadence ;
  rollValues = rollValues + rollRefCadence ;
  
% construct the return data structures -- convert to column vectors so that they agree
% with the vectors which are ingested by read_PrfTimeSeries

  ra.values = raValues(:) ; ra.uncertainties = raUncertainties(:) ;
  dec.values = decValues(:) ; dec.uncertainties = decUncertainties(:) ;
  roll.values = rollValues(:) ; roll.uncertainties = rollUncertainties(:) ;
  ra.gapIndices = gapIndices ; dec.gapIndices = gapIndices ; 
  roll.gapIndices = gapIndices ;
  
  spacecraftAttitudeStruct.ra = ra ;
  spacecraftAttitudeStruct.dec = dec ;
  spacecraftAttitudeStruct.roll = roll ;
  
%=========================================================================================
%
% Results Structure Blob
%
%=========================================================================================

  resultBlobFileName = 'fpgResultBlob.mat' ;
  fpgResultsStruct = get(fpgResultsObject,'*') ;
  struct_to_blob( fpgResultsStruct, resultBlobFileName ) ;
  
%=========================================================================================
%
% Geometry Import File
%
%=========================================================================================

  fpgImportFileName = write_fpg_for_import( fpgResultsObject ) ;

% Put it all together...
  
  fpgOutputs.geometryBlobFileName = geometryBlobFileName ;
  fpgOutputs.reportFileName = reportFileName ;
  fpgOutputs.fpgImportFileName = fpgImportFileName ;
  fpgOutputs.resultBlobFileName = resultBlobFileName ;
  fpgOutputs.spacecraftAttitudeStruct = spacecraftAttitudeStruct ;
  
% and that's it!

%
%
%
