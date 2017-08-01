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

package gov.nasa.kepler.mc.cm;

import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.spiffy.common.persistable.Persistable;

/**
 * Target parameters from the KIC. Parameters ({@link CelestialObjectParameter})
 * contain a value and an uncertainty. Values are initialized from the KIC, but
 * can be overridden by the characteristics table. Uncertainties are optional
 * and always come from the characteristics table.
 * 
 * @author Bill Wohler
 */
public class CelestialObjectParameters implements Persistable {

    // Order of fields as specified by Kic.Field.

    private int skyGroupId;
    private CelestialObjectParameter ra;
    private CelestialObjectParameter dec;
    private CelestialObjectParameter raProperMotion;
    private CelestialObjectParameter decProperMotion;
    private CelestialObjectParameter uMag;
    private CelestialObjectParameter gMag;
    private CelestialObjectParameter rMag;
    private CelestialObjectParameter iMag;
    private CelestialObjectParameter zMag;
    private CelestialObjectParameter gredMag;
    private CelestialObjectParameter d51Mag;
    private CelestialObjectParameter twoMassJMag;
    private CelestialObjectParameter twoMassHMag;
    private CelestialObjectParameter twoMassKMag;
    private CelestialObjectParameter keplerMag;
    private int keplerId;
    private CelestialObjectParameter twoMassId;
    private CelestialObjectParameter internalScpId;
    private CelestialObjectParameter alternateId;
    private CelestialObjectParameter alternateSource;
    private CelestialObjectParameter galaxyIndicator;
    private CelestialObjectParameter blendIndicator;
    private CelestialObjectParameter variableIndicator;
    private CelestialObjectParameter effectiveTemp;
    private CelestialObjectParameter log10SurfaceGravity;
    private CelestialObjectParameter log10Metallicity;
    private CelestialObjectParameter ebMinusVRedding;
    private CelestialObjectParameter avExtinction;
    private CelestialObjectParameter radius;
    // private CelestialObjectParameter source; // String
    private CelestialObjectParameter photometryQuality;
    private CelestialObjectParameter astrophysicsQuality;
    private CelestialObjectParameter catalogId;
    private CelestialObjectParameter scpId;
    private CelestialObjectParameter parallax;
    private CelestialObjectParameter galacticLongitude;
    private CelestialObjectParameter galacticLatitude;
    private CelestialObjectParameter totalProperMotion;
    private CelestialObjectParameter grColor;
    private CelestialObjectParameter jkColor;
    private CelestialObjectParameter gkColor;

    /**
     * Creates a {@link CelestialObjectParameters} object. For use only by the
     * inner {@link Builder} class, mock objects, serialization, and Hibernate.
     */
    public CelestialObjectParameters() {
    }

    /**
     * Creates a {@link CelestialObjectParameters} object with the given
     * builder.
     */
    private CelestialObjectParameters(Builder builder) {

        // Order of fields as specified by Kic.Field.

        skyGroupId = builder.celestialObject.getSkyGroupId();
        ra = builder.celestialObjectParameters.ra;
        dec = builder.celestialObjectParameters.dec;
        raProperMotion = builder.celestialObjectParameters.raProperMotion;
        decProperMotion = builder.celestialObjectParameters.decProperMotion;
        uMag = builder.celestialObjectParameters.uMag;
        gMag = builder.celestialObjectParameters.gMag;
        rMag = builder.celestialObjectParameters.rMag;
        iMag = builder.celestialObjectParameters.iMag;
        zMag = builder.celestialObjectParameters.zMag;
        gredMag = builder.celestialObjectParameters.gredMag;
        d51Mag = builder.celestialObjectParameters.d51Mag;
        twoMassJMag = builder.celestialObjectParameters.twoMassJMag;
        twoMassHMag = builder.celestialObjectParameters.twoMassHMag;
        twoMassKMag = builder.celestialObjectParameters.twoMassKMag;
        keplerMag = builder.celestialObjectParameters.keplerMag;
        keplerId = builder.celestialObject.getKeplerId();
        twoMassId = builder.celestialObjectParameters.twoMassId;
        internalScpId = builder.celestialObjectParameters.internalScpId;
        alternateId = builder.celestialObjectParameters.alternateId;
        alternateSource = builder.celestialObjectParameters.alternateSource;
        galaxyIndicator = builder.celestialObjectParameters.galaxyIndicator;
        blendIndicator = builder.celestialObjectParameters.blendIndicator;
        variableIndicator = builder.celestialObjectParameters.variableIndicator;
        effectiveTemp = builder.celestialObjectParameters.effectiveTemp;
        log10SurfaceGravity = builder.celestialObjectParameters.log10SurfaceGravity;
        log10Metallicity = builder.celestialObjectParameters.log10Metallicity;
        ebMinusVRedding = builder.celestialObjectParameters.ebMinusVRedding;
        avExtinction = builder.celestialObjectParameters.avExtinction;
        radius = builder.celestialObjectParameters.radius;
        // this.source = builder.celestialObjectParameters.source;
        photometryQuality = builder.celestialObjectParameters.photometryQuality;
        astrophysicsQuality = builder.celestialObjectParameters.astrophysicsQuality;
        catalogId = builder.celestialObjectParameters.catalogId;
        scpId = builder.celestialObjectParameters.scpId;
        parallax = builder.celestialObjectParameters.parallax;
        galacticLongitude = builder.celestialObjectParameters.galacticLongitude;
        galacticLatitude = builder.celestialObjectParameters.galacticLatitude;
        totalProperMotion = builder.celestialObjectParameters.totalProperMotion;
        grColor = builder.celestialObjectParameters.grColor;
        jkColor = builder.celestialObjectParameters.jkColor;
        gkColor = builder.celestialObjectParameters.gkColor;
    }

