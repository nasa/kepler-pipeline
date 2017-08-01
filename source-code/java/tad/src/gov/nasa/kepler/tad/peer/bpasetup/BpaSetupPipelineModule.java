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

package gov.nasa.kepler.tad.peer.bpasetup;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.MaskTableFactory;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableFactory;
import gov.nasa.kepler.mc.TargetListSetOperations;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.tad.peer.bpa.BpaPipelineModule;
import gov.nasa.kepler.tad.peer.coa.CoaPipelineModule;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Creates a background {@link TargetTable}, {@link MaskTable}, and {@link Mask}
 * s. Preconditions: {@link CoaPipelineModule} has run for the
 * {@link TargetListSet}. Postconditions: A background {@link TargetTable},
 * {@link MaskTable}, and {@link Mask} are generated for the
 * {@link TargetListSet}.
 * 
 * @author Miles Cote
 */
public class BpaSetupPipelineModule extends PipelineModule {

    static final TargetType TARGET_TYPE = TargetType.BACKGROUND;

    static final int INDEX_IN_TABLE = 0;

    static final MaskType MASK_TYPE = MaskType.BACKGROUND;

    public static final String MODULE_NAME = "bpasetup";

    private static final Log log = LogFactory.getLog(BpaSetupPipelineModule.class);

    private TargetListSet targetListSet;

    private final TargetCrud targetCrud;
    private final TargetSelectionCrud targetSelectionCrud;
    private final MaskTableFactory maskTableFactory;
    private final TargetTableFactory targetTableFactory;
    private final Mask mask;

    public BpaSetupPipelineModule() {
        this(new TargetCrud(), new TargetSelectionCrud(),
            new MaskTableFactory(), new TargetTableFactory(), new Mask(null,
                BpaPipelineModule.theOfficialTwoByTwoOffsets()));
    }

    BpaSetupPipelineModule(TargetCrud targetCrud,
        TargetSelectionCrud targetSelectionCrud,
        MaskTableFactory maskTableFactory,
        TargetTableFactory targetTableFactory, Mask mask) {
        this.targetCrud = targetCrud;
        this.targetSelectionCrud = targetSelectionCrud;
        this.maskTableFactory = maskTableFactory;
        this.targetTableFactory = targetTableFactory;
        this.mask = mask;
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return SingleUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParams = newArrayList();
        requiredParams.add(TadParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        TadParameters params = pipelineTask.getParameters(TadParameters.class);
        targetListSet = targetSelectionCrud.retrieveTargetListSet(params.getTargetListSetName());

        log.info(TargetListSetOperations.getTlsInfo(targetListSet));

        if (targetListSet.getState() != State.LOCKED) {
            throw new ModuleFatalProcessingException(
                TargetListSetOperations.getNotLockedTlsErrorText(targetListSet));
        }

        if (targetListSet.getType() != TargetType.LONG_CADENCE) {
            throw new ModuleFatalProcessingException(MODULE_NAME
                + " must run on a " + TargetType.LONG_CADENCE
                + " targetListSet.\n  targetType: " + targetListSet.getType()
                + TargetListSetOperations.getTlsInfo(targetListSet));
        }

        TargetTable oldTargetTable = targetListSet.getBackgroundTable();

        MaskTable oldMaskTable = null;
        if (oldTargetTable != null) {
            oldMaskTable = oldTargetTable.getMaskTable();
        }

        log.debug("Create the backgroundMaskTable.");
        MaskTable maskTable = maskTableFactory.create(MASK_TYPE);
        targetCrud.createMaskTable(maskTable);

        List<Mask> masks = newArrayList();
        mask.setMaskTable(maskTable);
        mask.setPipelineTask(pipelineTask);
        mask.setIndexInTable(INDEX_IN_TABLE);
        masks.add(mask);
        targetCrud.createMasks(masks);

        log.debug("Create the backgroundTargetTable.");
        TargetTable backgroundTable = targetTableFactory.create(TARGET_TYPE);
        backgroundTable.setObservingSeason(targetListSet.getTargetTable()
            .getObservingSeason());
        backgroundTable.setMaskTable(maskTable);
        targetCrud.createTargetTable(backgroundTable);
        targetListSet.setBackgroundTable(backgroundTable);

        backgroundTable.setPlannedStartTime(targetListSet.getStart());
        backgroundTable.setPlannedEndTime(targetListSet.getEnd());
        backgroundTable.getMaskTable()
            .setPlannedStartTime(targetListSet.getStart());
        backgroundTable.getMaskTable()
            .setPlannedEndTime(targetListSet.getEnd());

        // Delete the old tables.
        targetCrud.delete(oldTargetTable);
        targetCrud.delete(oldMaskTable);
    }

}
