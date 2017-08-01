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

import static gov.nasa.kepler.services.metrics.threepar.PhysicalDiskMonitor.DiskTotalsEnum.IO_SEC_CURR_TOTAL_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.PhysicalDiskMonitor.DiskTotalsEnum.IO_SIZE_KBYTES_CURR_TOTAL_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.PhysicalDiskMonitor.DiskTotalsEnum.KBYTES_SEC_CUR_TOTAL_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.PhysicalDiskMonitor.DiskTotalsEnum.QLEN_TOTAL_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.PhysicalDiskMonitor.DiskTotalsEnum.READ_WRITE_TOTAL_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.PhysicalDiskMonitor.DiskTotalsEnum.SVC_MS_CURR_TOTAL_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.PhysicalDiskMonitor.DiskTotalsEnum.TOTAL_NUM_FIELDS;
import static gov.nasa.kepler.services.metrics.threepar.PhysicalDiskMonitor.PerDiskEnum.DISK_NUM_FIELDS;
import static gov.nasa.kepler.services.metrics.threepar.PhysicalDiskMonitor.PerDiskEnum.IDLE_PCT_CURR_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.PhysicalDiskMonitor.PerDiskEnum.QLEN_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.PhysicalDiskMonitor.PerDiskEnum.READ_WRITE_INDEX;
import static gov.nasa.kepler.services.metrics.threepar.UnitNameConstants.BASE10K;
import static gov.nasa.kepler.services.metrics.threepar.UnitNameConstants.BASE10_K_TO_BASE2_K;
import static gov.nasa.kepler.services.metrics.threepar.UnitNameConstants.IOOPS_SEC;
import static gov.nasa.kepler.services.metrics.threepar.UnitNameConstants.IO_SIZE_BYTES;
import static gov.nasa.kepler.services.metrics.threepar.UnitNameConstants.KBYTES_SEC;
import static gov.nasa.kepler.services.metrics.threepar.UnitNameConstants.SVC_US;
import gov.nasa.spiffy.common.metrics.ValueMetric;

import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;

/**
 * Monitor physical disk activity.
 * 
 * @author Sean McCauliff
 *
 */
class PhysicalDiskMonitor extends AbstractMonitor {

    private static final Log log = LogFactory.getLog(PhysicalDiskMonitor.class);
    
    private final String cmd;
    private final DescriptiveStatistics queueStats = new DescriptiveStatistics();
    private final DescriptiveStatistics idleStats = new DescriptiveStatistics();
    
    
    PhysicalDiskMonitor(int pollInterval) {
        cmd = "statpd -rw -d " + pollInterval;
    }
    
    /* (non-Javadoc)
     * @see gov.nasa.kepler.threepar.AbstractMonitor#command()
     */
    @Override
    protected String command() {
        return cmd;
    }

    /* (non-Javadoc)
     * @see gov.nasa.kepler.threepar.AbstractMonitor#name()
     */
    @Override
    protected String name() {
        return "Physical Disk Monitor";
    }

    /**
     * @see gov.nasa.kepler.services.metrics.threepar.AbstractMonitor#processPoll(java.util.List)
     */
    @Override
    protected void processPoll(List<String> lines) {
        boolean foundStart = false;
        boolean foundTotals = false;
        for (String line : lines) {
            if (!foundStart) {
                foundStart = line.indexOf("Qlen") != -1;
                continue;
            }
            
            if (line.indexOf("---------------------------") != -1) {
                foundTotals = true;
                continue;
            }
            
            if (foundTotals) {
                parseTotals(line);
            } else {
                parseDisk(line);
            }
        }
    }

    //  ID     Port      Cur  Avg  Max  Cur  Avg  Max  Cur  Avg   Cur   Avg Qlen Cur Avg
    public static enum PerDiskEnum {
        DISK_ID_INDEX,
        PORT_INDEX,
        READ_WRITE_INDEX,
        IO_SEC_CURR_INDEX,
        IO_SEC_AVG_INDEX,
        IO_SEC_MAX_INDEX,
        KBYTES_SEC_CUR_INDEX,
        KBYTES_SEC_AVG_INDEX,
        KBYTES_SEC_MAX_INDEX,
        SVC_MS_CURR_INDEX,
        SVC_MS_AVG_INDEX,
        IO_SIZE_KBYTES_CURR_INDEX,
        IO_SIZE_KBYTES_AVG_INDEX,
        QLEN_INDEX,
        IDLE_PCT_CURR_INDEX,
        IDLE_PCT_AVG_INDEX,
        DISK_NUM_FIELDS
    }
    
