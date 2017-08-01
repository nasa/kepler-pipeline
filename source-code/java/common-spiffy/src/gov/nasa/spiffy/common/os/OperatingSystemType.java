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

package gov.nasa.spiffy.common.os;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This type is a container for operating system specific information and can be
 * used for portability across operating systems.
 * 
 * @author Forrest Girouard
 * 
 */
public enum OperatingSystemType {
    DEFAULT("Linux",
        "LD_LIBRARY_PATH",
        LinuxMemInfo.class,
        LinuxCpuInfo.class,
        LinuxProcInfo.class), LINUX("Linux",
        "LD_LIBRARY_PATH",
        LinuxMemInfo.class,
        LinuxCpuInfo.class,
        LinuxProcInfo.class), MAC_OS_X("Darwin",
        "DYLD_LIBRARY_PATH",
        MacOSXMemInfo.class,
        MacOSXCpuInfo.class,
        MacOSXProcInfo.class);

    public static final String OPERATING_SYSTEM_PROPERTY_NAME = "os.name";
    public static final String ARCH_DATA_MODEL_PROPERTY_NAME = "sun.arch.data.model";
    private static final Log log = LogFactory.getLog(OperatingSystemType.class);

    private final String name;
    private final String archDataModel;
    private final String sharedObjectPathEnvVar;
    private final Class<? extends MemInfo> memInfoClass;
    private final Class<? extends CpuInfo> cpuInfoClass;
    private final Class<? extends ProcInfo> procInfoClass;

    private OperatingSystemType(String name, String sharedObjectPathEnvVar,
        Class<? extends MemInfo> memInfoClass,
        Class<? extends CpuInfo> cpuInfoClass,
        Class<? extends ProcInfo> procInfoClass) {
        this.name = name;
        this.archDataModel = System.getProperty(ARCH_DATA_MODEL_PROPERTY_NAME);
        this.sharedObjectPathEnvVar = sharedObjectPathEnvVar;
        this.memInfoClass = memInfoClass;
        this.cpuInfoClass = cpuInfoClass;
        this.procInfoClass = procInfoClass;
    }

    public String getName() {
        return name;
    }

    public String getArchDataModel() {
        return archDataModel;
    }

    public String getSharedObjectPathEnvVar() {
        return sharedObjectPathEnvVar;
    }

    public CpuInfo getCpuInfo() throws Exception {
        return cpuInfoClass.newInstance();
    }

    public MemInfo getMemInfo() throws Exception {
        return memInfoClass.newInstance();
    }

    public ProcInfo getProcInfo(int pid) throws Exception {
        Class<?>[] procInfoArgs = new Class[] { int.class };
        return procInfoClass.getConstructor(procInfoArgs)
            .newInstance(pid);
    }

    public ProcInfo getProcInfo() throws Exception {
        return procInfoClass.newInstance();
    }

    public static final OperatingSystemType byName(String name) {
        if (name == null) {
            throw new IllegalArgumentException("name cannot be null.");
        }

        for (OperatingSystemType type : OperatingSystemType.values()) {
            if (type != OperatingSystemType.DEFAULT && type.getName()
                .equalsIgnoreCase(name.trim()
                    .replace(' ', '_'))) {
                return type;
            }
        }

        log.warn(name + ": unrecognized operating system, using default type");
        return OperatingSystemType.DEFAULT;
    }

    public static final OperatingSystemType byType(String name) {
        if (name == null) {
            throw new IllegalArgumentException("name cannot be null.");
        }

        for (OperatingSystemType type : OperatingSystemType.values()) {
            if (type.toString()
                .equalsIgnoreCase(name.trim()
                    .replace(' ', '_'))) {
                return type;
            }
        }

        log.warn(name + ": unrecognized operating system, using default type");
        return OperatingSystemType.DEFAULT;
    }

    public static final OperatingSystemType getInstance() {
        return OperatingSystemType.byType(System.getProperty(OPERATING_SYSTEM_PROPERTY_NAME));
    }
}