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
import static gov.nasa.kepler.common.FitsConstants.MODULE_KW;
import static gov.nasa.kepler.common.FitsConstants.OUTPUT_KW;
import gov.nasa.kepler.dr.fits.FitsColumn;
import gov.nasa.kepler.dr.fits.FitsHeader;
import gov.nasa.kepler.dr.fits.FitsTable;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;

import java.util.List;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

/**
 * Contains a science pmrf mod/out.
 * 
 * @author Miles Cote
 * 
 */
public final class SciencePmrfModOut {

    private final ModOut modOut;
    private final List<SciencePmrfEntry> sciencePmrfEntries;

    public static final SciencePmrfModOut of(FitsTable fitsTable) {
        int ccdModule = fitsTable.getFitsHeader()
            .getIntValue(MODULE_KW);
        int ccdOutput = fitsTable.getFitsHeader()
            .getIntValue(OUTPUT_KW);
        ModOut modOut = ModOut.of(ccdModule, ccdOutput);

        List<FitsColumn> fitsColumns = fitsTable.getFitsColumns();
        List<Number> ccdRows = fitsColumns.get(0)
            .getValues();
        List<Number> ccdColumns = fitsColumns.get(1)
            .getValues();
        List<Number> targetIds = fitsColumns.get(2)
            .getValues();
        List<Number> apertureIds = fitsColumns.get(3)
            .getValues();

        List<SciencePmrfEntry> sciencePmrfEntries = newArrayList();
        for (int i = 0; i < ccdRows.size(); i++) {
            sciencePmrfEntries.add(new SciencePmrfEntry(ccdRows.get(i)
                .shortValue(), ccdColumns.get(i)
                .shortValue(), targetIds.get(i)
                .intValue(), apertureIds.get(i)
                .shortValue()));
        }

        return new SciencePmrfModOut(modOut, sciencePmrfEntries);
    }

    public static final SciencePmrfModOut of(
        TadTargetTableModOut tadTargetTableModOut) {
        ModOut modOut = tadTargetTableModOut.getModOut();

        List<SciencePmrfEntry> sciencePmrfEntries = newArrayList();
        for (TargetDefinition targetDefinition : tadTargetTableModOut.getTargetDefinitions()) {
            Mask mask = targetDefinition.getMask();
            for (Offset offset : mask.getOffsets()) {
                int ccdRow = targetDefinition.getReferenceRow()
                    + offset.getRow();
                int ccdColumn = targetDefinition.getReferenceColumn()
                    + offset.getColumn();
                int targetId = targetDefinition.getKeplerId();
                int apertureId = mask.getIndexInTable();

                sciencePmrfEntries.add(new SciencePmrfEntry((short) ccdRow,
                    (short) ccdColumn, (int) targetId, (short) apertureId));
            }
        }

        return new SciencePmrfModOut(modOut, sciencePmrfEntries);
    }

    SciencePmrfModOut(ModOut modOut, List<SciencePmrfEntry> sciencePmrfEntries) {
        this.modOut = modOut;
        this.sciencePmrfEntries = sciencePmrfEntries;
    }

    public FitsTable toFitsTable() {
        FitsHeader fitsHeader = FitsHeader.of(ImmutableMap.of(MODULE_KW,
            String.valueOf(modOut.getCcdModule()), OUTPUT_KW,
            String.valueOf(modOut.getCcdOutput())));

        List<Number> ccdRows = newArrayList();
        List<Number> ccdColumns = newArrayList();
        List<Number> targetIds = newArrayList();
        List<Number> apertureIds = newArrayList();
        for (SciencePmrfEntry sciencePmrfEntry : sciencePmrfEntries) {
            ccdRows.add(sciencePmrfEntry.getCcdRow());
            ccdColumns.add(sciencePmrfEntry.getCcdColumn());
            targetIds.add(sciencePmrfEntry.getTargetId());
            apertureIds.add(sciencePmrfEntry.getApertureId());
        }

        List<FitsColumn> fitsColumns = newArrayList();
        fitsColumns.add(new FitsColumn(ccdRows));
        fitsColumns.add(new FitsColumn(ccdColumns));
        fitsColumns.add(new FitsColumn(targetIds));
        fitsColumns.add(new FitsColumn(apertureIds));

        return new FitsTable(fitsHeader, fitsColumns);
    }

    public TadTargetTableModOut toTadTargetTableModOut() {
        List<TargetDefinition> targetDefinitions = newArrayList();
        for (SciencePmrfEntry sciencePmrfEntry : sciencePmrfEntries) {
            Mask mask = new Mask();
            mask.setIndexInTable(sciencePmrfEntry.getApertureId());
            mask.setOffsets(ImmutableList.of(new Offset(0, 0)));

            TargetDefinition targetDefinition = new TargetDefinition(
                sciencePmrfEntry.getCcdRow(), sciencePmrfEntry.getCcdColumn(),
                0, mask);
            targetDefinition.setKeplerId(sciencePmrfEntry.getTargetId());

            targetDefinitions.add(targetDefinition);
        }

        return new TadTargetTableModOut(modOut, targetDefinitions);
    }

    public ModOut getModOut() {
        return modOut;
    }

    public List<SciencePmrfEntry> getSciencePmrfEntries() {
        return sciencePmrfEntries;
    }

    

    @Override
    public String toString() {
        final int maxLen = 2;
        StringBuilder builder = new StringBuilder();
        builder.append("SciencePmrfModOut [modOut=")
            .append(modOut)
            .append(", sciencePmrfEntries=")
            .append(
                sciencePmrfEntries != null ? sciencePmrfEntries.subList(0,
                    Math.min(sciencePmrfEntries.size(), maxLen)) : null)
            .append("]");
        return builder.toString();
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((modOut == null) ? 0 : modOut.hashCode());
        result = prime
            * result
            + ((sciencePmrfEntries == null) ? 0 : sciencePmrfEntries.hashCode());
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
        SciencePmrfModOut other = (SciencePmrfModOut) obj;
        if (modOut == null) {
            if (other.modOut != null)
                return false;
        } else if (!modOut.equals(other.modOut))
            return false;
        if (sciencePmrfEntries == null) {
            if (other.sciencePmrfEntries != null)
                return false;
        } else if (!sciencePmrfEntries.isEmpty()
            && !sciencePmrfEntries.equals(other.sciencePmrfEntries))
            return false;
        return true;
    }

}
