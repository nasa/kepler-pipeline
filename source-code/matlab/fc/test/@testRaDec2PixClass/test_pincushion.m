function self = test_pincushion( self )
%
% test_pincushion -- test raDec2PixClass features related to pincushion correction
%
% This is a unit test which runs under mlunit as part of the testRaDec2PixClass.  It
%    performs the following tests which are related to the position-dependent plate scale
%    correction ("pincushion effect"):
%
% ==> A geometry model which has 336 coefficients (ie, no slots for pincushion) will not
%     instantiate a geometryClass object.
% ==> A geometry model which has 420 coefficients will instantiate a geometryClass object.
% ==> Round-trip agreement with all pincushion coefficients set to zero remains within the
%     1e-9 tolerance established in test_round_trip.m.  
% ==> When I change the pincushion coefficients for CCD 1 (mod 2, outs 1 and 2; channels 1
%     and 2), there is no effect on the transformations for mod/outs other than the the
%     first 2, but the first 2 do change.
% ==> With nonzero pincushion coefficients on CCD 1, the round-trip accuracy remains
%     within the specified tolerance.
% ==> The transformation runs without errors on a grid which covers the area of one of the
%     mod/outs which has a nonzero pincushion, and one which has zero pincushion.
% ==> The pincushion correction does not produce errors when the arguments to raDec2Pix
%     and pix2RaDec are vectors, and regardless of the vector orientation (row or column).
%
% The correct syntax to invoke just this test is as follows:
%
%    run(text_test_runner,testRaDec2PixClass('test_pincushion')) ;
%
% Version date:  2009-April-21.
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

  display('pincushion features') 
  
  roundTripAccuracy = 1e-9 ;
  mjd = 54930 ;
  
% At a distance of 1000 pixels from the center of the module, we want the effect to be at
% the level of 0.1 pixels; that means that we want it to be a 1e-4 effect at that location
  
  pincushionMagnitudeAt1000Pixels = 1e-4 ;
  
  initialize_soc_variables ;
  testDataDir = fullfile(socTestDataRoot, 'fc', 'geometry', 'pincushion');
  
% TEST 1:  geometry model with incorrect structure won't instantiate

  load(fullfile(testDataDir,'ra-dec-2-pix-model-bad-geometry-model.mat')) ;
  
  gmBad = raDec2PixModel.geometryModel ;
    try_to_catch_error_condition(...
      'go = geometryClass(gmBad) ;', ...
      'constantsArrayIncorrectLength', ...
      'caller' ) ;
  
  for iModel = 1:length(gmBad.constants)
      gmBad.constants(iModel).array(337:420) = 0 ;
  end
   try_to_catch_error_condition(...
      'go = geometryClass(gmBad) ;', ...
      'uncertaintyArrayIncorrectLength', ...
      'caller' ) ;
  
% TEST 2:  geometry model with correct structure will instantiate

  clear raDec2PixModel ;
  load(fullfile(testDataDir,'ra-dec-2-pix-model.mat')) ;
  gmGood = raDec2PixModel.geometryModel ;
  go = geometryClass(gmGood) ;
  clear go ;
  raDec2PixModel.spiceFileDir = fullfile(socTestDataRoot, 'fc', 'spice');
  raDec2PixObject = raDec2PixClass(raDec2PixModel,'zero-based') ;
  
% TEST 2a:  ill-formed geometry model can't be passed to raDec2PixClass object via set
% method

  try_to_catch_error_condition(...
      'raDec2PixObject=set(raDec2PixObject,''geometryModel'',gmBad) ;', ...
      'set', ...
      'caller' ) ;
  
  clear gmBad ;
  
