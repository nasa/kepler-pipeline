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

package gov.nasa.kepler.systest.sbt;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.TicToc;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.tad.Image;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

public class SbtRetrieveTad extends AbstractSbt {
    private static final String SDF_FILE_NAME = "/tmp/sbt-retrieve-tad.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = true;

    public static class TadContainer implements Persistable {
        public List<TargetContainer> targets = new ArrayList<TargetContainer>();
        
        public List<TargetDefinitionContainer> targetDefinitions = new ArrayList<TargetDefinitionContainer>();
        public List<TargetDefinitionContainer> backgroundTargetDefinitions = new ArrayList<TargetDefinitionContainer>();

        public List<MaskDefinitionContainer> targetMaskDefinitions = new ArrayList<MaskDefinitionContainer>();
        public List<MaskDefinitionContainer> backgroundMaskDefinitions = new ArrayList<MaskDefinitionContainer>();

        public double[][] coaImage = new double[FcConstants.CCD_ROWS][FcConstants.CCD_COLUMNS];

        public TadContainer(List<ObservedTarget> targets,
            List<TargetDefinition> targetDefinitions,
            List<TargetDefinition> backgroundTargetDefinitions,
            List<Mask> masks, List<Mask> backgroundMasks, Image coaImage) {
            
            if (coaImage != null) {
                this.coaImage = coaImage.getModuleOutputImage();
            } else {
                blankOutCoaImage();
            }

            for (ObservedTarget target : targets) {
                if (target.getAperture() != null) {
                    this.targets.add(new TargetContainer(target));
                }
            }
           
            for (TargetDefinition targetDefinition : targetDefinitions) {
                this.targetDefinitions.add(new TargetDefinitionContainer(targetDefinition));
            }
            
            for (TargetDefinition backgroundTargetDefinition : backgroundTargetDefinitions) {
                this.backgroundTargetDefinitions.add(new TargetDefinitionContainer(backgroundTargetDefinition));
            }

            for (Mask mask : masks) {
                this.targetMaskDefinitions.add(new MaskDefinitionContainer(mask));
            }

            for (Mask backgroundMask : backgroundMasks) {
                this.backgroundMaskDefinitions.add(new MaskDefinitionContainer(backgroundMask));
            }
        }
        
        private void blankOutCoaImage() {
            int nrows = FcConstants.CCD_ROWS;
            int ncols = FcConstants.CCD_COLUMNS;

            for (int irow = 0; irow < nrows; ++irow) {
                for (int icol = 0; icol < ncols; ++icol) {
                    this.coaImage[irow][icol] = 0.0;
                }
            }
        }
    }
    

    
    public static class MaskDefinitionContainer implements Persistable {
        public int[] rowOffsets;
        public int[] columnOffsets;
        
        public MaskDefinitionContainer(Mask mask) {
            List<Offset> offsets = mask.getOffsets();
            int nOffsets = mask.getOffsets().size();

            rowOffsets = new int[nOffsets];
            columnOffsets = new int[nOffsets];

            for (int ii = 0; ii < nOffsets; ++ii) {
                Offset offset = offsets.get(ii);
                rowOffsets[ii] = offset.getRow();
                columnOffsets[ii] = offset.getColumn();
            }
        }
    }
    
    public static class TargetDefinitionContainer implements Persistable {
        public int keplerId;
        public int maskIndex;
        public int referenceRow;
        public int referenceColumn;
        public int excessPixels;
        public int status;
        
        public TargetDefinitionContainer(TargetDefinition targetDefinition) {
            this.keplerId = targetDefinition.getKeplerId();
            this.maskIndex = targetDefinition.getMask().getIndexInTable();
            this.referenceRow = targetDefinition.getReferenceRow();
            this.referenceColumn = targetDefinition.getReferenceColumn();
            this.excessPixels = targetDefinition.getExcessPixels();
            this.status = targetDefinition.getStatus();
        }
    }
    
    public static class TargetContainer implements Persistable {
        public int keplerId;
        public String[] labels;
        public int referenceRow;
        public int referenceColumn;
        public List<Offset> offsets;
        public int badPixelCount;
        public double crowdingMetric;
        public double skyCrowdingMetric;
        public double fluxFractionInAperture;
        public boolean isRejected;
        public double signalToNoiseRatio;
        public int distanceFromEdge;
        public double magnitude;
        public double ra;
        public double dec;
        public float effectiveTemp;
        public boolean isUserDefined;
        public int saturatedRowCount;

