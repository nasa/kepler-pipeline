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

package gov.nasa.kepler.sggen;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.cm.TargetSelectionOperations;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.uow.KicGroup;
import gov.nasa.kepler.mc.uow.KicGroupUowTask;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Pipeline module that calls the MATLAB module, sggen. This module calls
 * ra_dec_2_pix on every KIC entry in the inputs and computes the sky group ID
 * based on the location.
 * 
 * @author tklaus
 * 
 */
public class SkyGroupGenPipelineModule extends MatlabPipelineModule {
    
    public static final int SEASON_COUNT = 4;
    
    private static final Log log = LogFactory.getLog(SkyGroupGenPipelineModule.class);

    public static final String MODULE_NAME = "sggen";

    private RaDec2PixOperations raDec2PixOperations = new RaDec2PixOperations();
    private CelestialObjectOperations celestialObjectOperations;
    private TargetSelectionOperations targetSelectionOperations = new TargetSelectionOperations();
    private RollTimeOperations rollTimeOperations = new RollTimeOperations();

    // Not read-only since we change the skygroup.
    private KicCrud kicCrud = new KicCrud(false);

    private double mjd;
    private int season;
    
    private Map<Integer, Kic> starMap = new HashMap<Integer, Kic>();

    private RaDec2PixModel raDec2PixModel;

    public SkyGroupGenPipelineModule() {
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return KicGroupUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParams = newArrayList();
        requiredParams.add(KicGroup.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {

        celestialObjectOperations = getCelestialObjectOperations(pipelineInstance);

        raDec2PixModel = raDec2PixOperations.retrieveRaDec2PixModel();

        KicGroupUowTask uow = pipelineTask.uowTaskInstance();
        List<Star> stars = getStars(uow.getStartId(), uow.getEndId());

        KicGroup params = pipelineTask.getParameters(KicGroup.class);
        mjd = params.getMjd();
        season = rollTimeOperations.mjdToSeason(mjd);
        
        SkyGroupGenInputs inputs = new SkyGroupGenInputs();
        inputs.setStars(stars);
        inputs.setMjd(mjd);
        inputs.setRaDec2PixModel(raDec2PixModel);

        SkyGroupGenOutputs outputs = new SkyGroupGenOutputs();
        if (!inputs.getStars()
            .isEmpty()) {
            executeAlgorithm(pipelineTask, inputs, outputs);
            storeOutputs(outputs);
        }
    }

    private List<Star> getStars(int startKeplerId, int endKeplerId) {
        List<Kic> kics = kicCrud.retrieveKics(startKeplerId, endKeplerId);
        List<CelestialObjectParameters> celestialObjectParametersList = celestialObjectOperations.retrieveCelestialObjectParameters(
            startKeplerId, endKeplerId);
        if (kics.size() != celestialObjectParametersList.size()) {
            throw new ModuleFatalProcessingException(
                "Number of KIC objects accessed via "
                    + KicCrud.class.getSimpleName() + " (" + kics.size()
                    + ") differed from number of objects access by "
                    + CelestialObjectOperations.class.getSimpleName() + " ("
                    + celestialObjectParametersList.size()
                    + ") for Kepler IDs between " + startKeplerId + " and "
                    + endKeplerId);
        }
        log.info("Retrieved " + kics.size() + " KICS between " + startKeplerId
            + " and " + endKeplerId);

        for (Kic kic : kics) {
            starMap.put(kic.getKeplerId(), kic);
        }

        List<Star> stars = new ArrayList<Star>();
        for (CelestialObjectParameters celestialObjectParameters : celestialObjectParametersList) {
            Star star = new Star(celestialObjectParameters.getKeplerId(),
                celestialObjectParameters.getRa()
                    .getValue(), celestialObjectParameters.getDec()
                    .getValue());
            stars.add(star);
        }

        return stars;
    }

    protected void storeOutputs(SkyGroupGenOutputs outputs) {
        List<Star> stars = outputs.getStars();
        for (Star star : stars) {
            int skyGroupId = skyGroupIdFor(star.getCcdModule(),
                star.getCcdOutput(), season);
            Kic kic = starMap.get(star.getKeplerId());
            if (kic == null) {
                throw new ModuleFatalProcessingException("keplerId("
                    + star.getKeplerId()
                    + ") found in outputs, but not in starMap");
            }
            if (skyGroupId != kic.getSkyGroupId()) {
                kic.setSkyGroupId(skyGroupId);
            }
        }
    }

    private int skyGroupIdFor(int ccdModule, int ccdOutput, int season) {
        if (ccdModule == -1 || ccdOutput < 1 || ccdOutput > 4) {
            return 0;
        }

        return targetSelectionOperations.skyGroupIdFor(ccdModule, ccdOutput,
            season);
    }

    void setRaDec2PixOperations(RaDec2PixOperations raDec2PixOperations) {
        this.raDec2PixOperations = raDec2PixOperations;
    }

    private CelestialObjectOperations getCelestialObjectOperations(
        PipelineInstance pipelineInstance) {

        if (celestialObjectOperations == null) {
            celestialObjectOperations = new CelestialObjectOperations(
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance),
                true);
        }

        return celestialObjectOperations;
    }

    void setCelestialObjectOperations(
        CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    void setTargetSelectionOperations(
        TargetSelectionOperations targetSelectionOperations) {
        this.targetSelectionOperations = targetSelectionOperations;
    }

    void setKicCrud(KicCrud kicCrud) {
        this.kicCrud = kicCrud;
    }
    
    void setRollTimeOperations(RollTimeOperations rollTimeOperations) {
        this.rollTimeOperations = rollTimeOperations;
    }
}
