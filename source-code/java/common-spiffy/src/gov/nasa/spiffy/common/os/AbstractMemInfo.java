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

package gov.nasa.spiffy.common.os;

import java.io.IOException;
import java.io.Reader;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.lang.management.MemoryUsage;

import javax.management.Notification;
import javax.management.NotificationEmitter;
import javax.management.NotificationListener;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author Forrest Girouard
 * 
 */
public abstract class AbstractMemInfo extends AbstractSysInfo implements
    MemInfo {

    private static final Log log = LogFactory.getLog(AbstractMemInfo.class);

    private static final long BYTES_PER_KB = 1024L;

    public AbstractMemInfo(Reader memInfo) throws IOException {

        super(memInfo);
    }

    public abstract String getTotalMemoryKey();

    public abstract String getFreeMemoryKey();

    public abstract String getBuffersKey();

    public abstract String getCachedKey();

    public abstract String getCachedSwapKey();

    public abstract String getTotalSwapKey();

    public abstract String getFreeSwapKey();

    @Override
    public long getTotalMemoryKB() {
        return getValueInKb(getTotalMemoryKey());
    }

    @Override
    public long getFreeMemoryKB() {
        return getValueInKb(getFreeMemoryKey());
    }

    @Override
    public long getBuffersKB() {
        return getValueInKb(getBuffersKey());
    }

    @Override
    public long getCachedKB() {
        return getValueInKb(getCachedKey());
    }

    @Override
    public long getCachedSwapedKB() {
        return getValueInKb(getCachedSwapKey());
    }

    @Override
    public long getTotalSwapKB() {
        return getValueInKb(getTotalSwapKey());
    }

    @Override
    public long getFreeSwapKB() {
        return getValueInKb(getFreeSwapKey());
    }

    private long getValueInKb(String key) {
        if (key == null) {
            return -1L;
        }

        long longValue = 0L;
        String value = get(key.toLowerCase());
        if (value != null && value.length() > 0) {
            String[] parts = value.split(" ");
            if (parts.length > 0) {
                try {
                    longValue = Long.valueOf(parts[0]);
                } catch (NumberFormatException ignore) {
                }
                if (parts.length > 1) {
                    if (parts[1].equalsIgnoreCase("GB")) {
                        longValue *= BYTES_PER_KB * BYTES_PER_KB;
                    } else if (parts[1].equalsIgnoreCase("MB")
                        || parts[1].equalsIgnoreCase("M")) {
                        longValue *= BYTES_PER_KB;
                    }
                }
            }
        }

        log.debug(String.format("%s: %,d KB", key, longValue));

        return longValue;
    }

    @Override
    public MemoryUsage getMemoryUsage(boolean heap) {
        return AbstractMemInfo.getJvmMemoryUsage(heap);
    }

    static MemoryUsage getJvmMemoryUsage(boolean heap) {

        MemoryMXBean mbean = ManagementFactory.getMemoryMXBean();
        NotificationEmitter emitter = (NotificationEmitter) mbean;
        emitter.addNotificationListener(new NotificationListener() {

            @Override
            public void handleNotification(Notification notification,
                Object handback) {
                // TODO Auto-generated method stub
            }

        }, null, null);

        MemoryUsage memoryUsage = heap ? mbean.getHeapMemoryUsage()
            : mbean.getNonHeapMemoryUsage();

        return memoryUsage;
    }
}
