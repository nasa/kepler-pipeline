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

package gov.nasa.kepler.cal.ffi;

import static gov.nasa.kepler.common.ConfigMap.ConfigMapMnemonic.*;
import static gov.nasa.kepler.common.FcConstants.*;

import java.util.HashMap;
import java.util.Map;

import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.ConfigMapEntry;

/**
 * A config map that has the default coordinates for the collateral bounding
 * boxes.
 * 
 * @author Sean McCauliff
 * 
 */
public class FakeConfigMap extends ConfigMap {
    public FakeConfigMap() {
        this(0, 0.0);
    }
    
    public FakeConfigMap(int id, double mjd) {
        
        this.put(smearStartCol.mnemonic(),
            Integer.toString(LEADING_BLACK_END + 1));
        this.put(smearEndCol.mnemonic(),
            Integer.toString(TRAILING_BLACK_START - 1));
        this.put(smearStartRow.mnemonic(),
            Integer.toString(VIRTUAL_SMEAR_START));
        this.put(smearEndRow.mnemonic(), Integer.toString(VIRTUAL_SMEAR_END));

        this.put(maskedStartCol.mnemonic(),
            Integer.toString(LEADING_BLACK_END + 1));
        this.put(maskedEndCol.mnemonic(),
            Integer.toString(TRAILING_BLACK_START - 1));
        this.put(maskedStartRow.mnemonic(),
            Integer.toString(MASKED_SMEAR_START));
        this.put(maskedEndRow.mnemonic(), Integer.toString(MASKED_SMEAR_END));

        this.put(darkStartCol.mnemonic(),
            Integer.toString(TRAILING_BLACK_START));
        this.put(darkEndCol.mnemonic(), Integer.toString(TRAILING_BLACK_END));
        this.put(darkStartRow.mnemonic(), Integer.toString(0));
        this.put(darkEndRow.mnemonic(), Integer.toString(CCD_ROWS - 1));
    }

    public gov.nasa.kepler.hibernate.dr.ConfigMap toHibernate() {
        Map<String, String> map = new HashMap<String, String>();
        for (ConfigMapEntry entry : getEntries()) {
            map.put(entry.getMnemonic(), entry.getValue());
        }
        
        gov.nasa.kepler.hibernate.dr.ConfigMap hConfig =
            new gov.nasa.kepler.hibernate.dr.ConfigMap(getId(), getTime(), map);
        return hConfig;
    }
}
