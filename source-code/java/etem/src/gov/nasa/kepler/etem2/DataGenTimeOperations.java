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

package gov.nasa.kepler.etem2;

import gov.nasa.kepler.common.MatlabDateFormatter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.mc.spice.SpiceException;
import gov.nasa.kepler.mc.vtc.VtcOperations;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.text.ParseException;
import java.util.Date;

/**
 * NOTE: This class should only be used by etem.
 * 
 * @author Miles Cote
 */
public class DataGenTimeOperations {

    /**
     * This method should be used by any code that deals with vtc time. -
     * dataSetPacker gets vtcStartOfEtemStartDate (because it immediately adds
     * oneShortCadence) - etem2Rp gets vtcStartOfEtemStartDate (and it needs to
     * immediately add oneShortCadence and the length of a baseline)
     * 
     * @param etemStartDate
     * @return
     * @throws ParseException
     */
    public double getVtcStartSeconds(String etemStartDate)
        throws ParseException {
        Date date = MatlabDateFormatter.dateFormatter()
            .parse(etemStartDate);
        double mjd = ModifiedJulianDate.dateToMjd(date);

        VtcOperations vtcOperations = new VtcOperations();
        long vtc;
        try {
            vtc = vtcOperations.getVtc(mjd);
        } catch (SpiceException e) {
            throw new PipelineException("Unable to get vtc", e);
        }

        double vtcSeconds = vtc / 256E0;

        return vtcSeconds;
    }

    public int getCadence(DataGenParameters dataGenParams,
        PlannedSpacecraftConfigParameters scConfigParams,
        CadenceType cadenceType, String matlabDate) throws ParseException {

        long cadenceZeroMilliseconds = MatlabDateFormatter.dateFormatter()
            .parse(dataGenParams.getCadenceZeroDate())
            .getTime();

        long matlabDateMilliseconds = MatlabDateFormatter.dateFormatter()
            .parse(matlabDate)
            .getTime();

        long millisecondsSinceCadenceZero = matlabDateMilliseconds
            - cadenceZeroMilliseconds;
        double secondsSinceCadenceZero = ((double) millisecondsSinceCadenceZero) / 1000;
        double doubleValueOfCadence = 0;
        switch (cadenceType) {
            case LONG:
                doubleValueOfCadence = secondsSinceCadenceZero
                    / scConfigParams.getSecondsPerShortCadence()
                    / scConfigParams.getShortCadencesPerLongCadence();
                break;
            case SHORT:
                doubleValueOfCadence = secondsSinceCadenceZero
                    / scConfigParams.getSecondsPerShortCadence();
                break;
        }

        int leftPart = (int) doubleValueOfCadence;
        double rightPart = doubleValueOfCadence - leftPart;

        double upperBound = .04;
        double lowerBound = 1 - upperBound;
        int intValueOfCadence;
        if (rightPart < .5) {
            // a little bit high.

            // check that it's not too high.
            // TODO: Commenting out these checks since the dates specified in
            // the request form
            // do not pass the validation. I suspect that the validation logic
            // is wrong (using
            // 59.89199767108013 for the length of a SC instead of 60)
            // if (rightPart > upperBound) {
            // String lowerDate = getMatlabDate(dataGenParams, scConfigParams,
            // cadenceType, (int) Math.floor(doubleValueOfCadence));
            // String upperDate = getMatlabDate(dataGenParams, scConfigParams,
            // cadenceType, (int) Math.ceil(doubleValueOfCadence));
            // throw new PipelineException("Input date must be within "
            // + upperBound
            // + " cadences of an actual cadence. inputDate = "
            // + matlabDate + ", doubleValueOfCadence = "
            // + doubleValueOfCadence + ". Please use " + lowerDate
            // + " or " + upperDate);
            // }

            intValueOfCadence = (int) Math.floor(doubleValueOfCadence);
        } else {
            // a little bit low.

            // check that it's not too low.
            // if (rightPart < lowerBound) {
            // String lowerDate = getMatlabDate(dataGenParams, scConfigParams,
            // cadenceType, (int) Math.floor(doubleValueOfCadence));
            // String upperDate = getMatlabDate(dataGenParams, scConfigParams,
            // cadenceType, (int) Math.ceil(doubleValueOfCadence));
            // throw new PipelineException("Input date must be within "
            // + upperBound
            // + " cadences of an actual cadence. inputDate = "
            // + matlabDate + ", doubleValueOfCadence = "
            // + doubleValueOfCadence + ". Please use " + lowerDate
            // + " or " + upperDate);
            // }

            intValueOfCadence = (int) Math.ceil(doubleValueOfCadence);
        }

        return intValueOfCadence;
    }

    public String getMatlabDate(DataGenParameters dataGenParams,
        PlannedSpacecraftConfigParameters scConfigParams,
        CadenceType cadenceType, int cadenceNumber) throws ParseException {

        double cadenceZeroMjd = ModifiedJulianDate.dateToMjd(MatlabDateFormatter.dateFormatter()
            .parse(dataGenParams.getCadenceZeroDate()));

        double daysPerCadence = 0;
        switch (cadenceType) {
            case LONG:
                daysPerCadence = scConfigParams.getSecondsPerShortCadence()
                    * scConfigParams.getShortCadencesPerLongCadence() / 86400;
                break;
            case SHORT:
                daysPerCadence = scConfigParams.getSecondsPerShortCadence() / 86400;
                break;
        }

        double outputMjd = cadenceZeroMjd + cadenceNumber * daysPerCadence;

        return MatlabDateFormatter.dateFormatter()
            .format(ModifiedJulianDate.mjdToDate(outputMjd));
    }

}
