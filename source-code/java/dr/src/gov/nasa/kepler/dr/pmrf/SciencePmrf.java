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

package gov.nasa.kepler.dr.pmrf;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.dr.fits.FitsFile;
import gov.nasa.kepler.dr.fits.FitsHeader;
import gov.nasa.kepler.dr.fits.FitsTable;
import gov.nasa.kepler.hibernate.dr.PmrfLog;
import gov.nasa.kepler.hibernate.dr.PmrfLog.PmrfType;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.util.Iterator;
import java.util.List;
import java.util.Set;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Sets;

/**
 * Conatains a science pmrf.
 * 
 * @author Miles Cote
 * 
 */
public final class SciencePmrf {

    private final TargetType targetType;
    private final int targetTableId;
    private final int apertureTableId;
    private final List<SciencePmrfModOut> sciencePmrfModOuts;

    public static final SciencePmrf of(Pmrf pmrf) {
        PmrfType pmrfType = pmrf.getPmrfLog()
            .getPmrfType();

        FitsFile fitsFile = pmrf.getFitsFile();

        int targetTableId = fitsFile.getFitsHeader()
            .getIntValue(pmrfType.getTargetTableKeyword());
        int apertureTableId = fitsFile.getFitsHeader()
            .getIntValue(pmrfType.getApertureTableKeyword());

        List<SciencePmrfModOut> sciencePmrfModOuts = newArrayList();
        for (FitsTable fitsTable : fitsFile.getFitsTables()) {
            sciencePmrfModOuts.add(SciencePmrfModOut.of(fitsTable));
        }

        return new SciencePmrf(pmrf.getPmrfLog()
            .getPmrfType()
            .getTargetType(), targetTableId, apertureTableId,
            sciencePmrfModOuts);
    }

    public static final SciencePmrf of(TadTargetTable tadTargetTable) {
        int targetTableId = tadTargetTable.getTargetTable()
            .getExternalId();
        int apertureTableId = tadTargetTable.getTargetTable()
            .getMaskTable()
            .getExternalId();

        List<SciencePmrfModOut> sciencePmrfModOuts = newArrayList();
        for (TadTargetTableModOut tadTargetTableModOut : tadTargetTable.getTadTargetTableModOuts()) {
            sciencePmrfModOuts.add(SciencePmrfModOut.of(tadTargetTableModOut));
        }

        return new SciencePmrf(tadTargetTable.getTargetTable()
            .getType(), targetTableId, apertureTableId, sciencePmrfModOuts);
    }

    SciencePmrf(TargetType targetType, int targetTableId, int apertureTableId,
        List<SciencePmrfModOut> sciencePmrfModOuts) {
        this.targetType = targetType;
        this.targetTableId = targetTableId;
        this.apertureTableId = apertureTableId;
        this.sciencePmrfModOuts = sciencePmrfModOuts;
    }

    public Pmrf toPmrf() {
        PmrfType pmrfType = PmrfType.valueOf(targetType);

        PmrfLog pmrfLog = new PmrfLog(null, pmrfType, targetTableId);

        FitsHeader fitsHeader = FitsHeader.of(ImmutableMap.of(
            pmrfType.getTargetTableKeyword(), String.valueOf(targetTableId),
            pmrfType.getApertureTableKeyword(), String.valueOf(apertureTableId)));

        List<FitsTable> fitsTables = newArrayList();
        for (SciencePmrfModOut sciencePmrfModOut : sciencePmrfModOuts) {
            fitsTables.add(sciencePmrfModOut.toFitsTable());
        }

        FitsFile fitsFile = new FitsFile(fitsHeader, fitsTables);

        return new Pmrf(pmrfLog, fitsFile);
    }

    public TadTargetTable toTadTargetTable() {
        MaskTable maskTable = new MaskTable(MaskType.valueOf(targetType));
        maskTable.setExternalId(apertureTableId);

        TargetTable targetTable = new TargetTable(targetType);
        targetTable.setExternalId(targetTableId);
        targetTable.setMaskTable(maskTable);

        List<TadTargetTableModOut> tadTargetTableModOuts = newArrayList();
        for (SciencePmrfModOut sciencePmrfModOut : sciencePmrfModOuts) {
            tadTargetTableModOuts.add(sciencePmrfModOut.toTadTargetTableModOut());
        }

        return new TadTargetTable(targetTable, tadTargetTableModOuts);
    }

    public TargetType getTargetType() {
        return targetType;
    }

    public int getTargetTableId() {
        return targetTableId;
    }

