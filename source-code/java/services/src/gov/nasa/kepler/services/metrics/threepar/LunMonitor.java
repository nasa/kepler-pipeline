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

package gov.nasa.kepler.services.metrics.threepar;

import static gov.nasa.kepler.services.metrics.threepar.LunMonitor.FieldEnum.HOST_NAME_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.LunMonitor.FieldEnum.IO_SEC_CURR_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.LunMonitor.FieldEnum.IO_SIZE_KB_CURR_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.LunMonitor.FieldEnum.KBYTES_SEC_CURR_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.LunMonitor.FieldEnum.LUN_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.LunMonitor.FieldEnum.PARTS_PER_LINE;
import static gov.nasa.kepler.services.metrics.threepar.LunMonitor.FieldEnum.QUEUE_LENGTH_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.LunMonitor.FieldEnum.READ_WRITE_TYPE_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.LunMonitor.FieldEnum.SVC_MS_CUR_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.LunMonitor.FieldEnum.VOL_NAME_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.UnitNameConstants.BASE10K;
import static gov.nasa.kepler.services.metrics.threepar.UnitNameConstants.BASE10_K_TO_BASE2_K;
import static gov.nasa.kepler.services.metrics.threepar.UnitNameConstants.IOOPS_SEC;
import static gov.nasa.kepler.services.metrics.threepar.UnitNameConstants.IO_SIZE_BYTES;
import static gov.nasa.kepler.services.metrics.threepar.UnitNameConstants.KBYTES_SEC;
import static gov.nasa.kepler.services.metrics.threepar.UnitNameConstants.QUEUE_LEN;
import static gov.nasa.kepler.services.metrics.threepar.UnitNameConstants.SVC_NS;
import gov.nasa.spiffy.common.metrics.ValueMetric;

import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * Generates statistics about the luns on the 3par system.
 * 
 *               22:43:40 06/18/08 r/w I/O per second KBytes per sec  Svt ms   IOSz KB
Lun      VVname       Host  Port      Cur  Avg  Max  Cur  Avg  Max Cur Avg  Cur  Avg Qlen
  0  opfsdata01      Prism 2:3:1   r    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
  0  opfsdata01      Prism 2:3:1   w    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
  0  opfsdata01      Prism 2:3:1   t    0    0    0    0    0    0 0.0 0.0  0.0  0.0    0
  3   opfslog01      Prism 2:3:1   r    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
  3   opfslog01      Prism 2:3:1   w    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
  3   opfslog01      Prism 2:3:1   t    0    0    0    0    0    0 0.0 0.0  0.0  0.0    0
 17  opfsdata02      Prism 2:3:1   r    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
 17  opfsdata02      Prism 2:3:1   w    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
 17  opfsdata02      Prism 2:3:1   t    0    0    0    0    0    0 0.0 0.0  0.0  0.0    0
 18   opfslog02      Prism 2:3:1   r    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
 18   opfslog02      Prism 2:3:1   w    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
 18   opfslog02      Prism 2:3:1   t    0    0    0    0    0    0 0.0 0.0  0.0  0.0    0
  0  opfsdata01      Prism 3:3:1   r    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
  0  opfsdata01      Prism 3:3:1   w    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
  0  opfsdata01      Prism 3:3:1   t    0    0    0    0    0    0 0.0 0.0  0.0  0.0    0
  3   opfslog01      Prism 3:3:1   r    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
  3   opfslog01      Prism 3:3:1   w    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
  3   opfslog01      Prism 3:3:1   t    0    0    0    0    0    0 0.0 0.0  0.0  0.0    0
 17  opfsdata02      Prism 3:3:1   r    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
 17  opfsdata02      Prism 3:3:1   w    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
 17  opfsdata02      Prism 3:3:1   t    0    0    0    0    0    0 0.0 0.0  0.0  0.0    0
 18   opfslog02      Prism 3:3:1   r    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
 18   opfslog02      Prism 3:3:1   w    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
 18   opfslog02      Prism 3:3:1   t    0    0    0    0    0    0 0.0 0.0  0.0  0.0    0
  4 oporadata01 Quaternion 2:3:2   r    0    0    0    0    0    0 0.0 0.0  0.0  0.0    -
  4 oporadata01 Quaternion 2:3:2   w    1    1    1   11   11   11 0.3 0.3 11.3 11.3    -
  4 oporadata01 Quaternion 2:3:2   t    1    1    1   11   11   11 0.3 0.3 11.3 11.3    0

 * @author Sean McCauliff
 *
 */
