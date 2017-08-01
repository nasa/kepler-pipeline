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

package gov.nasa.kepler.hibernate.pi;

import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;

public class PipelineDefinitionNodePathTest {

    /**
     * o / \ n1 n2 / \ n3 n4
     * 
     * @throws Exception
     */
    @Test
    public void testPath() throws Exception {
        PipelineDefinition pd = new PipelineDefinition();
        PipelineDefinitionNode n1 = new PipelineDefinitionNode();
        PipelineDefinitionNode n2 = new PipelineDefinitionNode();
        PipelineDefinitionNode n3 = new PipelineDefinitionNode();
        PipelineDefinitionNode n4 = new PipelineDefinitionNode();

        pd.getRootNodes()
            .add(n1);
        pd.getRootNodes()
            .add(n2);
        n2.getNextNodes()
            .add(n3);
        n2.getNextNodes()
            .add(n4);

        PipelineDefinitionNodePath n1ExpectedPath = new PipelineDefinitionNodePath(
            parseList(0));
        PipelineDefinitionNodePath n2ExpectedPath = new PipelineDefinitionNodePath(
            parseList(1));
        PipelineDefinitionNodePath n3ExpectedPath = new PipelineDefinitionNodePath(
            parseList(1, 0));
        PipelineDefinitionNodePath n4ExpectedPath = new PipelineDefinitionNodePath(
            parseList(1, 1));

        pd.buildPaths();

        ReflectionEquals comparer = new ReflectionEquals();

        comparer.assertEquals("n1", n1ExpectedPath, n1.getPath());
        comparer.assertEquals("n2", n2ExpectedPath, n2.getPath());
        comparer.assertEquals("n3", n3ExpectedPath, n3.getPath());
        comparer.assertEquals("n4", n4ExpectedPath, n4.getPath());
    }

    private List<Integer> parseList(int... pathElements) {
        List<Integer> path = new ArrayList<Integer>();

        for (int pathElement : pathElements) {
            path.add(pathElement);
        }

        return path;
    }
}
