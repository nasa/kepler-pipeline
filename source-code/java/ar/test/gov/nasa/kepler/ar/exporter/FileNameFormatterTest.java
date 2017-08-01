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

package gov.nasa.kepler.ar.exporter;

import static org.junit.Assert.*;

import org.junit.Test;

import gov.nasa.kepler.common.FfiType;
import gov.nasa.kepler.common.Cadence.CadenceType;

public class FileNameFormatterTest {

    @Test
    public void k2FluxName() {
        FileNameFormatter formatter = new FileNameFormatter();
        assertEquals("ktwo000000042-c01_llc.fits", formatter.k2FluxName(42, 1, false));
        assertEquals("ktwo000000042-c11_llc.fits", formatter.k2FluxName(42, 11, false));
        assertEquals("ktwo000000042-c111_llc.fits", formatter.k2FluxName(42, 111, false));
        assertEquals("ktwo000000042-c01_slc.fits", formatter.k2FluxName(42, 1, true));
        assertEquals("ktwo000000042-c11_slc.fits", formatter.k2FluxName(42, 11, true));
        assertEquals("ktwo000000042-c111_slc.fits", formatter.k2FluxName(42, 111, true));
    }
    @Test
    public void k2FfiName() {
        FileNameFormatter formatter = new FileNameFormatter();
        FfiType ffiType = FfiType.SOC_CAL;
        assertEquals("ktwo000000042-c01_ffi-cal.fits", formatter.k2FfiName("ktwo000000042", ffiType, 1));
        assertEquals("ktwo000000042-c11_ffi-cal.fits", formatter.k2FfiName("ktwo000000042", ffiType, 11));
        assertEquals("ktwo000000042-c111_ffi-cal.fits", formatter.k2FfiName("ktwo000000042", ffiType, 111));
    }

    @Test
    public void k2CollateralName() {
        FileNameFormatter formatter = new FileNameFormatter();
        CadenceType cadenceType = CadenceType.LONG;
        assertEquals("ktwo042-c01_coll.fits", formatter.k2CollateralName(1, 4, 2, cadenceType));
        assertEquals("ktwo042-c11_coll.fits", formatter.k2CollateralName(11, 4, 2, cadenceType));
        assertEquals("ktwo042-c111_coll.fits", formatter.k2CollateralName(111, 4, 2, cadenceType));
    }

    @Test
    public void k2BackgroundName() {
        FileNameFormatter formatter = new FileNameFormatter();
        assertEquals("ktwo042-c01_bkg.fits", formatter.k2BackgroundName(1, 4, 2));
        assertEquals("ktwo042-c11_bkg.fits", formatter.k2BackgroundName(11, 4, 2));
        assertEquals("ktwo042-c111_bkg.fits", formatter.k2BackgroundName(111, 4, 2));
    }

    @Test
    public void k2ArpName() {
        FileNameFormatter formatter = new FileNameFormatter();
        assertEquals("ktwo042-c01_arp.fits", formatter.k2ArpName(1, 4, 2));
        assertEquals("ktwo042-c11_arp.fits", formatter.k2ArpName(11, 4, 2));
        assertEquals("ktwo042-c111_arp.fits", formatter.k2ArpName(111, 4, 2));
    }

    @Test
    public void k2CbvName() {
        FileNameFormatter formatter = new FileNameFormatter();
        CadenceType cadenceType = CadenceType.LONG;
        assertEquals("ktwo-c01-d04_lcbv.fits", formatter.k2CbvName(1, 4, cadenceType));
        assertEquals("ktwo-c11-d04_lcbv.fits", formatter.k2CbvName(11, 4, cadenceType));
        assertEquals("ktwo-c111-d04_lcbv.fits", formatter.k2CbvName(111, 4, cadenceType));
    }

    @Test
    public void k2TargetPixelName() {
        FileNameFormatter formatter = new FileNameFormatter();
        assertEquals("ktwo000000042-c01_lpd-targ.fits", formatter.k2TargetPixelName(42, 1, false, false));
        assertEquals("ktwo000000042-c11_lpd-targ.fits", formatter.k2TargetPixelName(42, 11, false, false));
        assertEquals("ktwo000000042-c111_lpd-targ.fits", formatter.k2TargetPixelName(42, 111, false, false));

        assertEquals("ktwo000000042-c01_spd-targ.fits", formatter.k2TargetPixelName(42, 1, true, false));
        assertEquals("ktwo000000042-c11_spd-targ.fits", formatter.k2TargetPixelName(42, 11, true, false));
        assertEquals("ktwo000000042-c111_spd-targ.fits", formatter.k2TargetPixelName(42, 111, true, false));

        assertEquals("ktwo000000042-c01_lpd-targ.fits.gz", formatter.k2TargetPixelName(42, 1, false, true));
        assertEquals("ktwo000000042-c11_lpd-targ.fits.gz", formatter.k2TargetPixelName(42, 11, false, true));
        assertEquals("ktwo000000042-c111_lpd-targ.fits.gz", formatter.k2TargetPixelName(42, 111, false, true));

        assertEquals("ktwo000000042-c01_spd-targ.fits.gz", formatter.k2TargetPixelName(42, 1, true, true));
        assertEquals("ktwo000000042-c11_spd-targ.fits.gz", formatter.k2TargetPixelName(42, 11, true, true));
        assertEquals("ktwo000000042-c111_spd-targ.fits.gz", formatter.k2TargetPixelName(42, 111, true, true));
    }
}
