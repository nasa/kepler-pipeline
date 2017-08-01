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

package gov.nasa.kepler.ar.exporter.ktc.verifier;


import java.util.List;

/**
 * Calculate the minumum and maximum times for something that has planned and
 * actual times.
 * 
 * @author Sean McCauliff
 *
 */
class MinMaxTimes {
    

    public static MinMaxTimes create(List<? extends ActualAndPlannedTimes> anpTimes) {
        MinMaxTimes mmt = new MinMaxTimes();
        
        for (ActualAndPlannedTimes anp : anpTimes) {
            if (anp.actualStartMjd() != null) {
                mmt.minActualStart = Math.min(anp.actualStartMjd(), mmt.minActualStart);
                mmt.maxActualStart = Math.max(anp.actualStartMjd(), mmt.maxActualStart);
            }
            if (anp.actualEndMjd() != null) {
                mmt.minActualEnd = Math.min(anp.actualEndMjd(), mmt.minActualEnd);
                mmt.maxActualEnd = Math.max(anp.actualEndMjd(), mmt.maxActualEnd);
            }
            mmt.minPlannedStart = Math.min(anp.plannedStartMjd(), mmt.minPlannedStart);
            mmt.maxPlannedStart = Math.max(anp.plannedStartMjd(), mmt.maxPlannedStart);
            mmt.minPlannedEnd = Math.min(anp.plannedEndMjd(), mmt.minPlannedEnd);
            mmt.maxPlannedEnd = Math.max(anp.plannedEndMjd(), mmt.maxPlannedEnd);
        }
        
        return mmt;
    }
    
    
    private double minActualStart =   Double.MAX_VALUE;
    private double maxActualStart = - 1;
    private double minActualEnd =     Double.MAX_VALUE;
    private double maxActualEnd =     -1;
    private double minPlannedStart = Double.MAX_VALUE;
    private double maxPlannedStart = -1;
    private double minPlannedEnd =    Double.MAX_VALUE;
    private double maxPlannedEnd = -  1;
    
    
    public double minActualStart() {
        return minActualStart;
    }
    public double maxActualStart() {
        return maxActualStart;
    }
    public double minActualEnd() {
        return minActualEnd;
    }
    public double maxActualEnd() {
        return maxActualEnd;
    }
    public double minPlannedStart() {
        return minPlannedStart;
    }
    public double maxPlannedStart() {
        return maxPlannedStart;
    }
    public double minPlannedEnd() { 
        return minPlannedEnd;
    }
    public double maxPlannedEnd() {
        return maxPlannedEnd;
    }
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        long temp;
        temp = Double.doubleToLongBits(maxActualEnd);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(maxActualStart);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(maxPlannedEnd);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(maxPlannedStart);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(minActualEnd);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(minActualStart);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(minPlannedEnd);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(minPlannedStart);
        result = prime * result + (int) (temp ^ (temp >>> 32));
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
        MinMaxTimes other = (MinMaxTimes) obj;
        if (Double.doubleToLongBits(maxActualEnd) != Double.doubleToLongBits(other.maxActualEnd))
            return false;
        if (Double.doubleToLongBits(maxActualStart) != Double.doubleToLongBits(other.maxActualStart))
            return false;
        if (Double.doubleToLongBits(maxPlannedEnd) != Double.doubleToLongBits(other.maxPlannedEnd))
            return false;
        if (Double.doubleToLongBits(maxPlannedStart) != Double.doubleToLongBits(other.maxPlannedStart))
            return false;
        if (Double.doubleToLongBits(minActualEnd) != Double.doubleToLongBits(other.minActualEnd))
            return false;
        if (Double.doubleToLongBits(minActualStart) != Double.doubleToLongBits(other.minActualStart))
            return false;
        if (Double.doubleToLongBits(minPlannedEnd) != Double.doubleToLongBits(other.minPlannedEnd))
            return false;
        if (Double.doubleToLongBits(minPlannedStart) != Double.doubleToLongBits(other.minPlannedStart))
            return false;
        return true;
    }
    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append("MinMaxTimes [maxActualEnd=")
            .append(maxActualEnd)
            .append(", maxActualStart=")
            .append(maxActualStart)
            .append(", maxPlannedEnd=")
            .append(maxPlannedEnd)
            .append(", maxPlannedStart=")
            .append(maxPlannedStart)
            .append(", minActualEnd=")
            .append(minActualEnd)
            .append(", minActualStart=")
            .append(minActualStart)
            .append(", minPlannedEnd=")
            .append(minPlannedEnd)
            .append(", minPlannedStart=")
            .append(minPlannedStart)
            .append("]");
        return builder.toString();
    }
   
    /**
     * 
     * @param a
     * @param descriptionA
     * @param b
     * @param descriptionB
     * @param plannedDelta If two planned times differ by less than this amount
     * then they are considered the same.
     * @return
     */
    public static String diff(MinMaxTimes a, String descriptionA, MinMaxTimes b, String descriptionB, double plannedDelta) {
        StringBuilder bldr = new StringBuilder();
        bldr.append("Different (t/f)\t").append("attr\t").append(descriptionA).append("\t").append(descriptionB).append("\n");
        
        boolean diff = false;
        diff = diffLine(" Min actual start  ", a.minActualStart,  b.minActualStart, bldr, 0) || diff;
        diff = diffLine(" Max actual start  ", a.maxActualStart, b.maxActualStart, bldr, 0) || diff;
        diff = diffLine(" Min actual end    ", a.minActualEnd, b.minActualEnd, bldr, 0) || diff;
        diff = diffLine(" Max actual end    ", a.maxActualEnd, b.maxActualEnd, bldr, 0) || diff;
        diff = diffLine(" Min planned start ", a.minPlannedStart, b.minPlannedStart, bldr, plannedDelta) || diff;
        diff = diffLine(" Max planned start ", a.maxPlannedStart, b.maxPlannedStart, bldr, plannedDelta) || diff;
        diff = diffLine(" Min planned end   ", a.minPlannedEnd, b.minPlannedEnd, bldr, plannedDelta) || diff;
        diff = diffLine(" Max planned end   ", a.maxPlannedEnd, b.maxPlannedEnd, bldr, plannedDelta) || diff;
        
        if (diff) {
            return bldr.toString();
        }
        return "";
        
    }
    
    private static boolean diffLine(String attributeDescription, 
                                    double a, double b, StringBuilder bldr, 
                                    double delta) {
        double diff = Math.abs(a - b);
        boolean diffFlag = diff > delta;
        bldr.append(diffFlag).append(attributeDescription).append(a).append("\t").append(b).append("\n");
        
        return diffFlag;
    }
}