class LunMonitor extends AbstractMonitor {

    private static final Log log = LogFactory.getLog(LunMonitor.class);
    private final String cmd;
    
    LunMonitor(int pollSeconds) {
        cmd = "statvlun -rw -host Testfs -d " + pollSeconds;
    }
    
    @Override
    protected String command() {
        return cmd;
    }

    @Override
    protected String name() {
        return "Lun Statistics Poller";
    }

    @Override
    protected void processPoll(List<String> lines) {
	//log.info("Process poll called.");
        boolean seenHeader = false;
        for (String line : lines) {
            if (!seenHeader) {
                if (line.indexOf("Lun") != -1) {
                    seenHeader = true;
                }
                continue;
            }
            
            parseLine(line);
        }
    }
    
    public static enum FieldEnum {
        LUN_INDEX,
        VOL_NAME_INDEX,
        HOST_NAME_INDEX,
        PORT_NAME_INDEX,
        READ_WRITE_TYPE_INDEX,
        IO_SEC_CURR_INDEX,
        IO_SEC_AVG_INDEX,
        IO_SEC_MAX_INDEX,
        KBYTES_SEC_CURR_INDEX,
        KBYTES_SEC_AVG_INDEX,
        KBYTES_SEC_MAX_INDEX,
        SVC_MS_CUR_INDEX,
        SVC_MS_AVG_INDEX,
        IO_SIZE_KB_CURR_INDEX,
        IO_SIZE_KB_AVG_INDEX,
        QUEUE_LENGTH_INDEX,
        PARTS_PER_LINE
    }
    
    
    private void parseLine(String line) {
        String[] parts = line.trim().split("\\s+");
        if (parts.length != PARTS_PER_LINE.ordinal()) {
            return;
        }

        String lun = parts[LUN_INDEX.ordinal()];
        String volName = parts[VOL_NAME_INDEX.ordinal()];
        String hostName = parts[HOST_NAME_INDEX.ordinal()];
        String readWriteType = parts[READ_WRITE_TYPE_INDEX.ordinal()];

        String metricNamePrefix = 
            "lun-" + lun + "." + volName + "." + hostName + "." +readWriteType;

        int ioOpsPerSecond = Integer.parseInt(parts[IO_SEC_CURR_INDEX.ordinal()]);

        String ioOpsPerSecondKey = metricNamePrefix + IOOPS_SEC;
        ValueMetric.addValue(ioOpsPerSecondKey, ioOpsPerSecond);

        int kbytesSecond = Integer.parseInt(parts[KBYTES_SEC_CURR_INDEX.ordinal()]);
        kbytesSecond = (int) (kbytesSecond * BASE10_K_TO_BASE2_K);
        String kBytesSecKey = metricNamePrefix + KBYTES_SEC;
        ValueMetric.addValue(kBytesSecKey, kbytesSecond);

        double serviceTimeNanos = Double.parseDouble(parts[SVC_MS_CUR_INDEX.ordinal()]);
        serviceTimeNanos *= 1000.0;
        String serviceTimeNanosKey = metricNamePrefix + SVC_NS;
        ValueMetric.addValue(serviceTimeNanosKey, (long) serviceTimeNanos);

        double ioSizeBytes = Double.parseDouble(parts[IO_SIZE_KB_CURR_INDEX.ordinal()]);
        ioSizeBytes *= BASE10K * BASE10_K_TO_BASE2_K;
        String ioSizeBytesKey = metricNamePrefix + IO_SIZE_BYTES;
        ValueMetric.addValue(ioSizeBytesKey, (long) ioSizeBytes);

        String queueSizeStr = parts[QUEUE_LENGTH_INDEX.ordinal()];
        if (!queueSizeStr.equals("-")) {
            int queueSize = Integer.parseInt(queueSizeStr);
            String queueSizeKey = metricNamePrefix + QUEUE_LEN;
            ValueMetric.addValue(queueSizeKey, queueSize);
        }
        log.info(ioOpsPerSecondKey + " = " + ioOpsPerSecond);
    }

}
