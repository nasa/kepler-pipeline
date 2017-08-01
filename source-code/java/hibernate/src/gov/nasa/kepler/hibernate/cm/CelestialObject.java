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

package gov.nasa.kepler.hibernate.cm;

/**
 * Shared attributes of {@link CelestialObject}s. All {@link CelestialObject}s
 * should use just the Kepler ID in their <code>hashCode</code> and
 * <code>equals</code> methods.
 * <p>
 * See KSOC-21163 Catalog Management.<br>
 * See KSOC-21113 SOC SCP ICD.
 * 
 * @author Bill Wohler
 * @author Miles Cote
 */
public interface CelestialObject {

    public Integer getAlternateId();

    public Integer getAlternateSource();

    public Integer getAstrophysicsQuality();

    public Float getAvExtinction();

    public Integer getBlendIndicator();

    public Integer getCatalogId();

    public Float getD51Mag();

    public double getDec();

    public Float getDecProperMotion();

    public Float getEbMinusVRedding();

    public Integer getEffectiveTemp();

    public Double getGalacticLatitude();

    public Double getGalacticLongitude();

    public Integer getGalaxyIndicator();

    public Float getGkColor();

    public Float getGMag();

    public Float getGrColor();

    public Float getGredMag();

    public Float getIMag();

    public Float getJkColor();

    public Integer getInternalScpId();

    public int getKeplerId();

    public Float getKeplerMag();

    public Float getLog10Metallicity();

    public Float getLog10SurfaceGravity();

    public Float getParallax();

    public Integer getPhotometryQuality();

    public String getProvenance();

    public double getRa();

    public Float getRadius();

    public Float getRaProperMotion();

    public Float getRMag();

    public Integer getScpId();

    public int getSkyGroupId();

    public String getSource();

    public Float getTotalProperMotion();

    public Float getTwoMassHMag();

    public Integer getTwoMassId();

    public Float getTwoMassJMag();

    public Float getTwoMassKMag();

    public Float getUMag();

    public Integer getVariableIndicator();

    public Float getZMag();

}
