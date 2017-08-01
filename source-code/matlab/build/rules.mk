#
# Copyright 2017 United States Government as represented by the
# Administrator of the National Aeronautics and Space Administration.
# All Rights Reserved.
# 
# NASA acknowledges the SETI Institute's primary role in authoring and
# producing the Kepler Data Processing Pipeline under Cooperative
# Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
# NNX11AI14A, NNX13AD01A & NNX13AD16A.
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
.PHONY: clean clean-matlab dist test mlint

all ::
ifeq ($(strip $(MATLAB_HOME)),)
	@echo "ERROR: MATLAB_HOME is undefined" >&2 ;
	@exit 2
endif

all :: $(BUILDBIN)

OBJ = $(CSRC:.cpp=.o)

# Note that mex will compile all of $MEXSRC into a single file whose
# stem comes from the first file in $MEXSRC.
MEXFILES := $(MEXSRC:.c=.$(MEXSUFFIX))
MEXFILES := $(MEXFILES:.cc=.$(MEXSUFFIX))
MEXFILES := $(patsubst $(MEX)/%,$(BUILDMEX)/%,$(MEXFILES))

$(BUILDMEX)/%.$(MEXSUFFIX) : $(MEX)/%.c
	-$(MKDIR) -p $(dir $@)
	$(MEX) -outdir $(dir $@) $(MEXFLAGS) $< $(MEXEXTRA)

$(BUILDMEX)/%.$(MEXSUFFIX) : $(MEX)/%.cc
	-$(MKDIR) -p $(dir $@)
	$(MEX) -outdir $(dir $@) $(MEXFLAGS) $< $(MEXEXTRA)

# This is the old way of doing things, where the MATLAB
# code was compiled into a shared lib (with mcc) and the C++
# code was linked against it (using mbuild) to create the executable
#
# UNCOMMENT the following and comment-out the new rule below to
# go back to the old way (you'll also need to change MCCOPTS in macros.mk).
#
#$(BUILDLIB) : $(MEXFILES) $(MSRC)
#	-$(MKDIR) -p $(dir $@)
#	$(MCC) $(MCCOPTS) $(addprefix -a ,$(MEXFILES)) \
#		-W cpplib:$(basename $(notdir $@)) -T link:lib $(MSRC)
#
#$(BUILDBIN) : $(BUILDLIB) $(CSRC)
#	-$(MKDIR) -p $(dir $@)
#	$(MBUILD) $(CSRC) $(addprefix -L,$(dir $(BUILDLIB))) \
#		$(patsubst lib%.so,-l%,$(notdir $(BUILDLIB))) \
#		$(INCLUDES) $(CCFLAGS) $(LDFLAGS) -output $@



# This is the new way of doing things, where just the MATLAB
# code is compiled into a stand-alone executable (with mcc)
#
# COMMENT this out and uncomment the rules above to go back to the
# old C++ way (you'll also need to change MCCOPTS in macros.mk).

$(BUILDBIN) : $(MEXFILES) $(MSRC)
	-$(MKDIR) -p $(dir $@)
	$(MCC) $(MCCOPTS) \
		$(addprefix -a ,$(MEXFILES)) \
		$(addprefix -a ,$(MCCARCHIVEFILES)) \
		-m -d $(BINDIR) -o $(NAME) $(MGENDIR)/$(NAME)_init.m \
		$(MGENDIR)/$(NAME)_main.m $(MSRC)

test ::
	cd $(MTESTDIR); \
	matlab -nodisplay -r "$(MTESTDRIVER);quit" -logfile $@.log ; \
	if [ -e tests_failed.txt ]; then \
	    touch /tmp/matlab-test.failed; \
	fi

mlint ::
	-$(MKDIR) -p $(MLINTDIR)
	$(MLINT) `find mfiles -name \*.m` > $(MLINTDIR)/mlint.txt 2>&1

doc ::
	-$(MKDIR) -p $(DOCDIR)
	matlab -r "$(PUBLISH) ./publish-list $(DOCDIR); quit" -nodisplay
	matlab -r "$(DEPFUN) ./depfun-list $(DOCDIR); quit" -nodisplay
	-for i in `find $(DOCDIR) -name \*.dot`; do \
            (cd `dirname $$i`; sfdp -Tpdf -o`basename $$i .dot`.pdf `basename $$i`) \
        done

build-nomcc :: $(MEXFILES) install-reports

dist :: clean-matlab all install-reports
	-$(MKDIR) -p $(MBINDISTDIR)
	rm -rf $(MBINDISTDIR)/$(NAME)_mcr
	if [ -s $(BUILDBIN) ]; then cp $(BUILDBIN) $(MBINDISTDIR); fi
	if [ -s $(BUILDCTF) ]; then cp $(BUILDCTF) $(MBINDISTDIR); fi
	if [ -s $(BUILDRUNSH) ]; then cp $(BUILDRUNSH) $(MBINDISTDIR); fi
	if [ -d $(BUILDAPP) ]; then \
	    rm -rf $(MBINDISTDIR)/$(NAME).app $(MBINDISTDIR)/$(NAME); \
	    cp -R $(BUILDAPP) $(MBINDISTDIR); \
	    ( cd $(MBINDISTDIR); \
	      ln -s $(NAME).app/Contents/MacOS/$(NAME) .; ) \
	fi

install-reports ::
	if [ -d $(REPORT) ]; then \
            $(MKDIR) -p $(REPORTSDISTDIR)/$(NAME); \
            $(RM) $(REPORTSDISTDIR)/$(NAME)/*; \
            cp $(REPORT)/* $(REPORTSDISTDIR)/$(NAME); \
        fi

clean :: clean-matlab
	$(RM) -r $(BUILDDIR)

clean-matlab ::
	$(RM) $(OBJ)
	$(RM) -r $(BINDIR) $(MCCOUTDIR) $(BUILDMEX)

