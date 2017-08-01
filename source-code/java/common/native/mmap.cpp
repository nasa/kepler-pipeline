/**
 *  An alternative implementation of memory mapped file I/O.
 *  
 *  Copyright 2017 United States Government as represented by the
 *  Administrator of the National Aeronautics and Space Administration.
 *  All Rights Reserved.
 *  
 *  This file is available under the terms of the NASA Open Source Agreement
 *  (NOSA). You should have received a copy of this agreement with the
 *  Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 *  
 *  No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 *  WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 *  INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 *  WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 *  INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 *  FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 *  TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 *  CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 *  OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 *  OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 *  FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 *  REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 *  AND DISTRIBUTES IT "AS IS."
 *
 *  Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 *  AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 *  SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 *  THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 *  EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 *  PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 *  SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 *  STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 *  PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 *  REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 *  TERMINATION OF THIS AGREEMENT.
 */
#include <iostream>
#include <fstream>
#include <algorithm>
#include <memory>
#include <functional>

#include <boost/timer/timer.hpp>
#include <boost/cstdint.hpp>
#include <boost/interprocess/file_mapping.hpp>
#include <boost/interprocess/mapped_region.hpp>


extern "C" {
#include <jni.h>
}

using namespace std;
using namespace boost::interprocess;
using namespace kepler::common;

/**
 *  This C++ function is a Java static method to initialize the
 *  memory map.  This will map the entire file.  This will return
 *  an object of type gov.nasa.kepler.common.file.Mmap.NativeInfo or
 *  throw an IOException.  The information stored in the NativeInfo
 *  are the pointers to the C++ objects needed to do the unmap as
 *  well as the native memory address of the memory map which is need
 *  on all subsequent calls to read/write.
 */
extern "C" 
JNIEXPORT jobject JNICALL Java_gov_nasa_kepler_common_file_Mmap_map(JNIEnv *env, jstring absolutePath_java) {

    const char *absolutePath = 
        env->GetStringUTFChars(absolutePath_java, 0);
    //TODO:  deallocate string
    if (absolutePath == 0) {
        //OOM
        return 0;
    }

    jclass mmapNativeInfoClass = 
        env->FindClass("gov/nasa/kepler/file/Mmap/NativeInfo");
    if (mmapNativeInfoClass == 0) {
        //Exception already set.
        return 0;
    }
    
    jMethodId nativeInfoConstructor = 
        env->GetMethodID(mmapInternalsClass, "<init>", "(JJJ)V");
    if (nativeInfoConstructor == 0) {
        return 0;
    }

    unique_ptr<file_mapping> m_file;
    unique_ptr<mapped_region> region = 0;
    jobject nativeInfo = 0;
    try {
        m_file.reset(new file_mapping(absolutePath, read_write));

        // See http://www.boost.org/doc/libs/1_53_0/doc/html/boost/interprocess/mapped_region.html
        region.reset(
            new mapped_region(*m_file,read_write));
        
        int8_t * mmapAddress = (int8_t*) region->get_address();
        //size_t actualMapSize  = region->get_size();
        nativeInfo = 
            env->NewObject(mmapNativeInfoClass,
                nativeInfoConstructor, mmapAddress,
                 fileMapping.get(), mappedRegion.get());
        if (internals == 0) {
            return 0;
        }
    } catch (const exception& ex) {
        jclass ioExceptionClass = 
            env->FindClass("java/io/IOException");
        env->ThrowNew(ioExceptionClass, ex.what());
        return 0;
    }

    //Everyting worked out so don't delete our memory map when this
    //scope is exited.
    m_file.release();
    region.release();
    return nativeInfo;
}

/**
 *  Static Java method for writing to a memory map.
 */
extern "C" 
JNIEXPORT void JNICALL Java_gov_nasa_kepler_common_file_Mmap_write(JNIEnv *env, jlong mmapAddressLong, jlong mmapOffset,
     jByteArray buf, jint bufOffset, jint size) {
     
    int32_t bufLength = env->GetArrayLength(buf);
    if ((bufOffset + size) > bufLength || bufOffset < 0) {
        jclass ioExceptionClass = 
            env->FindClass("java/io/IOException");
        env->ThrowNew(ioExceptionClass, "Attempt to read past buffer.");
        return;
    }
    
    boolean isCopy = false;
    int8_t* nativeBytes = env->GetByteArrayElements(buf, &isCopy);
    if (nativeBytes == 0) {
        jclass oomClass = env->FindClass("java/lang/OutOfMemoryError");
        env->ThrowNew(oomClass);
    }
    
    //TODO: how will I know if writing to disk has failed?
    //TODO:  check write off of end of mmap
    int8_t* mmapAddress = (int8_t*) mmapAddressLong;
    memcpy(mmapAddress+mmapOffset, nativeBytes+bufOffset, size);
    
    //TODO: wrap this in raii
    env->ReleaseByteArrayElements(buf, nativeBytes, JNI_ABORT);
    
}

read();

write();

flush();

unmap();
