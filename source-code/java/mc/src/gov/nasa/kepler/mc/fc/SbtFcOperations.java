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

package gov.nasa.kepler.mc.fc;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.PixelTimeSeriesType;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.TargetMetricsTimeSeriesType;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.BlobSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidTimeSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CosmicRayMetricType;

import java.util.List;


public class SbtFcOperations {
    
    public static TargetTable instantiateTargetTable(String enumName) {
        TargetTable targetTable = new TargetTable(getTargetType(enumName));
        return targetTable;
    }
    
    public static CentroidTimeSeriesType getCentroidTimeSeriesType(String enumName) {
        return PaFsIdFactory.CentroidTimeSeriesType.valueOf(enumName);
    }
    
    public static PaFsIdFactory.CosmicRayMetricType getPaCosmicRayMetricType(String enumName) {
        return PaFsIdFactory.CosmicRayMetricType.valueOf(enumName);
    }

    public static CalFsIdFactory.CosmicRayMetricType getCalCosmicRayMetricType(String enumName) {
        return CalFsIdFactory.CosmicRayMetricType.valueOf(enumName);
    }
    
    public static CollateralType getCollateralType(String enumName) {
        return CollateralType.valueOf(enumName);
    }
    
    public static CosmicRayMetricType getCosmicRayMetricType(String enumName) {
        return CosmicRayMetricType.valueOf(enumName);
    }

    public static PaFsIdFactory.TimeSeriesType getFluxTimeSeriesType(String enumName) {
        return PaFsIdFactory.TimeSeriesType.valueOf(enumName);
    }

    public static BlobSeriesType getBlobSeriesType(String enumName) {
        return BlobSeriesType.valueOf(enumName);
    }

    public static PixelTimeSeriesType getCalPixelTimeSeriesType(String enumName) {
        return PixelTimeSeriesType.valueOf(enumName);
    }

    public static CadenceType getCadenceType(String enumName) {
        return CadenceType.valueOf(enumName);
    }

    public static MetricsTimeSeriesType getMetricsTimeSeriesType(String enumName) {
        return MetricsTimeSeriesType.valueOf(enumName);
    }

    public static TargetMetricsTimeSeriesType getTargetMetricsTimeSeriesType(String enumName) {
        return TargetMetricsTimeSeriesType.valueOf(enumName);
    }

    public static TargetType getTargetType(String enumName) {
        return TargetType.valueOf(enumName);
    }

    public static DrFsIdFactory.TimeSeriesType getDrTimeSeriesType(String enumName) {
        return DrFsIdFactory.TimeSeriesType.valueOf(enumName);
    }
    
    public static FsId[] makeArrayFromList(List<FsId> list) {
        return list.toArray(new FsId[0]);
    }
    
    public static TargetTable getNullTargetTable() {
    	return (TargetTable) null;
    }
}