% TEST 3:  round-trip accuracy, pincushion coeffs set to zero -- we'll use pixels near the
% middle of the FOV

  [modList,outList] = convert_to_module_output(1:84) ;
  rowList = repmat(500,size(modList)) ;
  colList = repmat(600,size(modList)) ;
  modList = modList(:) ; outList = outList(:) ;
  rowList = rowList(:) ; colList = colList(:) ;
  [ra0, dec0] = pix_2_ra_dec(raDec2PixObject,modList,outList,rowList,colList,mjd) ;
  ra0 = ra0(:) ; dec0 = dec0(:) ;
  [m0,o0,r0,c0] = ra_dec_2_pix(raDec2PixObject,ra0,dec0,mjd) ;
  m0 = m0(:) ; o0 = o0(:) ;
  r0 = r0(:) ; c0 = c0(:) ;
  mlunit_assert( all(abs([r0 ; c0]-[rowList ; colList]) < roundTripAccuracy), ...
      'Round-trip, pincushion == 0: Row / column round-trip accuracy out of tolerance' ) ;
  assert_equals( [modList ; outList],[m0 ; o0], ...
      'Round-trip, pincushion == 0: module / output values disagree' ) ;

% TEST 4:  set the pincushion parameters for mod 2 outs 1 and 2 and see that only these 2
% mod-outs see a change in transformation behavior 

% We will set the parameters to yield exactly 0.1 worth of motion for 1000
% pixels' offset

  gm = raDec2PixModel.geometryModel ;
  plateScaleMod2Out1 = gm.constants(1).array(336) ;
  pincushionMod2Out1 = pincushionMagnitudeAt1000Pixels / 1000^2 / plateScaleMod2Out1^2 ;
  for iModel=1:length(gm.constants)
      gm.constants(iModel).array(337:338) = pincushionMod2Out1 ;
  end
  
% Note that this implicitly tests that a valid geometry model can be passed via set method
% to the raDec2PixClass object
  
  raDec2PixObject = set(raDec2PixObject,'geometryModel',gm) ;
  [ra1, dec1] = pix_2_ra_dec(raDec2PixObject,modList,outList,rowList,colList,mjd) ;
  ra1 = ra1(:) ; dec1 = dec1(:) ;
  assert_equals( [ra1(3:end) ; dec1(3:end)],[ra0(3:end) ; dec0(3:end)], ...
      'Change mod 2 outs 1 and 2 pincushion changed RAs on other CCDs' ) ;
  mlunit_assert( all([ra1(1:2) ; dec1(1:2)] ~= [ra0(1:2) ; dec0(1:2)]), ...
      'Change mod 2 outs 1 and 2 pincushion has no effect on RAs and Decs on that CCD' ) ;
  
  [m1,o1,r1,c1] = ra_dec_2_pix(raDec2PixObject,ra1,dec1,mjd) ;
  m1 = m1(:) ; o1 = o1(:) ;
  r1 = r1(:) ; c1 = c1(:) ;
  assert_equals( [m1 ; o1], [m0 ; o0], ...
      'Change mod 2 outs 1 and 2 pincushion changed module / output solutions' ) ;
  assert_equals( [r1(3:end) ; c1(3:end)], [r0(3:end) ; c0(3:end)], ...
      'Change mod 2 outs 1 and 2 pincushion changed row/col solutions on other channels' ) ;
  mlunit_assert( all([r1(1:2) ; c1(1:2)] ~= [r0(1:2) ; c0(1:2)]), ...
      'Change mod 2 outs 1 and 2 pincushion has no effect on rows and columns on that CCD' ) ;

% TEST 5:  Round-trip accuracy remains as good as it was without the pincushion terms
% specified

  mlunit_assert( all(abs([r1 ; c1]-[rowList ; colList]) < roundTripAccuracy), ...
      'Round-trip, pincushion ~= 0: Row / column round-trip accuracy out of tolerance' ) ;
  assert_equals( [modList ; outList],[m1 ; o1], ...
      'Round-trip, pincushion ~= 0: module / output values disagree' ) ;

% TEST 6:  correction works all over the CCD, including in places where there are zeros in
% the intermediate transformations