        public TargetContainer(ObservedTarget target) {
            this.keplerId = target.getKeplerId();
            this.labels = target.getLabels().toArray(new String[0]);
            this.referenceRow = target.getAperture().getReferenceRow();
            this.referenceColumn = target.getAperture().getReferenceColumn();
            this.offsets = target.getAperture().getOffsets();
            this.badPixelCount = target.getBadPixelCount();
            this.crowdingMetric = target.getCrowdingMetric();
            this.skyCrowdingMetric = target.getSkyCrowdingMetric();
            this.fluxFractionInAperture = target.getFluxFractionInAperture();
            this.isRejected = target.isRejected();
            this.signalToNoiseRatio = target.getSignalToNoiseRatio();
            this.distanceFromEdge = target.getDistanceFromEdge();
            this.magnitude = target.getMagnitude();
            this.ra = target.getRa();
            this.dec = target.getDec();
            this.effectiveTemp = target.getEffectiveTemp();
            this.isUserDefined = target.getAperture().isUserDefined();
            this.saturatedRowCount = target.getSaturatedRowCount();
        }
    }
  
    public SbtRetrieveTad() {
        super(REQUIRES_DATABASE, REQUIRES_FILESTORE);
    }

    public String retrieveTad(int ccdModule, int ccdOutput, String inputTargetListSetName, boolean includeRejected, boolean requireSupplemental) throws Exception {
        if (! validateDatastores()) {
            return "";
        }

        TicToc.tic("Retrieving TAD data...");
        
        TargetListSet targetListSetToUse = getTargetListSetToUse(inputTargetListSetName, requireSupplemental);

        TargetCrud targetCrud = new TargetCrud();
        TargetTable targetTable = targetListSetToUse.getTargetTable();
        TargetTable backgroundTargetTable = targetListSetToUse.getBackgroundTable();
        
        List<ObservedTarget> targets;
        if (includeRejected) {
            targets = targetCrud.retrieveObservedTargetsPlusRejected(targetTable, ccdModule, ccdOutput);
        } else {
            targets = targetCrud.retrieveObservedTargets(targetTable, ccdModule, ccdOutput);
        }

        List<TargetDefinition> targetDefinitions = targetCrud.retrieveTargetDefinitions(targetTable, ccdModule, ccdOutput);
        List<TargetDefinition> backgroundTargetDefinitions = targetCrud.retrieveTargetDefinitions(backgroundTargetTable, ccdModule, ccdOutput);

        List<Mask> masks = targetCrud.retrieveMasks(targetTable.getMaskTable());

        List<Mask> backgroundMasks = newArrayList();
        if (backgroundTargetTable != null) {
            backgroundMasks = targetCrud.retrieveMasks(backgroundTargetTable.getMaskTable());
        }

        Image image = targetCrud.retrieveImage(targetTable, ccdModule, ccdOutput);

        
        TadContainer container = new TadContainer(targets, targetDefinitions, backgroundTargetDefinitions, masks, backgroundMasks, image);
        
        TicToc.toc();

        return makeSdf(container, SDF_FILE_NAME);
    }
    
    private TargetListSet getTargetListSetToUse(String inputTargetListSetName, boolean requireSupplemental) {

        List<TargetListSet> targetListSets = new TargetSelectionCrud().retrieveAllTargetListSets();

        TargetListSet targetListSetToUse = null;
        
        for (TargetListSet targetListSet : targetListSets) {
            if (requireSupplemental && targetListSet.getSupplementalTls() == null ) {
                continue;
            }
            
            if (targetListSet.getName().equals(inputTargetListSetName)) {
                targetListSetToUse = targetListSet;
            }
        }

        if (targetListSetToUse == null) {
            throw new IllegalArgumentException(
                "The inputTlsName must exist in the database and cannot refer to a supplemental tls.  The " +
                "inputTlsName needs to refer to an original " +
                "tls because a supplemental tls does not typically have target definitions.  retrieve_tad " +
                "uses the same behavior as the pipeline: automatically override " +
                "applicable tad fields in the original tls using fields from the latest supplemental " +
                "tls.\n  inputTlsName: " + inputTargetListSetName);
        }
        
        return targetListSetToUse;
    }

    public static void main(String[] args) throws Exception {
        int ccdModule = 2;
        int ccdOutput = 1;
        String targetListSetName = "quarter5_spring2010_lc_v2";
        
        SbtRetrieveTad sbt = new SbtRetrieveTad();
        String path = sbt.retrieveTad(ccdModule, ccdOutput, targetListSetName, true, true);
        System.out.println(path);

    }

}
