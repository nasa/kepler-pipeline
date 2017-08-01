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

import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.io.IOException;
import java.util.Date;
import java.util.List;

import nom.tam.fits.BinaryTable;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCardException;

/**
 * Represents a cadence fits file.
 * 
 * @author Miles Cote
 * 
 */
public abstract class CadenceFits extends KeplerFits {

    protected int cadenceNumber;

    protected double secondsPerCadence;
    protected double cadenceMjd;

    protected CadenceFits(String fitsDir, TargetType targetType,
        int cadenceNumber, double cadenceZeroMjd, List<Header> masterHeaders,
        int scConfigId, double secondsPerShortCadence,
        int shortCadencesPerLong, int compressionId, int badId, int bgpId,
        int tadId, int lctId, int sctId, int rptId, boolean hasMotion)
        throws Exception {

        super(fitsDir, targetType, cadenceZeroMjd, masterHeaders, scConfigId,
            secondsPerShortCadence, shortCadencesPerLong, compressionId, badId,
            bgpId, tadId, lctId, sctId, rptId, hasMotion);

        this.cadenceNumber = cadenceNumber;
        this.cadenceZeroMjd = cadenceZeroMjd;

        initialize();
    }

    @Override
    protected Date getTimestamp() {
        secondsPerCadence = 0;
        switch (cadenceType) {
            case LONG:
                secondsPerCadence = secondsPerShortCadence
                    * shortCadencesPerLong;
                break;
            case SHORT:
                secondsPerCadence = secondsPerShortCadence;
                break;
        }

        cadenceMjd = getStartMjd(cadenceNumber + 1);
        Date cadenceDate = ModifiedJulianDate.mjdToDate(cadenceMjd);
        return cadenceDate;
    }

    private double getStartMjd(int cadenceNumber) {
        double secondsFromCadenceZero = cadenceNumber * secondsPerCadence;
        double daysFromCadenceZero = secondsFromCadenceZero / 86400;
        double startMjd = cadenceZeroMjd + daysFromCadenceZero;

        return startMjd;
    }

    @Override
    protected void addSpecificKeywordsToPrimaryHdu() throws HeaderCardException {
        switch (cadenceType) {
            case LONG:
                primaryHeader.addValue(LC_INTER_KW,
                    cadenceNumber, "");
                break;
            case SHORT:
                primaryHeader.addValue(SC_INTER_KW,
                    cadenceNumber, "");

                // Also set LC_INTER in the sc case because the sc cal export
                // depends on the LC_INTER keyword.
                // Use integer division so that short cadences 0 to 29 map to
                // long cadence 0, etc.
                primaryHeader.addValue(LC_INTER_KW,
                    cadenceNumber / shortCadencesPerLong, "");
                break;
        }

        primaryHeader.addValue(STARTIME_KW,
            getStartMjd(cadenceNumber), "");
        primaryHeader.addValue(END_TIME_KW,
            getStartMjd(cadenceNumber + 1), "");
    }

    public void addColumns(int[] rawValueColumn) throws FitsException,
        IOException {

        BinaryTable binaryTable = new BinaryTable(
            new Object[] { rawValueColumn });

        addBinaryTableHdu(binaryTable);
    }

}
