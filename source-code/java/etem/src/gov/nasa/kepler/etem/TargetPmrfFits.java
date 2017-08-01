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

package gov.nasa.kepler.etem;

import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.List;

import nom.tam.fits.BinaryTable;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;

/**
 * This class encapsulates the creation and access of the target data and pixel
 * mapping reference FITS files
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class TargetPmrfFits extends PmrfFits {

    private static final String BGM = "_bgm";
    public static final String SCM = "_scm";
    public static final String LCM = "_lcm";

    public TargetPmrfFits(String fitsDir, TargetType targetType,
        double cadenceZeroMjd,
        List<Header> masterHeaders, int scConfigId, 
        double secondsPerShortCadence, int shortCadencesPerLong,
        int compressionId, int badId, int bgpId, int tadId, int lctId,
        int sctId, int rptId)
        throws Exception {

        super(fitsDir, targetType, 
            cadenceZeroMjd, masterHeaders, scConfigId, 
            secondsPerShortCadence, shortCadencesPerLong,
            compressionId, badId, bgpId, tadId, lctId,
            sctId, rptId);
    }

    protected String getSuffix(TargetType targetType) {
        NumberFormat formatter = new DecimalFormat("000");
        String badIdString = formatter.format(Math.abs(badId));
        String bgpIdString = formatter.format(Math.abs(bgpId));
        String tadIdString = formatter.format(Math.abs(tadId));
        String lctIdString = formatter.format(Math.abs(lctId));
        String sctIdString = formatter.format(Math.abs(sctId));

        switch (targetType) {
            case LONG_CADENCE:
                return "-" + lctIdString + "-" + tadIdString + LCM;
            case SHORT_CADENCE:
                return "-" + sctIdString + "-" + tadIdString + SCM;
            case BACKGROUND:
                return "-" + bgpIdString + "-" + badIdString + BGM;
            default:
                throw new PipelineException("Invalid target type " + targetType
                    + " for " + this.getClass()
                        .getName());
        }
    }

    public static List<Header> getMasterHeaders(String masterFitsPath,
        TargetType targetType) throws FitsException {
        String masterSuffix = null;

        switch (targetType) {
            case LONG_CADENCE:
                masterSuffix = LCM;
                break;
            case SHORT_CADENCE:
                masterSuffix = SCM;
                break;
            case BACKGROUND:
                masterSuffix = BGM;
                break;
        }

        return getMasterHeaders(masterFitsPath, masterSuffix);
    }

    public void addColumns(int[] targetIdColumn, short[] apertureIdColumn,
        short[] rowColumn, short[] colColumn) throws FitsException, IOException {

        BinaryTable binaryTable = new BinaryTable(new Object[] { rowColumn,
            colColumn, targetIdColumn, apertureIdColumn });

        addBinaryTableHdu(binaryTable);
    }
}
