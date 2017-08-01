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

package gov.nasa.kepler.pi.parameters;

import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Descriptor for a {@link ParameterSet}, either 
 * in the parameter library or in an export directory
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class ParameterSetDescriptor {

    public enum State{
        /** initial state */
        NONE,
        /** param set exists in the library, 
         * and the contents are identical */
        SAME,
        /** param set exists in the library,
         * but the contents are different */
        UPDATE,
        /** param set does not exist in the library */
        CREATE,
        /** param set exists in the library, but not
         * in the import directory */
        LIBRARY_ONLY,
        /** param set will be exported */
        EXPORT,
        /** param set exists in the import directory, but
         * is ignored because it is on the exclude list */
        IGNORE,
        /** param class does not exist */
        CLASS_MISSING
    }
    
    private String name;
    private String className;
    private State state;
    /** textual representation of the props in the library */
    private String libraryProps = null;
    /** textual representation of the props in the export file */
    private String fileProps = null;
    
    private ParameterSet libraryParamSet = null;
    private BeanWrapper<Parameters> importedParamsBean = null;
    
    public ParameterSetDescriptor() {
    }

    public ParameterSetDescriptor(String name, String className) {
        this.name = name;
        this.className = className;
    }

    public ParameterSetDescriptor(String name, String className, State state) {
        this.name = name;
        this.className = className;
        this.state = state;
    }

    @Override
    public String toString(){
        return state + " : " + name + " (" + className + ")";
    }
    
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getClassName() {
        return className;
    }

    public String shortClassName() {
        if(className != null){
            return className.substring(className.lastIndexOf(".")+1);
        }else{
            return "null";
        }
    }

    public void setClassName(String className) {
        this.className = className;
    }

    public State getState() {
        return state;
    }

    public void setState(State state) {
        this.state = state;
    }

    /**
     * @return the libraryProps
     */
    public String getLibraryProps() {
        return libraryProps;
    }

    /**
     * @param libraryProps the libraryProps to set
     */
    public void setLibraryProps(String libraryProps) {
        this.libraryProps = libraryProps;
    }

    /**
     * @return the fileProps
     */
    public String getFileProps() {
        return fileProps;
    }

    /**
     * @param fileProps the fileProps to set
     */
    public void setFileProps(String fileProps) {
        this.fileProps = fileProps;
    }

    /**
     * @return the libraryParamSet
     */
    public ParameterSet getLibraryParamSet() {
        return libraryParamSet;
    }

    /**
     * @param libraryParamSet the libraryParamSet to set
     */
    public void setLibraryParamSet(ParameterSet libraryParamSet) {
        this.libraryParamSet = libraryParamSet;
    }

    /**
     * @return the importedParamsBean
     */
    public BeanWrapper<Parameters> getImportedParamsBean() {
        return importedParamsBean;
    }

    /**
     * @param importedParamsBean the importedParamsBean to set
     */
    public void setImportedParamsBean(BeanWrapper<Parameters> importedParamsBean) {
        this.importedParamsBean = importedParamsBean;
    }
}
