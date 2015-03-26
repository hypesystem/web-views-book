.DEFAULT: build.html

build.html: src/*/*
	ruby -rredcarpet bookbuilder.rb > build.html
