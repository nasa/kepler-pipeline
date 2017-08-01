#
# Copyright 2017 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# All Rights Reserved.
# 
# This file is available under the terms of the NASA Open Source Agreement
# (NOSA). You should have received a copy of this agreement with the
# Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
# 
# No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
# WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
# INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
# WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
# INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
# FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
# TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
# CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
# OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
# OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
# FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
# REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
# AND DISTRIBUTES IT "AS IS."
#
# Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
# AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
# SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
# THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
# EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
# PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
# SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
# STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
# PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
# REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
# TERMINATION OF THIS AGREEMENT.
#

MKDIR    := mkdir
RM       := rm -f

BUILDDIR := build
BINDIR   := $(BUILDDIR)/bin
LIBDIR   := $(BUILDDIR)/lib
GENDIR   := $(BUILDDIR)/generated
MGENDIR  := $(BUILDDIR)/generated/mfiles
MLINTDIR := $(BUILDDIR)/reports/mlint
DOCDIR   := $(BUILDDIR)/doc
DISTDIR  := $(SOC_CODE_MATLAB_REL_PATH)/../dist
MBINDISTDIR  := $(DISTDIR)/mbin
REPORTSDISTDIR  := $(DISTDIR)/reports

# system identification
UNAMES := $(shell uname -s | tr '[:lower:]' '[:upper:]' | cut -c-9)
PROC := $(shell uname -p)
ifeq ($(PROC),unknown)
PROC := $(shell uname -m)
endif
ifeq ($(PROC),i386)
PROC := i686
endif

ifeq ($(MATLAB_HOME),)
ifneq ($(MATLAB),) # on the NAS
    export MATLAB_HOME := $(strip $(MATLAB))
endif
else
    export MATLAB_HOME := $(strip $(MATLAB_HOME))
endif

# Force PROC to x86_64 on the Mac when MATLAB 2007a is not being used. 
# This is necessary because the Mac's uname -m always reports i386,
# even if it's 64-bit. This worked with MATLAB 2007a since it was
# 32-bit.
ifeq ($(UNAMES),DARWIN)
ifneq ($(MATLAB_HOME),)
ifneq ($(shell cat $(MATLAB_HOME)/.VERSION),R2007a)
    PROC = x86_64
endif
endif
endif

# MATLAB compiler settings

.SUFFIXES: .mexglx .mexa64 .mexmac .mexmaci .mexsol .mexmaci64

# From "mex -help":
#    solaris         - .mexsol
#    hpux            - .mexhpux
#    glnx86          - .mexglx
#    glnxa64         - .mexa64
#    Mac OS X        - .mexmac, .mexmaci, mexmaci64
ifeq ($(UNAMES),LINUX)
ifeq ($(PROC),x86_64)
MEXSUFFIX := mexa64
else
MEXSUFFIX := mexglx
endif # x86_64
else
ifeq ($(UNAMES),DARWIN)
ifeq ($(PROC),x86_64)
MEXSUFFIX := mexmaci64
export DYLD_LIBRARY_PATH := $(MATLAB_HOME)/bin/maci64:$(MATLAB_HOME)/sys/os/maci64:$(MATLAB_HOME)/Contents/MacOS:$(MATLAB_HOME)/extern/lib/maci64
else
MEXSUFFIX := mexmaci
export DYLD_LIBRARY_PATH := $(MATLAB_HOME)/bin/maci:$(MATLAB_HOME)/sys/os/maci:$(MATLAB_HOME)/bin/maci/MATLAB.app/Contents/MacOS:$(MATLAB_HOME)/extern/lib/maci
endif # x86_64
else
ifeq ($(UNAMES),SUNOS)
MEXSUFFIX := mexsol
else
MEXSUFFIX := unexpected
endif #SOLARIS
endif #DARWIN
endif #LINUX


MCC       = mcc
BUILDMCC  = $(BUILDDIR)/$(MCC)
MCCOUTDIR = $(BUILDMCC)

# old way (C++), putting mcc output in build/mcc
#
# UNCOMMENT this and comment out the line below to
# go back to the C++ way
#
#MCCOPTS   = -d $(BUILDMCC)

# new way (MATLAB only), putting mcc output in build/bin
#
# COMMENT this out and uncomment the line above to go
# back to the C++ way

MCCOPTS   = -N -d $(BINDIR) -R -singleCompThread -R -nodisplay -R -nodesktop \
	-p $(MATLAB_HOME)/toolbox/signal -p $(MATLAB_HOME)/toolbox/stats

MEX       = mex
BUILDMEX  = $(BUILDDIR)/$(MEX)
BUILDMEX2 = $(BUILDMEX)/%.$(MEXSUFFIX)

# See also mlintrpt for emitting HTML.
# -config=settings.txt to customize mlint
MLINT     = $(MATLAB_HOME)/bin/glnxa64/mlint

PUBLISH   = run_publish
DEPFUN    = run_depfun

# The name of the directory that contains the report in LaTeX format.
REPORT    = report

# C++ compiler settings (C++ compiler is invoked indirectly
# through the MATLAB mbuild script)

MBUILD = mbuild
INCLUDES = -Iinclude -I$(GENDIR) -I$(BUILDMCC) \
	-I$(SOC_CODE_MATLAB_REL_PATH)/mi-common/include
CCFLAGS = -O2
LDFLAGS = -L$(SOC_CODE_MATLAB_REL_PATH)/mi-common/$(LIBDIR) -lmicommon

SHLIB = lib$(NAME).so
LIB = $(SHLIB)
BIN = $(NAME)
CTF = $(NAME).ctf

# The run_BIN.sh script is generated by mcc. It is not used by the
# pipeline code, but is useful for manual troubleshooting, so we
# copy it to MBINDISTDIR
RUNSH = run_$(NAME).sh

BUILDBIN = $(addprefix $(BINDIR)/,$(BIN))
BUILDLIB = $(addprefix $(BUILDMCC)/,$(LIB))
BUILDCTF = $(addprefix $(BINDIR)/,$(CTF))
BUILDRUNSH = $(addprefix $(BINDIR)/,$(RUNSH))
BUILDAPP = $(addprefix $(BINDIR)/,$(NAME).app)

# Unit tests

MTESTDIR = test
MTESTDRIVER = $(NAME)_run_all_tests_txt

