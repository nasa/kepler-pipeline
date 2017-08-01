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

package gov.nasa.kepler.dr.pixels;

import static gov.nasa.kepler.common.FitsConstants.DCT_PURP_REV_CLK_VALUE;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.dr.RclcPixelLogCrud;
import gov.nasa.kepler.mc.dr.PixelTimeSeriesWriter;
import gov.nasa.kepler.mc.dr.RclcPixelTimeSeriesOperations;

import java.util.concurrent.Future;
import java.util.concurrent.ThreadPoolExecutor;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Dispatches rclc files.
 * 
 * @author Miles Cote
 * 
 */
public class RclcPixelDispatcher extends LongCadencePixelDispatcher {

    private static final Log log = LogFactory.getLog(RclcPixelDispatcher.class);

    public RclcPixelDispatcher() {
        super(new RclcPixelLogCrud());
    }

    @Override
    protected PixelTimeSeriesWriter createPixelTimeSeriesWriter(
        DataSetType dataSetType, int ccdModule, int ccdOutput) {
        log.info("Creating " + RclcPixelTimeSeriesOperations.class + "...");

        return new RclcPixelTimeSeriesOperations(dataSetType, ccdModule,
            ccdOutput);
    }

    @Override
    protected boolean handleReverseClocking(String fitsPath,
        boolean reverseClockingInEffect, PixelLog pixelLog,
        String dctPurpValue, String fitsFileName) {
        log.info("Handling reverse clocking...");

        if (reverseClockingInEffect && dctPurpValue != null
            && dctPurpValue.equals(DCT_PURP_REV_CLK_VALUE)) {
            pixelLog.setReverseClockingInEffect(reverseClockingInEffect);

            return false;
        } else {
            ignoredFilenames.add(fitsFileName);

            log.info("Excluded pixel log." + "\n  file: " + fitsPath
                + "\n  reverseClockingInEffect: " + reverseClockingInEffect
                + "\n  dctPurpValue: " + dctPurpValue);

            return true;
        }
    }

    @Override
    protected Future<?> checkAndFlush(ThreadPoolExecutor flusherThread,
        Future<?> flusherTaskResult) {
        timeSeriesBuffer.flush();

        return null;
    }

    @Override
    protected void check(Future<?> flusherTaskResult) {
        // Flusher thread is not used by this class, so there is nothing to
        // check.
    }

}
