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

package gov.nasa.kepler.ar.archive;


import gov.nasa.kepler.ar.exporter.background.BackgroundPolynomial;
import gov.nasa.kepler.common.SipWcsCoordinates;
import gov.nasa.kepler.common.SipWcsCoordinates.SipPolynomial;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * The output from running the Matlab archive module.
 * 
 * @author Sean McCauliff
 *
 */
public final class ArchiveOutputs implements Persistable {
    private List<BackgroundPixelValue> background;
    private List<BarycentricCorrection> barycentricOutputs;
    private List<TargetDva> targetDva;
    private List<TargetWcs> targetWcs;
    private BackgroundPolynomial backgroundPolynomial;
    private SipWcsCoordinates sipWcsCoordinates;
    private BarycentricCorrection ffiBarycentricCorrection;
    private CotrendingBasisVectors cotrendingBasisVectors;
    
    /**
     * To support the Persistable interface.
     */
    
    public ArchiveOutputs() {
        
    }
    
    
    public ArchiveOutputs(List<BackgroundPixelValue> background) {
        super();
        this.background = background;
    }

    public List<BackgroundPixelValue> getBackground() {
        return background;
    }
    
    public Map<Pixel, BackgroundPixelValue> backgroundToMap() {
        Map<Pixel, BackgroundPixelValue> rv = 
            new HashMap<Pixel, BackgroundPixelValue>(background.size() * 2);
        for (BackgroundPixelValue bgv : background) {
            rv.put(new Pixel(bgv.getCcdRow(), bgv.getCcdColumn()), bgv);
        }
        return rv;
    }
    
    public Map<Integer, BarycentricCorrection> barycentricCorrectionToMap() {
        Map<Integer, BarycentricCorrection> rv =
            new HashMap<Integer, BarycentricCorrection>(barycentricOutputs.size() * 2);
        for (BarycentricCorrection bc : barycentricOutputs) {
            rv.put(bc.getKeplerId(), bc);
        }
        return rv;
    }
    
    public Map<Integer, TargetDva> targetsDva() {
        Map<Integer,TargetDva> rv = new HashMap<Integer, TargetDva>(targetDva.size() * 2);
        for (TargetDva t : targetDva) {
            rv.put(t.getKeplerId(), t);
        }
        return rv;
    }

    public Map<Integer, TargetWcs> targetsWcs() {
        Map<Integer,TargetWcs> rv = new HashMap<Integer, TargetWcs>(targetWcs.size() * 2);
        for (TargetWcs t : targetWcs) {
            rv.put(t.getKeplerId(), t);
        }
        return rv;
    }
    
    public BackgroundPolynomial backgroundPolynomial() {
        return backgroundPolynomial;
    }
    
    public SipWcsCoordinates sipWcsCoordinates() {
        return sipWcsCoordinates;
    }
    
    public BarycentricCorrection ffiBarycentricCorrection() {
        return ffiBarycentricCorrection;
    }
    
    public CotrendingBasisVectors cotrendingBasisVectors() {
        return cotrendingBasisVectors;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((background == null) ? 0 : background.hashCode());
        result = prime
            * result
            + ((barycentricOutputs == null) ? 0 : barycentricOutputs.hashCode());
        result = prime * result
            + ((targetDva == null) ? 0 : targetDva.hashCode());
        result = prime * result
            + ((targetWcs == null) ? 0 : targetWcs.hashCode());
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
        ArchiveOutputs other = (ArchiveOutputs) obj;
        if (background == null) {
            if (other.background != null)
                return false;
        } else if (!background.equals(other.background))
            return false;
        if (barycentricOutputs == null) {
            if (other.barycentricOutputs != null)
                return false;
        } else if (!barycentricOutputs.equals(other.barycentricOutputs))
            return false;
        if (targetDva == null) {
            if (other.targetDva != null)
                return false;
        } else if (!targetDva.equals(other.targetDva))
            return false;
        if (targetWcs == null) {
            if (other.targetWcs != null)
                return false;
        } else if (!targetWcs.equals(other.targetWcs))
            return false;
        return true;
    }


  

}