    // Accessors, in alphabetical order.

    public CelestialObjectParameter getAlternateId() {
        return alternateId;
    }

    public CelestialObjectParameter getAlternateSource() {
        return alternateSource;
    }

    public CelestialObjectParameter getAstrophysicsQuality() {
        return astrophysicsQuality;
    }

    public CelestialObjectParameter getAvExtinction() {
        return avExtinction;
    }

    public CelestialObjectParameter getBlendIndicator() {
        return blendIndicator;
    }

    public CelestialObjectParameter getCatalogId() {
        return catalogId;
    }

    public CelestialObjectParameter getD51Mag() {
        return d51Mag;
    }

    public CelestialObjectParameter getDec() {
        return dec;
    }

    public CelestialObjectParameter getDecProperMotion() {
        return decProperMotion;
    }

    public CelestialObjectParameter getEbMinusVRedding() {
        return ebMinusVRedding;
    }

    public CelestialObjectParameter getEffectiveTemp() {
        return effectiveTemp;
    }

    public CelestialObjectParameter getGalacticLatitude() {
        return galacticLatitude;
    }

    public CelestialObjectParameter getGalacticLongitude() {
        return galacticLongitude;
    }

    public CelestialObjectParameter getGalaxyIndicator() {
        return galaxyIndicator;
    }

    public CelestialObjectParameter getGkColor() {
        return gkColor;
    }

    public CelestialObjectParameter getGMag() {
        return gMag;
    }

    public CelestialObjectParameter getGrColor() {
        return grColor;
    }

    public CelestialObjectParameter getGredMag() {
        return gredMag;
    }

    public CelestialObjectParameter getIMag() {
        return iMag;
    }

    public CelestialObjectParameter getJkColor() {
        return jkColor;
    }

