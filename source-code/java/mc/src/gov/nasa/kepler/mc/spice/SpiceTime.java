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

import java.io.File;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class supports conversion to and from MJD and {@link KeplerSclkTime}.
 * It uses the SPICE {@link LeapSecondsKernel} and SPICE
 * {@link KeplerSpacecraftClockKernel} correctly (i.e. the date conversions
 * exactly match the date conversions of the chronos tool in the NAIF toolkit).
 * This class is accurate to plus/minus one millisecond, with the exception of
 * the limitation below.
 * 
 * <p>- Limitations:
 * 
 * <p>- Accounting for multiple SCLK "partitions" has not been implemented.
 * This is not needed for Kepler.
 * 
 * <p>- Note that although the SCLK -> UTC mapping is a one-to-one function,
 * the mapping UTC -> SCLK is not one-to-one in java. For example, the dates
 * "2005-12-31 23:59:60.000" and "2006-01-01 00:00:00.000" both map to
 * 1136073600000 milliseconds, when in fact, they should map to a different
 * number of milliseconds since they are different points in time. Therefore,
 * the UTC -> SCLK mapping is undefined from the start of a leap second to the
 * end of a leap second.
 * 
 * @author Miles Cote
 * 
 */
public class SpiceTime {
    
    private static final Log log = LogFactory.getLog(SpiceTime.class);

    static final int SECONDS_PER_DAY = 86400;

    private double epochMjd;
    private KeplerSpacecraftClockKernel sclkKernel;
    private LeapSecondsKernel lskKernel;

    public SpiceTime(double epochMjd, KeplerSpacecraftClockKernel sclkKernel,
        LeapSecondsKernel lskKernel) {
        this.epochMjd = epochMjd;
        this.sclkKernel = sclkKernel;
        this.lskKernel = lskKernel;
    }

    public SpiceTime(double epochMjd, File sclkKernelFile, File lskKernelFile)
        throws SpiceException {
        SpiceKernelFileReader reader = new SpiceKernelFileReader(sclkKernelFile);
        this.sclkKernel = new KeplerSpacecraftClockKernel(
            reader.getKernelData());

        reader = new SpiceKernelFileReader(lskKernelFile);
        this.lskKernel = new LeapSecondsKernel(reader.getKernelData(), epochMjd);

        this.epochMjd = epochMjd;
    }

    public double getMjd(KeplerSclkTime keplerSclkTime) throws SpiceException {
        double ephemeralSecondsSinceEpoch = sclkKernel.getEphemeralSecondsSinceEpoch(keplerSclkTime);

        double utcSecondsSinceEpoch = lskKernel.getUtcSecondsSinceEpoch(ephemeralSecondsSinceEpoch);

        double daysSinceEpoch = utcSecondsSinceEpoch / SECONDS_PER_DAY;

        log.info("daysSinceEpoch" + daysSinceEpoch);
        double mjd = epochMjd + daysSinceEpoch;

        return mjd;
    }

    public KeplerSclkTime getKeplerSclkTime(double mjd) throws SpiceException {
        double daysSinceEpoch = mjd - epochMjd;

        log.info("daysSinceEpoch" + daysSinceEpoch);
        double utcSecondsSinceEpoch = daysSinceEpoch * SECONDS_PER_DAY;

        double ephemeralSecondsSinceEpoch = lskKernel.getEphemeralSecondsSinceEpoch(utcSecondsSinceEpoch);

        KeplerSclkTime keplerSclkTime = sclkKernel.getKeplerSclkTime(ephemeralSecondsSinceEpoch);

        return keplerSclkTime;
    }

}
