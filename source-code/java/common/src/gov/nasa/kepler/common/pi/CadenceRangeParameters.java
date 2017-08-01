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

package gov.nasa.kepler.common.pi;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.ranges.Range;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.List;

/**
 * This interface must be implemented by sub-classes of {@link Parameters} for
 * pipelines that contain nodes that use the CadenceUowTaskGenerator (or a
 * sub-class of it).
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class CadenceRangeParameters implements Parameters {

    /*
     * See CadenceRangeParametersBeanInfo for documentation of these fields.
     */
    private int startCadence;
    private int endCadence;
    private int numberOfBins;
    private int minimumBinSize;
    private boolean binByTargetTable;
    private String[] excludeCadences;

    public CadenceRangeParameters() {
        this(0, 0);
    }

    public CadenceRangeParameters(int startCadence, int endCadence) {
        this(startCadence, endCadence, 0, 0);
    }

    public CadenceRangeParameters(int startCadence, int endCadence,
        int numberOfBins, int minimumBinSize) {
        this(startCadence, endCadence, numberOfBins, minimumBinSize, false,
            new String[0]);
    }

    public CadenceRangeParameters(int startCadence, int endCadence,
        boolean binByTargetTable, String[] excludeCadences) {
        this(startCadence, endCadence, 0, 0, binByTargetTable, excludeCadences);
    }

    CadenceRangeParameters(int startCadence, int endCadence, int numberOfBins,
        int minimumBinSize, boolean binByTargetTable, String[] excludeCadences) {
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.numberOfBins = numberOfBins;
        this.minimumBinSize = minimumBinSize;
        this.binByTargetTable = binByTargetTable;
        this.excludeCadences = excludeCadences;

        validate();
    }

    private void validate() {
        if (startCadence < 0) {
            throw new IllegalArgumentException(
                "startCadence cannot be less than 0." + "\n  startCadence: "
                    + startCadence);
        }
        if (endCadence < 0) {
            throw new IllegalArgumentException(
                "endCadence cannot be less than 0." + "\n  endCadence: "
                    + endCadence);
        }
        if (numberOfBins < 0) {
            throw new IllegalArgumentException(
                "numberOfBins cannot be less than 0." + "\n  numberOfBins: "
                    + numberOfBins);
        }
        if (minimumBinSize < 0) {
            throw new IllegalArgumentException(
                "minimumBinSize cannot be less than 0."
                    + "\n  minimumBinSize: " + minimumBinSize);
        }
        if (startCadence > endCadence) {
            throw new IllegalArgumentException(
                "startCadence cannot be greater than endCadence."
                    + "\n  startCadence: " + startCadence + "\n  endCadence: "
                    + endCadence);
        }
    }

    public List<Integer> toExcludeCadences() {
        List<Integer> excludeCadenceList = newArrayList();
        for (String s : excludeCadences) {
            Range range = Range.forString(s);
            excludeCadenceList.addAll(range.toIntegers());
        }

        return excludeCadenceList;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public void setStartCadence(int startCadence) {
        this.startCadence = startCadence;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public void setEndCadence(int endCadence) {
        this.endCadence = endCadence;
    }

    public int getNumberOfBins() {
        return numberOfBins;
    }

    public void setNumberOfBins(int numberOfBins) {
        this.numberOfBins = numberOfBins;
    }

    public int getMinimumBinSize() {
        return minimumBinSize;
    }

    public void setMinimumBinSize(int minimumBinSize) {
        this.minimumBinSize = minimumBinSize;
    }

    public boolean isBinByTargetTable() {
        return binByTargetTable;
    }

    public void setBinByTargetTable(boolean binByTargetTable) {
        this.binByTargetTable = binByTargetTable;
    }

    public String[] getExcludeCadences() {
        return excludeCadences;
    }

    public void setExcludeCadences(String[] excludeCadences) {
        this.excludeCadences = excludeCadences;
    }

}
