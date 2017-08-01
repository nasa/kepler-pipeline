%
% Organization of "independent variable" data structure in focal plane geometry fitting:
%
%    The third argument returned from unpack_fpg_options is a data structure, fitterArgs,
%    which is passed to the FPG model function.  This data structure represents the
%    "independent variables" which go to the model function (so that it can produce the
%    set of model dependent variables which correspond to the independent variables), but
%    it also contains a bunch of other information which is needed by the model function.
%    The fields of the structure are defined below.
%
%    fitterArgs.RADecModOut:  contains an array with 4 columns.  The first and second
%       columns are the RA and Dec values which are used in the fit (ie, the RA and Dec
%       values which are run through ra_dec_2_pix, producing row and column values which
%       are compared to the measured row and column values to produce the chisq).  The
%       third and fourth columns are the module and output that the point is expected to
%       fall on; this information is used in a check -- if the output of ra_dec_2_pix has
%       different module or output than what came out of the motion polynomials (ie, if
%       the fitter passes a HUGE set of misalignments to the model function), then the
%       data points with inconsistent module and output are not used in the fit.
%
%       Note that the same set of RAs and Decs are used to generate pixel positions for
%       all of the cadences in the fit.  Combined with the issues above, this means that
%       RA and Dec values should be chosen which are (1) far enough from the edges of a
%       mod/out that they don't "fall off the edge" when the geometry parameters are
%       varied by the fitter, and (2) far enough from the edges of a mod/out that they
%       don't "fall off the edge" for some of the cadences, if the cadences have different
%       orientations.
%
%    fitterArgs.raDec2PixObject:  the object of raDec2PixClass which is used for
%       ra_dec_2_pix calls.
%
%    fitterArgs.mjds:  vector of modified Julian dates for the cadences in the fit, in the
%       same order as the cadences were in when the constraint points were generated.
%
%    fitterArgs.geometryParMap:  column vector with length = 3 * number of CCDs, this is
%       the map between the vector of parameters used by the fitter and the parameters in
%       the raDec2PixClass geometryModel array:  if geometryParMap(j) == 0, it means that
%       geometryModel.constants.array(j) is not one of the parameters to be fitted; if
%       geometryParMap(j) == k, then geometryModel.constants.array(j) maps to fit
%       parameter k in the vector of parameters.
%
%    fitterArgs.plateScaleParMap:  shows which parameter in the fit parameter vector is
%       the plate scale.  This parameter is zero if the user chose not to fit the plate
%       scale.
%
%    cadenceRAMap, cadenceDecMap, cadenceRollMap:  these map from the fit parameter vector
%       to the orientations of the non-reference cadences:  cadenceRAMap(iCadence) is the
%       index into the fit parameter vector of the fitted RA offset of cadence number
%       iCadence.  When iCadence == reference cadence, cadenceRAMap(iCadence) == 0.  The
%       other 3 vectors work the same way.
%
% See also:  update_fpg_lc unpack_fpg_options fpg_constraintPoints.
%
% Version date:  2008-Apr-24.
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
%    2008-apr-24, PT:
%       change format of geometryParMap.
%
%=========================================================================================
