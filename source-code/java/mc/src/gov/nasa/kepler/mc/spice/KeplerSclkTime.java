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

package gov.nasa.kepler.mc.spice;

/**
 * This class represents time according to the Kepler Spacecraft Clock.
 * 
 * <p>- From
 * svn+ssh://host/path/to/test-data/kplr2008178193843.tsc:
 * <p>-
 * <p>- SCLK Format
 * <p>- --------------------------------------------------------
 * <p>-
 * <p>- The on-board clock, the conversion for which is provided by this
 * <p>- SCLK file, consists of two fields:
 * <p>-
 * <p>- SSSSSSSSSS.MMMMMM
 * <p>-
 * <p>- where:
 * <p>-
 * <p>- SSSSSSSSSS -- count of on-board seconds
 * <p>-
 * <p>- MMMMMM -- count of microseconds
 * 
 * @author Miles Cote
 * 
 */
public class KeplerSclkTime {

    private static final long MAX_SECOND_INCREMENTS = 4908535265L;
    private static final long MAX_MICROSECOND_INCREMENTS = 183600L;

    private long secondIncrements;
    private long microsecondIncrements;

    public KeplerSclkTime(long secondIncrements, long microsecondIncrements)
        throws SpiceException {
        if (secondIncrements < 0) {
            throw new SpiceException(
                "secondsIncrements must not be less than zero.\n  secondsIncrements: "
                    + secondIncrements);
        }

        if (microsecondIncrements < 0) {
            throw new SpiceException(
                "microsecondIncrements must not be less than zero.\n  microsecondIncrements: "
                    + microsecondIncrements);
        }

        if (secondIncrements > MAX_SECOND_INCREMENTS
            || secondIncrements == MAX_SECOND_INCREMENTS
            && microsecondIncrements > MAX_MICROSECOND_INCREMENTS) {
            throw new SpiceException("KeplerSclkTime must not be greater than "
                + MAX_SECOND_INCREMENTS + "." + MAX_MICROSECOND_INCREMENTS
                + ".\n  secondIncrements: " + secondIncrements
                + "\n  microsecondsIncrements: " + microsecondIncrements);
        }

        this.secondIncrements = secondIncrements;
        this.microsecondIncrements = microsecondIncrements;
    }

    public double getSeconds() {
        return ((double) secondIncrements) + ((double) microsecondIncrements)
            / 1000000E0;
    }

    public long getSecondIncrements() {
        return secondIncrements;
    }

    public long getMicrosecondIncrements() {
        return microsecondIncrements;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + (int) (microsecondIncrements ^ (microsecondIncrements >>> 32));
        result = prime * result
            + (int) (secondIncrements ^ (secondIncrements >>> 32));
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        final KeplerSclkTime other = (KeplerSclkTime) obj;
        if (microsecondIncrements != other.microsecondIncrements)
            return false;
        if (secondIncrements != other.secondIncrements)
            return false;
        return true;
    }

    @Override
    public String toString() {
        return secondIncrements + "." + microsecondIncrements;
    }

}
