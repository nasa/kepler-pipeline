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

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import gov.nasa.kepler.hibernate.cm.CelestialObject;

/**
 * This custom target is missing some information needed for processing.
 * 
 * @author Sean McCauliff
 *
 */
public class MissingDataCelestialObject implements CelestialObject {
    private final static Log log = LogFactory.getLog(MissingDataCelestialObject.class);

    private static final String MISSING_DATA_PROVENANCE = "Unknown";
    
    private final CelestialObject proxiedObject;
    private Double ra;
    private Double dec;
    
    public MissingDataCelestialObject(CelestialObject proxiedObject) {
        this.proxiedObject = proxiedObject;
    }
    
    public void setDec(double newDec) {
        dec = newDec;
    }
    
    public void setRa(double newRa) {
        ra = newRa;
    }

    @Override
    public int getKeplerId() { 
        return proxiedObject.getKeplerId();
    }

    @Override
    public int getSkyGroupId() { 
        return proxiedObject.getSkyGroupId();
    }

    @Override
    public Integer getAlternateId() { 
        return proxiedObject.getAlternateId();
    }

    @Override
    public Integer getAlternateSource() { 
        return proxiedObject.getAlternateSource();
    }

    @Override
    public Integer getAstrophysicsQuality() { 
        return proxiedObject.getAstrophysicsQuality();
    }

    @Override
    public Float getAvExtinction() { 
        return proxiedObject.getAvExtinction();
    }

    @Override
    public Integer getBlendIndicator() { 
        return proxiedObject.getBlendIndicator();
    }

    @Override
    public Integer getCatalogId() { 
        return proxiedObject.getCatalogId();
    }

    @Override
    public Float getD51Mag() { 
        return proxiedObject.getD51Mag();
    }

    @Override
    public double getDec() { 
        if (dec == null) {
            log.warn("Returning NaN for declination since declination has not" +
                " been computed yet for keplerId " + getKeplerId() + "\".");
            return Double.NaN;
        }
        return dec;
    }

    @Override
    public Float getDecProperMotion() { 
        return proxiedObject.getDecProperMotion();
    }

    @Override
    public Float getEbMinusVRedding() { 
        return proxiedObject.getEbMinusVRedding();
    }

    @Override
    public Integer getEffectiveTemp() { 
        return proxiedObject.getEffectiveTemp();
    }

    @Override
    public Double getGalacticLatitude() { 
        return proxiedObject.getGalacticLatitude();
    }

    @Override
    public Double getGalacticLongitude() { 
        return proxiedObject.getGalacticLongitude();
    }

    @Override
    public Integer getGalaxyIndicator() { 
        return proxiedObject.getGalaxyIndicator();
    }

    @Override
    public Float getGkColor() { 
        return proxiedObject.getGkColor();
    }

    @Override
    public Float getGMag() { 
        return proxiedObject.getGMag();
    }

    @Override
    public Float getGrColor() { 
        return proxiedObject.getGrColor();
    }

    @Override
    public Float getGredMag() { 
        return proxiedObject.getGredMag();
    }

    @Override
    public Float getIMag() { 
        return proxiedObject.getIMag();
    }

    @Override
    public Float getJkColor() { 
        return proxiedObject.getJkColor();
    }

    @Override
    public Integer getInternalScpId() { 
        return proxiedObject.getInternalScpId();
    }

    @Override
    public Float getKeplerMag() { 
        return proxiedObject.getKeplerMag();
    }

    @Override
    public Float getLog10Metallicity() { 
        return proxiedObject.getLog10Metallicity();
    }

    @Override
    public Float getLog10SurfaceGravity() { 
        return proxiedObject.getLog10SurfaceGravity();
    }

    @Override
    public Float getParallax() { 
        return proxiedObject.getParallax();
    }

    @Override
    public Integer getPhotometryQuality() { 
        return proxiedObject.getPhotometryQuality();
    }
    
    @Override
    public String getProvenance() {
        return MISSING_DATA_PROVENANCE;
    }

    @Override
    public double getRa() { 
        if (ra == null) {
            log.warn("Returning NaN for right ascension since declination has not" +
                " been computed yet for keplerId " + getKeplerId() + "\".");
            return Double.NaN;
        }
        return ra;
    }

    @Override
    public Float getRadius() { 
        return proxiedObject.getRadius();
    }

    @Override
    public Float getRaProperMotion() { 
        return proxiedObject.getRaProperMotion();
    }

    @Override
    public Float getRMag() { 
        return proxiedObject.getRMag();
    }

    @Override
    public Integer getScpId() { 
        return proxiedObject.getScpId();
    }

    @Override
    public String getSource() { 
        return proxiedObject.getSource();
    }

    @Override
    public Float getTotalProperMotion() { 
        return proxiedObject.getTotalProperMotion();
    }

    @Override
    public Float getTwoMassHMag() { 
        return proxiedObject.getTwoMassHMag();
    }

    @Override
    public Integer getTwoMassId() { 
        return proxiedObject.getTwoMassId();
    }

    @Override
    public Float getTwoMassJMag() { 
        return proxiedObject.getTwoMassJMag();
    }

    @Override
    public Float getTwoMassKMag() { 
        return proxiedObject.getTwoMassKMag();
    }

    @Override
    public Float getUMag() { 
        return proxiedObject.getUMag();
    }

    @Override
    public Integer getVariableIndicator() { 
        return proxiedObject.getVariableIndicator();
    }

    @Override
    public Float getZMag() { 
        return proxiedObject.getZMag();
    }

}
