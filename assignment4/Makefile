# % matches anything, $< refers to the name of the first prerequisite, 
# and $@ refers to the file name of the target of the rule

.PHONY: run clean
.PRECIOUS: %.ozf

FILE = assignment4

run: $(FILE).ozf
	ozengine $(FILE).ozf

%.ozf: %.oz
	ozc -c $<

clean:
	rm *.ozf
