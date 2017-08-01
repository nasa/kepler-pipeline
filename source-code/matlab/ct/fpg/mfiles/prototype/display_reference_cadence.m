function display_reference_cadence( initialPars, finalPars, fitterArgs, refLCDataStruct, ...
    magMin, magMax )
%
% DISPLAY_REFERENCE_CADENCE -- display the pixels from the reference cadence, plus the
%    expected star positions, within a range of stellar magnitudes.
%
% display_reference_cadence( initialPars, finalPars, fitterArgs, refLCDataStruct, magMin,
%    magMax) finds the stars that correspond to targets in the refLCDataStruct, and which
%    have stellar magnitudes between magMin and magMax.  The pixels in refLCDataStruct
%    which correspond to these stars are imaged, and the stellar positions are overlaid.
%    Both positions before FPG fitting (red) and after (blue) are shown.
%
% Version date:  2008-June-06.
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
%     2008-June-06, PT:
%         make use of additional keplerId vector at higher level of refLCDataStruct to
%         eliminate overhead from concatenating keplerID values.
%
%=========================================================================================

% draw the focal plane

  draw_ccd(1:42) ;
  hold on
  
% construct "before" and "after" raDec2PixClass objects

  raDec2PixBefore = put_geometry_pars_in_raDec2PixObj( initialPars, ...
      fitterArgs.raDec2PixObject, fitterArgs.geometryParMap, fitterArgs.plateScaleParMap ) ;
  raDec2PixAfter  = put_geometry_pars_in_raDec2PixObj( finalPars, ...
      fitterArgs.raDec2PixObject, fitterArgs.geometryParMap, fitterArgs.plateScaleParMap ) ;

% get the MJD for the reference cadence

  mjd = fitterArgs.mjds(1) ;
  
% load the canned KIC database from disk

  load kics_database ;
  
% loop over the modules and outputs present in the refLCDataStruct

  for iChannel = 1:length(refLCDataStruct)
      
      module = refLCDataStruct(iChannel).module ;
      output = refLCDataStruct(iChannel).output ;
      
%     perform the "database query" to find the stars on this mod/out within the magnitude
%     range

      absoluteChannel = convert_from_module_output(module,output) ;
      catalogIndices = find( kicsDatabase(absoluteChannel).RMag <= magMax & ...
          kicsDatabase(absoluteChannel).RMag >= magMin ) ;
      catalogID = kicsDatabase(absoluteChannel).keplerId(catalogIndices) ;
      
%     find the Kepler ID's of all the targets in the pixel data structure

%      dataStructID = [refLCDataStruct(iChannel).keplerIdTimeSeriesStruct.keplerId] ;
      dataStructID = refLCDataStruct(iChannel).keplerId ;
      
%     find the IDs which are present in both datasets

      [keplerIDs,indexCatalog,indexStruct] = intersect(catalogID, dataStructID) ;
      
%     image the pixels associated with the targets of interest

      display_extracted_time_series(module, output, ...
          refLCDataStruct(iChannel).keplerIdTimeSeriesStruct(indexStruct)) ;
      
%    now for the stars:  we need to get their RA and Dec values

     catalogIndices = catalogIndices(indexCatalog) ;
     ra  = kicsDatabase(absoluteChannel).RA(catalogIndices) * 180 / 12 ;
     dec = kicsDatabase(absoluteChannel).Dec(catalogIndices) ;
      
%    now convert to MORC coordinates, both before and after

     [modBefore, outBefore, rowBefore, colBefore] = ra_dec_2_pix( raDec2PixBefore, ...
         ra, dec, mjd ) ;
     [modAfter,  outAfter,  rowAfter,  colAfter ] = ra_dec_2_pix( raDec2PixAfter, ...
         ra, dec, mjd ) ;
     
%     convert to focal plane coordinates

      [zpBefore,ypBefore] = morc_to_focal_plane_coords( modBefore, outBefore, ...
          rowBefore, colBefore ) ;
      [zpAfter, ypAfter ] = morc_to_focal_plane_coords( modAfter,  outAfter,  ...
          rowAfter,  colAfter  ) ;
      
%     and plot those points!

      plot(zpBefore, ypBefore, 'r.') ;
      plot(zpAfter , ypAfter , 'b.') ;
      
  end % loop over channels in refLCDataStruct
  
  hold off
      