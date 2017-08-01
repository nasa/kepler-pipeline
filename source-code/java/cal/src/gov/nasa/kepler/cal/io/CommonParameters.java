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

package gov.nasa.kepler.cal.io;

import gov.nasa.kepler.cal.ffi.FfiModOut;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.fc.FlatFieldModel;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.UndershootModel;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.gar.RequantTable;

import java.util.Collections;
import java.util.List;

/**
 * Common parameters for all Cal invocations used to contruct cal inputs.
 * 
 * @author Sean McCauliff
 *
 */
public class CommonParameters {

    private final boolean emptyParameters;
    
    private final TargetTable targetTable;
    
    private final TargetTable lcTargetTable;
    
    private final TargetTable backgroundTargetTable;

    private final int ccdModule;

    private final int ccdOutput;

    private final String cadenceType;
    
    private final CalModuleParameters moduleParametersStruct;

    private final CalCosmicRayParameters cosmicRayParametersStruct;

    private final PouModuleParameters pouModuleParametersStruct;

    private final CalHarmonicsIdentificationParameters harmonicsParametersStruct;
    
    private final GapFillModuleParameters gapFillParametersStruct;
    
    private final TimestampSeries cadenceTimes;

    private final GainModel gainModel;

    private final FlatFieldModel flatFieldModel;

    private final TwoDBlackModel twoDBlackModel;

    private final LinearityModel linearityModel;

    private final UndershootModel undershootModel;

    private final ReadNoiseModel readNoiseModel;

    private final List<TwoDBlackId> twoDBlackIds;

    private final List<LdeUndershootId> ldeUndershootIds;

    private final List<ConfigMap> spacecraftConfigMap;

    private final List<RequantTable> requantTables;

    private final List<HuffmanTable> huffmanTables;
    
    private final int season;
    
    private final int quarter;
     
    private final int k2Campaign;
    
     /**
      * 
      */
    private final BlobFileSeries oneDBlackBlobs;
     
    private final BlobFileSeries dynamic2DBlackBlobs;
    
    private final BlobFileSeries smearBlobs;
     
    private long pipelineTaskId = -1;
    
    private final List<FfiModOut> ffiModOut;
   
    /**
     * Use this constructor when we need cal to generate an empty output for the
     * same set of parameters.
     */
    public CommonParameters(TargetTable targetTable,
                            TargetTable lcTargetTable,
                            TargetTable backgroundTargetTable,
                            int ccdModule,
                            int ccdOutput,
                            String cadenceType,
                            int season,
                            int quarter,
                            CalModuleParameters moduleParametersStruct,
                            CalCosmicRayParameters cosmicRayParametersStruct,
                            PouModuleParameters pouModuleParametersStruct,
                            CalHarmonicsIdentificationParameters harmonicsParameterStruct,
                            GapFillModuleParameters gapFillParametersStruct,
                            TimestampSeries cadenceTimes) {
        this.targetTable = targetTable;
        this.lcTargetTable = lcTargetTable;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.cadenceType = cadenceType;
        this.moduleParametersStruct = moduleParametersStruct;
        this.cosmicRayParametersStruct = cosmicRayParametersStruct;
        this.pouModuleParametersStruct = pouModuleParametersStruct;
        this.harmonicsParametersStruct = harmonicsParameterStruct;
        this.gapFillParametersStruct = gapFillParametersStruct;
        this.cadenceTimes = cadenceTimes;
        this.gainModel = new GainModel();
        this.flatFieldModel = new FlatFieldModel();
        this.twoDBlackModel = new TwoDBlackModel();
        this.linearityModel = new LinearityModel();
        this.undershootModel = new UndershootModel();
        this.readNoiseModel = new ReadNoiseModel();
        this.twoDBlackIds = Collections.emptyList();
        this.ldeUndershootIds = Collections.emptyList();
        this.spacecraftConfigMap = Collections.emptyList();
        this.requantTables = Collections.emptyList();
        this.huffmanTables = Collections.emptyList();
        this.season = season;
        this.quarter = quarter;
        this.oneDBlackBlobs = new BlobFileSeries();
        this.dynamic2DBlackBlobs = new BlobFileSeries();
        this.backgroundTargetTable = backgroundTargetTable;
        this.smearBlobs = new BlobFileSeries();
        this.ffiModOut = Collections.emptyList();
        this.emptyParameters = true; //This is important.
        this.k2Campaign = moduleParametersStruct.getK2Campaign();
    }
        
