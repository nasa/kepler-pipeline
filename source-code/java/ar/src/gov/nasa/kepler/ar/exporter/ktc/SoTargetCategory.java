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

import static gov.nasa.kepler.ar.exporter.ktc.InvestigationBase.*;

import java.util.HashMap;
import java.util.Map;
/**
 * Categories the science office uses in target list files.
 * @author Sean McCauliff
 *
 */
enum SoTargetCategory {
    EB (EX),
    INCLUDE (EX),
    LEPINE (EX),
    PLANETARY (EX),
    ST_SC1 (EX),
    ST_SC2 (EX),
    ST_SC3 (EX),
    UNCLASSIFIED (EX),
    ASTROMETRY (STKL),
    PDQ_STELLAR (ES),
    PPA_STELLAR (ES),
    ARP (EN),
    PDQ_DYNAMIC (EN),
    PPA_LDE (EN),
    ASTERO_LC (STKL),
    ASTERO_SC (STKS),
    ASTERO_SC1 (STKS),
    ASTERO_SC2 (STKS),
    ASTERO_SC3 (STKS),
    ASTEROSEISMOLOGY_PRF_CDPP_SC (STKS),
    CLUSTER (STC),
    GO_LC (GO),
    GO_SC1 (GO),
    GO_SC2 (GO),
    GO_SC3 (GO),
    BACKGROUND_SUPERAPERTURE(EXBA);
    
    

    /**
     * Unlike valueOf() methods this will return null rather than throwing an
     * exception if a category name is not matched to an element in the enum.
     * 
     * @param name "EB", "INCLUDE", etc.
     * @return  This may return null if name does not match any categories.
     */
    public static SoTargetCategory fromName(String name) {
        return nameToCategory.get(name);
    }
    
    private InvestigationBase investigationBase;

    private SoTargetCategory(InvestigationBase investigationBase) {
        this.investigationBase = investigationBase;
    }
    
    public InvestigationBase investigationBase() {
        return investigationBase;
    }
    
    private static final Map<String, SoTargetCategory> nameToCategory = new HashMap<String, SoTargetCategory>();
    
    static {
        for (SoTargetCategory cat : values()) {
            nameToCategory.put(cat.name(), cat);
        }
    }
}