% To determine this, we need to first find the offsets which are used to transform the row
% and column from the notional center of the module to the centers of the readout
% locations.

  rowOffset = gmGood.constants(1).array(128) ;
  colOffset = gmGood.constants(1).array(129) ;
  
  rowMaximum = rowOffset + raDec2PixModel.nRowsImaging + raDec2PixModel.nMaskedSmear - 0.5 ; 
  colMaximum = colOffset + raDec2PixModel.nColsImaging + raDec2PixModel.nLeadingBlack - 0.5 ; 
  
% We want the grid to go from -0.5 pixels in each DOF to the max values listed above, but
% also to include row = 0, col = 0.  Define the grid of interest now

  rowGrid = [-0.5 linspace(0,rowMaximum,15)] ;
  colGrid = [-0.5 linspace(0,colMaximum,15)] ;
  [rowValues, colValues] = meshgrid(rowGrid,colGrid) ;
  rowValues = rowValues(:) ;
  colValues = colValues(:) ;
  modValues = repmat(2,size(rowValues)) ;
  outValues = repmat(1,size(rowValues)) ;
  
  [raValues,decValues] = pix_2_ra_dec(raDec2PixObject, modValues, outValues, ...
      rowValues, colValues, mjd) ;
  mlunit_assert( all(raValues<300) && all(raValues>280), ...
      'RA values with pincushion not reasonable' ) ;
  mlunit_assert( all(decValues<50) && all(decValues>40), ...
      'DEC values with pincushion not reasonable' ) ;
  
  [m2,o2,r2,c2] = ra_dec_2_pix( raDec2PixObject, raValues, decValues, mjd ) ;
  
% Now do the same check on a mod/out which has no pincushion 

  modValues = repmat(2,size(rowValues)) ;
  outValues = repmat(3,size(rowValues)) ;

 [raValues,decValues] = pix_2_ra_dec(raDec2PixObject, modValues, outValues, ...
      rowValues, colValues, mjd) ;
  mlunit_assert( all(raValues<300) && all(raValues>280), ...
      'RA values with pincushion not reasonable' ) ;
  mlunit_assert( all(decValues<50) && all(decValues>40), ...
      'DEC values with pincushion not reasonable' ) ;
  
  [m2,o2,r2,c2] = ra_dec_2_pix( raDec2PixObject, raValues, decValues, mjd ) ;
  
% We only require that the transformation be formally reversible on the area of the
% viewable silicon, and even there we can have round-off error causing the pixels to be
% estimated onto the neighboring mod/out.  So do the reversibility test over the viewable
% area, with a slight offset from the mod/out boundary to prevent slipover

  rowMaximum = raDec2PixModel.nRowsImaging + raDec2PixModel.nMaskedSmear - 0.5 - 1e-6 ;
  colMaximum = raDec2PixModel.nColsImaging + raDec2PixModel.nLeadingBlack - 0.5 - 1e-6 ; 

  rowGrid = [-0.5 linspace(0,rowMaximum,15)] ;
  colGrid = [-0.5 linspace(0,colMaximum,15)] ;
  [rowValues, colValues] = meshgrid(rowGrid,colGrid) ;
  rowValues = rowValues(:) ;
  colValues = colValues(:) ;
  modValues = repmat(2,size(rowValues)) ;
  outValues = repmat(1,size(rowValues)) ;
  
  [raValues,decValues] = pix_2_ra_dec(raDec2PixObject, modValues, outValues, ...
      rowValues, colValues, mjd) ;
  [m2,o2,r2,c2] = ra_dec_2_pix( raDec2PixObject, raValues, decValues, mjd ) ;
  m2 = m2(:) ; o2 = o2(:) ; 
  r2 = r2(:) ; c2 = c2(:) ;
  assert_equals( [modValues ; outValues],[m2 ; o2], ...
      'Round-trip, grid, pincushion ~= 0: module / output values disagree' ) ;
  mlunit_assert( all(abs([r2 ; c2]-[rowValues ; colValues]) < roundTripAccuracy), ...
      'Round-trip, grid, pincushion ~= 0: Row / column round-trip accuracy out of tolerance' ) ;