    public CommonParameters(TargetTable targetTable,
        TargetTable lcTargetTable,
        TargetTable backgroundTargetTable,
        int ccdModule,
        int ccdOutput, String cadenceType,
        CalModuleParameters moduleParametersStruct,
        CalCosmicRayParameters cosmicRayParametersStruct,
        PouModuleParameters pouModuleParametersStruct,
        CalHarmonicsIdentificationParameters harmonicsParameterStruct,
        GapFillModuleParameters gapFillParametersStruct,
        TimestampSeries cadenceTimes, GainModel gainModel,
        FlatFieldModel flatFieldModel, TwoDBlackModel twoDBlackModel,
        LinearityModel linearityModel, UndershootModel undershootModel,
        ReadNoiseModel readNoiseModel, List<TwoDBlackId> twoDBlackIds,
        List<LdeUndershootId> ldeUndershootIds,
        List<ConfigMap> spacecraftConfigMap, List<RequantTable> requantTables,
        List<HuffmanTable> huffmanTables, int season, int quarter,
        BlobFileSeries oneDBlackBlobs, BlobFileSeries dynamic2dBlackBlobs,
        BlobFileSeries smearBlobs,
        List<FfiModOut> ffiModOut) {

        this.targetTable = targetTable;
        this.lcTargetTable = lcTargetTable;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.cadenceType = cadenceType;
        this.moduleParametersStruct = moduleParametersStruct;
        this.cosmicRayParametersStruct = cosmicRayParametersStruct;
        this.pouModuleParametersStruct = pouModuleParametersStruct;
        this.harmonicsParametersStruct = harmonicsParameterStruct;
        this.gapFillParametersStruct = gapFillParametersStruct;
        this.cadenceTimes = cadenceTimes;
        this.gainModel = gainModel;
        this.flatFieldModel = flatFieldModel;
        this.twoDBlackModel = twoDBlackModel;
        this.linearityModel = linearityModel;
        this.undershootModel = undershootModel;
        this.readNoiseModel = readNoiseModel;
        this.twoDBlackIds = twoDBlackIds;
        this.ldeUndershootIds = ldeUndershootIds;
        this.spacecraftConfigMap = spacecraftConfigMap;
        this.requantTables = requantTables;
        this.huffmanTables = huffmanTables;
        this.season = season;
        this.quarter = quarter;
        this.oneDBlackBlobs = oneDBlackBlobs;
        this.dynamic2DBlackBlobs = dynamic2dBlackBlobs;
        this.backgroundTargetTable = backgroundTargetTable;
        this.smearBlobs = smearBlobs;
        this.ffiModOut = ffiModOut;
        this.emptyParameters = false;
        this.k2Campaign = moduleParametersStruct.getK2Campaign();
    }

    public int startCadence() {
        return cadenceTimes.cadenceNumbers[0];
    }
    
    public int endCadence() {
        return cadenceTimes.cadenceNumbers[cadenceTimes.cadenceNumbers.length - 1];
    }
    
    public TargetTable backgroundTargetTable() {
        return backgroundTargetTable;
    }
    
    public TargetTable targetTable() {
        return targetTable;
    }
    
    public int ccdModule() {
        return ccdModule;
    }

    public int ccdOutput() {
        return ccdOutput;
    }

    public CalModuleParameters moduleParametersStruct() {
        return moduleParametersStruct;
    }

    public CalCosmicRayParameters cosmicRayParametersStruct() {
        return cosmicRayParametersStruct;
    }

    public PouModuleParameters pouModuleParametersStruct() {
        return pouModuleParametersStruct;
    }

    public TimestampSeries cadenceTimes() {
        return cadenceTimes;
    }

    public GainModel gainModel() {
        return gainModel;
    }

    public FlatFieldModel flatFieldModel() {
        return flatFieldModel;
    }

    public TwoDBlackModel twoDBlackModel() {
        return twoDBlackModel;
    }

    public LinearityModel linearityModel() {
        return linearityModel;
    }

    public UndershootModel undershootModel() {
        return undershootModel;
    }

    public ReadNoiseModel readNoiseModel() {
        return readNoiseModel;
    }

    public List<TwoDBlackId> twoDBlackIds() {
        return twoDBlackIds;
    }

    public List<LdeUndershootId> ldeUndershootIds() {
        return ldeUndershootIds;
    }

    public List<ConfigMap> spacecraftConfigMap() {
        return spacecraftConfigMap;
    }

    public List<RequantTable> requantTables() {
        return requantTables;
    }

    public List<HuffmanTable> huffmanTables() {
        return huffmanTables;
    }

    public int season() {
        return season;
    }

    /**
     * These will be from an overlapping long cadence invocation.
     * @return
     */
    public BlobFileSeries oneDBlackBlobs() {
        return oneDBlackBlobs;
    }

    public BlobFileSeries dynamic2DBlackBlobs() {
        return dynamic2DBlackBlobs;
    }
    
    public BlobFileSeries smearBlobs() {
    	return smearBlobs;
    }
    
    public String cadenceTypeStr() {
        return cadenceType;
    }
    
    public CadenceType cadenceType() {
        return CadenceType.valueOf(cadenceType);
    }
    
    public long pipelineTaskId() {
        return pipelineTaskId;
    }
    
    public void setPipelineTaskId(long pipelineTaskId) {
        this.pipelineTaskId = pipelineTaskId;
    }
    
    public EmbeddedPipelineInfo embeddedPipelineInfo() {
        return new EmbeddedPipelineInfo(ccdModule, ccdOutput,
            startCadence(), endCadence(), pipelineTaskId,
            targetTable.getExternalId(), lcTargetTable.getExternalId(),
            backgroundTargetTable == null ? -1 : backgroundTargetTable.getExternalId(),
            cadenceTypeStr());
    }
    
    public List<FfiModOut> ffiModOut() {
        return ffiModOut;
    }

    public CalHarmonicsIdentificationParameters harmonicsParametersStruct() {
        return harmonicsParametersStruct;
    }
    
    public GapFillModuleParameters gapFillParametersStruct() {
        return gapFillParametersStruct;
    }
    
    /**
     * @return When true this set of parameters exists so that cal can generate empty
     * parameters.
     * 
     */
    public boolean emptyParameters() {
        return emptyParameters;
    }
    
    public int quarter() {
        if (k2Campaign != CalModuleParameters.K2_CAMPAIGN_MISSING) {
            return quarter;
        } else {
            return 0;
        }
    }
    
    public int k2Campaign() {
        return k2Campaign;
    }

 }