    public int getApertureTableId() {
        return apertureTableId;
    }

    public List<SciencePmrfModOut> getSciencePmrfModOuts() {
        return sciencePmrfModOuts;
    }

    
    /**
     * Generate a difference string that describes the differences between two
     * instances of SciencePmrf.
     * 
     * @param other
     * @return
     */
    public String diff(SciencePmrf other, int maxDifferences, String thisName, String otherName) {
        if (maxDifferences < 1) {
            throw new IllegalArgumentException("maxDifferences " + maxDifferences);
        }
        
        StringBuilder bldr = new StringBuilder();
        int nDiff = 0;
        if (!this.targetType.equals(targetType)) {
            nDiff++;
            bldr.append("this.targetType("+ this.targetType + 
                ") != other.targetType(" + other.targetType +")\n");
        }

        if (nDiff < maxDifferences && this.targetTableId != other.targetTableId) {
            bldr.append("this.targetTableId(" + this.targetTableId +
                ") != other.targetTableId(" + other.targetTableId + ")");
            nDiff++;
        }
        if (nDiff < maxDifferences && this.apertureTableId != other.apertureTableId) {
            bldr.append("this.apertureTableId(" + this.apertureTableId + 
                ") != (" + other.apertureTableId + ")");
            nDiff++;
        }

        if (nDiff < maxDifferences) {
            Set<SciencePmrfModOut> thisModOutSet = 
                ImmutableSet.copyOf(this.sciencePmrfModOuts);
            Set<SciencePmrfModOut> otherModOutSet = 
                ImmutableSet.copyOf(other.sciencePmrfModOuts);
            Set<SciencePmrfModOut> uniqueToThisSet = 
                Sets.difference(thisModOutSet, otherModOutSet);
            if (!uniqueToThisSet.isEmpty()) {
                bldr.append(thisName).append(" has modOuts that are not in common with ").append(otherName).append("\n");
                Iterator<SciencePmrfModOut> it = uniqueToThisSet.iterator();
                while (nDiff < maxDifferences && it.hasNext()) {
                    bldr.append(it.next().toString()).append("\n");
                    nDiff++;
                }
            }
            
            Set<SciencePmrfModOut> uniqueToOtherSet = 
                Sets.difference(otherModOutSet, thisModOutSet);
            if (nDiff < maxDifferences && !uniqueToThisSet.isEmpty()) {
                bldr.append(otherName).append(" has modOuts that are not in common with ").append(thisName).append("\n");
                Iterator<SciencePmrfModOut> it = uniqueToOtherSet.iterator();
                while (nDiff < maxDifferences && it.hasNext()) {
                    bldr.append(it.next().toString()).append("\n");
                    nDiff++;
                }
            }
            
            
            if (nDiff < maxDifferences && 
                uniqueToThisSet.isEmpty() &&
                uniqueToOtherSet.isEmpty() &&
                !this.sciencePmrfModOuts.equals(other.sciencePmrfModOuts)) {
                
                bldr.append(thisName).append(" and ")
                    .append(otherName)
                    .append(" have the same number of elements, but not in the same order.");
                nDiff++;
            }
        }
        if (nDiff == maxDifferences) {
            bldr.append("maxDifferences reached.");
        }
        return bldr.toString();
    }
    
    @Override
    public String toString() {
        final int maxLen = 2;
        StringBuilder builder = new StringBuilder();
        builder.append("SciencePmrf [targetType=")
            .append(targetType)
            .append(", targetTableId=")
            .append(targetTableId)
            .append(", apertureTableId=")
            .append(apertureTableId)
            .append(", sciencePmrfModOuts=")
            .append(
                sciencePmrfModOuts != null ? sciencePmrfModOuts.subList(0,
                    Math.min(sciencePmrfModOuts.size(), maxLen)) : null)
            .append("]");
        return builder.toString();
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + apertureTableId;
        result = prime
            * result
            + ((sciencePmrfModOuts == null) ? 0 : sciencePmrfModOuts.hashCode());
        result = prime * result + targetTableId;
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
        SciencePmrf other = (SciencePmrf) obj;
        if (apertureTableId != other.apertureTableId)
            return false;
        if (sciencePmrfModOuts == null) {
            if (other.sciencePmrfModOuts != null)
                return false;
        } else if (!sciencePmrfModOuts.equals(other.sciencePmrfModOuts))
            return false;
        if (targetTableId != other.targetTableId)
            return false;
        if (targetType != other.targetType)
            return false;
        return true;
    }

}
