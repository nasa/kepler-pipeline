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

package gov.nasa.spiffy.common.pi;


/**
 * PipelineModules should throw this exception for cases where the pipeline should
 * not attempt to re-try this task.
 * 
 * The difference between a ModuleFatalProcessingException and any other kind of exception 
 * is whether the pipeline will attempt to automatically re-try the task by rolling back 
 * the messaging transaction.  This puts the message back on the queue for delivery to 
 * another (or possibly the same) worker.  For ModuleFatalProcessingException, 
 * the pipeline will just mark the task as failed and will not retry (the operator can 
 * manually retry using the PIG once they fix the problem).  For any other exception, 
 * it will retry.  So, if you know for sure that the problem is 'permanent', like the 
 * requisite inputs not being available, incorrect configuration, or anything else where 
 * the error will continue to occur no matter how many times you try, you should throw 
 * ModuleFatalProcessingException.
 * 
 * @author tklaus
 *
 */
public class ModuleFatalProcessingException extends PipelineException {
    private static final long serialVersionUID = -5155087029123765745L;

    public ModuleFatalProcessingException(String errorText, Throwable t) {
        super(errorText, t);
    }

    public ModuleFatalProcessingException(String errorText) {
        super(errorText);
    }
    
    /**
     * 
     * @param errorCode
     * @param errorText
     * @param t
     * @deprecated errorCode no longer used, please use alternate ctor
     */
    @Deprecated
    public ModuleFatalProcessingException(int errorCode, String errorText, Throwable t) {
        super(errorText, t);
    }

    /**
     * 
     * @param errorCode
     * @param errorText
     * @deprecated errorCode no longer used, please use alternate ctor
     */
    @Deprecated
    public ModuleFatalProcessingException(int errorCode, String errorText) {
        super(errorText);
    }
}