    private void parseDisk(String line) {
        String[] parts = line.trim().split("\\s+");
        if (parts.length != DISK_NUM_FIELDS.ordinal()) {
            return;
        }
        
        if (!parts[READ_WRITE_INDEX.ordinal()].equals("t")) {
            return;
        }
        int idlePctCurr = Integer.parseInt(parts[IDLE_PCT_CURR_INDEX.ordinal()]);
        idleStats.addValue(idlePctCurr);
        
        int qlen = Integer.parseInt(parts[QLEN_INDEX.ordinal()]);
        queueStats.addValue(qlen);

    }
    
    public static enum DiskTotalsEnum {
        DISK_ID_TOTAL_INDEX,
        READ_WRITE_TOTAL_INDEX,
        IO_SEC_CURR_TOTAL_INDEX,
        IO_SEC_AVG_INDEX,
        KBYTES_SEC_CUR_TOTAL_INDEX,
        KBYTES_SEC_AVG_TOTAL_INDEX,
        SVC_MS_CURR_TOTAL_INDEX,
        SVC_MS_AVG_TOTAL_INDEX,
        IO_SIZE_KBYTES_CURR_TOTAL_INDEX,
        IO_SIZE_KBYTES_AVG_TOTAL_INDEX,
        QLEN_TOTAL_INDEX,
        IDLE_PCT_CURR_TOTAL_INDEX,
        IDLE_PCT_AVG_TOTAL_INDEX,
        TOTAL_NUM_FIELDS
        
    }
    
    private void parseTotals(String line) {
        log.info("Totals line: " + line);
        String[] parts = line.trim().split("\\s+");
        if (parts.length != TOTAL_NUM_FIELDS.ordinal()) {
            return;
        }
        
//        if (!parts[DISK_ID_TOTAL_INDEX.ordinal()].equals("total")) {
//            return;
//        }
        
        String readWrite = parts[READ_WRITE_TOTAL_INDEX.ordinal()];
        String keyPrefix = "threepar-physical-disk.totals." + readWrite;
        
        int ioopsSec = Integer.parseInt(parts[IO_SEC_CURR_TOTAL_INDEX.ordinal()]);
        ValueMetric.addValue(keyPrefix + IOOPS_SEC,  ioopsSec);
        
        int kbytesSec = Integer.parseInt(parts[KBYTES_SEC_CUR_TOTAL_INDEX.ordinal()]);
        ValueMetric.addValue(keyPrefix + KBYTES_SEC, kbytesSec);
        
        double svcUs = Double.parseDouble(parts[SVC_MS_CURR_TOTAL_INDEX.ordinal()]);
        svcUs *= 1000.0;
        ValueMetric.addValue(keyPrefix + SVC_US, (long) svcUs);
        
        double ioSizeBytes = Double.parseDouble(parts[IO_SIZE_KBYTES_CURR_TOTAL_INDEX.ordinal()]);
        ioSizeBytes *= BASE10K * BASE10_K_TO_BASE2_K;
        ValueMetric.addValue(keyPrefix + IO_SIZE_BYTES, (long) ioSizeBytes);
        
        String queueLengthStr = parts[QLEN_TOTAL_INDEX.ordinal()];
        if (!queueLengthStr.equals("-")) {
            
            ValueMetric.addValue(keyPrefix + ".queue.mean", (long) queueStats.getMean());
            ValueMetric.addValue(keyPrefix + ".queue.max", (long) queueStats.getMax());
            ValueMetric.addValue(keyPrefix + ".queue.min", (long) queueStats.getMin());
            ValueMetric.addValue(keyPrefix + ".queue.n-4sigma", (long) nAboveThreshold(queueStats));
            queueStats.clear();
            
            ValueMetric.addValue(keyPrefix + ".pct-util.mean", (long) this.idleStats.getMean());
            ValueMetric.addValue(keyPrefix + ".pct-util.max", (long) this.idleStats.getMax());
            ValueMetric.addValue(keyPrefix + ".pct-util.min", (long) this.idleStats.getMin());
            ValueMetric.addValue(keyPrefix + ".pct-util.n-4sigma", (long) nAboveThreshold(idleStats));
            idleStats.clear();
        }
        
    }
    
    private static long nAboveThreshold(DescriptiveStatistics stat) {
        double mean  = stat.getMean();
        if (mean == 0) {
            return 0;
        }
        double sd = stat.getStandardDeviation();
        double[] values = stat.getValues();
        int count=0;
        for (double v : values) {
            if ( Math.abs(v - mean) / sd > 4.0) {
                count++;
            }
        }
        return count;
    }


}
