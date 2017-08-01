function outputsStruct =  ar_matlab_controller(inputsStruct)
% outputsStruct =  ar_matlab_controller(inputsStruct)
%
% INPUTS:
%     inputStruct: A struct containing fields:
%         unpackBackgroundBlob       Logical.  When true populate the backgroundPolynomial output with the background blob.                                  background blob.
%         cadenceTimesStruct         PA cadenceType struct for the actual cadence type of this data (see cadenceType).
%         cadenceType                A string, either 'short' or 'long', describing the type of cadence.
%         ccdModule                  The CCD module for this unit of work
%         ccdOutput                  The CCD output for this unit of work
%         configMaps                 A PA configMap struct 
%         debugFlag                  A boolean flag to signal debug
%         fcConstants                an FcConstants object
%         longCadenceTimesStruct     PA cadenceType struct for the long cadences that cover this time covered by cadenceTimesStruct.  If cadenceType is 'long', cadenceTimesStruct and longCadenceTimesStruct will be identical
%         motionPolyBlobs            The motion poly blobs for this unit of work.
%         raDec2PixModel             a RaDec2Pix model valid for the times contained in motionPolyBlobs
%         unpackCbvBlob              Logical.  When true the field cotrendingBasisVectorBlobs will be defined and should be unpacked into the output struct.
%         cotrendingBasisVectorBlobs Only valid when unpackCbvBlob is true.
%         backgroundInputs:
%                 backgroundBlobs            PA background blobs
%                 pixelCoordinates.ccdRow    A vector of row coordinates, zero-based
%                 pixelCoordinates.ccdColumn A vector of column coordinates, zero-based
%
%         barycentricInputs.barycentricTargets:  A vector of structs, with the structs containing fields:
%                 keplerId                   The kepler ID of the target
%                 longCadenceReference       The reference cadence number (LONG CADENCE) for the target
%                 centerCcdRow               The center CCD row of the target
%                 centerCcdCol               The center CCD column of the target
%                 ra                         Right ascension of the target (decimal hours).
%                                            Can be Nan, in which case the RA is calculated using centerCcdRow and centerCcdCol.
%                 dec                        Declination of the target.  
%                                            Can be NaN, in which case the DEC is calculated using centerCcdRow and centerCcdCol.
%
%         dvaInputs.dvaTargets:  A vector of structs with the following fields.  The vector is nTargets long.
%                 keplerId                The keplerId of the target
%                 longReferenceCadence    The (long) cadence index number of the reference cadence.
%                 ra                      Right ascension of the target (decimal hours).  Can be NaN, in which case the RA is calculated using pix2radec.
%                 dec                     Declination of the target.  Can be NaN, in which case the declination is calculated using pix2radec.
%                 rowCentroid             Row centroid for target on the reference cadence.
%                 columnCentroid          Column centroid for target on the reference cadence.
%
%        wcsInputs.wcsTargets:  A vector of structs with the following fields.  The vector is nTargets long.
%                 keplerId               The keplerId of the target
%                 raDecimalHours         Right ascension of the target.  Can be null, in which case the RA is calculated using pix2radec.
%                 decDegrees             Declination of the target.Can be null, in which case the declination is calculated using pix2radec.
%                 longCadenceReference   The cadence number of the reference cadence for this target.
%                 rowCentroid            Row centroid for target on the reference cadence.
%                 columnCentroid         Column centroid for target on the reference cadence.
%                 pixelData         A vector of structs with the following fields.  The vector is nPixels long.
%                     ccdRow        Zero-based row coordinate
%                     ccdColumn     Zero-based column coordinate
%        ffiBarycentricCorrectionInputs:
%                 perform               Logical.  When true the FFI barycentric correction should be computed.
%                 referenceMjd          double. The mjd to use for the barycentric correction.  This may be a different time
%                                       than the reference long cadence.
%                 referenceLongCadence  int.  The long cadence to use to select a motion polynomial.
%                 ccdColumn             double. The ccdColumn to correct for.
%                 ccdRow                double. The ccdRow to correct for.
%        sipWcsInputs:
%                 perform               logical.  When true perform the SIP WCS computation.
%                 referenceLongCadence  int.  The long cadence to use.
%                 colStep               double.
%                 rowStep               double.
%
%
%
% OUTPUTS:
%     outputsStruct: A struct with fields:
%
%         .background: A vector of structs, one pixel per struct, with the following fields:
%             ccdRow                        The row address of this pixel, zero-based.
%             ccdColumn                     The column address of this pixel, zero-based.
%             background                    The background values for this pixel.  A nCadence-length array of doubles.
%             backgroundUncertainties       The background uncertainty values for this pixel.  A nCadence-length array of doubles.
%             backgroundGaps                The gap indicators for the background values this pixel.  A nCadence-length array of booleans.
%             backgroundUncertaintyGaps     The gap indicators for uncertainties of this pixel.  A nCadence-length array of booleans.
%
%         .barycentricOutputs: A vector of structs, each struct containing the following fields:
%             keplerId                  The kepler ID of the target
%             barycentricTimeOffset     The barycentric time offset vector for this target
%             barycentricGapIndicator   A gap indicator vector for the time offsets
%             raDecimalHours            The ra of the target, in hours.
%             decDecimalDegrees         The dec of the target, in degrees.
%
%         .targetDva: A vector of structs with the following fields.  The vector is nTargets long.
%             keplerId             The keplerId of the target
%             rowDva               The DVA row offset, in pixels.  A vector nCadences long.
%             columnDva            The DVA column offset, in pixels. A vector nCadences long.
%             rowGapIndicator      The DVA row gap indicator.  A vector nCadences long.
%             columnGapIndicator   The DVA column gap indicator.  A vector nCadences long.
%
%         .targetWcs: A vector of structs with the following fields.  The
%                     vector is nTargets long.  The value of each field, except
%                     as noted below, is a struct.  The struct's first field is
%                     named 'headerKeyword', with the value being the name of the
%                     FITS header keyword.  The struct's second field is named
%                     'value', with the value being the value of the FITS header
%                     keyword.  
%
%             keplerId                      Not a struct.  The Kepler ID of the target.
%             outputRaDecsAreCalculated     Boolean flag describing if the ra/dec has been calculated by the subcontroller.
%             subimageReferenceColumn                   
%             subimageReferenceRow                      
%             originalImageReferenceColumn              
%             originalImageReferenceRow                 
%             plateScaleColumn                          
%             plateScaleRow                             
%             subimageCoordinateSystemReferenceColumn   
%             subimageCoordinateSystemReferenceRow
%             subimageReferenceRightAscension           
%             subimageReferenceDeclination
%             unitMatrixDegreesPerPixelColumn       This field contains the RA platescale    
%             unitMatrixDegreesPerPixelRow          This field contains the dec platescale    
%             unitMatrixRotationMatrix11                
%             unitMatrixRotationMatrix12                
%             unitMatrixRotationMatrix21                
%             unitMatrixRotationMatrix22                
%             alternateRepresentationMatrix11           
%             alternateRepresentationMatrix12           
%             alternateRepresentationMatrix21           
%             alternateRepresentationMatrix22
%      
%         .sipWcsCoordinates struct
%             referenceCcdRow -- The reference row used in this calculation.
%             referenceCcdColumn -- The reference column used in this calculation.
%             ra  -- The right ascension of the reference pixel.
%             dec -- The declination of the reference pixel.
%             rotationAndScale -- An 2-element array of structs with field "array".
%
%            forwardPolynomial -- A struct with the following fields:
%                 a -- A struct with the following fields:
%                     order -- The order of this polynomial
%                     polynomial -- An array of structs with fields:
%                         keyword -- The keyword for this value of the polynomial
%                         value -- The value for this value of the polynomial
%                 b -- A struct with the following fields:
%                     order -- The order of this polynomial
%                     polynomial -- An array of structs with fields:
%                         keyword -- The keyword for this value of the polynomial
%                         value -- The value for this value of the polynomial
%            inversePolynomial -- A struct with the following fields:
%                 a -- A struct with the following fields:
%                     order -- The order of this polynomial
%                     polynomial -- An array of structs with fields:
%                         keyword -- The keyword for this value of the polynomial
%                         value -- The value for this value of the polynomial
%                 b -- A struct with the following fields:
%                     order -- The order of this polynomial
%                     polynomial -- An array of structs with fields:
%                         keyword -- The keyword for this value of the polynomial
%                         value -- The value for this value of the polynomial
%            cotrendingBasisVectors - A struct with the following fields:
%                 mapOrder - integer 
%                 nobandVectors - A matrix of nBasisVectors x time
%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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


    backgroundOutputStruct = adjusted_background_pixel_matlab_controller(inputsStruct);
    barycenterOutputStruct = barycentric_correction_matlab_controller(inputsStruct);
    targetDva              = dva_values_matlab_controller(inputsStruct);
    targetWcsOutputStruct  = wcs_target_pixels_matlab_controller(inputsStruct);
    unpackedBackgroundPoly = unpack_background_polynomial(inputsStruct);
    sipWcsCoordinates      = wcs_nonlinear(inputsStruct);
    ffiBarycentricCorrection = ffi_barycentric_correction(inputsStruct);
    unpackedBasisVectors = unpack_cbv_blob(inputsStruct);
    

    outputsStruct.background           = backgroundOutputStruct;
    outputsStruct.barycentricOutputs   = barycenterOutputStruct;
    outputsStruct.targetDva            = targetDva;
    outputsStruct.targetWcs            = targetWcsOutputStruct;
    outputsStruct.backgroundPolynomial = unpackedBackgroundPoly; 
    outputsStruct.sipWcsCoordinates        = sipWcsCoordinates;
    outputsStruct.ffiBarycentricCorrection = ffiBarycentricCorrection;
    outputsStruct.cotrendingBasisVectors = unpackedBasisVectors;
return
