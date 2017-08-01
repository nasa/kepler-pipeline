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

#ifndef _common_hpp_
#define _common_hpp_ 1

#include <memory>
#include <functional>

extern "C" {
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <jni.h>
}

namespace kepler{ namespace common {

typedef std::unique_ptr<char const[], std::function<void(char const*)>> jni_string_ptr;

/**
 * Generic exception base.   Allocated indicates that this exception
 * class should delete the associated string in the destructor.
 */
class KeplerException : public std::exception {
private:
    const bool allocated;
    const char* message;
public:
    KeplerException(const char* message_p) :
        allocated(false), message(message_p) {
    }
    
    KeplerException(char *message_p) : allocated(true) {
        message = strdup(message_p);
    }
    
    //Override from std::exception
    virtual const char* what() const noexcept {
        return message;
    }
    
    virtual ~KeplerException() noexcept {
        if (allocated) {
            delete message;
        }
    }
};

/**
 * manage file descriptor closing.
 */
class FileDescriptor {
private:
    int fd;
public:
    FileDescriptor(const char *pathname, int flags=(O_RDWR | O_CREAT), 
        mode_t mode=0600) {

        fd = open(pathname, flags, mode);
        if (fd < 0) {
            char* errBuf = new char[256];
            strerror_r(errno, errBuf, 255);
            throw KeplerException(errBuf);
        }
    }
    
    int operator*() const noexcept {
        return fd;
    }
    
    ~FileDescriptor() noexcept {
        close(fd);
    }
};


inline void deleteNativeString(JNIEnv* env,  jstring javaString,
     const char* nativeString) {
    if (env != 0 && nativeString != 0) {
        env->ReleaseStringUTFChars(javaString, nativeString);
    }
}



}} //end namesspace declarations

#endif //prevent multiple inclusion
