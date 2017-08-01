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

package gov.nasa.kepler.ar.exporter.ktc;

import static org.junit.Assert.*;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class InvestigationClassifierTest {

    final List<String> emptyLabels =  Collections.emptyList();
    final List<String> emptyCategory = Collections.emptyList();
    
    @Test
    public void noMatchTest() {
        InvestigationClassifier iClassify = new InvestigationClassifier();
        assertEquals("", iClassify.assign(Collections.singletonList("BLAHBLAHBLAH"), emptyLabels));
        assertEquals("", iClassify.assign(emptyCategory, Collections.singletonList("BLAHBLAHBLAH")));
        assertEquals("", iClassify.assign(emptyCategory, emptyLabels));
    }
    
    @Test
    public void singleInvestigationTest() {
        InvestigationClassifier iClassify = new InvestigationClassifier();
        for (SoTargetCategory cat : SoTargetCategory.values()) {
            List<String> labels = (cat.investigationBase() == InvestigationBase.GO) ?
                Collections.singletonList("GO01234") : emptyLabels;
            String investigaionName = 
                iClassify.assign(Collections.singletonList(cat.name()), labels);
            String expected = (cat.investigationBase() == InvestigationBase.GO) ?
               labels.get(0) : cat.investigationBase().name();
            assertEquals(expected, investigaionName);
        }
    }
    
    @Test
    public void primaryWithSecondary() {
        InvestigationClassifier iClassify = new InvestigationClassifier();
        List<String> categoryNames = new ArrayList<String>();
        categoryNames.add(SoTargetCategory.PLANETARY.name());
        categoryNames.add(SoTargetCategory.PDQ_STELLAR.name());
        
        assertEquals(InvestigationBase.EX.name(), iClassify.assign(categoryNames, emptyLabels));
        
    }
    
    @Test
    public void allSecondaries() {
        InvestigationClassifier iClassify = new InvestigationClassifier();
        List<String> categoryNames = new ArrayList<String>();
        categoryNames.add(SoTargetCategory.PPA_LDE.name());
        categoryNames.add(SoTargetCategory.ASTROMETRY.name());
        categoryNames.add(SoTargetCategory.PDQ_STELLAR.name());

        
        assertEquals(InvestigationBase.STKL.name(), 
            iClassify.assign(categoryNames, emptyLabels));
        
    }
    
    @Test
    public void allPrimaries() {
        InvestigationClassifier iClassify = new InvestigationClassifier();
        List<String> categoryNames = new ArrayList<String>();
        categoryNames.add(SoTargetCategory.EB.name());
        categoryNames.add(SoTargetCategory.UNCLASSIFIED.name());
        categoryNames.add(SoTargetCategory.CLUSTER.name());
        categoryNames.add(SoTargetCategory.GO_LC.name());
        categoryNames.add(SoTargetCategory.ASTEROSEISMOLOGY_PRF_CDPP_SC.name());
        categoryNames.add(SoTargetCategory.BACKGROUND_SUPERAPERTURE.name());
        
        List<String> labels = new ArrayList<String>();
        labels.add("GO12345");
        labels.add("GO23456_LC");
        assertEquals("EX_EXBA_STC_STKS_GO12345_GO23456",
            iClassify.assign(categoryNames, labels));
    }
    
    @Test
    public void k2InvestigationClassifierTest() {
        InvestigationClassifier iClassify = new InvestigationClassifier();
        List<String> categoryNames = new ArrayList<String>();
        assertEquals("GO0001", 
            iClassify.assign(categoryNames, Arrays.asList("GO0001")));
        assertEquals("GO0001", 
                iClassify.assign(categoryNames, Arrays.asList("GO0001_SC")));
    }
}
