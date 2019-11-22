node_version = v12.13.0
tool_names = baiReadDepther bamstatsAlive craiReadDepther samtools samtools_od bgzip tabix tabix_od vcfReadDepther coverage geneCoverage bcftools vt vep clinphen freebayes knownVariants_2
tools = $(patsubst %, tool_bin/%, $(tool_names))

# This forces the use of the local node. This is necessary because sqlite3 (and
# possibly other dependencies appears to be using the node in $PATH, even when
# calling
# `node/bin/node node/bin/npm install`
# directly. This lead to a version mismatch.
export PATH := ./node/bin:./tools:$(PATH)

run: local_install
	node src/index.js

deploy_aws: local_install
	./deploy_aws.sh

local_install: node npm node_modules tool_bin $(tools) static

npm: node

node:
	wget https://nodejs.org/dist/$(node_version)/node-$(node_version)-linux-x64.tar.xz
	tar xf node-$(node_version)-linux-x64.tar.xz
	rm node-$(node_version)-linux-x64.tar.xz
	mv node-$(node_version)-linux-x64 node

tool_bin:
	mkdir tool_bin

tool_bin/%:
	tools/download_tool.sh $*

static:
	./populate_static.sh

node_modules:
	npm install

.PHONY: clean
clean:
	rm -rf node
	rm -rf node_modules
	rm -rf tool_bin
	rm -rf static 
