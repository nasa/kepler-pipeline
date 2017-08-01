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

import gov.nasa.spiffy.common.pi.PipelineException;

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * This class provides a simple wrapper around a String 
 * that contains a Java classname.  The constructors guarantee
 * that the className is always the name of a valid class,
 * and this class can be parameterized to enforce that 
 * the class extends from the parameterized type 
 * 
 * @author tklaus
 *
 */
@Embeddable
public class ClassWrapper<T> implements Comparable<ClassWrapper<T>>{

    private String clazz = null;
    @Column(nullable=true)
    private Boolean initialized = false;
    
    /** for Hibernate use only */
    ClassWrapper() {
    }

    /** 
     * Construct with a new instance
     * 
     * 
     * @param clazz
     */
    public ClassWrapper(Class<? extends T> clazz) {
        this.clazz = clazz.getName();
        this.initialized = true;
    }
    
    /**
     * Construct from an existing instance
     * 
     * @param <E>
     * @param instance
     * @throws PipelineException
     */
    public <E extends T> ClassWrapper(E instance) {
        this.clazz = instance.getClass().getName();
        this.initialized = true;
    }
    
    /**
     * Copy constructor
     * @param otherClassWrapper
     */
    public ClassWrapper(ClassWrapper<T> otherClassWrapper){
        this.clazz = otherClassWrapper.clazz;
        this.initialized = otherClassWrapper.initialized;
    }

    /**
     * Returns a new instance of T.
     * 
     * @throws PipelineException 
     */
    @SuppressWarnings("unchecked")
    public T newInstance() throws PipelineException{
        try {
            return (T) Class.forName(clazz).newInstance();
        } catch (Exception e) {
            throw new PipelineException("failed to instantiate instance with className=" + clazz + ", caught e = " + e, e );
        }
    }

    public Class<T> getClazz() {
        try {
            @SuppressWarnings("unchecked")
            Class<T> c = (Class<T>) Class.forName(clazz);
            return c;
        } catch (Exception e) {
            throw new PipelineException("failed to instantiate instance with className=" + clazz + ", caught e = " + e, e );
        }
    }

    /**
     * @return the className
     */
    public String getClassName() {
        return clazz;
    }

    public boolean isInitialized() {
        if(initialized == null){
            return false;
        }else{
            return initialized;
        }
    }

    @Override
    public String toString() {
        return clazz;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((clazz == null) ? 0 : clazz.hashCode());
        return result;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#equals(java.lang.Object)
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        final ClassWrapper<?> other = (ClassWrapper<?>) obj;
        if (clazz == null) {
            if (other.clazz != null)
                return false;
        } else if (!clazz.equals(other.clazz))
            return false;
        return true;
    }

    /* (non-Javadoc)
     * @see java.lang.Comparable#compareTo(java.lang.Object)
     */
    @Override
    public int compareTo(ClassWrapper<T> o) {
        return clazz.compareTo(o.clazz);
    }

}
