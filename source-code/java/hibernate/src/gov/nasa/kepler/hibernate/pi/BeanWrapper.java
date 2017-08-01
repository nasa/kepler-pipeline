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

import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javax.persistence.Column;
import javax.persistence.Embeddable;
import javax.persistence.FetchType;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.beanutils.BeanUtilsBean2;
import org.apache.commons.lang.ArrayUtils;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.Fetch;
import org.hibernate.annotations.FetchMode;

/**
 * This class provides database persistence for an arbitrary Java class
 * using JavaBeans semantics.  Persistence is provided by representing the
 * bean's contents as a Map<String,String> using the Apache Commons BeanUtils
 * classes (a thin wrapper on top of the JavaBeans Introspection classes).
 * 
 * This class also contains the name of the class and uses that to 
 * manage instantiation and to define the valid members of the Map.  
 * For type-safety, the class can be parameterized <T>.  The constructor then
 * enforces that the class can only be instantiated with types that extend T.  
 * T must conform to the JavaBeans specification.  
 *  
 * This class also provides instance management (create, populate, describe).
 * The instance created is considered to be transient; changes to the instance, either
 * directly or through the populate() method, do not affect the props Map that
 * gets persisted.  Changes to the props Map are only made when calling setProps() or
 * populateFromInstance(), or when instantiating a new Wrapper from an existing instance.
 * 
 * @author tklaus
 *
 */
@Embeddable
public class BeanWrapper<T> {

    @Column(nullable=true)
    private String clazz = null;
    @Column(nullable=true)
    private Boolean initialized = false;
    