% Now do the same check on a mod/out which has no pincushion 

  modValues = repmat(2,size(rowValues)) ;
  outValues = repmat(3,size(rowValues)) ;
  
 [raValues,decValues] = pix_2_ra_dec(raDec2PixObject, modValues, outValues, ...
      rowValues, colValues, mjd) ;
  mlunit_assert( all(raValues<300) && all(raValues>280), ...
      'RA values with pincushion not reasonable' ) ;
  mlunit_assert( all(decValues<50) && all(decValues>40), ...
      'DEC values with pincushion not reasonable' ) ;
  [m2,o2,r2,c2] = ra_dec_2_pix( raDec2PixObject, raValues, decValues, mjd ) ;
  m2 = m2(:) ; o2 = o2(:) ; 
  r2 = r2(:) ; c2 = c2(:) ;
  assert_equals( [modValues ; outValues],[m2 ; o2], ...
      'Round-trip, grid, pincushion == 0: module / output values disagree' ) ;
  mlunit_assert( all(abs([r2 ; c2]-[rowValues ; colValues]) < roundTripAccuracy), ...
      'Round-trip, grid, pincushion == 0: Row / column round-trip accuracy out of tolerance' ) ;

% Check that the value is correctly determined -- it should be 0.1 pixels at 1000 pixels
% in row or column from the center of the module.  We do this by generating RA and Dec in
% a transformation with no pincushion, and then put those through the transformation with
% a pincushion.  

  rowMaximum = rowOffset + raDec2PixModel.nRowsImaging + raDec2PixModel.nMaskedSmear - 0.5 ; 
  colMaximum = colOffset + raDec2PixModel.nColsImaging + raDec2PixModel.nLeadingBlack - 0.5 ;
  
  rowTest = [rowMaximum-1000 rowMaximum rowMaximum-1000/sqrt(2)] ;
  colTest = [colMaximum colMaximum-1000 colMaximum-1000/sqrt(2)] ;
  
  modTest = [2 2 2] ;
  outTest = [2 2 2] ;
  
  raDec2PixObjectNoPincushion = raDec2PixClass(raDec2PixModel,'zero-based') ;
  [raTest, decTest] = pix_2_ra_dec( raDec2PixObjectNoPincushion, modTest, outTest, ...
      rowTest, colTest, mjd ) ;
  [modOffset, outOffset, rowOffset, colOffset] = ra_dec_2_pix( raDec2PixObject, ...
      raTest, decTest, mjd ) ;
  
% what we expect is the following:
%
% The first point is off by 1000 pixels, but its column is == 0 in the module-centered
% coordinates, so we expect to see that rowOffset is -0.1 pixels different from rowTest
%
% In the second point we are again off by 1000 pixels but in this case row == 0 in the
% module-centered coordinates, so we expect that colOffset is -0.1 pixels different from
% colTest.
%
% In the third case, we are equally off in row and column, and the net offset is 1000
% pixels, so we expect that each of rowOffset and colOffset is -0.1/sqrt(2) off from the
% respective test coordinates.

  expectedRowDiff = -0.1 * [1 ; 0 ; 1/sqrt(2)] ;
  expectedColDiff = -0.1 * [0 ; 1 ; 1/sqrt(2)] ;
  expectedDiff = [expectedRowDiff ; expectedColDiff] ;
  diffTolerance = 0.1 * roundTripAccuracy * [1 ; 1 ; 1 ; 1 ; 1 ; 1] ;
  mlunit_assert( all( abs([rowOffset-rowTest' ; colOffset-colTest'] - expectedDiff) < ...
      diffTolerance ), ...
      'Magnitude of pincushion effect incorrect' ) ;
  
