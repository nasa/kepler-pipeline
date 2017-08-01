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

package gov.nasa.kepler.pi.metrics.report;

import java.text.ParseException;
import java.text.SimpleDateFormat;

import org.jfree.util.Log;

/**
 * A single line from a memdrone log file.
 * 
 * Lines in the memdrone log take the following form:
 * 
 * LINE:   Tue Aug 14 06:39:13 PDT 2012 tps             43085  172  3.4 845252 
 * FIELD#: 0   1   2  3        4   5    6               7      8    9   10
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class MemdroneSample {

    private String processName = "";
    private String processId = "";
    private long timestampMillis = 0L;
    private float percentCpu = -1.0f;
    private float percentMemory = -1.0f;
    private int memoryKilobytes = 0;
    
    private boolean valid = false;
    
    private static final SimpleDateFormat timestampFormat = new SimpleDateFormat("EEE MMM dd kk:mm:ss zzz yyyy");
    
    public MemdroneSample(String memdroneLogLine){
        valid = parse(memdroneLogLine);
    }
    
    public MemdroneSample(String processName, String processId, long timestampMillis,
        float percentCpu, float percentMemory, int memoryKilobytes) {
        this.processName = processName;
        this.processId = processId;
        this.timestampMillis = timestampMillis;
        this.percentCpu = percentCpu;
        this.percentMemory = percentMemory;
        this.memoryKilobytes = memoryKilobytes;
        
        valid = true;
    }

    private boolean parse(String memdroneLogLine){
        String[] elements = memdroneLogLine.split("\\s+");
        
        if(elements.length != 11){
            Log.warn("Parse error, num elements != 11 : " + memdroneLogLine);
            return false;
        }else{
            processName = elements[6];
            processId = elements[7];
            String timestampString = elements[0] + " " + // day of week
            elements[1] + " " + // month
            elements[2] + " " + // date
            elements[3] + " " + // time
            elements[4] + " " + // TZ
            elements[5];        // year

            try {
                timestampMillis = parseDate(timestampString);
                percentCpu = Float.parseFloat(elements[8]);
                percentMemory = Float.parseFloat(elements[9]);
                memoryKilobytes = Integer.parseInt(elements[10]);
            } catch (Exception e) {
                Log.warn("Parse error: " + e);
                return false;
            }
            return true;
        }
    }
    
    private long parseDate(String s) throws ParseException {
        return timestampFormat.parse(s).getTime();
    }

    public String getProcessName() {
        return processName;
    }

    public String getProcessId() {
        return processId;
    }

    public long getTimestampMillis() {
        return timestampMillis;
    }

    public float getPercentCpu() {
        return percentCpu;
    }

    public float getPercentMemory() {
        return percentMemory;
    }

    public int getMemoryKilobytes() {
        return memoryKilobytes;
    }

    public boolean isValid() {
        return valid;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        return "MemdroneSample [processName=" + processName + ", processId=" + processId + ", percentCpu=" + percentCpu
            + ", percentMemory=" + percentMemory + ", memoryKilobytes=" + memoryKilobytes + ", timestampMillis="
            + timestampMillis + ", valid=" + valid + "]";
    }
}
