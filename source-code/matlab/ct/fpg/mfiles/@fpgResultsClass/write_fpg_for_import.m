function filename = write_fpg_for_import( fpgResultsObject )
%
% write_fpg_for_import -- write focal plane geometry constants to a text file
%
% write_fpg_for_import( fpgResultsObject ) writes the focal plane geometry constants to a
%    text file in the format required for ingestion by the SOC FC data management system.
%    The filename is SeedGeometryData.MJD.txt, where MJD is the modified Julian date of
%    the earliest cadence used in the fit.
%
% Version date:  2009-April-23.
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
%     2009-April-23, PT:
%         add support for pincushion parameter.  Increase precision of MJD.
%     2008-November-14, PT:
%         increase precision of printed parameters.
%     2008-October-13, PT:
%         return the filename to the caller.
%     2008-September-24, PT:
%         change filename to match new format.
%     2008-July-22, PT:
%         changed format to eliminate leading blanks, per discussion with Kester.
%
%=========================================================================================

  mjd = get( fpgResultsObject.fpgFitClass, 'mjd' ) ;
  mjd = min(mjd) ;
  
% produce the filename

  dateString = datestr(now,30) ;
  dateString = [dateString(1:8) dateString(10:11)] ;

  filename = ['kplr',dateString,'_geometry.txt'] ;
  
% open the file for writing

  fp = fopen(filename,'w') ;
  
% make sure the parameters are in the raDec2PixClass object, and get it out of the
% fpgFitClass object

  fpgFitObject = set_raDec2Pix_geometry( fpgResultsObject.fpgFitClass, 1 ) ;
  rd2pmo = get(fpgFitObject,'raDec2PixObject') ;
  gm = get(rd2pmo,'geometryModel') ;
  gmConstants = gm.constants(1).array ;
  
% write the MJD in the top of the file

  fprintf(fp,'%10.4f\n',mjd) ;

% write the first 252 parameters out in 3-column format
  
  fprintf(fp,'%-16.14f %-16.13f %-16.11f\n',gmConstants(1:126)) ;
  fprintf(fp,'%-16.14f %-16.13f %-16.13f\n',gmConstants(127:252)) ;
  
% write the remaining parameters out in 1-column format -- f format for the plate scales,
% e format for the pincushion

  fprintf(fp,'%-16.14f\n',gmConstants(253:336)) ;
  fprintf(fp,'%-16.14e\n',gmConstants(337:420)) ;
  
  fclose(fp) ;
  
% and that's it!

%
%
%
