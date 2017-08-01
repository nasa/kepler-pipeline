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

package gov.nasa.kepler.ar.exporter.ktc;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.hibernate.tad.KtcInfo;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Eventually turn this into a line in the KTC.
 * 
 * @author Sean McCauliff
 * 
 */
public class CompletedKtcEntry implements Comparable<CompletedKtcEntry> {

    private static final char SEPARATOR_CHAR = '|';

    final String category;
    final Double actualStart;
    final Double actualStop;
    final String investigation;
    final double planStart;
    final double planStop;
    final int keplerId;
    final TargetTable.TargetType targetType;

    public CompletedKtcEntry(String category, Double actualStart,
        Double actualStop, String investigation, double planStart,
        double planStop, int keplerId, TargetType targetType) {
        this.category = category;
        this.actualStart = actualStart;
        this.actualStop = actualStop;
        this.investigation = investigation;
        this.planStart = planStart;
        this.planStop = planStop;
        this.keplerId = keplerId;
        this.targetType = targetType;

        validate();
    }

    CompletedKtcEntry(KtcInfo ktcInfo, String category, Double actualStart,
        Double actualStop, String investigation) {
        this.category = category;
        this.actualStart = actualStart;
        this.actualStop = actualStop;
        this.investigation = investigation;
        this.planStart = convertToDouble(ktcInfo.start);
        this.planStop = convertToDouble(ktcInfo.end);
        this.keplerId = ktcInfo.keplerId;
        this.targetType = ktcInfo.type;

        validate();
    }

    private void validate() {
        if (investigation == null) {
            throw new NullPointerException("Investigation may not be null.");
        }
        if (targetType == null) {
            throw new NullPointerException("targetType may not be null.");
        }
        if (category == null) {
            throw new NullPointerException("category may not be null.");
        }
        if (actualStart == null ^ actualStop == null) {
            throw new NullPointerException(
                "ActualStart and actualStop must both"
                    + " be null if one of them is null.");
        }
    }

    @Override
    public int compareTo(CompletedKtcEntry o) {
        int diff = this.keplerId - o.keplerId;
        if (diff != 0) {
            return diff;
        }
        if (this.targetType != o.targetType) {
            if (this.targetType == TargetTable.TargetType.LONG_CADENCE) {
                return -1;
            } else {
                return 1;
            }
        }

        diff = compareActualTimes(this.actualStart, o.actualStart);
        if (diff != 0) {
            return diff;
        }
        diff = compareActualTimes(this.actualStop, o.actualStop);
        if (diff != 0) {
            return diff;
        }

        diff = Double.compare(this.planStart, o.planStart);
        if (diff != 0) {
            return diff;
        }
        diff = Double.compare(this.planStop, o.planStop);
        if (diff != 0) {
            return diff;
        }

        diff = this.category.compareTo(o.category);
        if (diff != 0) {
            return diff;
        }
        return this.investigation.compareTo(o.investigation);
    }

    private static int compareActualTimes(Double a, Double b) {
        if (a != null && b == null) {
            return -1;
        }
        if (a == null && b != null) {
            return 1;
        }
        if (a != null && b != null) {
            return Double.compare(a, b);
        }
        return 0; // both null
    }

    public void printEntry(Appendable bwriter) throws IOException {

        bwriter.append(Integer.toString(keplerId));
        bwriter.append(SEPARATOR_CHAR);
        bwriter.append(targetType.ktcName());
        bwriter.append(SEPARATOR_CHAR);

        bwriter.append(category);
        bwriter.append(SEPARATOR_CHAR);
        bwriter.append(Double.toString(planStart));
        bwriter.append(SEPARATOR_CHAR);
        bwriter.append(Double.toString(planStop));
        bwriter.append(SEPARATOR_CHAR);
        if (actualStart != null) {
            bwriter.append(Double.toString(actualStart));
        }
        bwriter.append(SEPARATOR_CHAR);
        if (actualStop != null) {
            bwriter.append(Double.toString(actualStop));
        }
        bwriter.append(SEPARATOR_CHAR)
            .append(investigation);
        bwriter.append('\n');
    }

