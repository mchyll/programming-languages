# % matches anything, $< refers to the name of the first prerequisite, 
# and $@ refers to the file name of the target of the rule

.PHONY: clean all
.PRECIOUS: %.ozf

all: assignment2

%: %.ozf
	ozengine $<

%.ozf: %.oz
	ozc -c $<

clean:
	rm *.ozf
