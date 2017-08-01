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

package gov.nasa.kepler.systest.sbt.data;

import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFilledIndicesTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFluxTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType;

/**
 * This {@link Enum} coantains the types of {@link CorrectedFluxTimeSeries}
 * produced by PDC.
 * 
 * @author Miles Cote
 * 
 */
public enum CorrectedFluxType {
    ORIGINAL(PdcFluxTimeSeriesType.CORRECTED_FLUX,
        PdcFilledIndicesTimeSeriesType.FILLED_INDICES,
        PdcOutliersTimeSeriesType.OUTLIERS),
    HARMONIC_FREE(PdcFluxTimeSeriesType.HARMONIC_FREE_CORRECTED_FLUX,
        PdcFilledIndicesTimeSeriesType.HARMONIC_FREE_FILLED_INDICES,
        PdcOutliersTimeSeriesType.HARMONIC_FREE_OUTLIERS);

    private final PdcFluxTimeSeriesType pdcFluxTimeSeriesType;
    private final PdcFilledIndicesTimeSeriesType pdcFilledIndicesTimeSeriesType;
    private final PdcOutliersTimeSeriesType pdcOutliersTimeSeriesType;

    private CorrectedFluxType(PdcFluxTimeSeriesType pdcFluxTimeSeriesType,
        PdcFilledIndicesTimeSeriesType pdcFilledIndicesTimeSeriesType,
        PdcOutliersTimeSeriesType pdcOutliersTimeSeriesType) {
        this.pdcFluxTimeSeriesType = pdcFluxTimeSeriesType;
        this.pdcFilledIndicesTimeSeriesType = pdcFilledIndicesTimeSeriesType;
        this.pdcOutliersTimeSeriesType = pdcOutliersTimeSeriesType;
    }

    public PdcFluxTimeSeriesType getPdcFluxTimeSeriesType() {
        return pdcFluxTimeSeriesType;
    }

    public PdcFilledIndicesTimeSeriesType getPdcFilledIndicesTimeSeriesType() {
        return pdcFilledIndicesTimeSeriesType;
    }

    public PdcOutliersTimeSeriesType getPdcOutliersTimeSeriesType() {
        return pdcOutliersTimeSeriesType;
    }

}
