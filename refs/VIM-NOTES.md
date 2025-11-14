vim-notes

how to easily take notes on vim
define folder structure
	wip
	summary
	archive
navigate to urls with `gx`
navigate to file paths with `gf`

create/open a wip file:
	$ wip
	> wip/202511-wip.md

create a wip for a new task:
	$ wip-new task-name
	> wip/202511-task-name.md

list all wips:
	$ wip-list
	> wip/202511-wip.md
	> wip/202511-task-name.md

create/open summary file:
	$ summary
	> summary/202511-summary.md

when you are done with a task / new month:
	move wips to archive
		> wip/202511-wip.md
		> archive/202511-archive.md
	update references `wip` to `archive`