    public CelestialObjectParameter getInternalScpId() {
        return internalScpId;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public CelestialObjectParameter getKeplerMag() {
        return keplerMag;
    }

    public CelestialObjectParameter getLog10Metallicity() {
        return log10Metallicity;
    }

    public CelestialObjectParameter getLog10SurfaceGravity() {
        return log10SurfaceGravity;
    }

    public CelestialObjectParameter getParallax() {
        return parallax;
    }

    public CelestialObjectParameter getPhotometryQuality() {
        return photometryQuality;
    }

    public CelestialObjectParameter getRa() {
        return ra;
    }

    public CelestialObjectParameter getRadius() {
        return radius;
    }

    public CelestialObjectParameter getRaProperMotion() {
        return raProperMotion;
    }

    public CelestialObjectParameter getRMag() {
        return rMag;
    }

    public CelestialObjectParameter getScpId() {
        return scpId;
    }

    public int getSkyGroupId() {
        return skyGroupId;
    }

    // public CelestialObjectParameter getSource() {
    // return source;
    // }

    public CelestialObjectParameter getTotalProperMotion() {
        return totalProperMotion;
    }

    public CelestialObjectParameter getTwoMassHMag() {
        return twoMassHMag;
    }

    public CelestialObjectParameter getTwoMassId() {
        return twoMassId;
    }

    public CelestialObjectParameter getTwoMassJMag() {
        return twoMassJMag;
    }

    public CelestialObjectParameter getTwoMassKMag() {
        return twoMassKMag;
    }

    public CelestialObjectParameter getUMag() {
        return uMag;
    }

    public CelestialObjectParameter getVariableIndicator() {
        return variableIndicator;
    }

    public CelestialObjectParameter getZMag() {
        return zMag;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + keplerId;
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof CelestialObjectParameters)) {
            return false;
        }
        CelestialObjectParameters other = (CelestialObjectParameters) obj;
        if (keplerId != other.keplerId) {
            return false;
        }
        return true;
    }

    /**
     * Used to construct a {@link CelestialObjectParameters} object. To use this
     * class, a {@link Builder} object is created with the required parameter
     * (celestialObject). Then non-null fields are set using the available
     * builder methods. Finally, a {@link CelestialObjectParameters} object is
     * returned by using the build method. For example:
     * 
     * <pre>
     * CelestialObjectParameters celestialObjectParameters = new CelestialObjectParameters.Builder(
     *     celestialObject).raProperMotion(
     *     new CelestialObjectParameter(1.234F, 0.1234F))
     *     .decProperMotion(new CelestialObjectParameter(5.678F, 0.5678F))
     *     .build();
     * </pre>
     * 
     * The required parameter {@code celestialObject} is used to populate the
     * {@code value} field of each {@link CelestialObjectParameter} in case an
     * explicit builder method is not called. In this case,
     * {@link CelestialObjectParameter#hasUncertainty()} on the generated object
     * will return {@code false}.
     * <p>
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Bill Wohler
     */
    public static class Builder {
        private CelestialObjectParameters celestialObjectParameters = new CelestialObjectParameters();
        private CelestialObject celestialObject;

        /**
         * Creates a {@link Builder} object starting with an existing
         * {@link CelestialObject} object. The values in the
         * {@link CelestialObject} object are used to initialize the
         * {@link CelestialObjectParameter} {@code value} field when a builder
         * method isn't called on a parameter.
         * 
         * @param celestialObject an existing {@link CelestialObject} object
         */
        public Builder(CelestialObject celestialObject) {
            this.celestialObject = celestialObject;
        }

        // Builders, in alphabetical order.

        public Builder alternateId(CelestialObjectParameter alternateId) {
            celestialObjectParameters.alternateId = alternateId;
            return this;
        }

        public Builder alternateSource(CelestialObjectParameter alternateSource) {
            celestialObjectParameters.alternateSource = alternateSource;
            return this;
        }

        public Builder astrophysicsQuality(
            CelestialObjectParameter astrophysicsQuality) {
            celestialObjectParameters.astrophysicsQuality = astrophysicsQuality;
            return this;
        }

        public Builder avExtinction(CelestialObjectParameter avExtinction) {
            celestialObjectParameters.avExtinction = avExtinction;
            return this;
        }

        public Builder blendIndicator(CelestialObjectParameter blendIndicator) {
            celestialObjectParameters.blendIndicator = blendIndicator;
            return this;
        }

        public Builder catalogId(CelestialObjectParameter catalogId) {
            celestialObjectParameters.catalogId = catalogId;
            return this;
        }

        public Builder d51Mag(CelestialObjectParameter mag) {
            celestialObjectParameters.d51Mag = mag;
            return this;
        }

        public Builder dec(CelestialObjectParameter dec) {
            celestialObjectParameters.dec = dec;
            return this;
        }

        public Builder decProperMotion(CelestialObjectParameter decProperMotion) {
            celestialObjectParameters.decProperMotion = decProperMotion;
            return this;
        }

        public Builder ebMinusVRedding(CelestialObjectParameter ebMinusVRedding) {
            celestialObjectParameters.ebMinusVRedding = ebMinusVRedding;
            return this;
        }

        public Builder effectiveTemp(CelestialObjectParameter effectiveTemp) {
            celestialObjectParameters.effectiveTemp = effectiveTemp;
            return this;
        }

        public Builder galacticLatitude(
            CelestialObjectParameter galacticLatitude) {
            celestialObjectParameters.galacticLatitude = galacticLatitude;
            return this;
        }

        public Builder galacticLongitude(
            CelestialObjectParameter galacticLongitude) {
            celestialObjectParameters.galacticLongitude = galacticLongitude;
            return this;
        }

        public Builder galaxyIndicator(CelestialObjectParameter galaxyIndicator) {
            celestialObjectParameters.galaxyIndicator = galaxyIndicator;
            return this;
        }

        public Builder gkColor(CelestialObjectParameter color) {
            celestialObjectParameters.gkColor = color;
            return this;
        }

        public Builder gMag(CelestialObjectParameter mag) {
            celestialObjectParameters.gMag = mag;
            return this;
        }

        public Builder grColor(CelestialObjectParameter color) {
            celestialObjectParameters.grColor = color;
            return this;
        }

        public Builder gredMag(CelestialObjectParameter mag) {
            celestialObjectParameters.gredMag = mag;
            return this;
        }

        public Builder iMag(CelestialObjectParameter mag) {
            celestialObjectParameters.iMag = mag;
            return this;
        }

        public Builder internalScpId(CelestialObjectParameter id) {
            celestialObjectParameters.internalScpId = id;
            return this;
        }

        public Builder jkColor(CelestialObjectParameter color) {
            celestialObjectParameters.jkColor = color;
            return this;
        }

        public Builder keplerMag(CelestialObjectParameter mag) {
            celestialObjectParameters.keplerMag = mag;
            return this;
        }

        public Builder log10Metallicity(
            CelestialObjectParameter log10Metallicity) {
            celestialObjectParameters.log10Metallicity = log10Metallicity;
            return this;
        }

        public Builder log10SurfaceGravity(
            CelestialObjectParameter log10SurfaceGravity) {
            celestialObjectParameters.log10SurfaceGravity = log10SurfaceGravity;
            return this;
        }

        public Builder parallax(CelestialObjectParameter parallax) {
            celestialObjectParameters.parallax = parallax;
            return this;
        }

        public Builder photometryQuality(
            CelestialObjectParameter photometryQuality) {
            celestialObjectParameters.photometryQuality = photometryQuality;
            return this;
        }

        public Builder ra(CelestialObjectParameter ra) {
            celestialObjectParameters.ra = ra;
            return this;
        }

        public Builder radius(CelestialObjectParameter radius) {
            celestialObjectParameters.radius = radius;
            return this;
        }

        public Builder raProperMotion(CelestialObjectParameter raProperMotion) {
            celestialObjectParameters.raProperMotion = raProperMotion;
            return this;
        }

        public Builder rMag(CelestialObjectParameter mag) {
            celestialObjectParameters.rMag = mag;
            return this;
        }

        public Builder scpId(CelestialObjectParameter scpId) {
            celestialObjectParameters.scpId = scpId;
            return this;
        }

        // public Builder source(String source) {
        // celestialObjectParameters.source = source;
        // return this;
        // }

        public Builder totalProperMotion(
            CelestialObjectParameter totalProperMotion) {
            celestialObjectParameters.totalProperMotion = totalProperMotion;
            return this;
        }

        public Builder twoMassHMag(CelestialObjectParameter twoMassHMag) {
            celestialObjectParameters.twoMassHMag = twoMassHMag;
            return this;
        }

        public Builder twoMassId(CelestialObjectParameter twoMassId) {
            celestialObjectParameters.twoMassId = twoMassId;
            return this;
        }

        public Builder twoMassJMag(CelestialObjectParameter twoMassJMag) {
            celestialObjectParameters.twoMassJMag = twoMassJMag;
            return this;
        }

        public Builder twoMassKMag(CelestialObjectParameter twoMassKMag) {
            celestialObjectParameters.twoMassKMag = twoMassKMag;
            return this;
        }

        public Builder uMag(CelestialObjectParameter mag) {
            celestialObjectParameters.uMag = mag;
            return this;
        }

        public Builder variableIndicator(
            CelestialObjectParameter variableIndicator) {
            celestialObjectParameters.variableIndicator = variableIndicator;
            return this;
        }

        public Builder zMag(CelestialObjectParameter mag) {
            celestialObjectParameters.zMag = mag;
            return this;
        }

        public CelestialObjectParameters build() {
            if (celestialObjectParameters.ra == null) {
                celestialObjectParameters.ra = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getRa());
            }
            if (celestialObjectParameters.dec == null) {
                celestialObjectParameters.dec = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getDec());
            }
            if (celestialObjectParameters.raProperMotion == null) {
                celestialObjectParameters.raProperMotion = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getRaProperMotion());
            }
            if (celestialObjectParameters.decProperMotion == null) {
                celestialObjectParameters.decProperMotion = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getDecProperMotion());
            }
            if (celestialObjectParameters.uMag == null) {
                celestialObjectParameters.uMag = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getUMag());
            }
            if (celestialObjectParameters.gMag == null) {
                celestialObjectParameters.gMag = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getGMag());
            }
            if (celestialObjectParameters.rMag == null) {
                celestialObjectParameters.rMag = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getRMag());
            }
            if (celestialObjectParameters.iMag == null) {
                celestialObjectParameters.iMag = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getIMag());
            }
            if (celestialObjectParameters.zMag == null) {
                celestialObjectParameters.zMag = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getZMag());
            }
            if (celestialObjectParameters.gredMag == null) {
                celestialObjectParameters.gredMag = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getGredMag());
            }
            if (celestialObjectParameters.d51Mag == null) {
                celestialObjectParameters.d51Mag = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getD51Mag());
            }
            if (celestialObjectParameters.twoMassJMag == null) {
                celestialObjectParameters.twoMassJMag = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getTwoMassJMag());
            }
            if (celestialObjectParameters.twoMassHMag == null) {
                celestialObjectParameters.twoMassHMag = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getTwoMassHMag());
            }
            if (celestialObjectParameters.twoMassKMag == null) {
                celestialObjectParameters.twoMassKMag = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getTwoMassKMag());
            }
            if (celestialObjectParameters.keplerMag == null) {
                celestialObjectParameters.keplerMag = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getKeplerMag());
            }
            if (celestialObjectParameters.twoMassId == null) {
                celestialObjectParameters.twoMassId = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getTwoMassId());
            }
            if (celestialObjectParameters.internalScpId == null) {
                celestialObjectParameters.internalScpId = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getInternalScpId());
            }
            if (celestialObjectParameters.alternateId == null) {
                celestialObjectParameters.alternateId = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getAlternateId());
            }
            if (celestialObjectParameters.alternateSource == null) {
                celestialObjectParameters.alternateSource = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getAlternateSource());
            }
            if (celestialObjectParameters.galaxyIndicator == null) {
                celestialObjectParameters.galaxyIndicator = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getGalaxyIndicator());
            }
            if (celestialObjectParameters.blendIndicator == null) {
                celestialObjectParameters.blendIndicator = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getBlendIndicator());
            }
            if (celestialObjectParameters.variableIndicator == null) {
                celestialObjectParameters.variableIndicator = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getVariableIndicator());
            }
            if (celestialObjectParameters.effectiveTemp == null) {
                celestialObjectParameters.effectiveTemp = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getEffectiveTemp());
            }
            if (celestialObjectParameters.log10SurfaceGravity == null) {
                celestialObjectParameters.log10SurfaceGravity = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getLog10SurfaceGravity());
            }
            if (celestialObjectParameters.log10Metallicity == null) {
                celestialObjectParameters.log10Metallicity = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getLog10Metallicity());
            }
            if (celestialObjectParameters.ebMinusVRedding == null) {
                celestialObjectParameters.ebMinusVRedding = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getEbMinusVRedding());
            }
            if (celestialObjectParameters.avExtinction == null) {
                celestialObjectParameters.avExtinction = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getAvExtinction());
            }
            if (celestialObjectParameters.radius == null) {
                celestialObjectParameters.radius = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getRadius());
            }
            // if (celestialObjectParameters.source == null) {
            // celestialObjectParameters.source = new
            // CelestialObjectParameter(celestialObject.getProvenance(), celestialObject.getSource());
            // }
            if (celestialObjectParameters.photometryQuality == null) {
                celestialObjectParameters.photometryQuality = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getPhotometryQuality());
            }
            if (celestialObjectParameters.astrophysicsQuality == null) {
                celestialObjectParameters.astrophysicsQuality = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getAstrophysicsQuality());
            }
            if (celestialObjectParameters.catalogId == null) {
                celestialObjectParameters.catalogId = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getCatalogId());
            }
            if (celestialObjectParameters.scpId == null) {
                celestialObjectParameters.scpId = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getScpId());
            }
            if (celestialObjectParameters.parallax == null) {
                celestialObjectParameters.parallax = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getParallax());
            }
            if (celestialObjectParameters.galacticLongitude == null) {
                celestialObjectParameters.galacticLongitude = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getGalacticLongitude());
            }
            if (celestialObjectParameters.galacticLatitude == null) {
                celestialObjectParameters.galacticLatitude = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getGalacticLatitude());
            }
            if (celestialObjectParameters.totalProperMotion == null) {
                celestialObjectParameters.totalProperMotion = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getTotalProperMotion());
            }
            if (celestialObjectParameters.grColor == null) {
                celestialObjectParameters.grColor = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getGrColor());
            }
            if (celestialObjectParameters.jkColor == null) {
                celestialObjectParameters.jkColor = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getJkColor());
            }
            if (celestialObjectParameters.gkColor == null) {
                celestialObjectParameters.gkColor = new CelestialObjectParameter(
                    celestialObject.getProvenance(), celestialObject.getGkColor());
            }

            return new CelestialObjectParameters(this);
        }
    }
}
