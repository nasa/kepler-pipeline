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

package gov.nasa.kepler.hibernate.tad;

import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.gar.ExportTable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import org.apache.commons.lang.builder.ToStringBuilder;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;

/**
 * This class represents a target table that is sent to the MOC and uploaded to
 * the spacecraft. {@link ObservedTarget}s contain a reference to the
 * {@link TargetTable} that they are associated with.
 * 
 * @author Miles Cote
 * @author Bill Wohler
 */
@Entity
@Table(name = "TAD_TARGET_TABLE")
public class TargetTable extends ExportTable implements TypedTable {

    public static enum TargetType {
        BACKGROUND("Background", "bgp", "B", Cadence.CadenceType.LONG),
        LONG_CADENCE("Long cadence", "lct", "LC", Cadence.CadenceType.LONG),
        SHORT_CADENCE("Short cadence", "sct", "SC", Cadence.CadenceType.SHORT),
        REFERENCE_PIXEL("Reference pixel", "rpt", "R", null);

        private final String display;
        private final String shortName;
        private final String ktcName;
        private final Cadence.CadenceType cadenceType; // This may be null.

        private TargetType(String display, String shortName, String ktcName,
            CadenceType cadenceType) {
            this.display = display;
            this.shortName = shortName;
            this.ktcName = ktcName;
            this.cadenceType = cadenceType;
        }

        public static TargetType valueOf(Cadence.CadenceType cadenceType) {
            switch (cadenceType) {
                case LONG:
                    return LONG_CADENCE;
                case SHORT:
                    return SHORT_CADENCE;
                default:
                    throw new IllegalArgumentException("Unknown type "
                        + cadenceType);
            }
        }

        public static TargetType valueOfKtcType(String ktcString) {
            if (ktcString.equals(BACKGROUND.ktcName())) {
                return BACKGROUND;
            }
            if (ktcString.equals(LONG_CADENCE.ktcName())) {
                return LONG_CADENCE;
            }
            if (ktcString.equals(SHORT_CADENCE.ktcName())) {
                return SHORT_CADENCE;
            }
            if (ktcString.equals(REFERENCE_PIXEL.ktcName())) {
                return REFERENCE_PIXEL;
            }
            throw new IllegalArgumentException("Invalid kic type string \""
                + ktcString + "\".");
        }

        public static TargetType valueOfShortName(String shortNameString) {
            if (shortNameString.equals(BACKGROUND.shortName())) {
                return BACKGROUND;
            }
            if (shortNameString.equals(LONG_CADENCE.shortName())) {
                return LONG_CADENCE;
            }
            if (shortNameString.equals(SHORT_CADENCE.shortName())) {
                return SHORT_CADENCE;
            }
            if (shortNameString.equals(REFERENCE_PIXEL.shortName())) {
                return REFERENCE_PIXEL;
            }
            throw new IllegalArgumentException("Invalid short name string \""
                + shortNameString + "\".");
        }

        public String shortName() {
            return shortName;
        }

        @Override
        public String toString() {
            return display;
        }

        /**
         * As it is known in the Kepler Target Catalog.
         * 
         * @return
         */
        public String ktcName() {
            return ktcName;
        }

        public Cadence.CadenceType toCadenceType() {
            if (cadenceType == null) {
                throw new IllegalStateException(this
                    + " does not have an associated cadenceType");
            }
            return cadenceType;
        }
    }

    @Column(nullable = false)
    private TargetType type;

    @Column(nullable = false)
    private int observingSeason;

    @OneToOne(optional = true)
    @Cascade(CascadeType.EVICT)
    private MaskTable maskTable;

    @OneToOne(fetch = FetchType.LAZY)
    @Cascade(CascadeType.ALL)
    private TadReport tadReport;

    TargetTable() {
    }

    public TargetTable(TargetType type) {
        this.type = type;
    }

    public TargetTable(TargetTable targetTable) {
        state = targetTable.state;
        externalId = targetTable.externalId;
        plannedStartTime = targetTable.plannedStartTime;
        plannedEndTime = targetTable.plannedEndTime;
        fileName = targetTable.fileName;

        type = targetTable.type;
        observingSeason = targetTable.observingSeason;
        if (targetTable.maskTable != null) {
            maskTable = new MaskTable(targetTable.maskTable);
        }
    }

    @Override
    public int hashCode() {
        return super.hashCode();
    }

    @Override
    public boolean equals(Object obj) {
        return super.equals(obj);
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("type", type)
            .append("observingSeason", observingSeason)
            .append("maskTable", maskTable)
            .toString();
    }

    @Override
    public void validate() {
        super.validate();

        if (plannedEndTime == null) {
            throw new IllegalStateException("Table (" + getShortName()
                + ") must have a planned end time");
        }

        if (state == State.UNLOCKED) {
            throw new IllegalStateException("Table (" + getShortName()
                + ") must be locked");
        }
    }

    @Override
    protected String getShortName() {
        return type.shortName();
    }

    public MaskTable getMaskTable() {
        return maskTable;
    }

    public void setMaskTable(MaskTable maskTable) {
        this.maskTable = maskTable;
    }

    @Override
    public TargetType getType() {
        return type;
    }

    public void setType(TargetType type) {
        this.type = type;
    }

    public int getObservingSeason() {
        return observingSeason;
    }

    public void setObservingSeason(int observingSeason) {
        this.observingSeason = observingSeason;
    }

    public TadReport getTadReport() {
        return tadReport;
    }

    public void setTadReport(TadReport tadReport) {
        this.tadReport = tadReport;
    }

    public void testSetId(int id) {
        this.id = id;
    }

}