    public static CompletedKtcEntry parseInstance(String line) {
        List<String> parts = tokenize(line);
        if (parts.size() != 8) {
            throw new IllegalArgumentException("Bad line \"" + line
                + "\". Found " + parts.size() + " n tokens.");
        }

        int keplerId = Integer.parseInt(parts.get(0));
        TargetType targetType = TargetType.valueOfKtcType(parts.get(1));
        String category = parts.get(2);
        double planStart = Double.parseDouble(parts.get(3));
        double planStop = Double.parseDouble(parts.get(4));
        Double actualStart = (parts.get(5)
            .length() == 0) ? null : Double.parseDouble(parts.get(5));
        Double actualStop = (parts.get(6)
            .length() == 0) ? null : Double.parseDouble(parts.get(6));
        String investigation = parts.get(7);

        return new CompletedKtcEntry(category, actualStart, actualStop,
            investigation, planStart, planStop, keplerId, targetType);
    }

    /**
     * String.split and StringTokenizer both do not like parsing empty tokens
     * between delimiters like "a|b|c||e" should become {"a", "b","c","","e"}
     * but instead does not contain the "".
     * 
     * @param line
     * @return
     */
    private static List<String> tokenize(String line) {
        List<String> tokens = new ArrayList<String>();
        int stop = 0;
        for (int start = 0; start < line.length(); start = stop + 1) {
            stop = line.indexOf(SEPARATOR_CHAR, start);
            if (stop == -1) {
                stop = line.length();
            }
            tokens.add(line.substring(start, stop));
        }
        if (line.charAt(line.length() - 1) == SEPARATOR_CHAR) {
            tokens.add("");
        }
        return tokens;
    }

    static double convertToDouble(Date utcDate) {
        ModifiedJulianDate modifiedJulianDate = new ModifiedJulianDate(
            utcDate.getTime());

        return modifiedJulianDate.getMjd();
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((actualStart == null) ? 0 : actualStart.hashCode());
        result = prime * result
            + ((actualStop == null) ? 0 : actualStop.hashCode());
        result = prime * result
            + ((category == null) ? 0 : category.hashCode());
        result = prime * result
            + ((investigation == null) ? 0 : investigation.hashCode());
        result = prime * result + keplerId;
        long temp;
        temp = Double.doubleToLongBits(planStart);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(planStop);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        result = prime * result
            + ((targetType == null) ? 0 : targetType.hashCode());
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
        CompletedKtcEntry other = (CompletedKtcEntry) obj;
        if (actualStart == null) {
            if (other.actualStart != null)
                return false;
        } else if (!actualStart.equals(other.actualStart))
            return false;
        if (actualStop == null) {
            if (other.actualStop != null)
                return false;
        } else if (!actualStop.equals(other.actualStop))
            return false;
        if (category == null) {
            if (other.category != null)
                return false;
        } else if (!category.equals(other.category))
            return false;
        if (investigation == null) {
            if (other.investigation != null)
                return false;
        } else if (!investigation.equals(other.investigation))
            return false;
        if (keplerId != other.keplerId)
            return false;
        if (Double.doubleToLongBits(planStart) != Double.doubleToLongBits(other.planStart))
            return false;
        if (Double.doubleToLongBits(planStop) != Double.doubleToLongBits(other.planStop))
            return false;
        if (targetType == null) {
            if (other.targetType != null)
                return false;
        } else if (!targetType.equals(other.targetType))
            return false;
        return true;
    }

    @Override
    public String toString() {
        StringBuilder bldr = new StringBuilder();
        try {
            printEntry(bldr);
        } catch (IOException e) {
            return "ERROR";
        }
        return bldr.toString();
    }

    public String getCategory() {
        return category;
    }

    public Double getActualStart() {
        return actualStart;
    }

    public Double getActualStop() {
        return actualStop;
    }

    public String getInvestigation() {
        return investigation;
    }

    public double getPlanStart() {
        return planStart;
    }

    public double getPlanStop() {
        return planStop;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public TargetTable.TargetType getTargetType() {
        return targetType;
    }

}
