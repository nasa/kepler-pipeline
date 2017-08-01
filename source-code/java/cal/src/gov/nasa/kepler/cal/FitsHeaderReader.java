/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * This file is available under the terms of the NASA Open Source Agreement
 * (NOSA). You should have received a copy of this agreement with the
 * Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 * 
 * No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 * WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 * WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 * INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 * FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 * TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 * CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 * OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 * OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 * FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 * REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 * AND DISTRIBUTES IT "AS IS."
 * 
 * Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 * AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 * SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 * THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 * EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 * PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 * SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 * STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 * PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 * REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 * TERMINATION OF THIS AGREEMENT.
 */

package gov.nasa.kepler.cal;

import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.cal.ffi.FfiModOut;
import gov.nasa.kepler.common.FitsUtils;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.pi.PipelineException;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;

/**
 * This class reads fits {@link Header} keywords and creates a
 * {@link TimestampSeries}.
 * 
 * @author Miles Cote
 * 
 */
public class FitsHeaderReader {

    public TimestampSeries getCadenceTimes(FfiModOut ffiModOut) {
        TimestampSeries cadenceTimes = null;
        try {
            // Read flags from fits headers.
            Header primaryHduHeader = ffiModOut.primaryHdu.getHeader();

            // This class is only used by calffi, but ffi files do not have the
            // REQUANT keyword. Therefore, revert the setting of the requant
            // enabled flag as it was in the original calffi:
            // requantEnabled=false.
            //
            // boolean[] requantEnabled = new boolean[] {
            // FitsUtils.getHeaderBooleanValueChecked(
            // primaryHduHeader, PixelDispatcher.HDR_REQUANT_KEYWORD) };

            boolean[] isSefiAcc = new boolean[] { FitsUtils.getHeaderBooleanValueChecked(
                primaryHduHeader, SEFI_ACC_KW) };
            boolean[] isSefiCad = new boolean[] { FitsUtils.getHeaderBooleanValueChecked(
                primaryHduHeader, SEFI_CAD_KW) };
            boolean[] isLdeOos = new boolean[] { FitsUtils.getHeaderBooleanValueChecked(
                primaryHduHeader, LDE_OOS_KW) };
            boolean[] isFinePnt = new boolean[] { FitsUtils.getHeaderBooleanValueChecked(
                primaryHduHeader, FINE_PNT_KW) };
            boolean[] isMmntmDmp = new boolean[] { FitsUtils.getHeaderBooleanValueChecked(
                primaryHduHeader, MMNTMDMP_KW) };
            boolean[] isLdeParEr = new boolean[] { FitsUtils.getHeaderBooleanValueChecked(
                primaryHduHeader, LDEPARER_KW) };
            boolean[] isScrcErr = new boolean[] { FitsUtils.getHeaderBooleanValueChecked(
                primaryHduHeader, SCRC_ERR_KW) };

            cadenceTimes = new TimestampSeries(
                new double[] { ffiModOut.startMjd },
                new double[] { ffiModOut.midMjd },
                new double[] { ffiModOut.endMjd }, new boolean[] { false },
                new boolean[] { false }, new int[] { 1 }, isSefiAcc, isSefiCad,
                isLdeOos, isFinePnt, isMmntmDmp, isLdeParEr, isScrcErr);
        } catch (FitsException e) {
            throw new PipelineException("Unable to create "
                + TimestampSeries.class.getSimpleName(), e);
        }

        return cadenceTimes;
    }

}
