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

package gov.nasa.kepler.ar.exporter;

import static gov.nasa.kepler.common.ConfigMap.ConfigMapMnemonic.*;
import static gov.nasa.kepler.common.ConfigMap.configMapsShouldHaveUniqueValue;

import java.util.Collection;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.ConfigMap.ConfigMapMnemonic;

/**
 * Calculate parameters related to how the collateral data was coadded from the
 * 
 * @author Sean McCauliff
 *
 */
public class CollateralConfigValues implements CollateralParameterSource {

    private final Collection<ConfigMap> configMaps;
    
    public CollateralConfigValues(Collection<ConfigMap> configMaps) {
        if (configMaps == null) {
            throw new NullPointerException("configMaps");
        }
        if (configMaps.isEmpty()) {
            throw new IllegalArgumentException("No empty config maps.");
        }
        
        this.configMaps = configMaps;
    }
    

    private int configMapsValue(ConfigMapMnemonic mnemonic) {
        return Integer.parseInt(configMapsShouldHaveUniqueValue(configMaps, mnemonic));
    }
    
    @Override
    public int virtualSmearRowStart() {
        return configMapsValue(smearStartRow);
    }
    
    @Override
    public int virtualSmearRowEnd() {
        return configMapsValue(smearEndRow);
    }
    
    @Override
    public int virtualSmearColumnStart() {
        return configMapsValue(smearStartCol);
    }
    
    @Override
    public int virtualSmearColumnEnd() {
        return configMapsValue(smearEndCol);
    }
    
  
    @Override
    public int nVirtualSmearRowBins() {
        return configMapsValue(smearEndRow) - configMapsValue(smearStartRow) + 1;
    }
    
    @Override
    public int nVirtualSmearColumns() {
        return configMapsValue(smearEndCol) - configMapsValue(smearStartCol) + 1;
    }
    
    @Override
    public int nMaskedSmearRowBins() {
        return configMapsValue(maskedEndRow) - configMapsValue(maskedStartRow) + 1;
    }
    
    @Override
    public int nMaskedSmearColumns() {
        return configMapsValue(maskedEndCol) - configMapsValue(maskedStartCol) + 1;
    }
    
    @Override
    public int nBlackRows() {
        return configMapsValue(darkEndRow) - configMapsValue(darkStartRow) + 1;
    }
    
    @Override
    public int nBlackColumnBins() {
        return configMapsValue(darkEndCol) - configMapsValue(darkStartCol) + 1;
    }
    
    @Override
    public int maskedSmearRowStart() {
        return configMapsValue(maskedStartRow);
    }
    
    @Override
    public int maskedSmearRowEnd() {
        return configMapsValue(maskedEndRow);
    }
    
    @Override
    public int maskedSmearColumnStart() {
        return configMapsValue(smearStartCol);
    }
    
    @Override
    public int maskedSmearColumnEnd() {
        return configMapsValue(smearEndCol);
    }
    
    @Override
    public int blackRowStart() {
        return configMapsValue(darkStartRow);
    }
    
    public int blackRowEnd() {
        return configMapsValue(darkEndRow);
    }
    
    @Override
    public int blackColumnStart() {
        return configMapsValue(darkStartCol);
    }
    
    @Override
    public int blackColumnEnd() {
        return configMapsValue(darkEndCol);
    }

}