% TEST 7:  Results are identical no matter how the input vectors are oriented 

  mjdVector = [mjd mjd+1] ;
  
  [mrrr, orrr, rrrr, crrr] = ra_dec_2_pix( raDec2PixObject, raTest,  decTest,  mjdVector  ) ;
  [mrrc, orrc, rrrc, crrc] = ra_dec_2_pix( raDec2PixObject, raTest,  decTest,  mjdVector' ) ;
%  [mrcr, orcr, rrcr, crcr] = ra_dec_2_pix( raDec2PixObject, raTest,  decTest', mjdVector  ) ;
%  [mrcc, orcc, rrcc, crcc] = ra_dec_2_pix( raDec2PixObject, raTest,  decTest', mjdVector' ) ;
%  [mcrr, ocrr, rcrr, ccrr] = ra_dec_2_pix( raDec2PixObject, raTest', decTest,  mjdVector  ) ;
%  [mcrc, ocrc, rcrc, ccrc] = ra_dec_2_pix( raDec2PixObject, raTest', decTest,  mjdVector' ) ;
  [mccr, occr, rccr, cccr] = ra_dec_2_pix( raDec2PixObject, raTest', decTest', mjdVector  ) ;
  [mccc, occc, rccc, cccc] = ra_dec_2_pix( raDec2PixObject, raTest', decTest', mjdVector' ) ;
  
  mlunit_assert(                all(rrrr(:)==rrrc(:)) &&   ...
                  all(rrrr(:)==rccr(:)) && all(rrrr(:)==rccc(:)) , ...
      'Not all combinations row/col input to raDec2Pix give identical row outputs' ) ;
  mlunit_assert(                 isequal(crrr, crrc) && ...
                  isequal(crrr, cccr) && isequal(crrr, cccc), ...
      'Not all combinations row/col input to raDec2Pix give identical column outputs' ) ;
  mlunit_assert(                 isequal(mrrr, mrrc) && ...
                  isequal(mrrr, mccr) && isequal(mrrr, mccc), ...
      'Not all combinations row/col input to raDec2Pix give identical module outputs' ) ;
  mlunit_assert(                 isequal(orrr,orrc) && ...
                  isequal(orrr, occr) && isequal(orrr, occc), ...
      'Not all combinations row/col input to raDec2Pix give identical output outputs' ) ;
  
  [rarrrrr, decrrrrr] = pix_2_ra_dec( raDec2PixObject, ...
      modTest, outTest, rowTest, colTest, mjdVector ) ;
  [rarrrrc, decrrrrc] = pix_2_ra_dec( raDec2PixObject, ...
      modTest, outTest, rowTest, colTest, mjdVector' ) ;
  [rarrrcr, decrrrcr] = pix_2_ra_dec( raDec2PixObject, ...
      modTest, outTest, rowTest, colTest', mjdVector ) ;
  [rarrrcc, decrrrcc] = pix_2_ra_dec( raDec2PixObject, ...
      modTest, outTest, rowTest, colTest', mjdVector' ) ;
  [rarrcrr, decrrcrr] = pix_2_ra_dec( raDec2PixObject, ...
      modTest, outTest, rowTest', colTest, mjdVector ) ;
  [rarrcrc, decrrcrc] = pix_2_ra_dec( raDec2PixObject, ...
      modTest, outTest, rowTest', colTest, mjdVector' ) ;
  [rarrccr, decrrccr] = pix_2_ra_dec( raDec2PixObject, ...
      modTest, outTest, rowTest', colTest', mjdVector ) ;
  [rarrccc, decrrccc] = pix_2_ra_dec( raDec2PixObject, ...
      modTest, outTest, rowTest', colTest', mjdVector' ) ;
  [rarcrrr, decrcrrr] = pix_2_ra_dec( raDec2PixObject, ...
      modTest, outTest', rowTest, colTest, mjdVector ) ;
  [rarcrrc, decrcrrc] = pix_2_ra_dec( raDec2PixObject, ...
      modTest, outTest', rowTest, colTest, mjdVector' ) ;
  [rarcrcr, decrcrcr] = pix_2_ra_dec( raDec2PixObject, ...
      modTest, outTest', rowTest, colTest', mjdVector ) ;
  [rarcrcc, decrcrcc] = pix_2_ra_dec( raDec2PixObject, ...
      modTest, outTest', rowTest, colTest', mjdVector' ) ;
  [rarccrr, decrccrr] = pix_2_ra_dec( raDec2PixObject, ...
      modTest, outTest', rowTest', colTest, mjdVector ) ;
  [rarccrc, decrccrc] = pix_2_ra_dec( raDec2PixObject, ...
      modTest, outTest', rowTest', colTest, mjdVector' ) ;
  [rarcccr, decrcccr] = pix_2_ra_dec( raDec2PixObject, ...
      modTest, outTest', rowTest', colTest', mjdVector ) ;
  [rarcccc, decrcccc] = pix_2_ra_dec( raDec2PixObject, ...
      modTest, outTest', rowTest', colTest', mjdVector' ) ;
  
  [racrrrr, deccrrrr] = pix_2_ra_dec( raDec2PixObject, ...
      modTest', outTest, rowTest, colTest, mjdVector ) ;
  [racrrrc, deccrrrc] = pix_2_ra_dec( raDec2PixObject, ...
      modTest', outTest, rowTest, colTest, mjdVector' ) ;
  [racrrcr, deccrrcr] = pix_2_ra_dec( raDec2PixObject, ...
      modTest', outTest, rowTest, colTest', mjdVector ) ;
  [racrrcc, deccrrcc] = pix_2_ra_dec( raDec2PixObject, ...
      modTest', outTest, rowTest, colTest', mjdVector' ) ;
  [racrcrr, deccrcrr] = pix_2_ra_dec( raDec2PixObject, ...
      modTest', outTest, rowTest', colTest, mjdVector ) ;
  [racrcrc, deccrcrc] = pix_2_ra_dec( raDec2PixObject, ...
      modTest', outTest, rowTest', colTest, mjdVector' ) ;
  [racrccr, deccrccr] = pix_2_ra_dec( raDec2PixObject, ...
      modTest', outTest, rowTest', colTest', mjdVector ) ;
  [racrccc, deccrccc] = pix_2_ra_dec( raDec2PixObject, ...
      modTest', outTest, rowTest', colTest', mjdVector' ) ;
  [raccrrr, decccrrr] = pix_2_ra_dec( raDec2PixObject, ...
      modTest', outTest', rowTest, colTest, mjdVector ) ;
  [raccrrc, decccrrc] = pix_2_ra_dec( raDec2PixObject, ...
      modTest', outTest', rowTest, colTest, mjdVector' ) ;
  [raccrcr, decccrcr] = pix_2_ra_dec( raDec2PixObject, ...
      modTest', outTest', rowTest, colTest', mjdVector ) ;
  [raccrcc, decccrcc] = pix_2_ra_dec( raDec2PixObject, ...
      modTest', outTest', rowTest, colTest', mjdVector' ) ;
  [racccrr, deccccrr] = pix_2_ra_dec( raDec2PixObject, ...
      modTest', outTest', rowTest', colTest, mjdVector ) ;
  [racccrc, deccccrc] = pix_2_ra_dec( raDec2PixObject, ...
      modTest', outTest', rowTest', colTest, mjdVector' ) ;
  [raccccr, decccccr] = pix_2_ra_dec( raDec2PixObject, ...
      modTest', outTest', rowTest', colTest', mjdVector ) ;
  [raccccc, decccccc] = pix_2_ra_dec( raDec2PixObject, ...
      modTest', outTest', rowTest', colTest', mjdVector' ) ;
 
  mlunit_assert(                                  all(rarrrrr(:) == rarrrrc(:)) && ...
                 all(rarrrrr(:) == rarrrcr(:)) && all(rarrrrr(:) == rarrrcc(:)) && ...
                 all(rarrrrr(:) == rarrcrr(:)) && all(rarrrrr(:) == rarrcrc(:)) && ...
                 all(rarrrrr(:) == rarrccr(:)) && all(rarrrrr(:) == rarrccc(:)) && ...
                 all(rarrrrr(:) == rarcrrr(:)) && all(rarrrrr(:) == rarcrrc(:)) && ...
                 all(rarrrrr(:) == rarcrcr(:)) && all(rarrrrr(:) == rarcrcc(:)) && ...
                 all(rarrrrr(:) == rarccrr(:)) && all(rarrrrr(:) == rarccrc(:)) && ...
                 all(rarrrrr(:) == rarcccr(:)) && all(rarrrrr(:) == rarcccc(:)) && ...
                 all(rarrrrr(:) == racrrrr(:)) && all(rarrrrr(:) == racrrrc(:)) && ...
                 all(rarrrrr(:) == racrrcr(:)) && all(rarrrrr(:) == racrrcc(:)) && ...
                 all(rarrrrr(:) == racrcrr(:)) && all(rarrrrr(:) == racrcrc(:)) && ...
                 all(rarrrrr(:) == racrccr(:)) && all(rarrrrr(:) == racrccc(:)) && ...
                 all(rarrrrr(:) == raccrrr(:)) && all(rarrrrr(:) == raccrrc(:)) && ...
                 all(rarrrrr(:) == raccrcr(:)) && all(rarrrrr(:) == raccrcc(:)) && ...
                 all(rarrrrr(:) == racccrr(:)) && all(rarrrrr(:) == racccrc(:)) && ...
                 all(rarrrrr(:) == raccccr(:)) && all(rarrrrr(:) == raccccc(:)), ...
      'Not all combinations row/col input to Pix2RaDec give identical RA outputs' ) ;

  mlunit_assert(                                    all(decrrrrr(:) == decrrrrc(:)) && ...
                 all(decrrrrr(:) == decrrrcr(:)) && all(decrrrrr(:) == decrrrcc(:)) && ...
                 all(decrrrrr(:) == decrrcrr(:)) && all(decrrrrr(:) == decrrcrc(:)) && ...
                 all(decrrrrr(:) == decrrccr(:)) && all(decrrrrr(:) == decrrccc(:)) && ...
                 all(decrrrrr(:) == decrcrrr(:)) && all(decrrrrr(:) == decrcrrc(:)) && ...
                 all(decrrrrr(:) == decrcrcr(:)) && all(decrrrrr(:) == decrcrcc(:)) && ...
                 all(decrrrrr(:) == decrccrr(:)) && all(decrrrrr(:) == decrccrc(:)) && ...
                 all(decrrrrr(:) == decrcccr(:)) && all(decrrrrr(:) == decrcccc(:)) && ...
                 all(decrrrrr(:) == deccrrrr(:)) && all(decrrrrr(:) == deccrrrc(:)) && ...
                 all(decrrrrr(:) == deccrrcr(:)) && all(decrrrrr(:) == deccrrcc(:)) && ...
                 all(decrrrrr(:) == deccrcrr(:)) && all(decrrrrr(:) == deccrcrc(:)) && ...
                 all(decrrrrr(:) == deccrccr(:)) && all(decrrrrr(:) == deccrccc(:)) && ...
                 all(decrrrrr(:) == decccrrr(:)) && all(decrrrrr(:) == decccrrc(:)) && ...
                 all(decrrrrr(:) == decccrcr(:)) && all(decrrrrr(:) == decccrcc(:)) && ...
                 all(decrrrrr(:) == deccccrr(:)) && all(decrrrrr(:) == deccccrc(:)) && ...
                 all(decrrrrr(:) == decccccr(:)) && all(decrrrrr(:) == decccccc(:)), ...
      'Not all combinations row/col input to Pix2RaDec give identical Dec outputs' ) ;
  
return

% and that's it!

%
%
%
