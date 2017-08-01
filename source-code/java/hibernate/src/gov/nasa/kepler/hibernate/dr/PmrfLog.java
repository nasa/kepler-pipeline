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

package gov.nasa.kepler.hibernate.dr;

import static gov.nasa.kepler.common.FitsConstants.BKG_APER_KW;
import static gov.nasa.kepler.common.FitsConstants.BKTRGDEF_KW;
import static gov.nasa.kepler.common.FitsConstants.LCTRGDEF_KW;
import static gov.nasa.kepler.common.FitsConstants.SCTRGDEF_KW;
import static gov.nasa.kepler.common.FitsConstants.TARGAPER_KW;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.lang.StringUtils;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

@Entity
@Table(name = "DR_PMRF_LOG")
public class PmrfLog {

    public static enum PmrfType {
        LONG_CADENCE_TARGET(DispatcherType.LONG_CADENCE_TARGET_PMRF,
            TargetType.LONG_CADENCE,
            LCTRGDEF_KW,
            TARGAPER_KW),
        LONG_CADENCE_COLLATERAL(DispatcherType.LONG_CADENCE_COLLATERAL_PMRF,
            TargetType.LONG_CADENCE,
            LCTRGDEF_KW,
            TARGAPER_KW),
        BACKGROUND(DispatcherType.BACKGROUND_PMRF,
            TargetType.BACKGROUND,
            BKTRGDEF_KW,
            BKG_APER_KW),
        SHORT_CADENCE_TARGET(DispatcherType.SHORT_CADENCE_TARGET_PMRF,
            TargetType.SHORT_CADENCE,
            SCTRGDEF_KW,
            TARGAPER_KW),
        SHORT_CADENCE_COLLATERAL(DispatcherType.SHORT_CADENCE_COLLATERAL_PMRF,
            TargetType.SHORT_CADENCE,
            SCTRGDEF_KW,
            TARGAPER_KW);

        private final String name;
        private final DispatcherType dispatcherType;
        private final TargetType targetType;
        private final String targetTableKeyword;
        private final String apertureTableKeyword;

        private PmrfType(DispatcherType dispatcherType, TargetType targetType,
            String targetTableKeyword, String apertureTableKeyword) {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
            this.dispatcherType = dispatcherType;
            this.targetType = targetType;
            this.targetTableKeyword = targetTableKeyword;
            this.apertureTableKeyword = apertureTableKeyword;
        }

        public String getName() {
            return name;
        }

        public DispatcherType getDispatcherType() {
            return dispatcherType;
        }

        public TargetType getTargetType() {
            return targetType;
        }

        public String getTargetTableKeyword() {
            return targetTableKeyword;
        }

        public String getApertureTableKeyword() {
            return apertureTableKeyword;
        }

        public static PmrfType valueOf(TargetType targetType) {
            switch (targetType) {
                case LONG_CADENCE:
                    return PmrfType.LONG_CADENCE_TARGET;
                case SHORT_CADENCE:
                    return PmrfType.SHORT_CADENCE_TARGET;
                case BACKGROUND:
                    return PmrfType.BACKGROUND;
                default:
                    throw new IllegalArgumentException("Unexpected type: "
                        + targetType);
            }
        }
    }

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DR_PMRF_LOG_SEQ")
    @Column(nullable = false)
    private long id;

    @OneToOne
    private FileLog fileLog;

    private PmrfType pmrfType;
    private int targetTableId;

    PmrfLog() {
    }

    public PmrfLog(FileLog fileLog, PmrfType pmrfType, int targetTableId) {
        this.fileLog = fileLog;
        this.pmrfType = pmrfType;
        this.targetTableId = targetTableId;
    }

    public FileLog getFileLog() {
        return fileLog;
    }

    public long getId() {
        return id;
    }

    public PmrfType getPmrfType() {
        return pmrfType;
    }

    public int getTargetTableId() {
        return targetTableId;
    }

    @Override
    public String toString() {
        return "PmrfLog [fileLog=" + fileLog + ", pmrfType=" + pmrfType
            + ", targetTableId=" + targetTableId + "]";
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((fileLog == null) ? 0 : fileLog.hashCode());
        result = prime * result
            + ((pmrfType == null) ? 0 : pmrfType.hashCode());
        result = prime * result + targetTableId;
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
        PmrfLog other = (PmrfLog) obj;
        if (fileLog == null) {
            if (other.fileLog != null)
                return false;
        } else if (!fileLog.equals(other.fileLog))
            return false;
        if (pmrfType != other.pmrfType)
            return false;
        if (targetTableId != other.targetTableId)
            return false;
        return true;
    }

}
