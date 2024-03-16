# Changelog

## [5.8.0](https://github.com/linrongbin16/fzfx.nvim/compare/v5.7.3...v5.8.0) (2024-03-16)


### Features

* **preview:** add lineno for buffer preview ([#640](https://github.com/linrongbin16/fzfx.nvim/issues/640)) ([24fee5e](https://github.com/linrongbin16/fzfx.nvim/commit/24fee5e3ec82276354ab5aa16d93e574d41b9709))


### Performance Improvements

* **previewer:** reduce buffer previewer latency ([#642](https://github.com/linrongbin16/fzfx.nvim/issues/642)) ([5fa88e0](https://github.com/linrongbin16/fzfx.nvim/commit/5fa88e0c3b90740ce942aa606012a21565f92158))

## [5.7.3](https://github.com/linrongbin16/fzfx.nvim/compare/v5.7.2...v5.7.3) (2024-03-13)


### Bug Fixes

* **popup:** fix popup window auto-resize ([#635](https://github.com/linrongbin16/fzfx.nvim/issues/635)) ([1fa1881](https://github.com/linrongbin16/fzfx.nvim/commit/1fa188146727cb7b7849dd15510658cfd8b658f6))

## [5.7.2](https://github.com/linrongbin16/fzfx.nvim/compare/v5.7.1...v5.7.2) (2024-03-08)


### Bug Fixes

* **marks:** only show filename when file exists ([#632](https://github.com/linrongbin16/fzfx.nvim/issues/632)) ([7ccb1b2](https://github.com/linrongbin16/fzfx.nvim/commit/7ccb1b27bb6fd996b731915ab268492cd66541d2))

## [5.7.1](https://github.com/linrongbin16/fzfx.nvim/compare/v5.7.0...v5.7.1) (2024-03-08)


### Bug Fixes

* **popup:** fix height calculation on up/down direction ([#630](https://github.com/linrongbin16/fzfx.nvim/issues/630)) ([9a9f175](https://github.com/linrongbin16/fzfx.nvim/commit/9a9f175d463a5a4a50c24b0c7f23e18dbef25060))

## [5.7.0](https://github.com/linrongbin16/fzfx.nvim/compare/v5.6.1...v5.7.0) (2024-03-08)


### Features

* **marks:** add 'FzfxMarks' ([#627](https://github.com/linrongbin16/fzfx.nvim/issues/627)) ([8cb8fe2](https://github.com/linrongbin16/fzfx.nvim/commit/8cb8fe2feed538856b0826ddc2477bc3b0a9adf0))

## [5.6.1](https://github.com/linrongbin16/fzfx.nvim/compare/v5.6.0...v5.6.1) (2024-03-04)


### Performance Improvements

* **preview:** set longer delay for buffer previewer ([#625](https://github.com/linrongbin16/fzfx.nvim/issues/625)) ([ce21696](https://github.com/linrongbin16/fzfx.nvim/commit/ce21696986478173ae52930769ebdb1ac9a9f8a0))

## [5.6.0](https://github.com/linrongbin16/fzfx.nvim/compare/v5.5.1...v5.6.0) (2024-03-01)


### Features

* **buf_live_grep:** add 'FzfxBufLiveGrep' ([#622](https://github.com/linrongbin16/fzfx.nvim/issues/622)) ([b7ec64b](https://github.com/linrongbin16/fzfx.nvim/commit/b7ec64b1d9b95d6e4d8dd1aac6ea0e8952f9b001))

## [5.5.1](https://github.com/linrongbin16/fzfx.nvim/compare/v5.5.0...v5.5.1) (2024-02-26)


### Performance Improvements

* **previewer:** longer intervals when rendering buffer previewer ([#617](https://github.com/linrongbin16/fzfx.nvim/issues/617)) ([59e4578](https://github.com/linrongbin16/fzfx.nvim/commit/59e45789175f5ffe91ce23d042dc0b1ac9bb01da))

## [5.5.0](https://github.com/linrongbin16/fzfx.nvim/compare/v5.4.2...v5.5.0) (2024-02-26)


### Features

* **colors:** support RGB color codes in 'fzf_color_opts' ([#614](https://github.com/linrongbin16/fzfx.nvim/issues/614)) ([f1bfc89](https://github.com/linrongbin16/fzfx.nvim/commit/f1bfc895e816ed6a638215e670de9899ef40e4c2))


### Bug Fixes

* **fzf_opts:** add 'top'/'bottom' options ([#612](https://github.com/linrongbin16/fzfx.nvim/issues/612)) ([a4272cd](https://github.com/linrongbin16/fzfx.nvim/commit/a4272cd38cf7026466c250f5071bc468b289a599))
* **popup:** fix winopts calculation ([#609](https://github.com/linrongbin16/fzfx.nvim/issues/609)) ([5b4a003](https://github.com/linrongbin16/fzfx.nvim/commit/5b4a003707ff75ddd063cd43dfa7d573c21639cc))

## [5.4.2](https://github.com/linrongbin16/fzfx.nvim/compare/v5.4.1...v5.4.2) (2024-02-14)


### Bug Fixes

* **previewer:** cache fzf port & fix "Too many opened files" issue ([#604](https://github.com/linrongbin16/fzfx.nvim/issues/604)) ([13ff739](https://github.com/linrongbin16/fzfx.nvim/commit/13ff7391bf839772a464c141267ac5b0509d1b23))
* **previewer:** fix bad colorscheme name in bat theme ([#606](https://github.com/linrongbin16/fzfx.nvim/issues/606)) ([1e187c8](https://github.com/linrongbin16/fzfx.nvim/commit/1e187c8cfe31948cb14346cc0195f5e225e98584))

## [5.4.1](https://github.com/linrongbin16/fzfx.nvim/compare/v5.4.0...v5.4.1) (2024-02-09)


### Bug Fixes

* **buffers:** fix 'ctrl-d' interactions in Windows ([#600](https://github.com/linrongbin16/fzfx.nvim/issues/600)) ([dc33749](https://github.com/linrongbin16/fzfx.nvim/commit/dc33749b8cd2ee6c5f69dc59722ff80b43baa3e7))


### Performance Improvements

* **previewer:** reduce buffer previewer latency ([#598](https://github.com/linrongbin16/fzfx.nvim/issues/598)) ([603d0a5](https://github.com/linrongbin16/fzfx.nvim/commit/603d0a5daed443bbd4dba1190d7523c7b71145aa))

## [5.4.0](https://github.com/linrongbin16/fzfx.nvim/compare/v5.3.0...v5.4.0) (2024-02-08)


### Features

* **previewer:** enable buffer previewer on buffers ([#594](https://github.com/linrongbin16/fzfx.nvim/issues/594)) ([d2c0ea8](https://github.com/linrongbin16/fzfx.nvim/commit/d2c0ea8eaf9101ba8045b1368e142063b5821354))


### Bug Fixes

* **buffer previewer:** fix filetype highlighting ([#594](https://github.com/linrongbin16/fzfx.nvim/issues/594)) ([d2c0ea8](https://github.com/linrongbin16/fzfx.nvim/commit/d2c0ea8eaf9101ba8045b1368e142063b5821354))

## [5.3.0](https://github.com/linrongbin16/fzfx.nvim/compare/v5.2.0...v5.3.0) (2024-02-07)


### Features

* **config:** enable buffer previewer for git files ([#592](https://github.com/linrongbin16/fzfx.nvim/issues/592)) ([8199023](https://github.com/linrongbin16/fzfx.nvim/commit/8199023dad7e64bba82f98abe8de37cfa0ad2422))

## [5.2.0](https://github.com/linrongbin16/fzfx.nvim/compare/v5.1.6...v5.2.0) (2024-02-07)


### Features

* **previewer:** enable buffer previewer for files ([#591](https://github.com/linrongbin16/fzfx.nvim/issues/591)) ([8b05e76](https://github.com/linrongbin16/fzfx.nvim/commit/8b05e7625f4e6c9cf6dbf6448bd943c93b765601))


### Performance Improvements

* **buffer previewer:** improve buffer previewer performance ([#589](https://github.com/linrongbin16/fzfx.nvim/issues/589)) ([817a9a6](https://github.com/linrongbin16/fzfx.nvim/commit/817a9a6083af0103b1f86058ba3bafc912e4a988))

## [5.1.6](https://github.com/linrongbin16/fzfx.nvim/compare/v5.1.5...v5.1.6) (2024-02-05)


### Performance Improvements

* **buffer previewer:** improve performance ([#584](https://github.com/linrongbin16/fzfx.nvim/issues/584)) ([b7c580f](https://github.com/linrongbin16/fzfx.nvim/commit/b7c580f3f6f359433f101c6c3759a96d91d11541))
* **buffer previewer:** set longer delay for buffer file previewer ([#587](https://github.com/linrongbin16/fzfx.nvim/issues/587)) ([3d69db6](https://github.com/linrongbin16/fzfx.nvim/commit/3d69db6856f04d1f3825036148baed9a66f6452d))
* **lsp locations:** dedup lsp references results ([#587](https://github.com/linrongbin16/fzfx.nvim/issues/587)) ([3d69db6](https://github.com/linrongbin16/fzfx.nvim/commit/3d69db6856f04d1f3825036148baed9a66f6452d))

## [5.1.5](https://github.com/linrongbin16/fzfx.nvim/compare/v5.1.4...v5.1.5) (2024-02-04)


### Bug Fixes

* **spawn:** on complete for previewer label ([#582](https://github.com/linrongbin16/fzfx.nvim/issues/582)) ([9da7df6](https://github.com/linrongbin16/fzfx.nvim/commit/9da7df6b3e605d88ef3ac4e67a7f6ff0db06f86e))

## [5.1.4](https://github.com/linrongbin16/fzfx.nvim/compare/v5.1.3...v5.1.4) (2024-02-02)


### Performance Improvements

* **previewer:** improve bat themes generate3 ([#579](https://github.com/linrongbin16/fzfx.nvim/issues/579)) ([a482d0e](https://github.com/linrongbin16/fzfx.nvim/commit/a482d0e726fd41904625299af062cec67f1ff8e9))

## [5.1.3](https://github.com/linrongbin16/fzfx.nvim/compare/v5.1.2...v5.1.3) (2024-02-02)


### Bug Fixes

* **previewer:** fix bat theme helper ([#576](https://github.com/linrongbin16/fzfx.nvim/issues/576)) ([28d38ac](https://github.com/linrongbin16/fzfx.nvim/commit/28d38ac613b5c1b16e911371970aca288a9415e6))

## [5.1.2](https://github.com/linrongbin16/fzfx.nvim/compare/v5.1.1...v5.1.2) (2024-02-01)


### Performance Improvements

* **previewer:** improve bat themes generation ([#570](https://github.com/linrongbin16/fzfx.nvim/issues/570)) ([a4f0582](https://github.com/linrongbin16/fzfx.nvim/commit/a4f0582caf2444c1069a4d1485758113bb517049))

## [5.1.1](https://github.com/linrongbin16/fzfx.nvim/compare/v5.1.0...v5.1.1) (2024-01-31)


### Bug Fixes

* **colors:** fix static fzf color & icon opts ([#567](https://github.com/linrongbin16/fzfx.nvim/issues/567)) ([9a62620](https://github.com/linrongbin16/fzfx.nvim/commit/9a62620032e623fa2bc044886ac4893277eb9fa4))

## [5.1.0](https://github.com/linrongbin16/fzfx.nvim/compare/v5.0.4...v5.1.0) (2024-01-31)


### Features

* **buffer previewer:** add 'toggle-preview' key bindings ([#562](https://github.com/linrongbin16/fzfx.nvim/issues/562)) ([09cc257](https://github.com/linrongbin16/fzfx.nvim/commit/09cc2574bb77fd9b5bbf9d680f048171a2102478))
* **previewer:** add [@lsp](https://github.com/lsp).type support to bat theme generation ([#564](https://github.com/linrongbin16/fzfx.nvim/issues/564)) ([5c7b13c](https://github.com/linrongbin16/fzfx.nvim/commit/5c7b13cb2b4557fa41d418bbff0870d6c8bcc48d))
* **previewer:** add buffer preview key bindings for fzf action ([#559](https://github.com/linrongbin16/fzfx.nvim/issues/559)) ([e5df3c5](https://github.com/linrongbin16/fzfx.nvim/commit/e5df3c5b4554ebdbff4cd9507930565e551c2f27))
* **previewer:** add experimental nvim buffer previewer ([#556](https://github.com/linrongbin16/fzfx.nvim/issues/556)) ([8ffb7b3](https://github.com/linrongbin16/fzfx.nvim/commit/8ffb7b3edec0de26b81f68c2d4d70ed2cd3fbf84))
* **previewer:** translate nvim highlights into bat theme ([#557](https://github.com/linrongbin16/fzfx.nvim/issues/557)) ([36e4c29](https://github.com/linrongbin16/fzfx.nvim/commit/36e4c298ad82f2e20d3781b125fd31b5a33104e6))


### Bug Fixes

* **buffer previewer:** reset to first line when previewing a file ([#561](https://github.com/linrongbin16/fzfx.nvim/issues/561)) ([8136ad1](https://github.com/linrongbin16/fzfx.nvim/commit/8136ad1ea7f961f3cd2292f222ebd649a6d4236c))
* **previewer:** fix bat theme auto-generation ([#564](https://github.com/linrongbin16/fzfx.nvim/issues/564)) ([5c7b13c](https://github.com/linrongbin16/fzfx.nvim/commit/5c7b13cb2b4557fa41d418bbff0870d6c8bcc48d))

## [5.0.4](https://github.com/linrongbin16/fzfx.nvim/compare/v5.0.3...v5.0.4) (2024-01-05)


### Bug Fixes

* **file explorer:** record cannot go upper (ctrl-h) issue in empty dir ([#551](https://github.com/linrongbin16/fzfx.nvim/issues/551)) ([918bd78](https://github.com/linrongbin16/fzfx.nvim/commit/918bd7816e0e7693d337f968b2df92fde9cf0b96))

## [5.0.3](https://github.com/linrongbin16/fzfx.nvim/compare/v5.0.2...v5.0.3) (2024-01-05)


### Bug Fixes

* **icons:** fix fzf pointer/marker icons disable ([#552](https://github.com/linrongbin16/fzfx.nvim/issues/552)) ([65acce9](https://github.com/linrongbin16/fzfx.nvim/commit/65acce96d23f06896915ca89f9b7de668bbd9f88))

## [5.0.2](https://github.com/linrongbin16/fzfx.nvim/compare/v5.0.1...v5.0.2) (2024-01-04)


### Performance Improvements

* **feed:** use isolated memory space for resume across different nvim instances ([#549](https://github.com/linrongbin16/fzfx.nvim/issues/549)) ([5c29cc4](https://github.com/linrongbin16/fzfx.nvim/commit/5c29cc404f5a2096543f7941efc2c54ef87efc1b))

## [5.0.1](https://github.com/linrongbin16/fzfx.nvim/compare/v5.0.0...v5.0.1) (2024-01-04)


### Bug Fixes

* **log:** fix logging initialize ([#543](https://github.com/linrongbin16/fzfx.nvim/issues/543)) ([f1ff933](https://github.com/linrongbin16/fzfx.nvim/commit/f1ff9339d2d95b40ebb9a0bccaf48906ef5cd9eb))


### Performance Improvements

* **install:** drop off 'junegunn/fzf' dependecy ([#545](https://github.com/linrongbin16/fzfx.nvim/issues/545)) ([a80282e](https://github.com/linrongbin16/fzfx.nvim/commit/a80282ed04074a94e42d7d522f058a80948217b3))

## [5.0.0](https://github.com/linrongbin16/fzfx.nvim/compare/v4.1.5...v5.0.0) (2024-01-04)


### ⚠ BREAKING CHANGES

* **sub commands:** merge variants into sub commands ([#534](https://github.com/linrongbin16/fzfx.nvim/issues/534))

### Performance Improvements

* **sub commands:** merge variants into sub commands ([#534](https://github.com/linrongbin16/fzfx.nvim/issues/534)) ([20368d8](https://github.com/linrongbin16/fzfx.nvim/commit/20368d8c23a22c0dce9c398d4ab346a4f5e66c2a))

## [4.1.5](https://github.com/linrongbin16/fzfx.nvim/compare/v4.1.4...v4.1.5) (2023-12-31)


### Bug Fixes

* **buffers:** revert unload buffers change ([#536](https://github.com/linrongbin16/fzfx.nvim/issues/536)) ([86e9253](https://github.com/linrongbin16/fzfx.nvim/commit/86e9253c399ef93d28b2321079e571cc1c1e8f4a))

## [4.1.4](https://github.com/linrongbin16/fzfx.nvim/compare/v4.1.3...v4.1.4) (2023-12-29)


### Performance Improvements

* **actions:** delayed execute actions on fzf quit ([#530](https://github.com/linrongbin16/fzfx.nvim/issues/530)) ([3d40c3a](https://github.com/linrongbin16/fzfx.nvim/commit/3d40c3a0d3cdc669edf0ef11f2efcba597eb76ca))

## [4.1.3](https://github.com/linrongbin16/fzfx.nvim/compare/v4.1.2...v4.1.3) (2023-12-27)


### Bug Fixes

* **buffers:** Don't try to show unloaded buffers ([#526](https://github.com/linrongbin16/fzfx.nvim/issues/526)) ([7cf5de9](https://github.com/linrongbin16/fzfx.nvim/commit/7cf5de98c5396cb1f613488f0b36a9ab56510eaa))

## [4.1.2](https://github.com/linrongbin16/fzfx.nvim/compare/v4.1.1...v4.1.2) (2023-12-25)


### Bug Fixes

* **configs:** fix 'win_opts' recalculation ([#520](https://github.com/linrongbin16/fzfx.nvim/issues/520)) ([bd0e0b7](https://github.com/linrongbin16/fzfx.nvim/commit/bd0e0b77681d959e49aa0562db881ae916aa165e))

## [4.1.1](https://github.com/linrongbin16/fzfx.nvim/compare/v4.1.0...v4.1.1) (2023-12-25)


### Performance Improvements

* **configs:** support 'win_opts' as lua function ([#517](https://github.com/linrongbin16/fzfx.nvim/issues/517)) ([337225b](https://github.com/linrongbin16/fzfx.nvim/commit/337225b485d12b536aecdf1abc1e49cf58d260c0))

## [4.1.0](https://github.com/linrongbin16/fzfx.nvim/compare/v4.0.0...v4.1.0) (2023-12-25)


### Features

* **actions:** center cursor for 'rg'/'grep' edit actions ([#514](https://github.com/linrongbin16/fzfx.nvim/issues/514)) ([9c7b87e](https://github.com/linrongbin16/fzfx.nvim/commit/9c7b87e3a418f66858716b39b8d96163504e7fe2))

## [4.0.0](https://github.com/linrongbin16/fzfx.nvim/compare/v3.7.6...v4.0.0) (2023-12-25)


### ⚠ BREAKING CHANGES

* **fzfx.lib.paths:** drop 'fzfx.lib.paths'! ([#511](https://github.com/linrongbin16/fzfx.nvim/issues/511))
* **fzfx.lib.strings:** drop 'fzfx.lib.strings'! ([#511](https://github.com/linrongbin16/fzfx.nvim/issues/511))
* **fzfx.lib.tables:** drop 'fzfx.lib.tables'! ([#511](https://github.com/linrongbin16/fzfx.nvim/issues/511))
* **commons:** migrate to commons 'paths' modules! ([#511](https://github.com/linrongbin16/fzfx.nvim/issues/511))
* **commons:** drop 'fzfx.lib.nvims' module! ([#504](https://github.com/linrongbin16/fzfx.nvim/issues/504))
* **commons:** migrate to 'fzfx.lib.shells' and 'fzfx.lib.bufs' module! ([#504](https://github.com/linrongbin16/fzfx.nvim/issues/504))
* **commons:** migrate to commons 'numbers' module! ([#504](https://github.com/linrongbin16/fzfx.nvim/issues/504))
* **file explorer:** move alt+l/h to ctrl+l/h keys ([#510](https://github.com/linrongbin16/fzfx.nvim/issues/510))
* **jsons:** drop off 'fzfx.lib.jsons' module! ([#499](https://github.com/linrongbin16/fzfx.nvim/issues/499))
* **commons:** migrate to commons 'jsons' module! ([#499](https://github.com/linrongbin16/fzfx.nvim/issues/499))
* **commons:** migrate to commons 'fileios' module, drop off 'fzfx.lib.filesystems'! ([#498](https://github.com/linrongbin16/fzfx.nvim/issues/498))
* **decorator:** drop off legacy 'line_opts'! ([#496](https://github.com/linrongbin16/fzfx.nvim/issues/496))
* **commons:** migrate to commons 'termcolors' modules, drop off 'fzfx.lib.colors'! ([#496](https://github.com/linrongbin16/fzfx.nvim/issues/496))

### break

* **decorator:** drop off legacy 'line_opts'! ([#496](https://github.com/linrongbin16/fzfx.nvim/issues/496)) ([a985e4f](https://github.com/linrongbin16/fzfx.nvim/commit/a985e4fb78fc84194a621bb4c394ef96aa188d6b))
* **fzfx.lib.paths:** drop 'fzfx.lib.paths'! ([#511](https://github.com/linrongbin16/fzfx.nvim/issues/511)) ([3971ec5](https://github.com/linrongbin16/fzfx.nvim/commit/3971ec58038fa8a1fbddc7e440c805ecc61538ed))
* **fzfx.lib.strings:** drop 'fzfx.lib.strings'! ([#511](https://github.com/linrongbin16/fzfx.nvim/issues/511)) ([3971ec5](https://github.com/linrongbin16/fzfx.nvim/commit/3971ec58038fa8a1fbddc7e440c805ecc61538ed))
* **fzfx.lib.tables:** drop 'fzfx.lib.tables'! ([#511](https://github.com/linrongbin16/fzfx.nvim/issues/511)) ([3971ec5](https://github.com/linrongbin16/fzfx.nvim/commit/3971ec58038fa8a1fbddc7e440c805ecc61538ed))


### Performance Improvements

* **file explorer:** move alt+l/h to ctrl+l/h keys ([#510](https://github.com/linrongbin16/fzfx.nvim/issues/510)) ([c3ea764](https://github.com/linrongbin16/fzfx.nvim/commit/c3ea764171478dd5cae0d6602237d32cd3c43b34))
* **jsons:** drop off 'fzfx.lib.jsons' module! ([#499](https://github.com/linrongbin16/fzfx.nvim/issues/499)) ([8abffda](https://github.com/linrongbin16/fzfx.nvim/commit/8abffda709e12bf4a4584d9ce5ec3e826037d4ae))


### Code Refactoring

* **commons:** drop 'fzfx.lib.nvims' module! ([#504](https://github.com/linrongbin16/fzfx.nvim/issues/504)) ([4729b11](https://github.com/linrongbin16/fzfx.nvim/commit/4729b11029ca05e9ef912407cf07bc3615948746))
* **commons:** migrate to 'fzfx.lib.shells' and 'fzfx.lib.bufs' module! ([#504](https://github.com/linrongbin16/fzfx.nvim/issues/504)) ([4729b11](https://github.com/linrongbin16/fzfx.nvim/commit/4729b11029ca05e9ef912407cf07bc3615948746))
* **commons:** migrate to commons 'fileios' module, drop off 'fzfx.lib.filesystems'! ([#498](https://github.com/linrongbin16/fzfx.nvim/issues/498)) ([fd4e3f4](https://github.com/linrongbin16/fzfx.nvim/commit/fd4e3f453b0966a2f17621cf9e8095508d6d1011))
* **commons:** migrate to commons 'jsons' module! ([#499](https://github.com/linrongbin16/fzfx.nvim/issues/499)) ([8abffda](https://github.com/linrongbin16/fzfx.nvim/commit/8abffda709e12bf4a4584d9ce5ec3e826037d4ae))
* **commons:** migrate to commons 'numbers' module! ([#504](https://github.com/linrongbin16/fzfx.nvim/issues/504)) ([4729b11](https://github.com/linrongbin16/fzfx.nvim/commit/4729b11029ca05e9ef912407cf07bc3615948746))
* **commons:** migrate to commons 'paths' modules! ([#511](https://github.com/linrongbin16/fzfx.nvim/issues/511)) ([3971ec5](https://github.com/linrongbin16/fzfx.nvim/commit/3971ec58038fa8a1fbddc7e440c805ecc61538ed))
* **commons:** migrate to commons 'termcolors' modules, drop off 'fzfx.lib.colors'! ([#496](https://github.com/linrongbin16/fzfx.nvim/issues/496)) ([a985e4f](https://github.com/linrongbin16/fzfx.nvim/commit/a985e4fb78fc84194a621bb4c394ef96aa188d6b))

## [3.7.6](https://github.com/linrongbin16/fzfx.nvim/compare/v3.7.5...v3.7.6) (2023-12-08)


### Reverts

* **ci:** revert please-release action to v3, remove luarocks ci ([#482](https://github.com/linrongbin16/fzfx.nvim/issues/482)) ([22b3385](https://github.com/linrongbin16/fzfx.nvim/commit/22b3385824cf77f704b7499e39108612599b6a95))

## [3.7.5](https://github.com/linrongbin16/fzfx.nvim/compare/v3.7.4...v3.7.5) (2023-12-08)


### Bug Fixes

* **ci:** fix luarocks tags version ([#478](https://github.com/linrongbin16/fzfx.nvim/issues/478)) ([a3625dc](https://github.com/linrongbin16/fzfx.nvim/commit/a3625dc91d491b5490b6fdb2017f1df9635209e3))
* **ci:** fix please-release action permission ([#481](https://github.com/linrongbin16/fzfx.nvim/issues/481)) ([e377fb6](https://github.com/linrongbin16/fzfx.nvim/commit/e377fb6fbce8d3ad13f6ff09e922f436b3c76fcc))
* **ci:** only run luarocks upload if tags been created ([#480](https://github.com/linrongbin16/fzfx.nvim/issues/480)) ([5fee521](https://github.com/linrongbin16/fzfx.nvim/commit/5fee521de79446e79f3619604344be5d49db451a))

## [3.7.4](https://github.com/linrongbin16/fzfx.nvim/compare/v3.7.3...v3.7.4) (2023-12-08)


### Bug Fixes

* **ci:** fix luarocks actions trigger ([#476](https://github.com/linrongbin16/fzfx.nvim/issues/476)) ([da08581](https://github.com/linrongbin16/fzfx.nvim/commit/da08581dc1b8748b0a0b8c180235e4157b676d2a))

## [3.7.3](https://github.com/linrongbin16/fzfx.nvim/compare/v3.7.2...v3.7.3) (2023-12-08)


### Performance Improvements

* **ci:** again first release luarocks ([#474](https://github.com/linrongbin16/fzfx.nvim/issues/474)) ([eec2147](https://github.com/linrongbin16/fzfx.nvim/commit/eec21479aad146749e1ddf9dd64d056a0ba02876))

## [3.7.2](https://github.com/linrongbin16/fzfx.nvim/compare/v3.7.1...v3.7.2) (2023-12-08)


### Performance Improvements

* **ci:** first release luarocks package ([#472](https://github.com/linrongbin16/fzfx.nvim/issues/472)) ([7841210](https://github.com/linrongbin16/fzfx.nvim/commit/7841210a7e43c9ad2a0bb7eff0d660c3c365e66c))

## [3.7.1](https://github.com/linrongbin16/fzfx.nvim/compare/v3.7.0...v3.7.1) (2023-12-08)


### Performance Improvements

* **config:** migrate to provider decorators ([#469](https://github.com/linrongbin16/fzfx.nvim/issues/469)) ([f825f32](https://github.com/linrongbin16/fzfx.nvim/commit/f825f324664e512e0ee87973e19c9181eee8a834))

## [3.7.0](https://github.com/linrongbin16/fzfx.nvim/compare/v3.6.1...v3.7.0) (2023-12-07)


### Features

* **provider decorator:** add lua module based provider decorator ([#465](https://github.com/linrongbin16/fzfx.nvim/issues/465)) ([453de6a](https://github.com/linrongbin16/fzfx.nvim/commit/453de6abe053a1287785db3cfff0a66fbb505ccc))


### Performance Improvements

* **provider decorators:** add `stdpath('config')` to runtime path ([#468](https://github.com/linrongbin16/fzfx.nvim/issues/468)) ([e17f835](https://github.com/linrongbin16/fzfx.nvim/commit/e17f8357c4c0620401421a48ef5552145f63841f))

## [3.6.1](https://github.com/linrongbin16/fzfx.nvim/compare/v3.6.0...v3.6.1) (2023-12-06)


### Bug Fixes

* **test:** fix unit test for buffers 'delete buffer' interaction ([#452](https://github.com/linrongbin16/fzfx.nvim/issues/452)) ([38ba99f](https://github.com/linrongbin16/fzfx.nvim/commit/38ba99fe531640863568820dbe0b04b6258e3687))


### Performance Improvements

* **buffers:** migrate 'buffers' to 'cfg.buffers' ([#449](https://github.com/linrongbin16/fzfx.nvim/issues/449)) ([b9c4b2d](https://github.com/linrongbin16/fzfx.nvim/commit/b9c4b2de2639fca522203576172fb3a20d8a58c6))
* **config:** clean old configs ([#464](https://github.com/linrongbin16/fzfx.nvim/issues/464)) ([01a27ce](https://github.com/linrongbin16/fzfx.nvim/commit/01a27ce96f5be4332042f42ea4891b80e3645547))
* **config:** migrate 'git_branches' to 'cfg.git_branches' ([#454](https://github.com/linrongbin16/fzfx.nvim/issues/454)) ([688a786](https://github.com/linrongbin16/fzfx.nvim/commit/688a78687bc9eaa9ea87a901e65fa0acada5fda9))
* **config:** migrate to 'cfg.file_explorer' ([#463](https://github.com/linrongbin16/fzfx.nvim/issues/463)) ([dae8b9d](https://github.com/linrongbin16/fzfx.nvim/commit/dae8b9d71f9cfd2c39c3c234bbafee796a239120))
* **config:** migrate to 'cfg.git_blame' ([#456](https://github.com/linrongbin16/fzfx.nvim/issues/456)) ([058a6eb](https://github.com/linrongbin16/fzfx.nvim/commit/058a6eb6d927f17505a4618426eacfdea08b1c97))
* **config:** migrate to 'cfg.git_commits' ([#455](https://github.com/linrongbin16/fzfx.nvim/issues/455)) ([c94d21b](https://github.com/linrongbin16/fzfx.nvim/commit/c94d21ba2bd615a7e97266b037fd634e8795e9fa))
* **config:** migrate to 'cfg.lsp_definitions' ([#460](https://github.com/linrongbin16/fzfx.nvim/issues/460)) ([c57f7b0](https://github.com/linrongbin16/fzfx.nvim/commit/c57f7b0977fcefd80872c4f5fd4305fb1be55121))
* **config:** migrate to 'cfg.lsp_diagnostics' ([#459](https://github.com/linrongbin16/fzfx.nvim/issues/459)) ([0d3d0b8](https://github.com/linrongbin16/fzfx.nvim/commit/0d3d0b8789fc9f5ad35bf5cfa04357dd40ec9446))
* **config:** migrate to 'cfg.lsp_implementations' ([#461](https://github.com/linrongbin16/fzfx.nvim/issues/461)) ([1101df9](https://github.com/linrongbin16/fzfx.nvim/commit/1101df9c9a0a22ffe188c3a8baf9efd10b7a91ec))
* **config:** migrate to 'cfg.lsp_incoming_calls' ([#462](https://github.com/linrongbin16/fzfx.nvim/issues/462)) ([870f268](https://github.com/linrongbin16/fzfx.nvim/commit/870f2681a5c1598ca56c0e9d845c73b7f6c9234d))
* **config:** migrate to 'cfg.lsp_outgoing_calls' ([#462](https://github.com/linrongbin16/fzfx.nvim/issues/462)) ([870f268](https://github.com/linrongbin16/fzfx.nvim/commit/870f2681a5c1598ca56c0e9d845c73b7f6c9234d))
* **config:** migrate to 'cfg.lsp_references' ([#461](https://github.com/linrongbin16/fzfx.nvim/issues/461)) ([1101df9](https://github.com/linrongbin16/fzfx.nvim/commit/1101df9c9a0a22ffe188c3a8baf9efd10b7a91ec))
* **config:** migrate to 'cfg.lsp_type_definitions' ([#461](https://github.com/linrongbin16/fzfx.nvim/issues/461)) ([1101df9](https://github.com/linrongbin16/fzfx.nvim/commit/1101df9c9a0a22ffe188c3a8baf9efd10b7a91ec))
* **config:** migrate to 'cfg.vim_commands' ([#457](https://github.com/linrongbin16/fzfx.nvim/issues/457)) ([7d251d6](https://github.com/linrongbin16/fzfx.nvim/commit/7d251d65c835883b817c04e02337a65f4b56d1ef))
* **config:** migrate to 'cfg.vim_keymaps' ([#458](https://github.com/linrongbin16/fzfx.nvim/issues/458)) ([f3488fc](https://github.com/linrongbin16/fzfx.nvim/commit/f3488fc5a6d6ba3d8c1c4acddd8699621059d84b))
* **files:** migrate 'files' to 'cfg.files' ([#448](https://github.com/linrongbin16/fzfx.nvim/issues/448)) ([9a75e8f](https://github.com/linrongbin16/fzfx.nvim/commit/9a75e8f9a1341f3ee3d5c3ac4cfa7704a1a88ae9))
* **git_files:** migrate 'git_files' to 'cfg.git_files' ([#450](https://github.com/linrongbin16/fzfx.nvim/issues/450)) ([df4ee6c](https://github.com/linrongbin16/fzfx.nvim/commit/df4ee6c7d1ef5cb7c24c5de5180c4d2b6fa10d2f))
* **git_live_grep:** migrate 'git_live_grep' to 'cfg.git_live_grep' ([#451](https://github.com/linrongbin16/fzfx.nvim/issues/451)) ([ad93650](https://github.com/linrongbin16/fzfx.nvim/commit/ad9365070d69534ede1929c46f6ffc7a120d7baa))
* **git_status:** migrate 'git_status' to 'cfg.git_status' ([#453](https://github.com/linrongbin16/fzfx.nvim/issues/453)) ([fd3640d](https://github.com/linrongbin16/fzfx.nvim/commit/fd3640de4d0c7e268e2abc5c3c9f22bdd7c490a0))
* **lib:** add api `fzfx.lib.tables.tbl_get` ([0d3d0b8](https://github.com/linrongbin16/fzfx.nvim/commit/0d3d0b8789fc9f5ad35bf5cfa04357dd40ec9446))
* **lib:** provide standard API layer ([#439](https://github.com/linrongbin16/fzfx.nvim/issues/439)) ([d473b85](https://github.com/linrongbin16/fzfx.nvim/commit/d473b85f03cc3dcc7cb242d08a8e1bee5fb78693))
* **live_grep:** migrate 'live_grep' to 'cfg.live_grep' ([#448](https://github.com/linrongbin16/fzfx.nvim/issues/448)) ([9a75e8f](https://github.com/linrongbin16/fzfx.nvim/commit/9a75e8f9a1341f3ee3d5c3ac4cfa7704a1a88ae9))
* **log:** migrate to 'lib.log' ([#447](https://github.com/linrongbin16/fzfx.nvim/issues/447)) ([bbd1d9d](https://github.com/linrongbin16/fzfx.nvim/commit/bbd1d9d2f423939f920a772f8cefb1700e1181a9))
* **logs:** support safe-mode logs before setup ([#442](https://github.com/linrongbin16/fzfx.nvim/issues/442)) ([d575f58](https://github.com/linrongbin16/fzfx.nvim/commit/d575f58d753be23871a70c9244546af8c16825e2))
* **parsers:** migrate 'previewer_labels' ([#444](https://github.com/linrongbin16/fzfx.nvim/issues/444)) ([533abe6](https://github.com/linrongbin16/fzfx.nvim/commit/533abe67b81dc38f53cde3a3eeaa1202aa4f8144))
* **yanks:** migrate to 'detail.yanks' ([bbd1d9d](https://github.com/linrongbin16/fzfx.nvim/commit/bbd1d9d2f423939f920a772f8cefb1700e1181a9))

## [3.6.0](https://github.com/linrongbin16/fzfx.nvim/compare/v3.5.0...v3.6.0) (2023-11-27)


### Features

* **lsp_incoming_calls:** add `FzfxLspIncomingCalls` ([#436](https://github.com/linrongbin16/fzfx.nvim/issues/436)) ([81ec652](https://github.com/linrongbin16/fzfx.nvim/commit/81ec65226a240b593fc1d9f5fdb4ff65716451d6))
* **lsp_outgoing_calls:** add `FzfxLspOutgoingCalls` ([#436](https://github.com/linrongbin16/fzfx.nvim/issues/436)) ([81ec652](https://github.com/linrongbin16/fzfx.nvim/commit/81ec65226a240b593fc1d9f5fdb4ff65716451d6))


### Performance Improvements

* **path:** reduce duplicate lines ([#429](https://github.com/linrongbin16/fzfx.nvim/issues/429)) ([433c0b9](https://github.com/linrongbin16/fzfx.nvim/commit/433c0b9caac587c39f272f9f2219fdab49ca93be))
* **test:** add 'packadd' minimal test case ([#438](https://github.com/linrongbin16/fzfx.nvim/issues/438)) ([3a5c75a](https://github.com/linrongbin16/fzfx.nvim/commit/3a5c75a1b5f39130e39c55234c900ebfb8de96b7))

## [3.5.0](https://github.com/linrongbin16/fzfx.nvim/compare/v3.4.1...v3.5.0) (2023-11-23)


### Features

* **config:** add global `override_fzf_opts` with highest priority ([#427](https://github.com/linrongbin16/fzfx.nvim/issues/427)) ([487a234](https://github.com/linrongbin16/fzfx.nvim/commit/487a234c6df1854263956757802a4fe4d6d2494b))

## [3.4.1](https://github.com/linrongbin16/fzfx.nvim/compare/v3.4.0...v3.4.1) (2023-11-22)


### Bug Fixes

* **prompt:** respect `hidden` option when open files ([#424](https://github.com/linrongbin16/fzfx.nvim/issues/424)) ([287ba48](https://github.com/linrongbin16/fzfx.nvim/commit/287ba48e71f611a18a9785572d2e58c0ae724eec))

## [3.4.0](https://github.com/linrongbin16/fzfx.nvim/compare/v3.3.1...v3.4.0) (2023-11-16)


### Features

* **git_live_grep:** add FzfxGLiveGrep ([#419](https://github.com/linrongbin16/fzfx.nvim/issues/419)) ([ddb60b6](https://github.com/linrongbin16/fzfx.nvim/commit/ddb60b6ef3617750ed8c22046f15e516c5476625))

## [3.3.1](https://github.com/linrongbin16/fzfx.nvim/compare/v3.3.0...v3.3.1) (2023-11-14)


### Bug Fixes

* **actions:** fix ctrl-c abort error, improve error message ([#415](https://github.com/linrongbin16/fzfx.nvim/issues/415)) ([715f722](https://github.com/linrongbin16/fzfx.nvim/commit/715f72217fde499a7416a1422637a97e4da1c2af))

## [3.3.0](https://github.com/linrongbin16/fzfx.nvim/compare/v3.2.0...v3.3.0) (2023-11-12)


### Features

* **variant:** add resume last search variant to all commands ([#413](https://github.com/linrongbin16/fzfx.nvim/issues/413)) ([c46c92d](https://github.com/linrongbin16/fzfx.nvim/commit/c46c92d620b6357c4774187e42b1019460bf74bd))

## [3.2.0](https://github.com/linrongbin16/fzfx.nvim/compare/v3.1.0...v3.2.0) (2023-11-12)


### Features

* **variant:** add resume last search variant for 'files' ([#408](https://github.com/linrongbin16/fzfx.nvim/issues/408)) ([cfcb1d4](https://github.com/linrongbin16/fzfx.nvim/commit/cfcb1d485590a75a800287f552feace23a5a6a98))
* **variant:** add resume last search variant for 'live_grep' ([#408](https://github.com/linrongbin16/fzfx.nvim/issues/408)) ([cfcb1d4](https://github.com/linrongbin16/fzfx.nvim/commit/cfcb1d485590a75a800287f552feace23a5a6a98))

## [3.1.0](https://github.com/linrongbin16/fzfx.nvim/compare/v3.0.0...v3.1.0) (2023-11-11)


### Features

* **preview:** preview window label come back again with best performance! ([#404](https://github.com/linrongbin16/fzfx.nvim/issues/404)) ([f821558](https://github.com/linrongbin16/fzfx.nvim/commit/f82155872d4c333b61ca2e2f03e6b490b52c28aa))

## [3.0.0](https://github.com/linrongbin16/fzfx.nvim/compare/v2.5.3...v3.0.0) (2023-11-10)


### ⚠ BREAKING CHANGES

* **preview-label:** revert bad-performance feature since too laggy on x86_64 Windows 10 PC ([#401](https://github.com/linrongbin16/fzfx.nvim/issues/401))

### Performance Improvements

* **preview-label:** revert bad-performance feature since too laggy on x86_64 Windows 10 PC ([#401](https://github.com/linrongbin16/fzfx.nvim/issues/401)) ([c6941e9](https://github.com/linrongbin16/fzfx.nvim/commit/c6941e9e257c88e94d593c398ed19b1efc276d06))

## [2.5.3](https://github.com/linrongbin16/fzfx.nvim/compare/v2.5.2...v2.5.3) (2023-11-10)


### Bug Fixes

* **git_commits:** fix wrong current buffer checking ([#395](https://github.com/linrongbin16/fzfx.nvim/issues/395)) ([fc59c35](https://github.com/linrongbin16/fzfx.nvim/commit/fc59c3555d6d1d66413fc9b0309c48671286e95f))
* **rg:** fix column missing error ([#393](https://github.com/linrongbin16/fzfx.nvim/issues/393)) ([623da80](https://github.com/linrongbin16/fzfx.nvim/commit/623da80c8b228ac826b31225cbe1e748fa6a1b30))

## [2.5.2](https://github.com/linrongbin16/fzfx.nvim/compare/v2.5.1...v2.5.2) (2023-11-10)


### Bug Fixes

* **preview:** preview window label unchanged due to missing 'vim.rpcnotify' events ([75b8da7](https://github.com/linrongbin16/fzfx.nvim/commit/75b8da7bd317b176c4eec91fc6aeaa50df1137bf))
* **rpc:** release registered rpc callbacks ([#390](https://github.com/linrongbin16/fzfx.nvim/issues/390)) ([75b8da7](https://github.com/linrongbin16/fzfx.nvim/commit/75b8da7bd317b176c4eec91fc6aeaa50df1137bf))
* **rpc:** release rpc registries after fzf exit ([#388](https://github.com/linrongbin16/fzfx.nvim/issues/388)) ([52fb9ed](https://github.com/linrongbin16/fzfx.nvim/commit/52fb9ed3d77bc4a86c22ef29675d53b5a3c85185))


### Performance Improvements

* **preview:** improve preview label performance ([75b8da7](https://github.com/linrongbin16/fzfx.nvim/commit/75b8da7bd317b176c4eec91fc6aeaa50df1137bf))

## [2.5.1](https://github.com/linrongbin16/fzfx.nvim/compare/v2.5.0...v2.5.1) (2023-11-09)


### Performance Improvements

* **fzf:** optimize curl responding speed ([#384](https://github.com/linrongbin16/fzfx.nvim/issues/384)) ([64ec61d](https://github.com/linrongbin16/fzfx.nvim/commit/64ec61db80ab9eb7f9c3b51bcfa190d93421291b))

## [2.5.0](https://github.com/linrongbin16/fzfx.nvim/compare/v2.4.0...v2.5.0) (2023-11-09)


### Features

* **fzf:** support plain string as previewer label ([#376](https://github.com/linrongbin16/fzfx.nvim/issues/376)) ([a3048c2](https://github.com/linrongbin16/fzfx.nvim/commit/a3048c2dccd5c3f74d150969a7928b6c1627cb99))
* **preview:** add label for file explorer ([#382](https://github.com/linrongbin16/fzfx.nvim/issues/382)) ([64dcd72](https://github.com/linrongbin16/fzfx.nvim/commit/64dcd724a81ec67cdd350555112a1c4430755a93))
* **preview:** add label for rg/grep preview window ([#374](https://github.com/linrongbin16/fzfx.nvim/issues/374)) ([b82790f](https://github.com/linrongbin16/fzfx.nvim/commit/b82790f28728a6792aa4600465e7219949be78a1))
* **preview:** add vim commands, keymaps previewer label ([#380](https://github.com/linrongbin16/fzfx.nvim/issues/380)) ([c719e30](https://github.com/linrongbin16/fzfx.nvim/commit/c719e308899fd222e72efc0247f73a299a7c62d4))

## [2.4.0](https://github.com/linrongbin16/fzfx.nvim/compare/v2.3.0...v2.4.0) (2023-11-08)


### Features

* **actions:** require user confirm to discard modified buffer when jump to other files ([#365](https://github.com/linrongbin16/fzfx.nvim/issues/365)) ([1267589](https://github.com/linrongbin16/fzfx.nvim/commit/1267589f67152a5e679f7a2bf06abc74642e66ed))
* **preview:** add label for files preview via 'fzf --listen' ([#372](https://github.com/linrongbin16/fzfx.nvim/issues/372)) ([c99a062](https://github.com/linrongbin16/fzfx.nvim/commit/c99a062d86f0de02d3b58b84c9956875f1a7efdd))


### Bug Fixes

* **ui:** supress ctrl-c abort error ([#368](https://github.com/linrongbin16/fzfx.nvim/issues/368)) ([0e0d063](https://github.com/linrongbin16/fzfx.nvim/commit/0e0d06322c258683e3004e05ca8d0a85618eebd5))


### Performance Improvements

* **git & explorer:** check git repo, support delta/lsd ([#360](https://github.com/linrongbin16/fzfx.nvim/issues/360)) ([ebd7ac4](https://github.com/linrongbin16/fzfx.nvim/commit/ebd7ac440d8d301e444c4d62c6431f6ea3d1f434))
* **icon:** update default icon for unknown filetype ([#361](https://github.com/linrongbin16/fzfx.nvim/issues/361)) ([28d4d54](https://github.com/linrongbin16/fzfx.nvim/commit/28d4d5443cf6c8aa741eadcf2df12a533b9b5218))
* **json:** migrate legacy json_encode/json_decode to lua module ([#367](https://github.com/linrongbin16/fzfx.nvim/issues/367)) ([9e34209](https://github.com/linrongbin16/fzfx.nvim/commit/9e3420919dab61dd6209b81faad3fa717b8c8370))

## [2.3.0](https://github.com/linrongbin16/fzfx.nvim/compare/v2.2.1...v2.3.0) (2023-10-31)


### Features

* **git_status:** add FzfxGStatus commands, add git-delta support ([#358](https://github.com/linrongbin16/fzfx.nvim/issues/358)) ([491fb59](https://github.com/linrongbin16/fzfx.nvim/commit/491fb5943a48b3c224dfaf941132d33b6b033d1d))

## [2.2.1](https://github.com/linrongbin16/fzfx.nvim/compare/v2.2.0...v2.2.1) (2023-10-30)


### Performance Improvements

* **path:** add 'expand' option to normalize ([#332](https://github.com/linrongbin16/fzfx.nvim/issues/332)) ([8a13a8e](https://github.com/linrongbin16/fzfx.nvim/commit/8a13a8e8f4d1a459413a29a2e73462d22e92269a))
* **rpc_server:** more un-conflictable pipe name for Windows ([#341](https://github.com/linrongbin16/fzfx.nvim/issues/341)) ([15c9b12](https://github.com/linrongbin16/fzfx.nvim/commit/15c9b1225cabddcb1fbb055f166d45bc1cb43afc))
* **test:** improve tests ([#334](https://github.com/linrongbin16/fzfx.nvim/issues/334)) ([fa5845f](https://github.com/linrongbin16/fzfx.nvim/commit/fa5845ff98fdb138e8385e21419d0c1a44a6973e))
* **test:** improve tests2 ([#336](https://github.com/linrongbin16/fzfx.nvim/issues/336)) ([c68e23c](https://github.com/linrongbin16/fzfx.nvim/commit/c68e23c6685769af2977484277de85753fc89022))
* **test:** improve tests3 ([#352](https://github.com/linrongbin16/fzfx.nvim/issues/352)) ([1086fcf](https://github.com/linrongbin16/fzfx.nvim/commit/1086fcfbabec59200ac9f2ed9748df320fb8b5f3))

## [2.2.0](https://github.com/linrongbin16/fzfx.nvim/compare/v2.1.0...v2.2.0) (2023-10-27)


### Features

* **live_grep:** add buffer mode ([#327](https://github.com/linrongbin16/fzfx.nvim/issues/327)) ([df1851d](https://github.com/linrongbin16/fzfx.nvim/commit/df1851deb7fb2ad529ce0db22ae2c7d7a3adb0a5))


### Performance Improvements

* **module:** use self module path and drop 'fzfx#nvim#base_dir' ([f4061b4](https://github.com/linrongbin16/fzfx.nvim/commit/f4061b4ad1990dd124743af6f108cfc18a5a3883))
* **module:** use self module path, drop autoload ([#325](https://github.com/linrongbin16/fzfx.nvim/issues/325)) ([91146a5](https://github.com/linrongbin16/fzfx.nvim/commit/91146a58b1061eb78d93e4e07d20f81d37722caf))

## [2.1.0](https://github.com/linrongbin16/fzfx.nvim/compare/v2.0.0...v2.1.0) (2023-10-26)


### Features

* **popup:** realtime resize popup window ([#322](https://github.com/linrongbin16/fzfx.nvim/issues/322)) ([a463689](https://github.com/linrongbin16/fzfx.nvim/commit/a46368989249a83c5810152f0a88041a18321939))


### Bug Fixes

* **required:** set minimal required Neovim version to 0.7 ([#320](https://github.com/linrongbin16/fzfx.nvim/issues/320)) ([3b36751](https://github.com/linrongbin16/fzfx.nvim/commit/3b36751c449ef9c5ce68dcd6f2dbd62c0e2f0151))


### Performance Improvements

* **test:** improve test coverage ([#316](https://github.com/linrongbin16/fzfx.nvim/issues/316)) ([29ebe78](https://github.com/linrongbin16/fzfx.nvim/commit/29ebe785ce481f3c75f763979831d831e70d50d1))

## [2.0.0](https://github.com/linrongbin16/fzfx.nvim/compare/v1.5.0...v2.0.0) (2023-10-25)


### ⚠ BREAKING CHANGES

* **drop:** drop deprecated! ([#308](https://github.com/linrongbin16/fzfx.nvim/issues/308))

### Bug Fixes

* **bin:** setup log at first ([#309](https://github.com/linrongbin16/fzfx.nvim/issues/309)) ([a090851](https://github.com/linrongbin16/fzfx.nvim/commit/a0908513eff3457c16c2cd1a3597d02951ff6c58))


### Performance Improvements

* **drop:** drop deprecated! ([#308](https://github.com/linrongbin16/fzfx.nvim/issues/308)) ([545d137](https://github.com/linrongbin16/fzfx.nvim/commit/545d137de12872bf48f3061e59262e5c969abb2d))

## [1.5.0](https://github.com/linrongbin16/fzfx.nvim/compare/v1.4.0...v1.5.0) (2023-10-24)


### Features

* **keymaps:** add 'FzfxKeyMaps' to search vim keymaps ([#306](https://github.com/linrongbin16/fzfx.nvim/issues/306)) ([f43e70f](https://github.com/linrongbin16/fzfx.nvim/commit/f43e70f3ba7ab1132dfd65fbcf71db6bfc11912b))

## [1.4.0](https://github.com/linrongbin16/fzfx.nvim/compare/v1.3.0...v1.4.0) (2023-10-23)


### Features

* **actions:** add 'setqflist' ([#290](https://github.com/linrongbin16/fzfx.nvim/issues/290)) ([1284639](https://github.com/linrongbin16/fzfx.nvim/commit/1284639770c907fe7d850c5b05ddeb74a8db552e))
* add parse_file/parse_grep line helpers ([#222](https://github.com/linrongbin16/fzfx.nvim/issues/222)) ([5a503da](https://github.com/linrongbin16/fzfx.nvim/commit/5a503da25aec9a07ebde12dedae03e71056445c1))
* add variants for file explorer ([#213](https://github.com/linrongbin16/fzfx.nvim/issues/213)) ([289b8b8](https://github.com/linrongbin16/fzfx.nvim/commit/289b8b80c1348e604f141551a1c4877aecc5315f))
* bg color ^& fix exec ([#22](https://github.com/linrongbin16/fzfx.nvim/issues/22)) ([1a86b34](https://github.com/linrongbin16/fzfx.nvim/commit/1a86b34afeaeca879f05d4f7ea5ef4698f0044b6))
* buffers ([#57](https://github.com/linrongbin16/fzfx.nvim/issues/57)) ([bd1e0dc](https://github.com/linrongbin16/fzfx.nvim/commit/bd1e0dc2432f10a7947c1718ea3cb9ce9d600f64))
* color ([5537884](https://github.com/linrongbin16/fzfx.nvim/commit/5537884769b20f1ddab63c7885323e82ea31ef0b))
* colors ([#62](https://github.com/linrongbin16/fzfx.nvim/issues/62)) ([72b2437](https://github.com/linrongbin16/fzfx.nvim/commit/72b243747f6c0418f5c6e45eba79450b1f224815))
* **commands:** add 'FzfxCommands' to search vim commands ([#287](https://github.com/linrongbin16/fzfx.nvim/issues/287)) ([997821b](https://github.com/linrongbin16/fzfx.nvim/commit/997821ba69b6587ba392e3f5c46cc7dd196f62da))
* debug command ([b0ac732](https://github.com/linrongbin16/fzfx.nvim/commit/b0ac73244ac4ecf78671e29bffd07c538a86b3b6))
* diagnostics ([#124](https://github.com/linrongbin16/fzfx.nvim/issues/124)) ([a610762](https://github.com/linrongbin16/fzfx.nvim/commit/a610762e579eb31fdabb6f837f788cb7e3e9fc3e))
* file explorer (ls) ([#210](https://github.com/linrongbin16/fzfx.nvim/issues/210)) ([212c789](https://github.com/linrongbin16/fzfx.nvim/commit/212c789dc424e97894eef6209bb18f829b0191d4))
* files ([bf42213](https://github.com/linrongbin16/fzfx.nvim/commit/bf42213be415d19123a5a6f6ef4412756755c3b3))
* files ([362065c](https://github.com/linrongbin16/fzfx.nvim/commit/362065c6a650c88fb737bdd06807fb9b61d83244))
* git blame & general ([#102](https://github.com/linrongbin16/fzfx.nvim/issues/102)) ([21f5a62](https://github.com/linrongbin16/fzfx.nvim/commit/21f5a622494143ad270c430d72ad5e4c37996df5))
* git branches ([#68](https://github.com/linrongbin16/fzfx.nvim/issues/68)) ([7f055d5](https://github.com/linrongbin16/fzfx.nvim/commit/7f055d5549a01ffac8f2389ccf7a9315d2f44442))
* git commits ([#97](https://github.com/linrongbin16/fzfx.nvim/issues/97)) ([ded9623](https://github.com/linrongbin16/fzfx.nvim/commit/ded9623463864f8d0d07d08ac83e858a32d7ba10))
* git files ([#64](https://github.com/linrongbin16/fzfx.nvim/issues/64)) ([d83a857](https://github.com/linrongbin16/fzfx.nvim/commit/d83a857d619292a36ee736b88971a86acc2b0680))
* handle whitespaces on path ([#20](https://github.com/linrongbin16/fzfx.nvim/issues/20)) ([f05107b](https://github.com/linrongbin16/fzfx.nvim/commit/f05107b10523edfccb49403007d2b7efab8f487c))
* icon!!! ([#31](https://github.com/linrongbin16/fzfx.nvim/issues/31)) ([668a820](https://github.com/linrongbin16/fzfx.nvim/commit/668a82042e972427be541dfde5adad3d5173ed12))
* improve cwd ([#214](https://github.com/linrongbin16/fzfx.nvim/issues/214)) ([cd6042f](https://github.com/linrongbin16/fzfx.nvim/commit/cd6042fda05841a7d00321cae7323754d7bccba1))
* list_index ([#221](https://github.com/linrongbin16/fzfx.nvim/issues/221)) ([cb61fd5](https://github.com/linrongbin16/fzfx.nvim/commit/cb61fd5524a73f3cf8f871d60222c0119ae91498))
* live grep ([67c2776](https://github.com/linrongbin16/fzfx.nvim/commit/67c2776b6b3be654856db8b5537279368c9baf90))
* live grep ([#7](https://github.com/linrongbin16/fzfx.nvim/issues/7)) ([fda0337](https://github.com/linrongbin16/fzfx.nvim/commit/fda0337ec5189021ed6a5e023b75099bc4be1f91))
* log ([ffe368b](https://github.com/linrongbin16/fzfx.nvim/commit/ffe368ba848c8ae95cc8b1af967bc2443c309222))
* **logs:** split shell command provider/previewer logs ([#303](https://github.com/linrongbin16/fzfx.nvim/issues/303)) ([5ed1bcd](https://github.com/linrongbin16/fzfx.nvim/commit/5ed1bcd6728000c7ec692e99603ae69ab82a2edd))
* lsp color ([#166](https://github.com/linrongbin16/fzfx.nvim/issues/166)) ([690bf7a](https://github.com/linrongbin16/fzfx.nvim/commit/690bf7a42099c53a34534a79d10aba1083d59892))
* lsp commands ([#170](https://github.com/linrongbin16/fzfx.nvim/issues/170)) ([7589a88](https://github.com/linrongbin16/fzfx.nvim/commit/7589a8885b088a17fdeef040d0c768c10298a300))
* lsp definitions ([#150](https://github.com/linrongbin16/fzfx.nvim/issues/150)) ([10f5bfc](https://github.com/linrongbin16/fzfx.nvim/commit/10f5bfc3179729a579086fe67c3aa8ff29d66b82))
* lsp diagnostics file path color ([#125](https://github.com/linrongbin16/fzfx.nvim/issues/125)) ([f24e578](https://github.com/linrongbin16/fzfx.nvim/commit/f24e578d21809b7bed4fc0f92cb4fb922fbc1777))
* passing rg raw optoins ([c36bf8a](https://github.com/linrongbin16/fzfx.nvim/commit/c36bf8aff1bc0e425c6bd0853e3809e245a9ecca))
* please-release ([#254](https://github.com/linrongbin16/fzfx.nvim/issues/254)) ([a1d2da4](https://github.com/linrongbin16/fzfx.nvim/commit/a1d2da467596f679da0565ac7223324f23e10362))
* plugin home dir ([a55718f](https://github.com/linrongbin16/fzfx.nvim/commit/a55718f81a346de3c095174630e828cbb8a84b76))
* PR template ([#247](https://github.com/linrongbin16/fzfx.nvim/issues/247)) ([0843fb5](https://github.com/linrongbin16/fzfx.nvim/commit/0843fb56554237eeb54e1486a6e249be8796e153))
* relative window ([#172](https://github.com/linrongbin16/fzfx.nvim/issues/172)) ([01caa8b](https://github.com/linrongbin16/fzfx.nvim/commit/01caa8bc6c0b5689b79773112ad79b99adc0527a))
* restore query ([9c1ec44](https://github.com/linrongbin16/fzfx.nvim/commit/9c1ec443e7f2b9f3530eee4529f7c52a9391cefc))
* rgb color codes ([#165](https://github.com/linrongbin16/fzfx.nvim/issues/165)) ([835ca8a](https://github.com/linrongbin16/fzfx.nvim/commit/835ca8acbb7227997621e8f44e5c56702d7633a7))
* row/col win_opts ([#12](https://github.com/linrongbin16/fzfx.nvim/issues/12)) ([bd24d0a](https://github.com/linrongbin16/fzfx.nvim/commit/bd24d0a107330648ced401acdf30c02bc438d64f))
* **schema:** add 'PreviewerConfig' detection ([#266](https://github.com/linrongbin16/fzfx.nvim/issues/266)) ([2bdcef7](https://github.com/linrongbin16/fzfx.nvim/commit/2bdcef7f82a55327851b6d3ecb5e48c53f08a691))
* switch unrestricted mode ([5500bb1](https://github.com/linrongbin16/fzfx.nvim/commit/5500bb176a789f88a01c3cca066c0eaa3abe4a69))
* throw error ([c4eef09](https://github.com/linrongbin16/fzfx.nvim/commit/c4eef090f92bf3f5c548f92c63e386416567cf65))
* utils ([4ab3a4f](https://github.com/linrongbin16/fzfx.nvim/commit/4ab3a4f2ad9e950f962cab727ad91cc207b3ff33))
* visual/cword ([f9fbb86](https://github.com/linrongbin16/fzfx.nvim/commit/f9fbb86798ef331a6bf42213e720cbf4f9706fce))
* windows named pipe ([62a425f](https://github.com/linrongbin16/fzfx.nvim/commit/62a425fb815bfd36bb720c08b55b50d450c306ce))
* yank/put ([#45](https://github.com/linrongbin16/fzfx.nvim/issues/45)) ([b3db7b1](https://github.com/linrongbin16/fzfx.nvim/commit/b3db7b18e0efd32a542f9af7bdd007af65801d4e))


### Bug Fixes

* `new_pipe` not working on Windows arm64 ([#160](https://github.com/linrongbin16/fzfx.nvim/issues/160)) ([6efd376](https://github.com/linrongbin16/fzfx.nvim/commit/6efd376b7d2f79d667fae69bd11d0054f9cdbd2b))
* **actions:** 'bdelete' filename containing whitespaces ([#277](https://github.com/linrongbin16/fzfx.nvim/issues/277)) ([d3faf5a](https://github.com/linrongbin16/fzfx.nvim/commit/d3faf5a24177e57f19fbd056bcb940d614405a2d))
* **actions:** edit rg/grep results that contains whitespaces on filename ([#272](https://github.com/linrongbin16/fzfx.nvim/issues/272)) ([a202d1f](https://github.com/linrongbin16/fzfx.nvim/commit/a202d1f2b850271d5ff680a3ce85fbff42efba85))
* base dir ([3dbf684](https://github.com/linrongbin16/fzfx.nvim/commit/3dbf6840ed66a2489848603781150858bcd7a95a))
* base dir ([cb72633](https://github.com/linrongbin16/fzfx.nvim/commit/cb72633721ae4e1e8addb05834dde24f1a9fa2e1))
* buffer path ([#158](https://github.com/linrongbin16/fzfx.nvim/issues/158)) ([b0dc926](https://github.com/linrongbin16/fzfx.nvim/commit/b0dc926826ae17d172d424f27bf31236686da9e1))
* buffers wrong locked ([#100](https://github.com/linrongbin16/fzfx.nvim/issues/100)) ([760b1eb](https://github.com/linrongbin16/fzfx.nvim/commit/760b1eb0ba5736dcdb2727c74d621bdf19f4c647))
* **buffers:** current buffer, doc ([#98](https://github.com/linrongbin16/fzfx.nvim/issues/98)) ([990d5bf](https://github.com/linrongbin16/fzfx.nvim/commit/990d5bfdf2c4a6979a23655110287fe787924f5d))
* check method support ([#168](https://github.com/linrongbin16/fzfx.nvim/issues/168)) ([5aec401](https://github.com/linrongbin16/fzfx.nvim/commit/5aec401fab4f91d2f6a7234389207e0d6d7f29a9))
* close spawn handler ([#209](https://github.com/linrongbin16/fzfx.nvim/issues/209)) ([0338d6d](https://github.com/linrongbin16/fzfx.nvim/commit/0338d6d45858a07fd9073c8e8e74e826c2b71090))
* compat `vim.split` on v0.5.0, refactor actions ([#184](https://github.com/linrongbin16/fzfx.nvim/issues/184)) ([fafddf5](https://github.com/linrongbin16/fzfx.nvim/commit/fafddf51e47dd3b3a07184d5841506c51ba96a91))
* **config:** use cache.dir instead of hard coding ([#260](https://github.com/linrongbin16/fzfx.nvim/issues/260)) ([6bf24d1](https://github.com/linrongbin16/fzfx.nvim/commit/6bf24d1b81b29c5f37cfebfcf38c83213146d8af))
* depress log ([#78](https://github.com/linrongbin16/fzfx.nvim/issues/78)) ([4e0958d](https://github.com/linrongbin16/fzfx.nvim/commit/4e0958d9d5964ac61463f7770238dda6b221909f))
* directory icon ([#41](https://github.com/linrongbin16/fzfx.nvim/issues/41)) ([3326dd2](https://github.com/linrongbin16/fzfx.nvim/commit/3326dd2ddb6c348ecd7100bcead33e90a126b80b))
* edit files actions on path containing whitespaces for fd/find/eza/ls results ([#258](https://github.com/linrongbin16/fzfx.nvim/issues/258)) ([2a2c1a9](https://github.com/linrongbin16/fzfx.nvim/commit/2a2c1a93f840d58310fcbfbafd6da0643f300778))
* edit grep ([#92](https://github.com/linrongbin16/fzfx.nvim/issues/92)) ([5f2f017](https://github.com/linrongbin16/fzfx.nvim/commit/5f2f017053b88d65e7566e49c587bbc37b3d8af8))
* expand filename to full path ([#244](https://github.com/linrongbin16/fzfx.nvim/issues/244)) ([296aaf9](https://github.com/linrongbin16/fzfx.nvim/commit/296aaf92c24da4c16fd4b317c1794bbe3f2784a1))
* filepath with whitespaces ([#219](https://github.com/linrongbin16/fzfx.nvim/issues/219)) ([4491695](https://github.com/linrongbin16/fzfx.nvim/commit/449169597bbdb70d233a4ccadb2502116bcad0dd))
* func ref ([433e5d3](https://github.com/linrongbin16/fzfx.nvim/commit/433e5d3174ad07885eeb669daf76f81c069deebb))
* fuzzy mode ([598b701](https://github.com/linrongbin16/fzfx.nvim/commit/598b701b82807d273a00b30ea292b002e3950808))
* fuzzy switch ([fcbdbbe](https://github.com/linrongbin16/fzfx.nvim/commit/fcbdbbe34e3b16b9c986ad35b99bd33cfb4c96c9))
* fzf mode query ([4a5d69f](https://github.com/linrongbin16/fzfx.nvim/commit/4a5d69fe776625e49cd23af09ed169844ab3065b))
* fzfx_base ([39aa3a8](https://github.com/linrongbin16/fzfx.nvim/commit/39aa3a870cdd4655425bb54810a2532634439f91))
* git checkout on remote branches ([#153](https://github.com/linrongbin16/fzfx.nvim/issues/153)) ([e04a06d](https://github.com/linrongbin16/fzfx.nvim/commit/e04a06db730acb802ac3a1d987fd10b52107c2d6))
* grep exclude hiddens ([#93](https://github.com/linrongbin16/fzfx.nvim/issues/93)) ([a3ae56b](https://github.com/linrongbin16/fzfx.nvim/commit/a3ae56b73cccdd1c10e7ee72efe2374268e95807))
* header ([f2f6f1c](https://github.com/linrongbin16/fzfx.nvim/commit/f2f6f1c7fa43db5e0b847c69506a4343ecf96875))
* **interactions:** cd into directory containing spaces ([#279](https://github.com/linrongbin16/fzfx.nvim/issues/279)) ([e9bde4a](https://github.com/linrongbin16/fzfx.nvim/commit/e9bde4a870eb4709e4867b5150649553bbaf8f0a))
* live grep override ([#231](https://github.com/linrongbin16/fzfx.nvim/issues/231)) ([baa15e1](https://github.com/linrongbin16/fzfx.nvim/commit/baa15e1d9bc49133c0fb91a5b59262e3c020ff58))
* lock header for ls ([#211](https://github.com/linrongbin16/fzfx.nvim/issues/211)) ([3388d95](https://github.com/linrongbin16/fzfx.nvim/commit/3388d95f6b5324f01db9c65b814b62eb826cd106))
* log echo ([#55](https://github.com/linrongbin16/fzfx.nvim/issues/55)) ([1ed20c9](https://github.com/linrongbin16/fzfx.nvim/commit/1ed20c9204c91358b92a7257ff128343dc303d9b))
* lsp definitions color ([#159](https://github.com/linrongbin16/fzfx.nvim/issues/159)) ([07cca6a](https://github.com/linrongbin16/fzfx.nvim/commit/07cca6a7a11f5cfb74ba274a629db52f16a32c68))
* move plugin to autoload ([6421290](https://github.com/linrongbin16/fzfx.nvim/commit/64212903050dc6486eb4f3a0ffa53e14164daf06))
* no newline ([3641ae4](https://github.com/linrongbin16/fzfx.nvim/commit/3641ae486dba283a73d3b942d149ae7079fa61fe))
* nonumber ([#116](https://github.com/linrongbin16/fzfx.nvim/issues/116)) ([2d32add](https://github.com/linrongbin16/fzfx.nvim/commit/2d32addbf31308d0c90669d9bd34c3d06830768b))
* NotifyLevels npe ([#195](https://github.com/linrongbin16/fzfx.nvim/issues/195)) ([23ca90d](https://github.com/linrongbin16/fzfx.nvim/commit/23ca90dda56764ca5227430f8734220794d6582f))
* only setpos for last line ([#27](https://github.com/linrongbin16/fzfx.nvim/issues/27)) ([7ae74d4](https://github.com/linrongbin16/fzfx.nvim/commit/7ae74d4f25e11b8d5e36b39417e9f2847c69828f))
* packer.nvim ([#111](https://github.com/linrongbin16/fzfx.nvim/issues/111)) ([a05793a](https://github.com/linrongbin16/fzfx.nvim/commit/a05793a2358471cebb247d402afbe5c825a60d4a))
* path containing space ([#250](https://github.com/linrongbin16/fzfx.nvim/issues/250)) ([8fd2bc6](https://github.com/linrongbin16/fzfx.nvim/commit/8fd2bc6c411b863a105c92eee727ffe8447741ba))
* press ESC on fzf exit ([#59](https://github.com/linrongbin16/fzfx.nvim/issues/59)) ([8c419e5](https://github.com/linrongbin16/fzfx.nvim/commit/8c419e56058078cc7b6d825299c6667e6e21dfc5))
* prompt extra space ([#9](https://github.com/linrongbin16/fzfx.nvim/issues/9)) ([a8195f7](https://github.com/linrongbin16/fzfx.nvim/commit/a8195f7028f63270b807e20e84d620c8346c6eae))
* **push:** revert direct push to main branch ([9eac0c0](https://github.com/linrongbin16/fzfx.nvim/commit/9eac0c072ca161a0d58cf50e7aed6090486c7e9a))
* relative cursor window ([#176](https://github.com/linrongbin16/fzfx.nvim/issues/176)) ([55b35ca](https://github.com/linrongbin16/fzfx.nvim/commit/55b35caff324892c6ad507895e389bb42d3adb0f))
* relative window position ([#174](https://github.com/linrongbin16/fzfx.nvim/issues/174)) ([8cfb9cf](https://github.com/linrongbin16/fzfx.nvim/commit/8cfb9cfa5e9fb9f6d4f79d4359768a24ba8965e5))
* restore previous window on exit ([#54](https://github.com/linrongbin16/fzfx.nvim/issues/54)) ([fcc3f78](https://github.com/linrongbin16/fzfx.nvim/commit/fcc3f78f32c92441a3699e0d7b1dcab0445ecbe0))
* rtrim ([#161](https://github.com/linrongbin16/fzfx.nvim/issues/161)) ([8a6d6b7](https://github.com/linrongbin16/fzfx.nvim/commit/8a6d6b7d72442d46a39fa2c1306d44480f60fa19))
* set `row=0,col=0` for bang ([#53](https://github.com/linrongbin16/fzfx.nvim/issues/53)) ([bddfca3](https://github.com/linrongbin16/fzfx.nvim/commit/bddfca3911866e25977ba98d1fc4d3ce53379fe5))
* set spell=false ([#114](https://github.com/linrongbin16/fzfx.nvim/issues/114)) ([2e3a32f](https://github.com/linrongbin16/fzfx.nvim/commit/2e3a32f14a538e53c3775a24548f3a118b7288c1))
* shell opts for Windows ([#82](https://github.com/linrongbin16/fzfx.nvim/issues/82)) ([2bd1e56](https://github.com/linrongbin16/fzfx.nvim/commit/2bd1e56916bd2d04af35227f7494ad0a0bf0c0e6))
* shellslash ([#21](https://github.com/linrongbin16/fzfx.nvim/issues/21)) ([e1493ae](https://github.com/linrongbin16/fzfx.nvim/commit/e1493ae6c5c1cb4dbc598522591de0afe5cb529b))
* shellslash only for Windows ([#86](https://github.com/linrongbin16/fzfx.nvim/issues/86)) ([df6bfe0](https://github.com/linrongbin16/fzfx.nvim/commit/df6bfe0733d93d09f6e4963fc97b93fd5b98b792))
* stop reading on spawn ([#227](https://github.com/linrongbin16/fzfx.nvim/issues/227)) ([daf2731](https://github.com/linrongbin16/fzfx.nvim/commit/daf2731ea832efd25771a05e9870440189dfca7e))
* stridx ([#132](https://github.com/linrongbin16/fzfx.nvim/issues/132)) ([1cfe8c9](https://github.com/linrongbin16/fzfx.nvim/commit/1cfe8c9a29fe938fadc599e4249322fa9d2e7efa))
* trim ([0b45d2e](https://github.com/linrongbin16/fzfx.nvim/commit/0b45d2ed5c4c9f809fc2abedc73be26c55e16d81))
* trim query & rewrite popup and launch ([#29](https://github.com/linrongbin16/fzfx.nvim/issues/29)) ([107b07f](https://github.com/linrongbin16/fzfx.nvim/commit/107b07f9021320be7f7b6bdca919910b99b66799))
* **utils:** transform windows newline '\r\n' & close all 3 handles ([#288](https://github.com/linrongbin16/fzfx.nvim/issues/288)) ([511a919](https://github.com/linrongbin16/fzfx.nvim/commit/511a919a68e0d6d4e3ece21caa6111458d230048))
* visual select ([11e9119](https://github.com/linrongbin16/fzfx.nvim/commit/11e91199ca82482dd418e47776dbe77098dfeb8c))
* visual select ([3a5dd76](https://github.com/linrongbin16/fzfx.nvim/commit/3a5dd769333d69c10eef090b8e83018d16b06865))
* windows git log pretty ([#77](https://github.com/linrongbin16/fzfx.nvim/issues/77)) ([d2ed804](https://github.com/linrongbin16/fzfx.nvim/commit/d2ed804bb58e6fd3ec4c9d6d2cce98fb4ac019f2))
* windows named pipe ([#50](https://github.com/linrongbin16/fzfx.nvim/issues/50)) ([099e59e](https://github.com/linrongbin16/fzfx.nvim/commit/099e59e17460580acb162d70780624ac8b786bcc))


### Performance Improvements

* async file io with fs_read ([#135](https://github.com/linrongbin16/fzfx.nvim/issues/135)) ([aabf6c8](https://github.com/linrongbin16/fzfx.nvim/commit/aabf6c88eccf1d0964eb29c5c1c6eb3ee4c3290c))
* async io ([#133](https://github.com/linrongbin16/fzfx.nvim/issues/133)) ([d66d7b3](https://github.com/linrongbin16/fzfx.nvim/commit/d66d7b3636951d328dc51eac1be24b1a3552487a))
* backup ([3e7a199](https://github.com/linrongbin16/fzfx.nvim/commit/3e7a199f0f37b3ebc5906d66420e373a2ce9c2f5))
* bind toggle ([#71](https://github.com/linrongbin16/fzfx.nvim/issues/71)) ([0da7adf](https://github.com/linrongbin16/fzfx.nvim/commit/0da7adf6c343cde4f19ed2a30de0d596f8841120))
* **cmd:** migrate from jobstart to uv.spawn ([#285](https://github.com/linrongbin16/fzfx.nvim/issues/285)) ([fd570b0](https://github.com/linrongbin16/fzfx.nvim/commit/fd570b097f60777bb00d767d1109639fefb37aaa))
* command_list previewer ([#182](https://github.com/linrongbin16/fzfx.nvim/issues/182)) ([78ae874](https://github.com/linrongbin16/fzfx.nvim/commit/78ae874c51a6405e894160cd500b4ac5d2511d14))
* comments ([#28](https://github.com/linrongbin16/fzfx.nvim/issues/28)) ([13f05c6](https://github.com/linrongbin16/fzfx.nvim/commit/13f05c6cac52c9f55a5085633aaef3af22dd2065))
* detect batcat, fdfind first ([#13](https://github.com/linrongbin16/fzfx.nvim/issues/13)) ([ec2a807](https://github.com/linrongbin16/fzfx.nvim/commit/ec2a807a352b4d52e5fcd2cdb7b1f892110435c5))
* don't normalize path for Windows ([#44](https://github.com/linrongbin16/fzfx.nvim/issues/44)) ([9261d4a](https://github.com/linrongbin16/fzfx.nvim/commit/9261d4ab3bf01c71994b9880a242811df1983e4d))
* dynamic passing ([#84](https://github.com/linrongbin16/fzfx.nvim/issues/84)) ([711e7c9](https://github.com/linrongbin16/fzfx.nvim/commit/711e7c9f3dc1a48f66e0d02a8db90dc27b6955ce))
* file explorer & test ([#215](https://github.com/linrongbin16/fzfx.nvim/issues/215)) ([0468619](https://github.com/linrongbin16/fzfx.nvim/commit/046861978a47cd966f6bc918667fb811d1c90990))
* fzf default command ([#11](https://github.com/linrongbin16/fzfx.nvim/issues/11)) ([502df8e](https://github.com/linrongbin16/fzfx.nvim/commit/502df8eb125af580541da8fed701a6e8e95a5fa2))
* ggrep,gfind ([#94](https://github.com/linrongbin16/fzfx.nvim/issues/94)) ([dd510f8](https://github.com/linrongbin16/fzfx.nvim/commit/dd510f89d630ee1ba872a6711b8484ba13d41e27))
* git branches ([#75](https://github.com/linrongbin16/fzfx.nvim/issues/75)) ([667a94b](https://github.com/linrongbin16/fzfx.nvim/commit/667a94b38426632bb8ec8ca8cb1f587a8e4222c5))
* log ([#109](https://github.com/linrongbin16/fzfx.nvim/issues/109)) ([b6a7857](https://github.com/linrongbin16/fzfx.nvim/commit/b6a7857d88aa50b61a1324f9326006b608e8c9b5))
* lsp definitions ([#154](https://github.com/linrongbin16/fzfx.nvim/issues/154)) ([3418aef](https://github.com/linrongbin16/fzfx.nvim/commit/3418aefad1bff78494e67ac54f3644cf1269b1d8))
* migrate buffers ([#113](https://github.com/linrongbin16/fzfx.nvim/issues/113)) ([4da588b](https://github.com/linrongbin16/fzfx.nvim/commit/4da588bb0a759232698117c1be69ebf2f7f84232))
* move nvim,fzf executable check before open win ([#25](https://github.com/linrongbin16/fzfx.nvim/issues/25)) ([da6c446](https://github.com/linrongbin16/fzfx.nvim/commit/da6c446bf3eebfbb5d619833ed3c419a60daa5dd))
* path separator ([#51](https://github.com/linrongbin16/fzfx.nvim/issues/51)) ([3f783fd](https://github.com/linrongbin16/fzfx.nvim/commit/3f783fdccf8b974bed07e2e20520a53c27c98703))
* preview up/down keys ([#73](https://github.com/linrongbin16/fzfx.nvim/issues/73)) ([b9d115a](https://github.com/linrongbin16/fzfx.nvim/commit/b9d115aafb652b39c409e237a85b2c6469827c07))
* provider command ([c92b150](https://github.com/linrongbin16/fzfx.nvim/commit/c92b1509be7fcebdfdc19c1732b8fa20ef4505b0))
* provider switch ([#96](https://github.com/linrongbin16/fzfx.nvim/issues/96)) ([c36e378](https://github.com/linrongbin16/fzfx.nvim/commit/c36e378f8f95a099f16dcdca52cb5f1acf0812dd))
* reduce CommandConfig ([#251](https://github.com/linrongbin16/fzfx.nvim/issues/251)) ([ac78df6](https://github.com/linrongbin16/fzfx.nvim/commit/ac78df62c0e8d5fa1d2c2a11492827b2ca3f1b7d))
* reduce ESC keys & better multi keys ([#61](https://github.com/linrongbin16/fzfx.nvim/issues/61)) ([e159895](https://github.com/linrongbin16/fzfx.nvim/commit/e159895e4eab5c39d7f6e391f3b048fce85a8136))
* remove fzf/rg mode ([5bff616](https://github.com/linrongbin16/fzfx.nvim/commit/5bff6163c778ae308503bf5bdc64cd0c58d86068))
* remove internal env var ([e3b2e49](https://github.com/linrongbin16/fzfx.nvim/commit/e3b2e49cf9f7c8765cf55a01df2633188079881b))
* remove unused import ([33703c9](https://github.com/linrongbin16/fzfx.nvim/commit/33703c965c2a544ce8adb138650b0e1cafcd31de))
* **schema:** deprecate 'ProviderConfig' & 'PreviewerConfig' ([#268](https://github.com/linrongbin16/fzfx.nvim/issues/268)) ([3c2e32c](https://github.com/linrongbin16/fzfx.nvim/commit/3c2e32c0a97614a34d80b0d0392a0d377b3ead84))
* **schema:** deprecate note on 'PreviewerConfig' ([#270](https://github.com/linrongbin16/fzfx.nvim/issues/270)) ([6552efe](https://github.com/linrongbin16/fzfx.nvim/commit/6552efe8253a2b5ae467efc61df811f60a88141c))
* setup legacy ([ebbed25](https://github.com/linrongbin16/fzfx.nvim/commit/ebbed25cddcae73383c0239407bf9c90371916c7))
* shellslash ([#91](https://github.com/linrongbin16/fzfx.nvim/issues/91)) ([2663cd4](https://github.com/linrongbin16/fzfx.nvim/commit/2663cd4d4ec4778dc55b2271838b2ec7454a1c3a))
* socket server ([#39](https://github.com/linrongbin16/fzfx.nvim/issues/39)) ([5613c56](https://github.com/linrongbin16/fzfx.nvim/commit/5613c5662870f27fe7ef45b9a955f0402dd3dff8))
* use 'buffer' instead 'edit' for buffers ([#67](https://github.com/linrongbin16/fzfx.nvim/issues/67)) ([4e74d79](https://github.com/linrongbin16/fzfx.nvim/commit/4e74d79108155a864723e131d2f9d9ff2f5cb9b0))
* use uv spawn ([#181](https://github.com/linrongbin16/fzfx.nvim/issues/181)) ([7fe84c6](https://github.com/linrongbin16/fzfx.nvim/commit/7fe84c606ed5847108035f3dded7745ad61f1450))
* uv.spawn ([#128](https://github.com/linrongbin16/fzfx.nvim/issues/128)) ([5d54505](https://github.com/linrongbin16/fzfx.nvim/commit/5d54505d9f06fe1fada283024ce38d7213f3761e))
* win_opts row/col ([#23](https://github.com/linrongbin16/fzfx.nvim/issues/23)) ([f035673](https://github.com/linrongbin16/fzfx.nvim/commit/f0356732db5801b424234223d4f306a25db0d35c))


### Reverts

* lower minimal required version v0.6 ([#245](https://github.com/linrongbin16/fzfx.nvim/issues/245)) ([89eb334](https://github.com/linrongbin16/fzfx.nvim/commit/89eb334df7920a75386b659cd007a3ec5ea6fe13))

## [1.3.0](https://github.com/linrongbin16/fzfx.nvim/compare/v1.2.0...v1.3.0) (2023-10-23)


### Features

* **logs:** split shell command provider/previewer logs ([#303](https://github.com/linrongbin16/fzfx.nvim/issues/303)) ([5ed1bcd](https://github.com/linrongbin16/fzfx.nvim/commit/5ed1bcd6728000c7ec692e99603ae69ab82a2edd))

## [1.2.0](https://github.com/linrongbin16/fzfx.nvim/compare/v1.1.1...v1.2.0) (2023-10-20)


### Features

* **actions:** add 'setqflist' ([#290](https://github.com/linrongbin16/fzfx.nvim/issues/290)) ([1284639](https://github.com/linrongbin16/fzfx.nvim/commit/1284639770c907fe7d850c5b05ddeb74a8db552e))
* **commands:** add 'FzfxCommands' to search vim commands ([#287](https://github.com/linrongbin16/fzfx.nvim/issues/287)) ([997821b](https://github.com/linrongbin16/fzfx.nvim/commit/997821ba69b6587ba392e3f5c46cc7dd196f62da))


### Bug Fixes

* **utils:** transform windows newline '\r\n' & close all 3 handles ([#288](https://github.com/linrongbin16/fzfx.nvim/issues/288)) ([511a919](https://github.com/linrongbin16/fzfx.nvim/commit/511a919a68e0d6d4e3ece21caa6111458d230048))


### Performance Improvements

* **cmd:** migrate from jobstart to uv.spawn ([#285](https://github.com/linrongbin16/fzfx.nvim/issues/285)) ([fd570b0](https://github.com/linrongbin16/fzfx.nvim/commit/fd570b097f60777bb00d767d1109639fefb37aaa))

## [1.1.1](https://github.com/linrongbin16/fzfx.nvim/compare/v1.1.0...v1.1.1) (2023-10-11)


### Bug Fixes

* **actions:** 'bdelete' filename containing whitespaces ([#277](https://github.com/linrongbin16/fzfx.nvim/issues/277)) ([d3faf5a](https://github.com/linrongbin16/fzfx.nvim/commit/d3faf5a24177e57f19fbd056bcb940d614405a2d))
* **interactions:** cd into directory containing spaces ([#279](https://github.com/linrongbin16/fzfx.nvim/issues/279)) ([e9bde4a](https://github.com/linrongbin16/fzfx.nvim/commit/e9bde4a870eb4709e4867b5150649553bbaf8f0a))

## [1.1.0](https://github.com/linrongbin16/fzfx.nvim/compare/v1.0.2...v1.1.0) (2023-10-11)


### Features

* **schema:** add 'PreviewerConfig' detection ([#266](https://github.com/linrongbin16/fzfx.nvim/issues/266)) ([2bdcef7](https://github.com/linrongbin16/fzfx.nvim/commit/2bdcef7f82a55327851b6d3ecb5e48c53f08a691))


### Bug Fixes

* **actions:** edit rg/grep results that contains whitespaces on filename ([#272](https://github.com/linrongbin16/fzfx.nvim/issues/272)) ([a202d1f](https://github.com/linrongbin16/fzfx.nvim/commit/a202d1f2b850271d5ff680a3ce85fbff42efba85))
* **push:** revert direct push to main branch ([9eac0c0](https://github.com/linrongbin16/fzfx.nvim/commit/9eac0c072ca161a0d58cf50e7aed6090486c7e9a))


### Performance Improvements

* **schema:** deprecate 'ProviderConfig' & 'PreviewerConfig' ([#268](https://github.com/linrongbin16/fzfx.nvim/issues/268)) ([3c2e32c](https://github.com/linrongbin16/fzfx.nvim/commit/3c2e32c0a97614a34d80b0d0392a0d377b3ead84))
* **schema:** deprecate note on 'PreviewerConfig' ([#270](https://github.com/linrongbin16/fzfx.nvim/issues/270)) ([6552efe](https://github.com/linrongbin16/fzfx.nvim/commit/6552efe8253a2b5ae467efc61df811f60a88141c))

## [1.0.2](https://github.com/linrongbin16/fzfx.nvim/compare/v1.0.1...v1.0.2) (2023-10-09)


### Bug Fixes

* **config:** use cache.dir instead of hard coding ([#260](https://github.com/linrongbin16/fzfx.nvim/issues/260)) ([6bf24d1](https://github.com/linrongbin16/fzfx.nvim/commit/6bf24d1b81b29c5f37cfebfcf38c83213146d8af))

## [1.0.1](https://github.com/linrongbin16/fzfx.nvim/compare/v1.0.0...v1.0.1) (2023-10-09)


### Bug Fixes

* edit files actions on path containing whitespaces for fd/find/eza/ls results ([#258](https://github.com/linrongbin16/fzfx.nvim/issues/258)) ([2a2c1a9](https://github.com/linrongbin16/fzfx.nvim/commit/2a2c1a93f840d58310fcbfbafd6da0643f300778))

## 1.0.0 (2023-10-09)


### Features

* add parse_file/parse_grep line helpers ([#222](https://github.com/linrongbin16/fzfx.nvim/issues/222)) ([5a503da](https://github.com/linrongbin16/fzfx.nvim/commit/5a503da25aec9a07ebde12dedae03e71056445c1))
* add variants for file explorer ([#213](https://github.com/linrongbin16/fzfx.nvim/issues/213)) ([289b8b8](https://github.com/linrongbin16/fzfx.nvim/commit/289b8b80c1348e604f141551a1c4877aecc5315f))
* bg color ^& fix exec ([#22](https://github.com/linrongbin16/fzfx.nvim/issues/22)) ([1a86b34](https://github.com/linrongbin16/fzfx.nvim/commit/1a86b34afeaeca879f05d4f7ea5ef4698f0044b6))
* buffers ([#57](https://github.com/linrongbin16/fzfx.nvim/issues/57)) ([bd1e0dc](https://github.com/linrongbin16/fzfx.nvim/commit/bd1e0dc2432f10a7947c1718ea3cb9ce9d600f64))
* color ([5537884](https://github.com/linrongbin16/fzfx.nvim/commit/5537884769b20f1ddab63c7885323e82ea31ef0b))
* colors ([#62](https://github.com/linrongbin16/fzfx.nvim/issues/62)) ([72b2437](https://github.com/linrongbin16/fzfx.nvim/commit/72b243747f6c0418f5c6e45eba79450b1f224815))
* debug command ([b0ac732](https://github.com/linrongbin16/fzfx.nvim/commit/b0ac73244ac4ecf78671e29bffd07c538a86b3b6))
* diagnostics ([#124](https://github.com/linrongbin16/fzfx.nvim/issues/124)) ([a610762](https://github.com/linrongbin16/fzfx.nvim/commit/a610762e579eb31fdabb6f837f788cb7e3e9fc3e))
* file explorer (ls) ([#210](https://github.com/linrongbin16/fzfx.nvim/issues/210)) ([212c789](https://github.com/linrongbin16/fzfx.nvim/commit/212c789dc424e97894eef6209bb18f829b0191d4))
* files ([bf42213](https://github.com/linrongbin16/fzfx.nvim/commit/bf42213be415d19123a5a6f6ef4412756755c3b3))
* files ([362065c](https://github.com/linrongbin16/fzfx.nvim/commit/362065c6a650c88fb737bdd06807fb9b61d83244))
* git blame & general ([#102](https://github.com/linrongbin16/fzfx.nvim/issues/102)) ([21f5a62](https://github.com/linrongbin16/fzfx.nvim/commit/21f5a622494143ad270c430d72ad5e4c37996df5))
* git branches ([#68](https://github.com/linrongbin16/fzfx.nvim/issues/68)) ([7f055d5](https://github.com/linrongbin16/fzfx.nvim/commit/7f055d5549a01ffac8f2389ccf7a9315d2f44442))
* git commits ([#97](https://github.com/linrongbin16/fzfx.nvim/issues/97)) ([ded9623](https://github.com/linrongbin16/fzfx.nvim/commit/ded9623463864f8d0d07d08ac83e858a32d7ba10))
* git files ([#64](https://github.com/linrongbin16/fzfx.nvim/issues/64)) ([d83a857](https://github.com/linrongbin16/fzfx.nvim/commit/d83a857d619292a36ee736b88971a86acc2b0680))
* handle whitespaces on path ([#20](https://github.com/linrongbin16/fzfx.nvim/issues/20)) ([f05107b](https://github.com/linrongbin16/fzfx.nvim/commit/f05107b10523edfccb49403007d2b7efab8f487c))
* icon!!! ([#31](https://github.com/linrongbin16/fzfx.nvim/issues/31)) ([668a820](https://github.com/linrongbin16/fzfx.nvim/commit/668a82042e972427be541dfde5adad3d5173ed12))
* improve cwd ([#214](https://github.com/linrongbin16/fzfx.nvim/issues/214)) ([cd6042f](https://github.com/linrongbin16/fzfx.nvim/commit/cd6042fda05841a7d00321cae7323754d7bccba1))
* list_index ([#221](https://github.com/linrongbin16/fzfx.nvim/issues/221)) ([cb61fd5](https://github.com/linrongbin16/fzfx.nvim/commit/cb61fd5524a73f3cf8f871d60222c0119ae91498))
* live grep ([67c2776](https://github.com/linrongbin16/fzfx.nvim/commit/67c2776b6b3be654856db8b5537279368c9baf90))
* live grep ([#7](https://github.com/linrongbin16/fzfx.nvim/issues/7)) ([fda0337](https://github.com/linrongbin16/fzfx.nvim/commit/fda0337ec5189021ed6a5e023b75099bc4be1f91))
* log ([ffe368b](https://github.com/linrongbin16/fzfx.nvim/commit/ffe368ba848c8ae95cc8b1af967bc2443c309222))
* lsp color ([#166](https://github.com/linrongbin16/fzfx.nvim/issues/166)) ([690bf7a](https://github.com/linrongbin16/fzfx.nvim/commit/690bf7a42099c53a34534a79d10aba1083d59892))
* lsp commands ([#170](https://github.com/linrongbin16/fzfx.nvim/issues/170)) ([7589a88](https://github.com/linrongbin16/fzfx.nvim/commit/7589a8885b088a17fdeef040d0c768c10298a300))
* lsp definitions ([#150](https://github.com/linrongbin16/fzfx.nvim/issues/150)) ([10f5bfc](https://github.com/linrongbin16/fzfx.nvim/commit/10f5bfc3179729a579086fe67c3aa8ff29d66b82))
* lsp diagnostics file path color ([#125](https://github.com/linrongbin16/fzfx.nvim/issues/125)) ([f24e578](https://github.com/linrongbin16/fzfx.nvim/commit/f24e578d21809b7bed4fc0f92cb4fb922fbc1777))
* passing rg raw optoins ([c36bf8a](https://github.com/linrongbin16/fzfx.nvim/commit/c36bf8aff1bc0e425c6bd0853e3809e245a9ecca))
* please-release ([#254](https://github.com/linrongbin16/fzfx.nvim/issues/254)) ([a1d2da4](https://github.com/linrongbin16/fzfx.nvim/commit/a1d2da467596f679da0565ac7223324f23e10362))
* plugin home dir ([a55718f](https://github.com/linrongbin16/fzfx.nvim/commit/a55718f81a346de3c095174630e828cbb8a84b76))
* PR template ([#247](https://github.com/linrongbin16/fzfx.nvim/issues/247)) ([0843fb5](https://github.com/linrongbin16/fzfx.nvim/commit/0843fb56554237eeb54e1486a6e249be8796e153))
* relative window ([#172](https://github.com/linrongbin16/fzfx.nvim/issues/172)) ([01caa8b](https://github.com/linrongbin16/fzfx.nvim/commit/01caa8bc6c0b5689b79773112ad79b99adc0527a))
* restore query ([9c1ec44](https://github.com/linrongbin16/fzfx.nvim/commit/9c1ec443e7f2b9f3530eee4529f7c52a9391cefc))
* rgb color codes ([#165](https://github.com/linrongbin16/fzfx.nvim/issues/165)) ([835ca8a](https://github.com/linrongbin16/fzfx.nvim/commit/835ca8acbb7227997621e8f44e5c56702d7633a7))
* row/col win_opts ([#12](https://github.com/linrongbin16/fzfx.nvim/issues/12)) ([bd24d0a](https://github.com/linrongbin16/fzfx.nvim/commit/bd24d0a107330648ced401acdf30c02bc438d64f))
* switch unrestricted mode ([5500bb1](https://github.com/linrongbin16/fzfx.nvim/commit/5500bb176a789f88a01c3cca066c0eaa3abe4a69))
* throw error ([c4eef09](https://github.com/linrongbin16/fzfx.nvim/commit/c4eef090f92bf3f5c548f92c63e386416567cf65))
* utils ([4ab3a4f](https://github.com/linrongbin16/fzfx.nvim/commit/4ab3a4f2ad9e950f962cab727ad91cc207b3ff33))
* visual/cword ([f9fbb86](https://github.com/linrongbin16/fzfx.nvim/commit/f9fbb86798ef331a6bf42213e720cbf4f9706fce))
* windows named pipe ([62a425f](https://github.com/linrongbin16/fzfx.nvim/commit/62a425fb815bfd36bb720c08b55b50d450c306ce))
* yank/put ([#45](https://github.com/linrongbin16/fzfx.nvim/issues/45)) ([b3db7b1](https://github.com/linrongbin16/fzfx.nvim/commit/b3db7b18e0efd32a542f9af7bdd007af65801d4e))


### Bug Fixes

* `new_pipe` not working on Windows arm64 ([#160](https://github.com/linrongbin16/fzfx.nvim/issues/160)) ([6efd376](https://github.com/linrongbin16/fzfx.nvim/commit/6efd376b7d2f79d667fae69bd11d0054f9cdbd2b))
* base dir ([3dbf684](https://github.com/linrongbin16/fzfx.nvim/commit/3dbf6840ed66a2489848603781150858bcd7a95a))
* base dir ([cb72633](https://github.com/linrongbin16/fzfx.nvim/commit/cb72633721ae4e1e8addb05834dde24f1a9fa2e1))
* buffer path ([#158](https://github.com/linrongbin16/fzfx.nvim/issues/158)) ([b0dc926](https://github.com/linrongbin16/fzfx.nvim/commit/b0dc926826ae17d172d424f27bf31236686da9e1))
* buffers wrong locked ([#100](https://github.com/linrongbin16/fzfx.nvim/issues/100)) ([760b1eb](https://github.com/linrongbin16/fzfx.nvim/commit/760b1eb0ba5736dcdb2727c74d621bdf19f4c647))
* **buffers:** current buffer, doc ([#98](https://github.com/linrongbin16/fzfx.nvim/issues/98)) ([990d5bf](https://github.com/linrongbin16/fzfx.nvim/commit/990d5bfdf2c4a6979a23655110287fe787924f5d))
* check method support ([#168](https://github.com/linrongbin16/fzfx.nvim/issues/168)) ([5aec401](https://github.com/linrongbin16/fzfx.nvim/commit/5aec401fab4f91d2f6a7234389207e0d6d7f29a9))
* close spawn handler ([#209](https://github.com/linrongbin16/fzfx.nvim/issues/209)) ([0338d6d](https://github.com/linrongbin16/fzfx.nvim/commit/0338d6d45858a07fd9073c8e8e74e826c2b71090))
* compat `vim.split` on v0.5.0, refactor actions ([#184](https://github.com/linrongbin16/fzfx.nvim/issues/184)) ([fafddf5](https://github.com/linrongbin16/fzfx.nvim/commit/fafddf51e47dd3b3a07184d5841506c51ba96a91))
* depress log ([#78](https://github.com/linrongbin16/fzfx.nvim/issues/78)) ([4e0958d](https://github.com/linrongbin16/fzfx.nvim/commit/4e0958d9d5964ac61463f7770238dda6b221909f))
* directory icon ([#41](https://github.com/linrongbin16/fzfx.nvim/issues/41)) ([3326dd2](https://github.com/linrongbin16/fzfx.nvim/commit/3326dd2ddb6c348ecd7100bcead33e90a126b80b))
* edit grep ([#92](https://github.com/linrongbin16/fzfx.nvim/issues/92)) ([5f2f017](https://github.com/linrongbin16/fzfx.nvim/commit/5f2f017053b88d65e7566e49c587bbc37b3d8af8))
* expand filename to full path ([#244](https://github.com/linrongbin16/fzfx.nvim/issues/244)) ([296aaf9](https://github.com/linrongbin16/fzfx.nvim/commit/296aaf92c24da4c16fd4b317c1794bbe3f2784a1))
* filepath with whitespaces ([#219](https://github.com/linrongbin16/fzfx.nvim/issues/219)) ([4491695](https://github.com/linrongbin16/fzfx.nvim/commit/449169597bbdb70d233a4ccadb2502116bcad0dd))
* func ref ([433e5d3](https://github.com/linrongbin16/fzfx.nvim/commit/433e5d3174ad07885eeb669daf76f81c069deebb))
* fuzzy mode ([598b701](https://github.com/linrongbin16/fzfx.nvim/commit/598b701b82807d273a00b30ea292b002e3950808))
* fuzzy switch ([fcbdbbe](https://github.com/linrongbin16/fzfx.nvim/commit/fcbdbbe34e3b16b9c986ad35b99bd33cfb4c96c9))
* fzf mode query ([4a5d69f](https://github.com/linrongbin16/fzfx.nvim/commit/4a5d69fe776625e49cd23af09ed169844ab3065b))
* fzfx_base ([39aa3a8](https://github.com/linrongbin16/fzfx.nvim/commit/39aa3a870cdd4655425bb54810a2532634439f91))
* git checkout on remote branches ([#153](https://github.com/linrongbin16/fzfx.nvim/issues/153)) ([e04a06d](https://github.com/linrongbin16/fzfx.nvim/commit/e04a06db730acb802ac3a1d987fd10b52107c2d6))
* grep exclude hiddens ([#93](https://github.com/linrongbin16/fzfx.nvim/issues/93)) ([a3ae56b](https://github.com/linrongbin16/fzfx.nvim/commit/a3ae56b73cccdd1c10e7ee72efe2374268e95807))
* header ([f2f6f1c](https://github.com/linrongbin16/fzfx.nvim/commit/f2f6f1c7fa43db5e0b847c69506a4343ecf96875))
* live grep override ([#231](https://github.com/linrongbin16/fzfx.nvim/issues/231)) ([baa15e1](https://github.com/linrongbin16/fzfx.nvim/commit/baa15e1d9bc49133c0fb91a5b59262e3c020ff58))
* lock header for ls ([#211](https://github.com/linrongbin16/fzfx.nvim/issues/211)) ([3388d95](https://github.com/linrongbin16/fzfx.nvim/commit/3388d95f6b5324f01db9c65b814b62eb826cd106))
* log echo ([#55](https://github.com/linrongbin16/fzfx.nvim/issues/55)) ([1ed20c9](https://github.com/linrongbin16/fzfx.nvim/commit/1ed20c9204c91358b92a7257ff128343dc303d9b))
* lsp definitions color ([#159](https://github.com/linrongbin16/fzfx.nvim/issues/159)) ([07cca6a](https://github.com/linrongbin16/fzfx.nvim/commit/07cca6a7a11f5cfb74ba274a629db52f16a32c68))
* move plugin to autoload ([6421290](https://github.com/linrongbin16/fzfx.nvim/commit/64212903050dc6486eb4f3a0ffa53e14164daf06))
* no newline ([3641ae4](https://github.com/linrongbin16/fzfx.nvim/commit/3641ae486dba283a73d3b942d149ae7079fa61fe))
* nonumber ([#116](https://github.com/linrongbin16/fzfx.nvim/issues/116)) ([2d32add](https://github.com/linrongbin16/fzfx.nvim/commit/2d32addbf31308d0c90669d9bd34c3d06830768b))
* NotifyLevels npe ([#195](https://github.com/linrongbin16/fzfx.nvim/issues/195)) ([23ca90d](https://github.com/linrongbin16/fzfx.nvim/commit/23ca90dda56764ca5227430f8734220794d6582f))
* only setpos for last line ([#27](https://github.com/linrongbin16/fzfx.nvim/issues/27)) ([7ae74d4](https://github.com/linrongbin16/fzfx.nvim/commit/7ae74d4f25e11b8d5e36b39417e9f2847c69828f))
* packer.nvim ([#111](https://github.com/linrongbin16/fzfx.nvim/issues/111)) ([a05793a](https://github.com/linrongbin16/fzfx.nvim/commit/a05793a2358471cebb247d402afbe5c825a60d4a))
* path containing space ([#250](https://github.com/linrongbin16/fzfx.nvim/issues/250)) ([8fd2bc6](https://github.com/linrongbin16/fzfx.nvim/commit/8fd2bc6c411b863a105c92eee727ffe8447741ba))
* press ESC on fzf exit ([#59](https://github.com/linrongbin16/fzfx.nvim/issues/59)) ([8c419e5](https://github.com/linrongbin16/fzfx.nvim/commit/8c419e56058078cc7b6d825299c6667e6e21dfc5))
* prompt extra space ([#9](https://github.com/linrongbin16/fzfx.nvim/issues/9)) ([a8195f7](https://github.com/linrongbin16/fzfx.nvim/commit/a8195f7028f63270b807e20e84d620c8346c6eae))
* relative cursor window ([#176](https://github.com/linrongbin16/fzfx.nvim/issues/176)) ([55b35ca](https://github.com/linrongbin16/fzfx.nvim/commit/55b35caff324892c6ad507895e389bb42d3adb0f))
* relative window position ([#174](https://github.com/linrongbin16/fzfx.nvim/issues/174)) ([8cfb9cf](https://github.com/linrongbin16/fzfx.nvim/commit/8cfb9cfa5e9fb9f6d4f79d4359768a24ba8965e5))
* restore previous window on exit ([#54](https://github.com/linrongbin16/fzfx.nvim/issues/54)) ([fcc3f78](https://github.com/linrongbin16/fzfx.nvim/commit/fcc3f78f32c92441a3699e0d7b1dcab0445ecbe0))
* rtrim ([#161](https://github.com/linrongbin16/fzfx.nvim/issues/161)) ([8a6d6b7](https://github.com/linrongbin16/fzfx.nvim/commit/8a6d6b7d72442d46a39fa2c1306d44480f60fa19))
* set `row=0,col=0` for bang ([#53](https://github.com/linrongbin16/fzfx.nvim/issues/53)) ([bddfca3](https://github.com/linrongbin16/fzfx.nvim/commit/bddfca3911866e25977ba98d1fc4d3ce53379fe5))
* set spell=false ([#114](https://github.com/linrongbin16/fzfx.nvim/issues/114)) ([2e3a32f](https://github.com/linrongbin16/fzfx.nvim/commit/2e3a32f14a538e53c3775a24548f3a118b7288c1))
* shell opts for Windows ([#82](https://github.com/linrongbin16/fzfx.nvim/issues/82)) ([2bd1e56](https://github.com/linrongbin16/fzfx.nvim/commit/2bd1e56916bd2d04af35227f7494ad0a0bf0c0e6))
* shellslash ([#21](https://github.com/linrongbin16/fzfx.nvim/issues/21)) ([e1493ae](https://github.com/linrongbin16/fzfx.nvim/commit/e1493ae6c5c1cb4dbc598522591de0afe5cb529b))
* shellslash only for Windows ([#86](https://github.com/linrongbin16/fzfx.nvim/issues/86)) ([df6bfe0](https://github.com/linrongbin16/fzfx.nvim/commit/df6bfe0733d93d09f6e4963fc97b93fd5b98b792))
* stop reading on spawn ([#227](https://github.com/linrongbin16/fzfx.nvim/issues/227)) ([daf2731](https://github.com/linrongbin16/fzfx.nvim/commit/daf2731ea832efd25771a05e9870440189dfca7e))
* stridx ([#132](https://github.com/linrongbin16/fzfx.nvim/issues/132)) ([1cfe8c9](https://github.com/linrongbin16/fzfx.nvim/commit/1cfe8c9a29fe938fadc599e4249322fa9d2e7efa))
* trim ([0b45d2e](https://github.com/linrongbin16/fzfx.nvim/commit/0b45d2ed5c4c9f809fc2abedc73be26c55e16d81))
* trim query & rewrite popup and launch ([#29](https://github.com/linrongbin16/fzfx.nvim/issues/29)) ([107b07f](https://github.com/linrongbin16/fzfx.nvim/commit/107b07f9021320be7f7b6bdca919910b99b66799))
* visual select ([11e9119](https://github.com/linrongbin16/fzfx.nvim/commit/11e91199ca82482dd418e47776dbe77098dfeb8c))
* visual select ([3a5dd76](https://github.com/linrongbin16/fzfx.nvim/commit/3a5dd769333d69c10eef090b8e83018d16b06865))
* windows git log pretty ([#77](https://github.com/linrongbin16/fzfx.nvim/issues/77)) ([d2ed804](https://github.com/linrongbin16/fzfx.nvim/commit/d2ed804bb58e6fd3ec4c9d6d2cce98fb4ac019f2))
* windows named pipe ([#50](https://github.com/linrongbin16/fzfx.nvim/issues/50)) ([099e59e](https://github.com/linrongbin16/fzfx.nvim/commit/099e59e17460580acb162d70780624ac8b786bcc))


### Performance Improvements

* async file io with fs_read ([#135](https://github.com/linrongbin16/fzfx.nvim/issues/135)) ([aabf6c8](https://github.com/linrongbin16/fzfx.nvim/commit/aabf6c88eccf1d0964eb29c5c1c6eb3ee4c3290c))
* async io ([#133](https://github.com/linrongbin16/fzfx.nvim/issues/133)) ([d66d7b3](https://github.com/linrongbin16/fzfx.nvim/commit/d66d7b3636951d328dc51eac1be24b1a3552487a))
* backup ([3e7a199](https://github.com/linrongbin16/fzfx.nvim/commit/3e7a199f0f37b3ebc5906d66420e373a2ce9c2f5))
* bind toggle ([#71](https://github.com/linrongbin16/fzfx.nvim/issues/71)) ([0da7adf](https://github.com/linrongbin16/fzfx.nvim/commit/0da7adf6c343cde4f19ed2a30de0d596f8841120))
* command_list previewer ([#182](https://github.com/linrongbin16/fzfx.nvim/issues/182)) ([78ae874](https://github.com/linrongbin16/fzfx.nvim/commit/78ae874c51a6405e894160cd500b4ac5d2511d14))
* comments ([#28](https://github.com/linrongbin16/fzfx.nvim/issues/28)) ([13f05c6](https://github.com/linrongbin16/fzfx.nvim/commit/13f05c6cac52c9f55a5085633aaef3af22dd2065))
* detect batcat, fdfind first ([#13](https://github.com/linrongbin16/fzfx.nvim/issues/13)) ([ec2a807](https://github.com/linrongbin16/fzfx.nvim/commit/ec2a807a352b4d52e5fcd2cdb7b1f892110435c5))
* don't normalize path for Windows ([#44](https://github.com/linrongbin16/fzfx.nvim/issues/44)) ([9261d4a](https://github.com/linrongbin16/fzfx.nvim/commit/9261d4ab3bf01c71994b9880a242811df1983e4d))
* dynamic passing ([#84](https://github.com/linrongbin16/fzfx.nvim/issues/84)) ([711e7c9](https://github.com/linrongbin16/fzfx.nvim/commit/711e7c9f3dc1a48f66e0d02a8db90dc27b6955ce))
* file explorer & test ([#215](https://github.com/linrongbin16/fzfx.nvim/issues/215)) ([0468619](https://github.com/linrongbin16/fzfx.nvim/commit/046861978a47cd966f6bc918667fb811d1c90990))
* fzf default command ([#11](https://github.com/linrongbin16/fzfx.nvim/issues/11)) ([502df8e](https://github.com/linrongbin16/fzfx.nvim/commit/502df8eb125af580541da8fed701a6e8e95a5fa2))
* ggrep,gfind ([#94](https://github.com/linrongbin16/fzfx.nvim/issues/94)) ([dd510f8](https://github.com/linrongbin16/fzfx.nvim/commit/dd510f89d630ee1ba872a6711b8484ba13d41e27))
* git branches ([#75](https://github.com/linrongbin16/fzfx.nvim/issues/75)) ([667a94b](https://github.com/linrongbin16/fzfx.nvim/commit/667a94b38426632bb8ec8ca8cb1f587a8e4222c5))
* log ([#109](https://github.com/linrongbin16/fzfx.nvim/issues/109)) ([b6a7857](https://github.com/linrongbin16/fzfx.nvim/commit/b6a7857d88aa50b61a1324f9326006b608e8c9b5))
* lsp definitions ([#154](https://github.com/linrongbin16/fzfx.nvim/issues/154)) ([3418aef](https://github.com/linrongbin16/fzfx.nvim/commit/3418aefad1bff78494e67ac54f3644cf1269b1d8))
* migrate buffers ([#113](https://github.com/linrongbin16/fzfx.nvim/issues/113)) ([4da588b](https://github.com/linrongbin16/fzfx.nvim/commit/4da588bb0a759232698117c1be69ebf2f7f84232))
* move nvim,fzf executable check before open win ([#25](https://github.com/linrongbin16/fzfx.nvim/issues/25)) ([da6c446](https://github.com/linrongbin16/fzfx.nvim/commit/da6c446bf3eebfbb5d619833ed3c419a60daa5dd))
* path separator ([#51](https://github.com/linrongbin16/fzfx.nvim/issues/51)) ([3f783fd](https://github.com/linrongbin16/fzfx.nvim/commit/3f783fdccf8b974bed07e2e20520a53c27c98703))
* preview up/down keys ([#73](https://github.com/linrongbin16/fzfx.nvim/issues/73)) ([b9d115a](https://github.com/linrongbin16/fzfx.nvim/commit/b9d115aafb652b39c409e237a85b2c6469827c07))
* provider command ([c92b150](https://github.com/linrongbin16/fzfx.nvim/commit/c92b1509be7fcebdfdc19c1732b8fa20ef4505b0))
* provider switch ([#96](https://github.com/linrongbin16/fzfx.nvim/issues/96)) ([c36e378](https://github.com/linrongbin16/fzfx.nvim/commit/c36e378f8f95a099f16dcdca52cb5f1acf0812dd))
* reduce CommandConfig ([#251](https://github.com/linrongbin16/fzfx.nvim/issues/251)) ([ac78df6](https://github.com/linrongbin16/fzfx.nvim/commit/ac78df62c0e8d5fa1d2c2a11492827b2ca3f1b7d))
* reduce ESC keys & better multi keys ([#61](https://github.com/linrongbin16/fzfx.nvim/issues/61)) ([e159895](https://github.com/linrongbin16/fzfx.nvim/commit/e159895e4eab5c39d7f6e391f3b048fce85a8136))
* remove fzf/rg mode ([5bff616](https://github.com/linrongbin16/fzfx.nvim/commit/5bff6163c778ae308503bf5bdc64cd0c58d86068))
* remove internal env var ([e3b2e49](https://github.com/linrongbin16/fzfx.nvim/commit/e3b2e49cf9f7c8765cf55a01df2633188079881b))
* remove unused import ([33703c9](https://github.com/linrongbin16/fzfx.nvim/commit/33703c965c2a544ce8adb138650b0e1cafcd31de))
* setup legacy ([ebbed25](https://github.com/linrongbin16/fzfx.nvim/commit/ebbed25cddcae73383c0239407bf9c90371916c7))
* shellslash ([#91](https://github.com/linrongbin16/fzfx.nvim/issues/91)) ([2663cd4](https://github.com/linrongbin16/fzfx.nvim/commit/2663cd4d4ec4778dc55b2271838b2ec7454a1c3a))
* socket server ([#39](https://github.com/linrongbin16/fzfx.nvim/issues/39)) ([5613c56](https://github.com/linrongbin16/fzfx.nvim/commit/5613c5662870f27fe7ef45b9a955f0402dd3dff8))
* use 'buffer' instead 'edit' for buffers ([#67](https://github.com/linrongbin16/fzfx.nvim/issues/67)) ([4e74d79](https://github.com/linrongbin16/fzfx.nvim/commit/4e74d79108155a864723e131d2f9d9ff2f5cb9b0))
* use uv spawn ([#181](https://github.com/linrongbin16/fzfx.nvim/issues/181)) ([7fe84c6](https://github.com/linrongbin16/fzfx.nvim/commit/7fe84c606ed5847108035f3dded7745ad61f1450))
* uv.spawn ([#128](https://github.com/linrongbin16/fzfx.nvim/issues/128)) ([5d54505](https://github.com/linrongbin16/fzfx.nvim/commit/5d54505d9f06fe1fada283024ce38d7213f3761e))
* win_opts row/col ([#23](https://github.com/linrongbin16/fzfx.nvim/issues/23)) ([f035673](https://github.com/linrongbin16/fzfx.nvim/commit/f0356732db5801b424234223d4f306a25db0d35c))


### Reverts

* lower minimal required version v0.6 ([#245](https://github.com/linrongbin16/fzfx.nvim/issues/245)) ([89eb334](https://github.com/linrongbin16/fzfx.nvim/commit/89eb334df7920a75386b659cd007a3ec5ea6fe13))


### Break Changes

* 2023-08-17
  * Break: re-bind keys 'ctrl-e', 'ctrl-a' to 'toggle', 'toggle-all', remove 'ctrl-d'(deselect), 'alt-a'(deselect-all).
  * Break: re-bind key 'ctrl-l' (toggle-preview) to 'alt-p'.
* 2023-08-19
  * Break: refactor configs schema for general fzf-based searching commands.
* 2023-08-28
  * Deprecate: migrate 'git_commits' (`FzfxGCommits`) configs to new schema.
* 2023-08-30
  * Deprecate: migrate 'buffers' (`FzfxBuffers`) configs to new schema.
* 2023-09-11
  * Deprecate: migrate 'git_branches' (`FzfxGBranches`) configs to new schema.
* 2023-09-12
  * Deprecate: migrate 'git_files' (`FzfxGFiles`) configs to new schema.
* 2023-09-19
  * Deprecate: migrate 'live_grep' (`FzfxLiveGrep`) configs to new schema.
  * Deprecate: migrate 'files' (`FzfxFiles`) configs new schema.
* 2023-09-26
  * Break: drop support for Neovim v0.5.0, require minimal version &ge; v0.6.0.
* 2023-09-27
  * Minor break: move 'context_maker' option from 'providers' to 'other_opts' (in group config).
  * Minor break: drop support for 'line_type'/'line_delimiter'/'line_pos' option (in provider config).
* 2023-10-07
  * Deprecate: migrate 'GroupConfig' class to lua table.
* 2023-10-08
  - Deprecate: migrate 'InteractionConfig' class to lua table.
