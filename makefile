DATE := $(shell date -I)
DRAFTS := blog/_drafts
POSTS := blog/_posts

run:
	bundle exec jekyll serve --drafts

%.md: $(POSTS)/$(DATE)-%.md
	
.PHONY: %.md run

$(POSTS)/$(DATE)-%.md: $(DRAFTS)/%.md
	cat $< | sed "s/^date: .*$$/date: $(DATE)/g" > $@

.NOTINTERMEDIATE: $(POSTS)/$(DATE)-%.md
