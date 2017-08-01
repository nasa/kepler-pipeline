/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * NASA acknowledges the SETI Institute's primary role in authoring and
 * producing the Kepler Data Processing Pipeline under Cooperative
 * Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
 * NNX11AI14A, NNX13AD01A & NNX13AD16A.
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

package gov.nasa.kepler.tps;

import gov.nasa.kepler.fc.RollTimeModel;
import gov.nasa.kepler.mc.BootstrapModuleParameters;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.MqTimestampSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.List;

/**
 * 
 * @author Sean McCauliff
 * 
 */
@SuppressWarnings("unused")
public class TpsInputs implements Persistable {
    /** The inputs from are from this particular skygroup.  This is to assist
     * in debugging TPS. 
     */
    private int skyGroup;
    
    /** Parameters specific to the TPS pipeline module. */
    private TpsModuleParameters tpsModuleParameters;
    
    /** Controls filling of data gaps. */
    private GapFillModuleParameters gapFillParameters;
    
    /**  Used to identify regular oscillations in star brightness. */
    private TpsHarmonicsIdentificationParameters harmonicsIdentificationParameters;
    
    /** For running the boostrap. */
    private BootstrapModuleParameters bootstrapParameters;
    
    /** A list of targets which TPS will work on. */
    private List<TpsTarget> tpsTargets;
    
    /** The times when the the spacecraft rolled. */
    private RollTimeModel rollTimeModel;

    /** A mapping of cadence numbers to absolute times as well as anomaly flags. */
    private MqTimestampSeries cadenceTimes;
    
    /** MATLAB task timeout from the pipeline module definition. */
    private int taskTimeoutSecs;
    
    /** Number of tasks to allocate to each available core (i.e. the queue depth). */
    private double tasksPerCore;
    
    /**
     *  Don't use this.
     */
    public TpsInputs() {
    }

    public TpsInputs( int skyGroup, 
        TpsModuleParameters tpsModuleParameters,
        GapFillModuleParameters gapFillParameters,
        TpsHarmonicsIdentificationParameters tpsHarmonicsIdentificationParameters,
        BootstrapModuleParameters bootstrapParameters,
        List<TpsTarget> tpsTargets, RollTimeModel rollTimeModel,
        MqTimestampSeries cadenceTimes, int taskTimeoutSecs, double tasksPerCore) {

        this.skyGroup = skyGroup;
        this.tpsModuleParameters = tpsModuleParameters;
        this.gapFillParameters = gapFillParameters;
        this.harmonicsIdentificationParameters = tpsHarmonicsIdentificationParameters;
        this.bootstrapParameters = bootstrapParameters;
        this.tpsTargets = tpsTargets;
        this.rollTimeModel = rollTimeModel;
        this.cadenceTimes = cadenceTimes;
        this.taskTimeoutSecs = taskTimeoutSecs;
        this.tasksPerCore = tasksPerCore;
    }
}