    /** state of the bean */
    @CollectionOfElements(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @Column(nullable=true, length=4000)
    protected Map<String, String> props = new HashMap<String,String>();

    /** for Hibernate use only */
    BeanWrapper() {
    }

    /** 
     * Construct from a Class
     * A new instance of the class is created, and the props map
     * is populated from the default values in the new instance.
     * 
     * @param clazz
     */
    public BeanWrapper(Class<? extends T> clazz) {
        this.clazz = clazz.getName();
        /* call createInstance with populate==false so that the class defaults will be used */
        T instance = createInstance(false);
        Map<String, String> allProps = beanUtilsDescribe(instance);
        clearNulls(allProps);
        props = allProps;
        initialized = true;
    }
    
    /**
     * Construct from an existing instance
     * 
     * @param <E>
     * @param instance
     * @throws PipelineException
     */
    public <E extends T> BeanWrapper(E instance) {
        this.clazz = instance.getClass().getName();
        props = describe(instance);
        initialized = true;
    }
    
    /**
     * Copy constructor
     * @param otherBeanWrapper
     */
    public BeanWrapper(BeanWrapper<T> otherBeanWrapper){
        this.clazz = otherBeanWrapper.clazz;
        
        if(otherBeanWrapper.props != null){
            this.props = new HashMap<String, String>();
            this.props.putAll(otherBeanWrapper.props);            
        }
        
        this.initialized = otherBeanWrapper.initialized;
    }

    /**
     * Create a new instance of this bean.
     * If the props Map is set, use it to populate() the
     * instance.  
     * 
     * @param populate if true, populate the new instance with current contents of props
     * @throws PipelineException
     */
    @SuppressWarnings("unchecked")
    private T createInstance(boolean populate) throws PipelineException{
        try {
            T instance = (T) Class.forName(clazz).newInstance();
            if(populate){
                populate(instance);
            }
            
            return instance;
        } catch (Exception e) {
            throw new PipelineException("failed to instantiate instance with className=" + clazz + ", caught e = " + e, e );
        }
    }
    
    /**
     * Returns the instance of T, creating and initializing, if necessary.
     * 
     * Consider this object to be READ-ONLY.  Changes are only persisted when
     * calling populate() or setProperty()
     * 
     * @throws PipelineException 
     */
    public T getInstance() throws PipelineException{
        return createInstance(true);
    }

    /**
     * Populate the classname and map from the specified instance.
     *  
     * @param instance
     * @throws PipelineException
     */
    public void populateFromInstance(T instance) throws PipelineException{
        this.clazz = instance.getClass().getName();
        props = describe(instance);
    }

    /**
     * Returns true if new fields have been added to the class, but do not
     * exist in the database.  
     * 
     * @return
     */
    public boolean hasNewUnsavedFields(){
        T instance = getInstance();
        Map<String, String> newProps = describe(instance);
        
        Set<String> savedKeys = props.keySet();
        Set<String> currentKeys = newProps.keySet();
        
        // can't do this because Hibernate's proxy doesn't support it
        // boolean sameKeys = savedKeys.equals(currentKeys);
        
        boolean sameKeys = true;
        for (String currentKey : currentKeys) {
            if(!savedKeys.contains(currentKey)){
                sameKeys = false;
            }
        }
        
        if(!sameKeys){
            System.out.println("");
        }
        
        return(!sameKeys);
    }
    
    /**
     * Uses {@link BeanUtils} to populate the instance (the props Map is unaffected).  
     * 
     * @param properties
     * @throws PipelineException 
     */
    private void populate(T instance) throws PipelineException{
        if(props != null){
            try {
                /* props does not contain nulls, so before we call
                 * populate, we need to create a new Map (allProps) 
                 * with all of the properties returned by BeanUtilsBean2.describe,
                 * then override the values from props.  
                 * This also initializes new (unsaved) fields to the 
                 * default value specified in the class */
                
                Map<String, String> allProps = beanUtilsDescribe(instance);
                
                for (String key : allProps.keySet()) {
                    if(props.containsKey(key)){
                        allProps.put(key, props.get(key));
                    }
                }
                
                /* Using BeanUtilsBean2 instead of BeanUtils because BeanUtils does not
                 * handle arrays correctly (only sees the first element in the array) */
                BeanUtilsBean2 beanUtils = new BeanUtilsBean2();
                beanUtils.populate(instance, allProps);
                fixNulls(instance, allProps);
            } catch (Exception e) {
                throw new PipelineException("failed to populate bean, caught e = " + e, e );
            }
        }
    }

    /**
     * Override the behavior of BeanUtilsBean2 w.r.t. String[] and String fields with a null
     * or missing value in the Map.
     * 
     * For some reason, BeanUtilsBean2 sets String[] fields to an array with one null element instead
     * of an empty array when the value in the Map is null.  This method fixes that.  Strings are
     * initialized to the empty String "" 
     *  
     * @param allProps
     * @throws NoSuchFieldException 
     * @throws SecurityException 
     */
    private void fixNulls(T instance, Map<String, String> allProps) throws Exception{
        for (String key : allProps.keySet()) {
            String value = allProps.get(key);
            if(value == null){
                Class<? extends Object> instanceClass = instance.getClass();
                try {
                    Field f = instanceClass.getDeclaredField(key);
                    f.setAccessible(true);
                    Class<?> fieldClass = f.getType();
                    if(fieldClass.isArray() && ArrayUtils.EMPTY_STRING_ARRAY.getClass() == fieldClass){
                        f.set(instance, ArrayUtils.EMPTY_STRING_ARRAY);
                    }else if(fieldClass == String.class){
                        f.set(instance, "");
                    }
                } catch (NoSuchFieldException ignore) {
                    // ignore fields that no longer exist in the class
                }
            }
        }
    }
    
    /**
     * Uses {@link BeanUtils} to construct a Map containing all of the 
     * properties for T.  
     * 
     * Used by the PIG to populate a property editor
     * so the user can configure the properties.
     * 
     * Also removes the super-class properties that should not be visible to
     * the user (why doesn't BeanUtils offer this filtering capability?)
     * @param instance 
     * 
     * @return
     * @throws PipelineException
     */
    private Map<String, String> describe(T instance) throws PipelineException{
        try {
            Map<String, String> allProps = beanUtilsDescribe(instance); 
            clearNulls(allProps);
            
            return allProps;
        } catch (Exception e) {
            throw new PipelineException("failed to describe bean, caught e = " + e, e );
        }
    }
    
    /**
     * Uses {@link BeanUtilsBean2} to build a Map<String,String> of all
     * of the properties of the specified instance.
     * 
     * Note that this method returns an unaltered Map, so it may contain NULL
     * values.  Therefore, the member variable 'props' should NOT be set to this 
     * Map since Hibernate cannot correctly persist null Map values.
     *  
     * @param instance
     * @return
     * @throws PipelineException
     */
    private Map<String, String> beanUtilsDescribe(T instance) throws PipelineException{
        try {
            /* Using BeanUtilsBean2 instead of BeanUtils because BeanUtils does not
             * handle arrays correctly (only sees the first element in the array) */
            BeanUtilsBean2 beanUtils = new BeanUtilsBean2();
            @SuppressWarnings("unchecked")
            Map<String, String> allProps = beanUtils.describe(instance); 
            allProps.remove("class");
            
            return allProps;
        } catch (Exception e) {
            throw new PipelineException("failed to describe bean, caught e = " + e, e );
        }
    }
    
    /**
     * Remove map entries with null values.
     * 
     * Avoids issues where Hibernate does not correctly persist maps
     * where all the values are null.  It stores it ok, but 
     * when it's retrieved the map is empty, and when then saving it,
     * it fails to delete the old rows before inserting the new rows because
     * it thinks there are no rows in the db.
     * 
     * @param map
     */
    private void clearNulls(Map<String, String> map){
    	Set<String> badKeys = new HashSet<String>();
    	
    	for (String key : map.keySet()) {
			String value = map.get(key);
			if(value == null || value.length()==0){
				badKeys.add(key);
			}
		}
    	
    	for (String badKey : badKeys) {
			map.remove(badKey);
		}
    }
    
    public String getClassName(){
        return clazz;
    }
    
    public Class<?> getClazz() {
        try {
            return Class.forName(clazz);
        } catch (Exception e) {
            throw new PipelineException("failed to instantiate instance with className=" + clazz + ", caught e = " + e, e );
        }
    }

    public Map<String, String> getProps() {
        return props;
    }

    public void setClazz(Class<?> clazz) {
        this.clazz = clazz.getName();
        initialized = true;
    }

    public void setProps(Map<String, String> newProps) {
        clearNulls(newProps);
        this.props = newProps;
        initialized = true;
    }

    public boolean isInitialized() {
        if(initialized == null){
            return false;
        }else{
            return initialized;
        }
    }

    public void setInitialized(boolean set) {
        this.initialized = set;
    }
}
