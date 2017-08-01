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



package gov.nasa.kepler.fc.wrapper;

//
//import gov.nasa.kepler.modules.FocalPlaneCharacterization.peer.FocalPlaneCharacterizationInputs;
//import gov.nasa.kepler.modules.FocalPlaneCharacterization.peer.FocalPlaneCharacterizationOutputs;
//import gov.nasa.kepler.pipeline.database.DatabaseServiceFactory;
//import gov.nasa.kepler.pipeline.datamodel.persistence.ModuleParameterSet;
//import gov.nasa.kepler.pipeline.datamodel.persistence.PipelineInstance;
//import gov.nasa.kepler.pipeline.datamodel.persistence.PipelineInstanceNode;
//import gov.nasa.kepler.pipeline.framework.PipelineException;
//import gov.nasa.kepler.pipeline.module.AbstractModule;
//import gov.nasa.kepler.pipeline.worker.messages.WorkerTaskRequest;
//
//import gov.nasa.kepler.focalplanecharacterization.invalidpixels.FindInvalidPixels;
//
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//import org.apache.log4j.xml.DOMConfigurator;
//
public class FCWrapper { // extends AbstractModule {
//    /**
//     * Logger for this class
//     */
//    
//    private static final Log log = LogFactory.getLog( FCWrapper.class );
//
//    // JACE-generated C++ peer
//    private FCPeer peer = new FCPeer();
//    
//    /**
//     * @throws Exception 
//     * 
//     */
//    public FCWrapper() throws Exception {
//    }
//
//    @Override
//    public String getModuleName() {
//        return "FocalPlaneCharacterization";
//    }
//
//    @Override
//    public String getModuleVersion() {
//        return "1.0";
//    }
//    
//    @Override
//    public void processMessage(
//            WorkerTaskRequest    workerTaskRequest,
//            PipelineInstance     instance,
//            PipelineInstanceNode instanceNode
//    )
//    throws PipelineException
//    {
//        log.debug("processMessage(WorkerTaskRequest, PipelineInstance, PipelineInstanceNode) - start");
//
//        ModuleParameterSet moduleParams = null;// instanceNode.getPipelineNode().getModule().getParameterSet();
//        
//        for( long targetId = 42000; targetId < 42001; targetId++ ){
//            FCInput  inputs  = new FCInput();
//            FCOutput outputs = new FCOutput();
//            
//            populateInputs( inputs, moduleParams, targetId );
//
//            log.debug("invoking peer doFC()");
//            peer.doFC( inputs, outputs );
//            log.debug("done invoking peer doFC()");
//            
//            storeOutputs( outputs );
//        }
//        
//        log.debug("processMessage(WorkerTaskRequest, PipelineInstance, PipelineInstanceNode) - end");
//    }
//
//    private void populateInputs(
//            FCInput inputs,
//            ModuleParameterSet moduleParams,
//            long targetId 
//    ) throws PipelineException
//    {
//        PersistenceManager pm = DatabaseServiceFactory.getInstance().getPersistenceManager();
//        
//        FindInvalidPixels fip = new FindInvalidPixels();
//        
//        Query query = pm.newQuery(
//                          "javax.jdo.query.JDOQL", 
//                          "SELECT FROM invalidPixels WHERE targetId == requestedTarget"
//                      );
//        query.declareParameters("long requestedTarget");
//        query.setUnique( true );
//        log.debug("executing query");
////        Noise noise = (Noise) query.execute( targetId );    
//        log.debug("done executing query");
//    
////        LinkedList<NoiseValue> values = noise.getValues();
////        float[] noiseArray = new float[ values.size() ];
////        for( int index = 0; index < values.size(); index++ ){
////            noiseArray[ index ] = values.get( index ).getValue();
////        }
////        inputs.setNoise( noiseArray );
//    }
//
//    private void storeOutputs( FCOutput outputs ) {
//    }
//
//    /**
//     * main() simulates role of Messaging Service
//     * @param args
//     */
//    public static void main( String[] args ) {
//
//        DOMConfigurator.configure(ETC + LOG4J_CONFIG);
//        log.debug("main(String[]) - start");
//
//        try {
//            FCWrapper m = new FCWrapper();
//            m.processMessage( null, null, null );
//        
//        } catch (Exception e) {
//            log.error("main(String[])", e);
//        }
//        
//        log.debug("main(String[]) - end");
//    }
//
}
