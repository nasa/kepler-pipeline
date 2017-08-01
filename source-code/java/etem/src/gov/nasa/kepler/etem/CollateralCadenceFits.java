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

import java.util.List;

import nom.tam.fits.FitsException;
import nom.tam.fits.Header;

/**
 * This class encapsulates the creation and access of the collateral data and
 * pixel mapping reference FITS files
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class CollateralCadenceFits extends CadenceFits {

    private static final String SCS_COL = "_scs-col";
    private static final String LCS_COL = "_lcs-col";

    public CollateralCadenceFits(String fitsDir, TargetType targetType,
        int cadenceNumber,
        double cadenceZeroMjd, List<Header> masterHeaders, int scConfigId,
        double secondsPerShortCadence,
        int shortCadencesPerLong,
        int compressionId, int badId, int bgpId, int tadId, int lctId,
        int sctId, int rptId, boolean hasMotion) throws Exception {

        super(fitsDir, targetType, 
            cadenceNumber, cadenceZeroMjd, masterHeaders, scConfigId,
            secondsPerShortCadence, shortCadencesPerLong,
            compressionId, badId, bgpId, tadId, lctId,
            sctId, rptId, hasMotion);
    }

    @Override
    protected String getSuffix(TargetType targetType) {
        switch (targetType) {
            case LONG_CADENCE:
                return LCS_COL;
            case SHORT_CADENCE:
                return SCS_COL;
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
                masterSuffix = LCS_COL;
                break;
            case SHORT_CADENCE:
                masterSuffix = SCS_COL;
                break;
        }

        return getMasterHeaders(masterFitsPath, masterSuffix);
    }

}
